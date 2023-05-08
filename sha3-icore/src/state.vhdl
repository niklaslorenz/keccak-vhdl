library IEEE;

use IEEE.std_logic_1164.all;

package state is

    -- Data and Slices
    subtype lane_t is std_logic_vector(63 downto 0);
    subtype slice_t is std_logic_vector(24 downto 0);
    type double_slice_t is array(natural range 1 downto 0) of slice_t;
    subtype tile_slice_t is std_logic_vector(12 downto 0);
    type double_tile_slice_t is array(natural range 1 downto 0) of tile_slice_t;
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

    -- Random unsorted stuff
    type block_t is array(natural range 63 downto 0) of tile_slice_t;
    subtype rho_manager_iterator_t is natural;
    type rho_calc_t is array(natural range 3 downto 0) of tile_slice_t;

    type multi_buffer_data_t is array(natural range 6 downto 0) of std_logic_vector(3 downto 0);

    

    type buffer_t is array(natural range 35 downto 0) of std_logic_vector(6 downto 0);

    function get_lane(state : block_t; index : lane_index_t) return lane_t;

    procedure set_lane(state : inout block_t; index : in lane_index_t; data : in lane_t);

    function get_slice_tile(state: block_t; index : slice_index_t) return tile_slice_t;

    function get_rho_data(state : block_t; index : natural range 0 to 15) return rho_calc_t;

    function isValid(state : block_t) return boolean;

    function "or"(left, right : rho_calc_t) return rho_calc_t;

end package;

package body state is

    function get_lane(state: block_t; index : lane_index_t) return lane_t is
        variable result : lane_t;
    begin
        for i in 0 to 63 loop
            result(i) := state(i)(index);
        end loop;
        return result;
    end function;

    procedure set_lane(state : inout block_t; index : in lane_index_t; data : in lane_t) is
    begin
        for i in 0 to 63 loop
            state(i)(index) := data(i);
        end loop;
    end procedure;

    function get_slice_tile(state : block_t; index : slice_index_t) return tile_slice_t is
    begin
        return state(index);
    end function;

    function get_rho_data(state : block_t; index : natural range 0 to 15) return rho_calc_t is
    begin
        return (state(index * 4 + 3), state(index * 4 + 2), state(index * 4 + 1), state(index * 4));
    end function;

    function isValid(state : block_t) return boolean is
    begin
        for l in 0 to 12 loop
            for i in 0 to 63 loop
                if state(l)(i) /= '1' and state(l)(i) /= '0' then
                    return false;
                end if;
            end loop;
        end loop;
        return true;
    end function;

    function "or"(left, right : rho_calc_t) return rho_calc_t is
        variable res : rho_calc_t;
    begin
        for i in 0 to 3 loop
            res(i) := left(i) or right(i);
        end loop;
        return res;
    end function;

end package body;
