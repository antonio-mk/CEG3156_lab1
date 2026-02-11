library ieee;
use ieee.std_logic_1164.all;

entity result_selector is
    port (
        sel          : in  std_logic;
        
        add_sign     : in  std_logic;
        add_mantissa : in  std_logic_vector(7 downto 0);
        add_exponent : in  std_logic_vector(6 downto 0);
        add_overflow : in  std_logic;
        
        mul_sign     : in  std_logic;
        mul_mantissa : in  std_logic_vector(7 downto 0);
        mul_exponent : in  std_logic_vector(6 downto 0);
        mul_overflow : in  std_logic;
        
        out_sign     : out std_logic;
        out_mantissa : out std_logic_vector(7 downto 0);
        out_exponent : out std_logic_vector(6 downto 0);
        out_overflow : out std_logic
    );
end entity result_selector;

architecture structural of result_selector is
    component mux_2to1_1bit is
        port (
            data_in_0 : in  std_logic;
            data_in_1 : in  std_logic;
            sel_line  : in  std_logic;
            data_out  : out std_logic
        );
    end component;
    
    component mux_2to1_8bit is
        port (
            data_in_0 : in  std_logic_vector(7 downto 0);
            data_in_1 : in  std_logic_vector(7 downto 0);
            sel_line  : in  std_logic;
            data_out  : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component mux_2to1_7bit is
        port (
            data_in_0 : in  std_logic_vector(6 downto 0);
            data_in_1 : in  std_logic_vector(6 downto 0);
            sel_line  : in  std_logic;
            data_out  : out std_logic_vector(6 downto 0)
        );
    end component;
    
begin
    mux_sign: mux_2to1_1bit
        port map (
            data_in_0 => add_sign,
            data_in_1 => mul_sign,
            sel_line  => sel,
            data_out  => out_sign
        );
    
    mux_mantissa: mux_2to1_8bit
        port map (
            data_in_0 => add_mantissa,
            data_in_1 => mul_mantissa,
            sel_line  => sel,
            data_out  => out_mantissa
        );
    
    mux_exponent: mux_2to1_7bit
        port map (
            data_in_0 => add_exponent,
            data_in_1 => mul_exponent,
            sel_line  => sel,
            data_out  => out_exponent
        );
    
    mux_overflow: mux_2to1_1bit
        port map (
            data_in_0 => add_overflow,
            data_in_1 => mul_overflow,
            sel_line  => sel,
            data_out  => out_overflow
        );
    
end architecture structural;
