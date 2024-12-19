library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity invShiftRow is
    port(
        inputRow : in std_logic_vector(31 downto 0);
        shiftBy : in std_logic_vector(1 downto 0);
        outputRow : out std_logic_vector(31 downto 0)
    );
end invShiftRow;

architecture Behavioral of invShiftRow is
begin
    process(inputRow, shiftBy)
    begin
        if shiftBy = "00" then
            outputRow <= inputRow;
        elsif shiftBy = "01" then
            outputRow(31 downto 24) <= inputRow(7 downto 0);
            outputRow(23 downto 0) <= inputRow(31 downto 8);
        elsif shiftBy = "10" then
            outputRow(31 downto 16) <= inputRow(15 downto 0);
            outputRow(15 downto 0) <= inputRow(31 downto 16);
        else 
            outputRow(31 downto 8) <= inputRow(23 downto 0);
            outputRow(7 downto 0) <= inputRow(31 downto 24);
        end if;
    end process;
end Behavioral;