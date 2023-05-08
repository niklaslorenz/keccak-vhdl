library IEEE;

use IEEE.std_logic_1164.all;

package types is

    -- Data and Slices
    subtype lane_t is std_logic_vector(63 downto 0);
    subtype slice_t is std_logic_vector(24 downto 0);
    type double_slice_t is array(natural range 1 downto 0) of slice_t;
    subtype tile_slice_t is std_logic_vector(12 downto 0);
    type double_tile_slice_t is array(natural range 1 downto 0) of tile_slice_t;
    type quad_tile_slice_t is array(natural range 3 downto 0) of tile_slice_t;
    subtype remote_tile_slice_t is std_logic_vector(11 downto 0);
    type double_remote_tile_slice_t is array(natural range 1 downto 0) of remote_tile_slice_t;
    subtype transmission_t is std_logic_vector(63 downto 0);

    --Indices
    subtype atom_index_t is natural range 0 to 1;
    subtype round_index_t is natural range 0 to 23;
    subtype lane_index_t is natural range 0 to 12;
    subtype full_lane_index_t is natural range 0 to 24;
    subtype slice_index_t is natural range 0 to 63;
    subtype double_slice_index_t is natural range 0 to 31;

    -- Memory Block
    subtype mem_addr_t is natural range 0 to 127;
    type mem_port_input is record
		addr : mem_addr_t;
		data : double_tile_slice_t;
        en : std_logic;
        we : std_logic;
	end record;
    type mem_port_output is record
        data : double_tile_slice_t;
    end record;
    type mem_port is record
        input : mem_port_input;
        output : mem_port_output;
    end record;
    constant mem_port_init : mem_port := (input => (addr => 0, data => (others => (others => '0')), en => '0', we => '0'),
                                          output => (data => (others => (others => '0'))));

    type buffer_data_t is array(natural range 6 downto 0) of std_logic_vector(3 downto 0);

end package;