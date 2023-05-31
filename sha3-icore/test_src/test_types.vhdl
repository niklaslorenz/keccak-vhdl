library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;

package test_types is

    type block_t is array(natural range 63 downto 0) of tile_slice_t;

    type lane_aligned_block_t is array(natural range 12 downto 0) of lane_t;

    type full_lane_aligned_block_t is array(natural range 24 downto 0) of lane_t;

end package;