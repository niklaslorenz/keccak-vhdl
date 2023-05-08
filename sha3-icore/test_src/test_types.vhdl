library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;

package test_types is

    type block_t is array(natural range 63 downto 0) of tile_slice_t;

end package;