library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.test_types.all;

package test_util is
    
    procedure rho(data : inout block_t; atom_index : atom_index_t);
    
    function rho_function(data : block_t; atom_index : atom_index_t) return block_t;

    function get_lane(state : block_t; index : lane_index_t) return lane_t;

    procedure set_lane(state : inout block_t; index : in lane_index_t; data : in lane_t);

    function get_slice_tile(state: block_t; index : slice_index_t) return tile_slice_t;

    function get_rho_data(state : block_t; index : natural range 0 to 15) return quad_tile_slice_t;

    function isValid(state : block_t) return boolean;

end package;

package body test_util is

    procedure rho(data : inout block_t; atom_index : atom_index_t) is
        type offset_t is array(0 to 24) of natural;
	    constant offsets : offset_t := (0, 1, 62, 28, 27, 36, 44, 6, 55, 20, 3, 10, 43, 25, 39, 41, 45, 15, 21, 8, 18, 2, 61, 56, 14);
        variable lane : full_lane_index_t;
    begin
        if atom_index = 0 then
            for i in 0 to 12 loop
                set_lane(data, i, get_lane(data, i)(63 - offsets(i) downto 0) & get_lane(data, i)(63 downto 63 - offsets(i) + 1));
            end loop;
        else
            for i in 0 to 12 loop
                set_lane(data, i, get_lane(data, i)(63 - offsets(12 + i) downto 0) & get_lane(data, i)(63 downto 63 - offsets(12 + i) + 1));
            end loop;
        end if;
    end procedure;

    function rho_function(data : block_t; atom_index : atom_index_t) return block_t is
        variable result : block_t := data;
    begin
        rho(result, atom_index);
        return result;
    end function;

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

    function get_rho_data(state : block_t; index : natural range 0 to 15) return quad_tile_slice_t is
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

end package body;