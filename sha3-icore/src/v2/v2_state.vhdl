library IEEE;
use IEEE.std_logic_1164.all;

package v2_state is

	subtype lane_part_t is std_logic_vector(31 downto 0);
	type v2_block_t is array (natural range 0 to 12) of lane_part_t;
	subtype v2_atom_index_t is natural range 0 to 3;

end package;
