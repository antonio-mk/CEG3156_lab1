library ieee;
use ieee.std_logic_1164.all;

entity multiplier_9bit is
    port (
        multiplicand : in  std_logic_vector(8 downto 0);
        multiplier   : in  std_logic_vector(8 downto 0);
        product      : out std_logic_vector(17 downto 0)
    );
end entity multiplier_9bit;

architecture structural of multiplier_9bit is
    component full_adder_1bit is
        port(
            A, B, Cin : in  std_logic;
            Cout, S   : out std_logic
        );
    end component;
    
    type partial_product_array is array (0 to 8) of std_logic_vector(8 downto 0);
    signal pp : partial_product_array;
    
    type sum_array is array (0 to 8) of std_logic_vector(8 downto 0);
    type carry_array is array (0 to 8) of std_logic_vector(9 downto 0);
    signal sum_sig : sum_array;
    signal carry_sig : carry_array;
    
begin
    gen_pp_row: for i in 0 to 8 generate
        gen_pp_col: for j in 0 to 8 generate
            pp(i)(j) <= multiplicand(j) and multiplier(i);
        end generate gen_pp_col;
    end generate gen_pp_row;
    
    product(0) <= pp(0)(0);
    sum_sig(0) <= pp(0);
    carry_sig(0) <= (others => '0');
    
    row1_bit0: full_adder_1bit
        port map (
            A => pp(0)(1), B => pp(1)(0), Cin => '0',
            S => sum_sig(1)(0), Cout => carry_sig(1)(1)
        );
    gen_row1: for j in 1 to 7 generate
        row1_fa: full_adder_1bit
            port map (
                A => pp(0)(j+1), B => pp(1)(j), Cin => carry_sig(1)(j),
                S => sum_sig(1)(j), Cout => carry_sig(1)(j+1)
            );
    end generate gen_row1;
    row1_last: full_adder_1bit
        port map (
            A => '0', B => pp(1)(8), Cin => carry_sig(1)(8),
            S => sum_sig(1)(8), Cout => carry_sig(1)(9)
        );
    product(1) <= sum_sig(1)(0);
    
    gen_rows: for row in 2 to 8 generate
        row_bit0: full_adder_1bit
            port map (
                A => sum_sig(row-1)(1), B => pp(row)(0), Cin => '0',
                S => sum_sig(row)(0), Cout => carry_sig(row)(1)
            );
        gen_mid: for j in 1 to 7 generate
            row_fa: full_adder_1bit
                port map (
                    A => sum_sig(row-1)(j+1), B => pp(row)(j), Cin => carry_sig(row)(j),
                    S => sum_sig(row)(j), Cout => carry_sig(row)(j+1)
                );
        end generate gen_mid;
        row_last: full_adder_1bit
            port map (
                A => carry_sig(row-1)(9), B => pp(row)(8), Cin => carry_sig(row)(8),
                S => sum_sig(row)(8), Cout => carry_sig(row)(9)
            );
        product(row) <= sum_sig(row)(0);
    end generate gen_rows;
    
    product(9)  <= sum_sig(8)(1);
    product(10) <= sum_sig(8)(2);
    product(11) <= sum_sig(8)(3);
    product(12) <= sum_sig(8)(4);
    product(13) <= sum_sig(8)(5);
    product(14) <= sum_sig(8)(6);
    product(15) <= sum_sig(8)(7);
    product(16) <= sum_sig(8)(8);
    product(17) <= carry_sig(8)(9);
    
end architecture structural;
