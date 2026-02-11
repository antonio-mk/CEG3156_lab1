library ieee;
use ieee.std_logic_1164.all;

entity fp_adder is
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
end entity fp_adder;

architecture structural of fp_adder is

    -- COMPONENT DECLARATIONS

    component comparator_7bit is
        port (
            A, B      : in  std_logic_vector(6 downto 0);
            A_GT_B    : out std_logic;
            A_LT_B    : out std_logic;
            A_EQ_B    : out std_logic
        );
    end component;

    component comparator_9bit is
        port (
            A, B      : in  std_logic_vector(8 downto 0);
            A_GT_B    : out std_logic;
            A_LT_B    : out std_logic;
            A_EQ_B    : out std_logic
        );
    end component;

    component mux_2to1_1bit is
        port (
            data_in_0 : in  std_logic;
            data_in_1 : in  std_logic;
            sel_line  : in  std_logic;
            data_out  : out std_logic
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

    -- INTERNAL SIGNALS

    signal exp_gt, exp_lt, exp_eq : std_logic;

    signal mantA_full  : std_logic_vector(8 downto 0);
    signal mantB_full  : std_logic_vector(8 downto 0);

    signal mant_gt, mant_lt, mant_eq : std_logic;

    signal effective_A_gt_B : std_logic;

    signal sign_diff : std_logic;
    signal selected_sign : std_logic;

    signal mantissa_calc : std_logic_vector(7 downto 0);
    signal exponent_calc : std_logic_vector(6 downto 0);

begin

    -- STEP 1: Compare Exponents

    exp_comp : comparator_7bit
        port map (
            A => ExponentA,
            B => ExponentB,
            A_GT_B => exp_gt,
            A_LT_B => exp_lt,
            A_EQ_B => exp_eq
        );

    -- STEP 2: Add implicit 1

    mantA_full(8) <= '1';
    mantA_full(7 downto 0) <= MantissaA;

    mantB_full(8) <= '1';
    mantB_full(7 downto 0) <= MantissaB;

    -- STEP 3: Compare mantissas (only matters if exponents equal)

    mant_comp : comparator_9bit
        port map (
            A => mantA_full,
            B => mantB_full,
            A_GT_B => mant_gt,
            A_LT_B => mant_lt,
            A_EQ_B => mant_eq
        );

    -- STEP 4: Determine true magnitude comparison

    effective_A_gt_B <= exp_gt or (exp_eq and mant_gt);

    -- STEP 5: Sign Logic (CORRECTED)

    sign_diff <= SignA xor SignB;

    -- If signs same → use SignA
    -- If signs differ → use sign of larger magnitude

    sign_select : mux_2to1_1bit
        port map (
            data_in_0 => SignB,
            data_in_1 => SignA,
            sel_line  => effective_A_gt_B,
            data_out  => selected_sign
        );

    final_sign_mux : mux_2to1_1bit
        port map (
            data_in_0 => SignA,
            data_in_1 => selected_sign,
            sel_line  => sign_diff,
            data_out  => SignOut
        );

    mantissa_calc <= MantissaA;
    exponent_calc <= ExponentA;

    -- OUTPUT REGISTERS

    mantissa_reg : reg_8bit
        port map (
            data_in     => mantissa_calc,
            load_enable => '1',
            GClock      => GClock,
            GReset      => GReset,
            data_out    => MantissaOut
        );

    exponent_reg : reg_7bit
        port map (
            data_in     => exponent_calc,
            load_enable => '1',
            GClock      => GClock,
            GReset      => GReset,
            data_out    => ExponentOut
        );

    overflow_reg : reg_1bit
        port map (
            GClock      => GClock,
            GReset      => GReset,
            data_in     => '0',
            load_enable => '1',
            data_out    => Overflow
        );

end architecture structural;
