library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity invSBox is
   PORT(
        clka   : IN  STD_LOGIC;
        ena    : IN  STD_LOGIC;              
        input  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0); 
        douta  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) 
    );
end invSBox;

architecture Behavioral of invSBox is
    signal dig1, dig2         : std_logic_vector(3 downto 0);
    signal intermediate_add   : std_logic_vector(7 downto 0);

    component rom_invSbox
        Port (
            clka  : in  std_logic;
            ena   : in  std_logic; 
            addra : in  std_logic_vector(7 downto 0);
            douta : out std_logic_vector(7 downto 0)
        );
    end component;

begin
    address_finding: process(input)
    begin
        dig1 <= input(7 downto 4);
        dig2 <= input(3 downto 0);
        intermediate_add <= dig2 & dig1;  
    end process;

    rom_inst : rom_invSbox
        port map (
            clka  => clka,
            ena   => ena,
            addra => intermediate_add,
            douta => douta
        );

end Behavioral;
