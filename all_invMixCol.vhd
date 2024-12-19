library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity all_invMixCol is
    Port (
        input_matrix    : in  STD_LOGIC_VECTOR(127 downto 0);  -- 128-bit input matrix (4 rows, 32 bits each)
        select_mult     : in  STD_LOGIC_VECTOR(127 downto 0);  -- 128-bit select multiplication vector (4 rows, 32 bits each)
        result_matrix   : out STD_LOGIC_VECTOR(127 downto 0)    -- 128-bit output matrix
    );
end all_invMixCol;

architecture Behavioral of all_invMixCol is

    component invMixCol is
        Port (
            input_row      : in  STD_LOGIC_VECTOR(31 downto 0); 
            select_mult    : in  STD_LOGIC_VECTOR(31 downto 0);  
            result_output  : out STD_LOGIC_VECTOR(7 downto 0)    
        );
    end component;

    signal input_row    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal select_row  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal result : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal result_matrix_int : STD_LOGIC_VECTOR(127 downto 0);

begin

    gen_assignments: for i in 0 to 3 generate
        input_row(32*i + 31 downto 32*i) <= input_matrix(127- 32*i downto 96- 32*i);   -- input_matrix[i]
        select_row(32*i + 31 downto 32*i) <= select_mult(127- 32*i downto 96- 32*i);    -- select_mult[i]
    end generate;
    gen_invMixCol: for i in 0 to 15 generate
        invMixCol_inst : invMixCol
            port map (
                input_row    => input_matrix(8*i + 7 downto 8*i),
                select_mult  => select_mult(8*i + 7 downto 8*i),
                result_output => result_matrix_int(8*i + 7 downto 8*i)
            );
    end generate;
    result_matrix <= result_matrix_int;

end Behavioral;
