LIBRARY IEEE;

use IEEE.std_logic_1164.all;
use work.types.all;

package util is

    function pi(slice : slice_t) return slice_t;

    function chi(slice : slice_t) return slice_t;

    function theta_sums(slice : slice_t) return std_logic_vector;

    function theta(lower_sums : std_logic_vector(4 downto 0); higher_sums : std_logic_vector(4 downto 0); slice : slice_t) return slice_t;
    
    function theta(previous_slice : slice_t; this_slice : slice_t) return slice_t;

    procedure gamma(
        previous_sums : std_logic_vector(4 downto 0);
        slice : slice_t;
        slice_index : slice_index_t;
        round : round_index_t;
        no_theta : boolean;
        slice_sums : out std_logic_vector(4 downto 0);
        result : out slice_t
    );

    function round_constant(round_index : round_index_t) return lane_t;

    function to_lane(vec : std_ulogic_vector) return lane_t;

    function mergeSlice(f : tile_slice_t; r : remote_tile_slice_t; atom_index : atom_index_t) return slice_t;

    function asBit(condition : boolean) return std_logic;

end package;

package body util is

    function full_lane_index(x : natural range 0 to 4; y : natural range 0 to 4) return full_lane_index_t is
    begin
        return y * 5 + x;
    end function;

    function pi(slice : slice_t) return slice_t is
        variable result : slice_t;
    begin
        for y in 0 to 4 loop
            for x in 0 to 4 loop
                result(full_lane_index(x, y)) := slice(full_lane_index((x + 3 * y) mod 5, x));
            end loop;
        end loop;
        return result;
    end function;

    function chi(slice : slice_t) return slice_t is
        variable result : slice_t;
    begin
        for y in 0 to 4 loop
            for x in 0 to 4 loop
                result(full_lane_index(x, y)) := slice(full_lane_index(x, y)) xor (not slice(full_lane_index((x + 1) mod 5, y)) and slice(full_lane_index((x + 2) mod 5, y)));
            end loop;
        end loop;
        return result;
    end function;

    function theta_sums(slice : slice_t) return std_logic_vector is
        variable column_sums : std_logic_vector(4 downto 0) := (others => '0');
    begin
        for x in 0 to 4 loop
            for y in 0 to 4 loop
                column_sums(x) := column_sums(x) xor slice(full_lane_index(x, y));
            end loop;
        end loop;
        return column_sums;
    end function;

    function theta(lower_sums : std_logic_vector(4 downto 0); higher_sums : std_logic_vector(4 downto 0); slice : slice_t) return slice_t is
        variable result : slice_t;
        variable column_modifiers : std_logic_vector(4 downto 0) := (others => '0');
    begin
        for x in 0 to 4 loop
            column_modifiers(x) := higher_sums((x + 4) mod 5) xor lower_sums((x + 1) mod 5);
            for y in 0 to 4 loop
                result(full_lane_index(x, y)) := slice(full_lane_index(x, y)) xor column_modifiers(x);
            end loop;
        end loop;
        return result;
    end function;

    function theta(previous_slice : slice_t; this_slice : slice_t) return slice_t is
        variable prev_temp : std_logic_vector(4 downto 0);
        variable this_temp : std_logic_vector(4 downto 0);
    begin
        prev_temp := theta_sums(previous_slice);
        this_temp := theta_sums(this_slice);
        return theta(prev_temp, this_temp, this_slice);
    end function;

    procedure gamma(
        previous_sums : std_logic_vector(4 downto 0);
        slice : slice_t;
        slice_index : slice_index_t;
        round : round_index_t;
        no_theta : boolean;
        slice_sums : out std_logic_vector(4 downto 0);
        result : out slice_t
    ) is
        variable chi_slice : slice_t;
        variable iota_slice : slice_t;
        variable sums : std_logic_vector(4 downto 0);
    begin
        chi_slice := chi(pi(slice));
        iota_slice := chi_slice(24 downto 1) & (chi_slice(0) xor round_constant(round)(slice_index));
        if no_theta then
            slice_sums := "00000";
            result := iota_slice;
        else
            sums := theta_sums(slice);
            slice_sums := sums;
            result := theta(previous_sums, sums, iota_slice);
        end if;
    end procedure;

    function round_constant(round_index : round_index_t) return lane_t is
    begin
        case round_index is
            when  0 => return to_lane(x"0000000000000001");
            when  1 => return to_lane(x"0000000000008082");
            when  2 => return to_lane(x"800000000000808a");
            when  3 => return to_lane(x"8000000080008000");
            when  4 => return to_lane(x"000000000000808b");
            when  5 => return to_lane(x"0000000080000001");
            when  6 => return to_lane(x"8000000080008081");
            when  7 => return to_lane(x"8000000000008009");
            when  8 => return to_lane(x"000000000000008a");
            when  9 => return to_lane(x"0000000000000088");
            when 10 => return to_lane(x"0000000080008009");
            when 11 => return to_lane(x"000000008000000a");
            when 12 => return to_lane(x"000000008000808b");
            when 13 => return to_lane(x"800000000000008b");
            when 14 => return to_lane(x"8000000000008089");
            when 15 => return to_lane(x"8000000000008003");
            when 16 => return to_lane(x"8000000000008002");
            when 17 => return to_lane(x"8000000000000080");
            when 18 => return to_lane(x"000000000000800a");
            when 19 => return to_lane(x"800000008000000a");
            when 20 => return to_lane(x"8000000080008081");
            when 21 => return to_lane(x"8000000000008080");
            when 22 => return to_lane(x"0000000080000001");
            when 23 => return to_lane(x"8000000080008008");
        end case;
    end function;

    function to_lane(vec : std_ulogic_vector) return lane_t is
    begin
        return lane_t(vec);
    end function;

    function mergeSlice(f : tile_slice_t; r : remote_tile_slice_t; atom_index : atom_index_t) return slice_t is
    begin
        if atom_index = 0 then
            return r & f;
        else
            return f & r;
        end if;
    end function;

    function asBit(condition : boolean) return std_logic is
    begin
        if condition then
            return '1';
        else
            return '0';
        end if;
    end function;

end package body;