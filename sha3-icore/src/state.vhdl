library IEEE;

use IEEE.std_logic_1164.all;

package state is

    subtype lane_t is std_logic_vector(63 downto 0);
    subtype tile_slice_t is std_logic_vector(12 downto 0);
    subtype remote_slice_t is std_logic_vector(11 downto 0);
    subtype slice_t is std_logic_vector(24 downto 0);
    subtype transmission_word_t is std_logic_vector(31 downto 0);
    type block_t is array(natural range 63 downto 0) of tile_slice_t;

    type tile_computation_data_t is array(natural range 1 downto 0) of tile_slice_t;
    type computation_data_t is array(natural range 1 downto 0) of slice_t;
    subtype rho_manager_iterator_t is natural;
    type rho_calc_t is array(natural range 3 downto 0) of tile_slice_t;

    type multi_buffer_data_t is array(natural range 6 downto 0) of std_logic_vector(3 downto 0);

    subtype mem_addr_t is natural range 0 to 127;
    subtype atom_index_t is natural range 0 to 1;
    subtype lane_index_t is natural range 0 to 12;
    subtype full_lane_index_t is natural range 0 to 24;
    subtype slice_index_t is natural range 0 to 63;
    subtype computation_data_index_t is natural range 0 to 31;

    type buffer_t is array(natural range 35 downto 0) of std_logic_vector(6 downto 0);

    type mem_port_input is record
		addr : mem_addr_t;
		data : tile_computation_data_t;
        en : std_logic;
        we : std_logic;
	end record;

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
