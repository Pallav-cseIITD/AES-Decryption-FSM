library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_module is
    Port (
        clk_in : in STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR(127 downto 0);  -- 16 bytes input, ASCII encoded
        segments : out STD_LOGIC_VECTOR(6 downto 0);  -- Seven segments (A-G)
        anode_select : out STD_LOGIC_VECTOR(3 downto 0)  -- Digit select
    );
end top_module;
architecture Behavioral of top_module is
    component timing_circuit
        Port (
            clk_in : in STD_LOGIC;
            byte_select : out STD_LOGIC_VECTOR(1 downto 0);
            digit_select : out STD_LOGIC_VECTOR(1 downto 0);
            anodes : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component seven_segment
        Port (
            ascii_input : in STD_LOGIC_VECTOR(7 downto 0);
            A, B, C, D, E, F, G : out STD_LOGIC
        );
    end component;

    signal byte_sel : STD_LOGIC_VECTOR(1 downto 0);
    signal digit_sel : STD_LOGIC_VECTOR(1 downto 0);
    signal current_byte : STD_LOGIC_VECTOR(7 downto 0);

    signal data_in2 : STD_LOGIC_VECTOR(127 downto 0);

    -- Constant for initialization (ASCII "0123456789ABCDEF")
    constant INIT_DATA : STD_LOGIC_VECTOR(127 downto 0) := 
        x"30313233343536373839414243444546"; -- ASCII encoded

begin
    -- Initialization process to set data_in at the start
    init_data_tow: process
    begin
        data_in2 <= INIT_DATA; -- Assign initial value
        wait; -- Keeps this process from re-triggering
    end process init_data_tow;

    -- Timing circuit instance
    timing: timing_circuit port map (
        clk_in => clk_in,
        byte_select => byte_sel,
        digit_select => digit_sel,
        anodes => anode_select
    );

    -- Process to select the current byte based on byte_sel and digit_sel
    process(byte_sel, digit_sel, data_in2)
    begin
        case byte_sel is
            when "11" =>
                case digit_sel is
                    when "11" => current_byte <= data_in(7 downto 0);
                    when "10" => current_byte <= data_in(15 downto 8);
                    when "01" => current_byte <= data_in(23 downto 16);
                    when others => current_byte <= data_in(31 downto 24);
                end case;
            when "10" =>
                case digit_sel is
                    when "11" => current_byte <= data_in(39 downto 32);
                    when "10" => current_byte <= data_in(47 downto 40);
                    when "01" => current_byte <= data_in(55 downto 48);
                    when others => current_byte <= data_in(63 downto 56);
                end case;
            when "01" =>
                case digit_sel is
                    when "11" => current_byte <= data_in(71 downto 64);
                    when "10" => current_byte <= data_in(79 downto 72);
                    when "01" => current_byte <= data_in(87 downto 80);
                    when others => current_byte <= data_in(95 downto 88);
                end case;
            when others =>
                case digit_sel is
                    when "11" => current_byte <= data_in(103 downto 96);
                    when "10" => current_byte <= data_in(111 downto 104);
                    when "01" => current_byte <= data_in(119 downto 112);
                    when others => current_byte <= data_in(127 downto 120);
                end case;
        end case;
    end process;

    -- Seven segment decoder instance with current_byte
    display: seven_segment port map (
        ascii_input => current_byte,
        A => segments(6),
        B => segments(5),
        C => segments(4),
        D => segments(3),
        E => segments(2),
        F => segments(1),
        G => segments(0)
    );

end Behavioral;
