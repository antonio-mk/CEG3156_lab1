library ieee;
use ieee.std_logic_1164.all;

entity test_data_source is
    port (
        SignA        : out std_logic;
        MantissaA    : out std_logic_vector(7 downto 0);
        ExponentA    : out std_logic_vector(6 downto 0);
        
        SignB        : out std_logic;
        MantissaB    : out std_logic_vector(7 downto 0);
        ExponentB    : out std_logic_vector(6 downto 0)
    );
end entity test_data_source;

architecture dataflow of test_data_source is
begin
    SignA     <= '0';
    ExponentA <= "0111111";
    MantissaA <= "01000000";
    
    SignB     <= '1';
    ExponentB <= "1000000";
    MantissaB <= "01000000";
    
end architecture dataflow;
