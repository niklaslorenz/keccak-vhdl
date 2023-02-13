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

    subtype atom_index_t is natural range 0 to 1;
    subtype lane_index_t is natural range 0 to 12;
    subtype full_lane_index_t is natural range 0 to 24;
    subtype slice_index_t is natural range 0 to 63;
    subtype computation_data_index_t is natural range 0 to 31;

    function get_lane(state : block_t; index : lane_index_t) return lane_t;

    function get_slice_tile(state: block_t; index : slice_index_t) return tile_slice_t;

    function isValid(state : block_t) return boolean;

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

    function get_slice_tile(state : block_t; index : slice_index_t) return tile_slice_t is
    begin
        return state(index);
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

end package body;
