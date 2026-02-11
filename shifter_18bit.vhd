library ieee;
use ieee.std_logic_1164.all;

entity shifter_18bit is
    port (
        data_in     : in  std_logic_vector(17 downto 0);
        shift_amt   : in  std_logic_vector(3 downto 0);
        direction   : in  std_logic;
        data_out    : out std_logic_vector(17 downto 0)
    );
end entity shifter_18bit;

architecture structural of shifter_18bit is
    component mux_2to1_1bit is
        port (
            data_in_0    : in  std_logic;
            data_in_1    : in  std_logic;
            sel_line     : in  std_logic;
            data_out     : out std_logic
        );
    end component;
    
    signal stage1 : std_logic_vector(17 downto 0);
    signal stage2 : std_logic_vector(17 downto 0);
    signal stage3 : std_logic_vector(17 downto 0);
    signal stage4 : std_logic_vector(17 downto 0);
    
    signal shift1_src, shift2_src, shift4_src, shift8_src : std_logic_vector(17 downto 0);
    
begin
    gen_stage1: for i in 17 downto 0 generate
        gen_s1_high: if i = 17 generate
            shift1_src(17) <= '0' when direction = '0' else data_in(16);
        end generate gen_s1_high;
        gen_s1_low: if i = 0 generate
            shift1_src(0) <= data_in(1) when direction = '0' else '0';
        end generate gen_s1_low;
        gen_s1_mid: if i > 0 and i < 17 generate
            shift1_src(i) <= data_in(i+1) when direction = '0' else data_in(i-1);
        end generate gen_s1_mid;
        
        mux_s1: mux_2to1_1bit
            port map (
                data_in_0 => data_in(i),
                data_in_1 => shift1_src(i),
                sel_line  => shift_amt(0),
                data_out  => stage1(i)
            );
    end generate gen_stage1;
    
    gen_stage2: for i in 17 downto 0 generate
        gen_s2_high: if i >= 16 generate
            shift2_src(i) <= '0' when direction = '0' else stage1(i-2);
        end generate gen_s2_high;
        gen_s2_low: if i <= 1 generate
            shift2_src(i) <= stage1(i+2) when direction = '0' else '0';
        end generate gen_s2_low;
        gen_s2_mid: if i > 1 and i < 16 generate
            shift2_src(i) <= stage1(i+2) when direction = '0' else stage1(i-2);
        end generate gen_s2_mid;
        
        mux_s2: mux_2to1_1bit
            port map (
                data_in_0 => stage1(i),
                data_in_1 => shift2_src(i),
                sel_line  => shift_amt(1),
                data_out  => stage2(i)
            );
    end generate gen_stage2;
    
    gen_stage3: for i in 17 downto 0 generate
        gen_s3_high: if i >= 14 generate
            shift4_src(i) <= '0' when direction = '0' else stage2(i-4);
        end generate gen_s3_high;
        gen_s3_low: if i <= 3 generate
            shift4_src(i) <= stage2(i+4) when direction = '0' else '0';
        end generate gen_s3_low;
        gen_s3_mid: if i > 3 and i < 14 generate
            shift4_src(i) <= stage2(i+4) when direction = '0' else stage2(i-4);
        end generate gen_s3_mid;
        
        mux_s3: mux_2to1_1bit
            port map (
                data_in_0 => stage2(i),
                data_in_1 => shift4_src(i),
                sel_line  => shift_amt(2),
                data_out  => stage3(i)
            );
    end generate gen_stage3;
    
    gen_stage4: for i in 17 downto 0 generate
        gen_s4_high: if i >= 10 generate
            shift8_src(i) <= '0' when direction = '0' else stage3(i-8);
        end generate gen_s4_high;
        gen_s4_low: if i <= 7 generate
            shift8_src(i) <= stage3(i+8) when direction = '0' else '0';
        end generate gen_s4_low;
        gen_s4_mid: if i > 7 and i < 10 generate
            shift8_src(i) <= stage3(i+8) when direction = '0' else stage3(i-8);
        end generate gen_s4_mid;
        
        mux_s4: mux_2to1_1bit
            port map (
                data_in_0 => stage3(i),
                data_in_1 => shift8_src(i),
                sel_line  => shift_amt(3),
                data_out  => stage4(i)
            );
    end generate gen_stage4;
    
    data_out <= stage4;
    
end architecture structural;
