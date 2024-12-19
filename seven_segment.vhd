library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  
entity seven_segment is
    Port (
        ascii_input  : in  STD_LOGIC_VECTOR(7 downto 0);  
        A, B, C, D, E, F, G : out STD_LOGIC  
    );
end seven_segment;

architecture Behavioral of seven_segment is
    signal intermediate : STD_LOGIC_VECTOR(3 downto 0) := "0000";  
    signal S1, S2, S3, S4 : STD_LOGIC;
    signal NS1, NS2, NS3, NS4 : STD_LOGIC;
    signal valid_input : STD_LOGIC := '0';
begin
    S1 <= intermediate(3);
    S2 <= intermediate(2);
    S3 <= intermediate(1);
    S4 <= intermediate(0);
    
    NS1 <= NOT S1;
    NS2 <= NOT S2;
    NS3 <= NOT S3;
    NS4 <= NOT S4;

    process(ascii_input)
        variable converted_input : integer;
    begin
        valid_input <= '1';  

        converted_input := to_integer(unsigned(ascii_input));  
        if converted_input >= 48 and converted_input <= 57 then
            intermediate <= std_logic_vector(to_unsigned(converted_input - 48, 4));
            
        elsif converted_input >= 65 and converted_input <= 70 then
            intermediate <= std_logic_vector(to_unsigned(converted_input - 55, 4));
            
        elsif converted_input >= 97 and converted_input <= 102 then
            intermediate <= std_logic_vector(to_unsigned(converted_input - 87, 4));
            
        else
            intermediate <= "0000"; 
            valid_input <= '0';      
        end if;
        
        -- Report the intermediate value to the console
        -- Report the intermediate value to the console
        report "Intermediate value: " & integer'image(to_integer(unsigned(intermediate)));
    end process;
    
    process(valid_input, S1, S2, S3, S4, NS1, NS2, NS3, NS4)
    begin
        if valid_input = '0' then
            A <= '1';
            B <= '1';
            C <= '1';
            D <= '1';
            E <= '1';
            F <= '1';
            G <= '0';
        else
            A <= (NS1 AND NS2 AND NS3 AND S4) OR (NS1 AND S2 AND NS3 AND NS4) OR (S1 AND S2 AND NS3 AND S4) OR (S1 AND NS2 AND S3 AND S4);
            B <= (NS1 AND S2 AND NS3 AND S4) OR (S1 AND S2 AND NS3 AND NS4) OR (S2 AND S3 AND NS4) OR (S1 AND S3 AND S4);
            C <= (NS1 AND NS2 AND S3 AND NS4) OR ( S1 AND S2 AND NS3 AND NS4) OR (S1 AND S2 AND S3);
            D <= (NS1 AND NS2 AND NS3 AND S4) OR (NS1 AND S2 AND NS3 AND NS4) OR (S2 AND S3 AND S4) OR (S1 AND NS2 AND S3 AND NS4);
            E <= (NS1 AND S4) OR (NS1 AND S2 AND NS3) OR (NS2 AND NS3 AND S4);
            F <= (NS1 AND NS2 AND S3) OR (NS1 AND NS2 AND S4) OR (NS1 AND S3 AND S4) OR (S1 AND S2 AND NS3 AND S4);
            G <= (NS1 AND NS2 AND NS3 ) OR (NS1 AND S2 AND S3 AND S4) OR ( S1 AND S2 AND NS3 AND NS4);
        end if;
    end process;
end Behavioral;
