library ieee;
use ieee.std_logic_1164.all;

entity comparator_7bit is
    port (
        A       : in  std_logic_vector(6 downto 0);
        B       : in  std_logic_vector(6 downto 0);
        A_GT_B  : out std_logic;
        A_LT_B  : out std_logic;
        A_EQ_B  : out std_logic
    );
end entity comparator_7bit;

architecture structural of comparator_7bit is
    component comparator_1bit is
        port (
            A, B : in std_logic;
            a_gt_b, a_lt_b, a_eq_b : out std_logic
        );
    end component;
    
    signal gt : std_logic_vector(6 downto 0);
    signal lt : std_logic_vector(6 downto 0);
    signal eq : std_logic_vector(6 downto 0);
    
    signal gt_cascade : std_logic_vector(6 downto 0);
    signal lt_cascade : std_logic_vector(6 downto 0);
    signal eq_cascade : std_logic_vector(6 downto 0);
    
begin
    gen_comp: for i in 6 downto 0 generate
        comp_bit: comparator_1bit
            port map (
                A      => A(i),
                B      => B(i),
                a_gt_b => gt(i),
                a_lt_b => lt(i),
                a_eq_b => eq(i)
            );
    end generate gen_comp;
    
    gt_cascade(6) <= gt(6);
    lt_cascade(6) <= lt(6);
    eq_cascade(6) <= eq(6);
    
    gen_cascade: for i in 5 downto 0 generate
        gt_cascade(i) <= gt_cascade(i+1) or (eq_cascade(i+1) and gt(i));
        lt_cascade(i) <= lt_cascade(i+1) or (eq_cascade(i+1) and lt(i));
        eq_cascade(i) <= eq_cascade(i+1) and eq(i);
    end generate gen_cascade;
    
    A_GT_B <= gt_cascade(0);
    A_LT_B <= lt_cascade(0);
    A_EQ_B <= eq_cascade(0);
    
end architecture structural;
