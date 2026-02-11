Library ieee;
use ieee.std_logic_1164.all;

entity comparator_1bit is 
	port(A, B : in std_logic;
		  a_gt_b, a_lt_b, a_eq_b : out std_logic);
end entity comparator_1bit;

architecture gate_logic of comparator_1bit is
begin
	a_gt_b <= A and (not B);
	a_lt_b <= (not A) and B;
	a_eq_b <= A xnor B;
end architecture gate_logic;