library ieee;
use ieee.std_logic_1164.all;

entity fp_multiplier is
    port (
        GClock       : in  std_logic;
        GReset       : in  std_logic;
        
        SignA        : in  std_logic;
        MantissaA    : in  std_logic_vector(7 downto 0);
        ExponentA    : in  std_logic_vector(6 downto 0);
        
        SignB        : in  std_logic;
        MantissaB    : in  std_logic_vector(7 downto 0);
        ExponentB    : in  std_logic_vector(6 downto 0);
        
        SignOut      : out std_logic;
        MantissaOut  : out std_logic_vector(7 downto 0);
        ExponentOut  : out std_logic_vector(6 downto 0);
        Overflow     : out std_logic
    );
end entity fp_multiplier;

architecture structural of fp_multiplier is
    
    -- COMPONENT DECLARATIONS
    
    component multiplier_9bit is
        port (
            multiplicand : in  std_logic_vector(8 downto 0);
            multiplier   : in  std_logic_vector(8 downto 0);
            product      : out std_logic_vector(17 downto 0)
        );
    end component;
    
    component adder_7bit is
        port (
            term_a    : in  std_logic_vector(6 downto 0);
            term_b    : in  std_logic_vector(6 downto 0);
            carry_in  : in  std_logic;
            sum_out   : out std_logic_vector(6 downto 0);
            carry_out : out std_logic
        );
    end component;
    
    component full_adder_1bit is
        port (
            A    : in  std_logic;
            B    : in  std_logic;
            Cin  : in  std_logic;
            S    : out std_logic;
            Cout : out std_logic
        );
    end component;
    
    component reg_1bit is
        port (
            GClock      : in  std_logic;
            GReset      : in  std_logic;
            data_in     : in  std_logic;
            load_enable : in  std_logic;
            data_out    : out std_logic
        );
    end component;
    
    component reg_7bit is	
        port (
            data_in     : in  std_logic_vector(6 downto 0);
            load_enable : in  std_logic;
            GClock      : in  std_logic;
            GReset      : in  std_logic;
            data_out    : out std_logic_vector(6 downto 0)
        );
    end component;
	 
    component reg_8bit is
        port (
            data_in     : in  std_logic_vector(7 downto 0);
            load_enable : in  std_logic;
            GClock      : in  std_logic;
            GReset      : in  std_logic;
            data_out    : out std_logic_vector(7 downto 0)
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
    

    -- INTERNAL SIGNALS
    
    -- Extended mantissas with implicit leading 1
    signal mantA_ext     : std_logic_vector(8 downto 0);
    signal mantB_ext     : std_logic_vector(8 downto 0);
    
    -- Mantissa multiplication product
    signal product_full  : std_logic_vector(17 downto 0);
    
    -- Exponent addition (7-bit exponents, need to handle MSB separately)
    signal exp_sum_7bit   : std_logic_vector(6 downto 0);
    signal exp_sum_carry  : std_logic;
    signal exp_sum        : std_logic_vector(7 downto 0);
    
    -- Subtract bias (63) from exponent sum
    signal bias_inverted  : std_logic_vector(6 downto 0);
    signal exp_minus_bias : std_logic_vector(6 downto 0);
    signal exp_bias_carry : std_logic;
    
    -- Exponent increment for normalization
    signal exp_plus_one_7bit : std_logic_vector(6 downto 0);
    signal exp_inc_carry_7bit : std_logic;
    signal exp_inc_msb       : std_logic;
    signal exp_inc_carry_msb : std_logic;
    signal exp_plus_one      : std_logic_vector(7 downto 0);
    
    -- Normalized results
    signal normalized_exp : std_logic_vector(6 downto 0);
    signal normalized_man : std_logic_vector(7 downto 0);
    
    -- Sign calculation
    signal sign_internal  : std_logic;
    
begin
    
    -- STEP 1: Calculate sign (XOR of input signs)
    sign_internal <= SignA xor SignB;
    
    -- STEP 2: Extend mantissas with implicit leading 1
    mantA_ext <= '1' & MantissaA;
    mantB_ext <= '1' & MantissaB;
    
    -- STEP 3: Multiply mantissas (9-bit x 9-bit = 18-bit product)
    mant_mult: multiplier_9bit
        port map (
            multiplicand => mantA_ext,
            multiplier   => mantB_ext,
            product      => product_full
        );
    
    -- STEP 4: Add exponents (7-bit + 7-bit using 7-bit adder)
    
    exp_add: adder_7bit
        port map (
            term_a    => ExponentA,
            term_b    => ExponentB,
            carry_in  => '0',
            sum_out   => exp_sum_7bit,
            carry_out => exp_sum_carry
        );
    
    -- MSB of sum is just the carry out (since both inputs have 0 in bit 7)
    exp_sum <= exp_sum_carry & exp_sum_7bit;
    
    -- STEP 4b: Subtract bias (63) from exponent sum
    -- For multiplication: E_result = E_A + E_B - 63
    
    -- Invert 63 (0111111) for two's complement subtraction
    bias_inverted <= "1000000";  -- NOT(0111111) = 1000000
    
    -- Subtract bias: exp_sum - 63 = exp_sum + (-63) = exp_sum + NOT(63) + 1
    exp_bias_sub: adder_7bit
        port map (
            term_a    => exp_sum_7bit,
            term_b    => bias_inverted,
            carry_in  => '1',  -- Add 1 for two's complement
            sum_out   => exp_minus_bias,
            carry_out => exp_bias_carry
        );
    
    -- STEP 5: Increment exponent by 1 (for normalization case)
    
    exp_inc: adder_7bit
        port map (
            term_a    => exp_minus_bias,
            term_b    => "0000001",
            carry_in  => '0',
            sum_out   => exp_plus_one_7bit,
            carry_out => exp_inc_carry_7bit
        );
    
    exp_plus_one <= '0' & exp_plus_one_7bit;
    
    -- STEP 6: Normalization
    -- Product format: [17:0]
    -- If product_full(17) = 1: result is 1.xxxxxxxx, shift right (use bits [16:9])
    -- If product_full(17) = 0: result is 0.1xxxxxxx, no shift (use bits [15:8])
    
    -- Select mantissa based on normalization
    mantissa_mux: mux_2to1_8bit
        port map (
            data_in_0 => product_full(15 downto 8),  -- Not normalized (product_full(17)=0)
            data_in_1 => product_full(16 downto 9),  -- Normalized (product_full(17)=1, shift right)
            sel_line  => product_full(17),
            data_out  => normalized_man
        );
    
    -- Select exponent based on normalization
    exponent_mux: mux_2to1_7bit
        port map (
            data_in_0 => exp_minus_bias,        -- Not normalized (product_full(17)=0)
            data_in_1 => exp_plus_one_7bit,     -- Normalized (product_full(17)=1, increment exp)
            sel_line  => product_full(17),
            data_out  => normalized_exp
        );
    
    -- STEP 7: Output registers
    
    -- Sign output register
    sign_reg: reg_1bit
        port map (
            GClock      => GClock,
            GReset      => GReset,
            data_in     => sign_internal,
            load_enable => '1',
            data_out    => SignOut
        );
    
    -- Mantissa output register
    mant_reg: reg_8bit
        port map (
            data_in     => normalized_man,
            load_enable => '1',
            GClock      => GClock,
            GReset      => GReset,
            data_out    => MantissaOut
        );
    
    -- Exponent output register
    exp_reg: reg_7bit
        port map (
            data_in     => normalized_exp,
            load_enable => '1',
            GClock      => GClock,
            GReset      => GReset,
            data_out    => ExponentOut
        );
    
    -- Put Overflow to ground (no overflow detection in multiplier)
    Overflow <= '0';

end architecture structural;