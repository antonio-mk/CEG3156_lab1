library ieee;
use ieee.std_logic_1164.all;

entity leading_zero_detector is
    port (
        data_in     : in  std_logic_vector(17 downto 0);
        zero_count  : out std_logic_vector(4 downto 0);
        all_zeros   : out std_logic
    );
end entity leading_zero_detector;

architecture structural of leading_zero_detector is
    signal found : std_logic_vector(17 downto 0);
    signal pos   : std_logic_vector(4 downto 0);
    
begin
    found(17) <= data_in(17);
    
    gen_found: for i in 16 downto 0 generate
        found(i) <= found(i+1) or data_in(i);
    end generate gen_found;
    
    pos(4) <= not (data_in(17) or data_in(16) or data_in(15) or data_in(14) or
                   data_in(13) or data_in(12) or data_in(11) or data_in(10) or
                   data_in(9) or data_in(8));
    
    pos(3) <= (not pos(4) and not (data_in(17) or data_in(16) or data_in(15) or data_in(14))) or
              (pos(4) and not (data_in(9) or data_in(8) or data_in(7) or data_in(6)));
    
    pos(2) <= (not pos(4) and not pos(3) and not (data_in(17) or data_in(16))) or
              (not pos(4) and pos(3) and not (data_in(13) or data_in(12))) or
              (pos(4) and not pos(3) and not (data_in(9) or data_in(8))) or
              (pos(4) and pos(3) and not (data_in(5) or data_in(4)));
    
    pos(1) <= (not pos(4) and not pos(3) and not pos(2) and not data_in(17)) or
              (not pos(4) and not pos(3) and pos(2) and not data_in(15)) or
              (not pos(4) and pos(3) and not pos(2) and not data_in(13)) or
              (not pos(4) and pos(3) and pos(2) and not data_in(11)) or
              (pos(4) and not pos(3) and not pos(2) and not data_in(9)) or
              (pos(4) and not pos(3) and pos(2) and not data_in(7)) or
              (pos(4) and pos(3) and not pos(2) and not data_in(5)) or
              (pos(4) and pos(3) and pos(2) and not data_in(3));
    
    pos(0) <= (not pos(4) and not pos(3) and not pos(2) and not pos(1) and not data_in(17)) or
              (not pos(4) and not pos(3) and not pos(2) and pos(1) and not data_in(16)) or
              (not pos(4) and not pos(3) and pos(2) and not pos(1) and not data_in(15)) or
              (not pos(4) and not pos(3) and pos(2) and pos(1) and not data_in(14)) or
              (not pos(4) and pos(3) and not pos(2) and not pos(1) and not data_in(13)) or
              (not pos(4) and pos(3) and not pos(2) and pos(1) and not data_in(12)) or
              (not pos(4) and pos(3) and pos(2) and not pos(1) and not data_in(11)) or
              (not pos(4) and pos(3) and pos(2) and pos(1) and not data_in(10)) or
              (pos(4) and not pos(3) and not pos(2) and not pos(1) and not data_in(9)) or
              (pos(4) and not pos(3) and not pos(2) and pos(1) and not data_in(8)) or
              (pos(4) and not pos(3) and pos(2) and not pos(1) and not data_in(7)) or
              (pos(4) and not pos(3) and pos(2) and pos(1) and not data_in(6)) or
              (pos(4) and pos(3) and not pos(2) and not pos(1) and not data_in(5)) or
              (pos(4) and pos(3) and not pos(2) and pos(1) and not data_in(4)) or
              (pos(4) and pos(3) and pos(2) and not pos(1) and not data_in(3)) or
              (pos(4) and pos(3) and pos(2) and pos(1) and not data_in(2));
    
    zero_count <= pos;
    all_zeros <= not found(0);
    
end architecture structural;
