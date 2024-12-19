library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.aes_fsm_pkg.all;

entity AES_FSM is
    Port ( 
        clk           : in  STD_LOGIC;
        reset         : in  STD_LOGIC;
        start         : in  STD_LOGIC;
        done          : out STD_LOGIC;
        display_data  : out STD_LOGIC_VECTOR(31 downto 0);
        display_valid : out STD_LOGIC;
        current_state_debug : out state_type;
        temp_reg_debug : out STD_LOGIC_VECTOR(31 downto 0);
        data_reg_debug : out STD_LOGIC_VECTOR(31 downto 0);
        key_reg_debug : out STD_LOGIC_VECTOR(31 downto 0);
        round_count_debug : out Integer range 0 to 9
        
    );
end AES_FSM;

architecture Behavioral of AES_FSM is
    -- Memory interface components
    component input_rom
    port (
        clka  : in  STD_LOGIC;
        ena : in std_logic;
        addra : in  STD_LOGIC_VECTOR(3 downto 0);
        douta : out STD_LOGIC_VECTOR(7 downto 0)
    );
    end component;
    
    component roundkey_rom
    port (
        clka  : in  STD_LOGIC;
        ena : in std_logic;
        addra : in  STD_LOGIC_VECTOR(7 downto 0);
        douta : out STD_LOGIC_VECTOR(7 downto 0)
    );
    end component;
    
    -- Internal signals and registers
    signal current_state : state_type;
    signal next_state    : state_type;
    
    -- Memory control signals
    signal input_addr    : STD_LOGIC_VECTOR(3 downto 0);
    signal input_data    : STD_LOGIC_VECTOR(7 downto 0);
    signal key_addr      : STD_LOGIC_VECTOR(7 downto 0);
    signal key_data      : STD_LOGIC_VECTOR(7 downto 0);
    signal round_base_addr : unsigned(7 downto 0);
    
    -- 32-bit working registers
    signal data_reg      : STD_LOGIC_VECTOR(31 downto 0);
    signal key_reg       : STD_LOGIC_VECTOR(31 downto 0);
    signal temp_reg      : STD_LOGIC_VECTOR(31 downto 0);
    signal display_reg   : STD_LOGIC_VECTOR(31 downto 0);
    
    -- State matrix storage
    type matrix_array is array (0 to 3, 0 to 3) of STD_LOGIC_VECTOR(7 downto 0);
    signal state_matrix : matrix_array;
    signal key_matrix : matrix_array;
    
    -- Counters and control signals
    signal round_count : integer range 0 to 9;
    signal word_count  : integer range 0 to 3;
    signal prev_word_count  : integer range 0 to 3;
    signal prev_row_count  : integer range 0 to 3;
    signal byte_count  : integer range 0 to 3;
    signal row_count   : integer range 0 to 3;
    
    -- Components from previous implementation
    component complete_mix_columns is
        Port (
            input_column  : in  STD_LOGIC_VECTOR(31 downto 0);
            output_column : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component invShiftRow is
        port(
            inputRow  : in  STD_LOGIC_VECTOR(31 downto 0);
            shiftBy   : in  STD_LOGIC_VECTOR(1 downto 0);
            outputRow : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component all_InvSBox is
        PORT(
            clka   : IN  STD_LOGIC;
            ena    : IN  STD_LOGIC;              
            input  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); 
            douta  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
        );
    end component;
    
    -- Internal signals for component connections
    signal sbox_output   : STD_LOGIC_VECTOR(31 downto 0);
    signal shift_input   : STD_LOGIC_VECTOR(31 downto 0);
    signal shift_output  : STD_LOGIC_VECTOR(31 downto 0);
    signal shift_amount  : STD_LOGIC_VECTOR(1 downto 0);
    signal mixcol_output : STD_LOGIC_VECTOR(31 downto 0);
    signal reverse_round_addr : unsigned(7 downto 0);
    
begin
    -- Debug state output
    current_state_debug <= current_state;
    temp_reg_debug <= temp_reg;
    data_reg_debug <= data_reg;
    key_reg_debug <= key_reg;
    round_count_debug <= round_count;
    
    -- Component instantiations
    input_rom_inst: input_rom
        port map (
            clka  => clk,
            ena => '1',
            addra => input_addr,
            douta => input_data
        );
        
    roundkey_rom_inst: roundkey_rom
        port map (
            clka  => clk,
            ena => '1',
            addra => key_addr,
            douta => key_data
        );
        
    inv_sbox: all_InvSBox
        port map (
            clka  => clk,
            ena   => '1',
            input => temp_reg,
            douta => sbox_output
        );
        
    inv_shift: invShiftRow
        port map (
            inputRow  => shift_input,
            shiftBy   => shift_amount,
            outputRow => shift_output
        );
        
    mix_cols: complete_mix_columns
        port map (
            input_column  => temp_reg,
            output_column => mixcol_output
        );

    -- Sequential process for state updates
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
            round_count <= 0;
            word_count <= 0;
            prev_word_count <= 0;
            prev_row_count <= 0;
            byte_count <= 0;
            row_count <= 0;
            input_addr <= (others => '0');
            key_addr <= (others => '0');
            round_base_addr <= (others => '0');
            data_reg <= (others => '0');
            key_reg <= (others => '0');
            temp_reg <= (others => '0');
            display_reg <= (others => '0');
            reverse_round_addr <= "10010000";
            for i in 0 to 3 loop
                for j in 0 to 3 loop
                    key_matrix(i, j) <= (others => '0');
                end loop;
            end loop;
            
        elsif rising_edge(clk) then
            current_state <= next_state;
            
            case current_state is
                when LOAD_INPUT =>
                    data_reg <= data_reg(23 downto 0) & input_data;
                    input_addr <= std_logic_vector(unsigned(input_addr) + 1);
                    if byte_count = 3 then
                        byte_count <= 0;
                        prev_word_count <= word_count;
                        word_count <= (word_count + 1) mod 4;
                    else
                        byte_count <= byte_count + 1;
                    end if;
                    
               when LOAD_KEY =>
                    key_reg <= key_reg(23 downto 0) & key_data;
                    
                    -- Calculate address using the formula:
                    -- 144 - (16 * round_count) + (4 * word_count + byte_count)
                    key_addr <= std_logic_vector(to_unsigned(144 - (16 * round_count) + 
                               (4 * word_count + byte_count + 1), 8));  -- Added +1 for next cycle
                    
                    if byte_count = 3 then
                        -- Store completed word in key_matrix
                        key_matrix(0, word_count) <= key_reg(31 downto 24);
                        key_matrix(1, word_count) <= key_reg(23 downto 16);
                        key_matrix(2, word_count) <= key_reg(15 downto 8);
                        key_matrix(3, word_count) <= key_reg(7 downto 0);
                        
                        byte_count <= 0;
                        prev_word_count <= word_count;
                        
                        if word_count = 3 then
                            -- Only increment round_count after completing full word
                            word_count <= 0;
                            if round_count < 9 then  -- Changed from 10 to 9
                                round_count <= round_count + 1;
                            end if;
                        else
                            word_count <= word_count + 1;
                        end if;
                    else
                        byte_count <= byte_count + 1;
                    end if;
                    
                when XOR_STATE =>
                    -- XOR state matrix with key matrix (both in column-major format)
                    for col in 0 to 3 loop
                        for row in 0 to 3 loop
                            state_matrix(row, col) <= state_matrix(row, col) xor key_matrix(row, col);
                        end loop;
                    end loop;

                    
                when SUBBYTES_STATE =>
                    temp_reg <= sbox_output;
                    prev_word_count <= word_count;
                    word_count <= (word_count + 1) mod 4;
                    
                when SHIFTROWS_LOAD =>
                    for i in 0 to 3 loop
                        state_matrix(i, word_count) <= temp_reg(31-8*i downto 24-8*i);
                    end loop;
                    prev_word_count <= word_count;
                    if word_count = 3 then
                        word_count <= 0;
                    else
                        word_count <= (word_count + 1) mod 4;
                    end if;
                    
                when SHIFTROWS_PROCESS =>
                    shift_input <= state_matrix(row_count, 0) & 
                                 state_matrix(row_count, 1) & 
                                 state_matrix(row_count, 2) & 
                                 state_matrix(row_count, 3);
                    prev_row_count <= row_count;          
                    if row_count = 3 then
                        row_count <= 0;
                    else
                        row_count <= (row_count + 1) mod 4;
                    end if;
                    
                when SHIFTROWS_STORE =>
                    for i in 0 to 3 loop
                        state_matrix(row_count, i) <= shift_output(31-8*i downto 24-8*i);
                    end loop;
                    prev_row_count <= row_count;
                    if row_count = 3 then
                        row_count <= 0;
                    else
                        row_count <= (row_count + 1) mod 4;
                    end if;
                    
                when MIXCOLS_STATE =>
                    temp_reg <= mixcol_output;
                    prev_word_count <= word_count;
                    if word_count < 3 then
                        word_count <= (word_count + 1) mod 4;
                    else
                        word_count <= 0;
                    end if;
                    
                when WRITE_RESULT =>
                    temp_reg <= state_matrix(0, word_count) & 
                               state_matrix(1, word_count) & 
                               state_matrix(2, word_count) & 
                               state_matrix(3, word_count);
                    prev_word_count <= word_count;
                    if word_count = 3 then
                        word_count <= 0;
                        if round_count = 9 then
                            temp_reg <= data_reg;
                        else
                            round_count <= round_count + 1;
                            round_base_addr <= round_base_addr + 16;
                        end if;
                    else
                        word_count <= (word_count + 1) mod 4;
                    end if;
                    
                when DISPLAY_STATE =>
                    display_reg <= temp_reg;
                
                when others =>
                    null;
            end case;
        end if;
    end process;
    
    -- ShiftRows control logic
    shift_amount <= std_logic_vector(to_unsigned(row_count, 2));
    
    -- Display output assignment
    display_data <= display_reg;
    
    -- Next state logic process
    process(current_state, start, round_count, word_count, prev_word_count, byte_count, row_count, prev_row_count)
    begin
        next_state <= current_state;
        done <= '0';
        display_valid <= '0';
        
        case current_state is
            when IDLE =>
                if start = '1' then
                    next_state <= LOAD_INPUT;
                end if;
                
            when LOAD_INPUT =>
                if word_count = 0 and prev_word_count = 3 and byte_count = 1 then
                    next_state <= LOAD_KEY;
                end if;
                
             when LOAD_KEY =>
                if word_count = 0 and prev_word_count = 3 and byte_count = 1 then  -- Completed loading current round key
                    next_state <= XOR_STATE;
                end if;

                
            when XOR_STATE =>
                if round_count = 0 then
                    next_state <= SHIFTROWS_LOAD;
                elsif round_count = 9 then
                    next_state <= DISPLAY_STATE;
                else 
                    next_state <= MIXCOLS_STATE;
                end if;
                              
            when SUBBYTES_STATE =>
                if word_count = 0 and prev_word_count = 3 then
                    next_state <= WRITE_RESULT;
                end if;
                
            when SHIFTROWS_LOAD =>
                if word_count = 0 and prev_word_count = 3 then
                    next_state <= SHIFTROWS_PROCESS;
                end if;
                
            when SHIFTROWS_PROCESS =>
                if row_count = 0 and prev_row_count = 3 then
                    next_state <= SHIFTROWS_STORE;
                end if;
                
            when SHIFTROWS_STORE =>
                if row_count = 0 and prev_row_count = 3 then
                    next_state <= SUBBYTES_STATE;
                end if;
            
            when MIXCOLS_STATE =>
                if word_count = 0 and prev_word_count = 3 then
                    next_state <= SHIFTROWS_LOAD;
                end if;
                
            when WRITE_RESULT =>
                if word_count = 0 and prev_word_count = 3 then
                    next_state <= LOAD_KEY;
                end if;
                
            when DISPLAY_STATE =>
                display_valid <= '1';
                next_state <= DONE_STATE;
                
            when DONE_STATE =>
                done <= '1';
                if start = '0' then
                    next_state <= IDLE;
                end if;
        end case;
    end process;
end Behavioral;