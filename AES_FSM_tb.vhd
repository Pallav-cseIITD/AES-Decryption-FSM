library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.aes_fsm_pkg.all;

entity AES_FSM_tb is
end AES_FSM_tb;

architecture Behavioral of AES_FSM_tb is
    -- Component Declaration
    component AES_FSM
        Port ( 
            clk           : in  STD_LOGIC;
            reset         : in  STD_LOGIC;
            start         : in  STD_LOGIC;
            done          : out STD_LOGIC;
            display_data  : out STD_LOGIC_VECTOR(31 downto 0);
            display_valid : out STD_LOGIC;
            current_state_debug : out state_type;
            temp_reg_debug : out std_logic_vector(31 downto 0);
            data_reg_debug : out STD_LOGIC_VECTOR(31 downto 0);
            key_reg_debug : out STD_LOGIC_VECTOR(31 downto 0);
            round_count_debug : out Integer range 0 to 9
        );
    end component;

    -- Signal Declarations
    signal clk_tb           : STD_LOGIC := '0';
    signal reset_tb         : STD_LOGIC := '0';
    signal start_tb         : STD_LOGIC := '0';
    signal done_tb          : STD_LOGIC;
    signal display_data_tb  : STD_LOGIC_VECTOR(31 downto 0);
    signal display_valid_tb : STD_LOGIC;
    signal debug_state_tb   : state_type;  -- Renamed to avoid confusion
    signal temp_reg_debug_tb : std_logic_vector(31 downto 0);
    SIGNAL data_reg_debug_tb : STD_LOGIC_VECTOR(31 downto 0);
    SIGNAL key_reg_debug_tb :  STD_LOGIC_VECTOR(31 downto 0);
    SIGNAL round_count_debug_tb : Integer range 0 to 9;
    
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: AES_FSM 
        port map (
            clk => clk_tb,
            reset => reset_tb,
            start => start_tb,
            done => done_tb,
            display_data => display_data_tb,
            display_valid => display_valid_tb,
            current_state_debug => debug_state_tb, 
            temp_reg_debug => temp_reg_debug_tb, -- Connect to renamed signal
            data_reg_debug => data_reg_debug_tb,
            key_reg_debug => key_reg_debug_tb,
            round_count_debug => round_count_debug_tb
            
        );

    -- Clock Generation Process
    clk_process: process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD/2;
        clk_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin
        -- Initial reset
        reset_tb <= '1';
        wait for 100 ns;
        
        -- Release reset
        reset_tb <= '0';
        wait for CLK_PERIOD*2;
        
        -- Start the encryption
        wait until rising_edge(clk_tb);
        start_tb <= '1';
        wait for CLK_PERIOD;
        start_tb <= '0';
        
        -- Wait for completion
        wait until done_tb = '1';
        wait for CLK_PERIOD*10;
        
        -- End simulation
        wait;
    end process;

end Behavioral;