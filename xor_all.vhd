----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/30/2024 04:14:27 PM
-- Design Name: 
-- Module Name: xor_all - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity xor_all is
  Port ( 
    input : in std_logic_vector(31 downto 0);
    round_key : in std_logic_vector(31 downto 0);
    output : out std_logic_vector(31 downto 0)
  );
end xor_all;

architecture Behavioral of xor_all is

    component roundKey is
        port(
            cipher : in std_logic_vector(7 downto 0);
            roundkey : in std_logic_vector(7 downto 0);
            plain : out std_logic_vector(7 downto 0)
        );
    end component;

    signal temp_output : std_logic_vector(31 downto 0);

begin

    gen_roundkey : for i in 0 to 3 generate
        roundKey_inst : roundKey
            port map(
                cipher => input(8*i + 7 downto 8*i),        -- 8-bit slice from input
                roundkey => round_key(8*i+7 downto 8*i),    -- 8-bit slice from round_key
                plain => temp_output(8*i+7 downto 8*i)      -- 8-bit slice for output
            );
    end generate;
    output <= temp_output;

end Behavioral;
