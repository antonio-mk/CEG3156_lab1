library ieee;
use ieee.std_logic_1164.all;

-- Left shifter for 9-bit mantissa normalization
-- Shifts data LEFT (towards MSB) by shift_amt positions
-- Fills with zeros from the right (LSB)

entity shifter_left_9bit is
    port (
        data_in     : in  std_logic_vector(8 downto 0);
        shift_amt   : in  std_logic_vector(2 downto 0);
        data_out    : out std_logic_vector(8 downto 0)
    );
end entity shifter_left_9bit;

architecture structural of shifter_left_9bit is
    component mux_2to1_1bit is
        port (
            data_in_0    : in  std_logic;
            data_in_1    : in  std_logic;
            sel_line     : in  std_logic;
            data_out     : out std_logic
        );
    end component;
    
    signal stage1 : std_logic_vector(8 downto 0);
    signal stage2 : std_logic_vector(8 downto 0);
    signal stage3 : std_logic_vector(8 downto 0);
    
begin
    -- ========================================================================
    -- Stage 1: Shift by 1 position if shift_amt(0) = 1
    -- ========================================================================
    gen_stage1: for i in 8 downto 0 generate
        -- LSB: gets 0 when shifting
        gen_lsb: if i = 0 generate
            mux_s1: mux_2to1_1bit
                port map (
                    data_in_0 => data_in(0),
                    data_in_1 => '0',
                    sel_line  => shift_amt(0),
                    data_out  => stage1(0)
                );
        end generate gen_lsb;
        
        -- Other bits: get bit from position i-1 when shifting left
        gen_rest1: if i > 0 generate
            mux_s1: mux_2to1_1bit
                port map (
                    data_in_0 => data_in(i),
                    data_in_1 => data_in(i-1),
                    sel_line  => shift_amt(0),
                    data_out  => stage1(i)
                );
        end generate gen_rest1;
    end generate gen_stage1;
    
    -- ========================================================================
    -- Stage 2: Shift by 2 positions if shift_amt(1) = 1
    -- ========================================================================
    gen_stage2: for i in 8 downto 0 generate
        -- Two LSBs: get 0 when shifting
        gen_lsb2: if i <= 1 generate
            mux_s2: mux_2to1_1bit
                port map (
                    data_in_0 => stage1(i),
                    data_in_1 => '0',
                    sel_line  => shift_amt(1),
                    data_out  => stage2(i)
                );
        end generate gen_lsb2;
        
        -- Other bits: get bit from position i-2 when shifting left
        gen_rest2: if i > 1 generate
            mux_s2: mux_2to1_1bit
                port map (
                    data_in_0 => stage1(i),
                    data_in_1 => stage1(i-2),
                    sel_line  => shift_amt(1),
                    data_out  => stage2(i)
                );
        end generate gen_rest2;
    end generate gen_stage2;
    
    -- ========================================================================
    -- Stage 3: Shift by 4 positions if shift_amt(2) = 1
    -- ========================================================================
    gen_stage3: for i in 8 downto 0 generate
        -- Four LSBs: get 0 when shifting
        gen_lsb3: if i <= 3 generate
            mux_s3: mux_2to1_1bit
                port map (
                    data_in_0 => stage2(i),
                    data_in_1 => '0',
                    sel_line  => shift_amt(2),
                    data_out  => stage3(i)
                );
        end generate gen_lsb3;
        
        -- Other bits: get bit from position i-4 when shifting left
        gen_rest3: if i > 3 generate
            mux_s3: mux_2to1_1bit
                port map (
                    data_in_0 => stage2(i),
                    data_in_1 => stage2(i-4),
                    sel_line  => shift_amt(2),
                    data_out  => stage3(i)
                );
        end generate gen_rest3;
    end generate gen_stage3;
    
    data_out <= stage3;
    
end architecture structural;