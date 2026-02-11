library ieee;
use ieee.std_logic_1164.all;

entity leading_zero_detector_9bit is
    port (
        data_in     : in  std_logic_vector(8 downto 0);
        zero_count  : out std_logic_vector(3 downto 0);
        all_zeros   : out std_logic
    );
end entity leading_zero_detector_9bit;

architecture structural of leading_zero_detector_9bit is
    signal found : std_logic_vector(8 downto 0);
    signal pos   : std_logic_vector(3 downto 0);
    
begin
    -- Propagate "found a 1" signal from MSB to LSB
    found(8) <= data_in(8);
    
    gen_found: for i in 7 downto 0 generate
        found(i) <= found(i+1) or data_in(i);
    end generate gen_found;
    
    -- Determine position of first 1 (leading zero count)
    -- pos(3) is set if leading zeros >= 8 (only bit 0 might be 1)
    pos(3) <= not (data_in(8) or data_in(7) or data_in(6) or data_in(5) or
                   data_in(4) or data_in(3) or data_in(2) or data_in(1));
    
    -- pos(2) is set if leading zeros >= 4 in upper half OR >= 4 in lower half when upper is all zero
    pos(2) <= (not pos(3) and not (data_in(8) or data_in(7) or data_in(6) or data_in(5))) or
              (pos(3) and not (data_in(4) or data_in(3) or data_in(2) or data_in(1)));
    
    -- pos(1) logic
    pos(1) <= (not pos(3) and not pos(2) and not (data_in(8) or data_in(7))) or
              (not pos(3) and pos(2) and not (data_in(6) or data_in(5))) or
              (pos(3) and not pos(2) and not (data_in(4) or data_in(3))) or
              (pos(3) and pos(2) and not (data_in(2) or data_in(1)));
    
    -- pos(0) logic
    pos(0) <= (not pos(3) and not pos(2) and not pos(1) and not data_in(8)) or
              (not pos(3) and not pos(2) and pos(1) and not data_in(7)) or
              (not pos(3) and pos(2) and not pos(1) and not data_in(6)) or
              (not pos(3) and pos(2) and pos(1) and not data_in(5)) or
              (pos(3) and not pos(2) and not pos(1) and not data_in(4)) or
              (pos(3) and not pos(2) and pos(1) and not data_in(3)) or
              (pos(3) and pos(2) and not pos(1) and not data_in(2)) or
              (pos(3) and pos(2) and pos(1) and not data_in(1));
    
    zero_count <= pos;
    all_zeros <= not found(0);
    
end architecture structural;