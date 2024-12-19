library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_module_tb is
end top_module_tb;

architecture Behavioral of top_module_tb is
    -- Component Declaration
    component top_module
        Port (
            clk_in : in STD_LOGIC;
            data_in : in STD_LOGIC_VECTOR(127 downto 0);
            segments : out STD_LOGIC_VECTOR(6 downto 0);
            anode_select : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;
    
    -- Signal Declaration
    signal clk : STD_LOGIC := '0';
    signal data : STD_LOGIC_VECTOR(127 downto 0);
    signal seg_out : STD_LOGIC_VECTOR(6 downto 0);
    signal anode : STD_LOGIC_VECTOR(3 downto 0);
    
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;  -- 100 MHz clock

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: top_module port map (
        clk_in => clk,
        data_in => data,
        segments => seg_out,
        anode_select => anode
    );
    
    -- Clock process
    clock_proc: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize with ASCII values for 0-9 and A-F
        data <= "0011000000110001001100100011001100110100001101010011011000110111001110000011100100001010000010110000110000001101000001110000011111";
        
        -- Let it run for enough time to see all digits
--        wait for 100 ms;
        
--        -- Test with some invalid ASCII characters
--        data <= x"30" & x"31" & x"20" & x"33" &  -- Space character
--                x"34" & x"2A" & x"36" & x"37" &  -- '*' character
--                x"38" & x"39" & x"5A" & x"42" &  -- 'Z' character
--                x"43" & x"44" & x"23" & x"46";   -- '#' character
                
        wait for 100 ms;
        
        -- End simulation
        wait;
    end process;

end Behavioral;
