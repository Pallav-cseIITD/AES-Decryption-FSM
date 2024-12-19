library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timing_circuit is
    Port (
        clk_in : in STD_LOGIC;  -- 100 MHz input clock
        byte_select : out STD_LOGIC_VECTOR(1 downto 0);  -- Select which group of 4 bytes
        digit_select : out STD_LOGIC_VECTOR(1 downto 0);  -- Select which digit within group
        anodes : out STD_LOGIC_VECTOR(3 downto 0)  -- Anodes signal for display
    );
end timing_circuit;

architecture Behavioral of timing_circuit is
constant DISPLAY_REFRESH : integer := 100000;    -- Set for ~1 ms refresh rate
constant GROUP_CHANGE : integer := 100000000 - 1;  -- 1 second for group change

signal refresh_counter : integer := 0;
signal group_counter : integer := 0;
signal current_digit : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal current_group : STD_LOGIC_VECTOR(1 downto 0) := "00";

begin
process(clk_in)
begin
    if rising_edge(clk_in) then
        -- Display refresh counter
        if refresh_counter >= DISPLAY_REFRESH then
            refresh_counter <= 0;
            current_digit <= std_logic_vector(unsigned(current_digit) + 1);
        else
            refresh_counter <= refresh_counter + 1;
        end if;
        
        -- Group change counter (1 second)
        if group_counter >= GROUP_CHANGE then
            group_counter <= 0;
            current_group <= std_logic_vector(unsigned(current_group) + 1);
        else
            group_counter <= group_counter + 1;
        end if;
    end if;
end process;

-- Output assignments
byte_select <= current_group;
digit_select <= current_digit;

-- Anode selection based on current digit
process(current_digit)
begin
    case current_digit is
        when "00" => anodes <= "1110";
        when "01" => anodes <= "1101";
        when "10" => anodes <= "1011";
        when others => anodes <= "0111";
    end case;
end process;

end Behavioral;
