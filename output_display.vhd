library ieee;
use ieee.std_logic_1164.all;

entity output_display is
    port (
        sign_in         : in  std_logic;
        mantissa_in     : in  std_logic_vector(7 downto 0);
        exponent_in     : in  std_logic_vector(6 downto 0);
        overflow_in     : in  std_logic;
        
        mantissa_a      : in  std_logic_vector(7 downto 0);
        mantissa_b      : in  std_logic_vector(7 downto 0);
        
        LEDR            : out std_logic_vector(17 downto 0)
        
    );
end entity output_display;

architecture structural of output_display is  
begin

    LEDR(15)          <= sign_in;
    LEDR(14 downto 8) <= exponent_in;
    LEDR(7 downto 0)  <= mantissa_in;
    LEDR(16)          <= overflow_in;
    LEDR(17)          <= '0';

end architecture structural;
