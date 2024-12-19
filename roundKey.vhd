library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity roundKey is
    port(
            cipher : in std_logic_vector(7 downto 0);
            roundkey : in std_logic_vector(7 downto 0);
            plain : out std_logic_vector(7 downto 0)
        );
end roundKey;

architecture Behavioral of roundKey is

begin
    plain <= cipher xor roundkey;
end Behavioral;
