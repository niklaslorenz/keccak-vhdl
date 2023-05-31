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

    function get_double_tile_slice(state : block_t; index : natural range 0 to 31) return double_tile_slice_t;

    function get_quad_tile_slice(state : block_t; index : natural range 0 to 15) return quad_tile_slice_t;

    function isValid(state : block_t) return boolean;

    function to_slice_aligned_block(state : lane_aligned_block_t) return block_t;

    function block_from_hex_text(text : std_logic_vector(1087 downto 0)) return full_lane_aligned_block_t;

    function upper_block(full_block : full_lane_aligned_block_t) return block_t;

    function lower_block(full_block : full_lane_aligned_block_t) return block_t;

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

    function get_double_tile_slice(state : block_t; index : natural range 0 to 31) return double_tile_slice_t is
    begin
        return (state(index * 2 + 1), state(index * 2));
    end function;

    function get_quad_tile_slice(state : block_t; index : natural range 0 to 15) return quad_tile_slice_t is
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

    function to_slice_aligned_block(state : lane_aligned_block_t) return block_t is
        variable result : block_t;
    begin
        for i in 0 to 12 loop
            for j in 0 to 63 loop
                result(j)(i) := state(i)(j);
            end loop;
        end loop;
        return result;
    end function;

    function block_from_hex_text(text : std_logic_vector(1087 downto 0)) return full_lane_aligned_block_t is
        constant extension : std_logic_vector(511 downto 0) := (others => '0');
        variable extended : std_logic_vector(1599 downto 0);
        variable res : full_lane_aligned_block_t;
        variable current_lane : lane_t;
        variable flipped_lane : lane_t;
    begin
        extended := text & extension;
        for i in 0 to 24 loop
            current_lane := extended(64 * i + 63 downto 64 * i);
            for j in 0 to 7 loop
                flipped_lane(8 * j + 7 downto 8 * j) := current_lane(8 * (7 - j) + 7 downto 8 * (7 - j));
            end loop;
            res(i) := flipped_lane;
        end loop;
        return res;
    end function;

    function lower_block(full_block : full_lane_aligned_block_t) return block_t is
        variable temp : lane_aligned_block_t;
    begin
        for i in 0 to 12 loop
            temp(i) := full_block(24 - i);
        end loop;
        return to_slice_aligned_block(temp);
    end function;

    function upper_block(full_block : full_lane_aligned_block_t) return block_t is
        variable temp : lane_aligned_block_t;
    begin
        for i in 0 to 12 loop
            temp(i) := full_block(12 - i);
        end loop;
        return to_slice_aligned_block(temp);
    end function;

end package body;