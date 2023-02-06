library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.state.all;
use work.util.all;
use work.round_constants;

package slice_functions is

    function pi(slice : slice_t) return slice_t;
    function chi(slice : slice_t) return slice_t;
    procedure rho(data : inout block_t; atom_index : atom_index_t);
    function rho_function(data : block_t; atom_index : atom_index_t) return block_t;

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

end package slice_functions;

package body slice_functions is

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

    procedure rho(data : inout block_t; atom_index : atom_index_t) is
        type offset_t is array(0 to 24) of natural;
	    constant offsets : offset_t := (0, 1, 62, 28, 27, 36, 44, 6, 55, 20, 3, 10, 43, 25, 39, 41, 45, 15, 21, 8, 18, 2, 61, 56, 14);
        variable lane : full_lane_index_t;
    begin
        if atom_index = 0 then
            for i in 0 to 12 loop
                data(i) := data(i)(63 - offsets(i) downto 0) & data(i)(63 downto 63 - offsets(i) + 1);
            end loop;
        else
            for i in 0 to 12 loop
                data(i) := data(i)(63 - offsets(12 + i) downto 0) & data(i)(63 downto 63 - offsets(12 + i) + 1);
            end loop;
        end if;
    end procedure;

    function rho_function(data : block_t; atom_index : atom_index_t) return block_t is
        variable result : block_t := data;
    begin
        rho(result, atom_index);
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
        iota_slice := chi_slice(24 downto 1) & (chi_slice(0) xor round_constants.get(round)(slice_index));
        if no_theta then
            slice_sums := "00000";
            result := iota_slice;
        else
            sums := theta_sums(slice);
            slice_sums := sums;
            result := theta(previous_sums, sums, iota_slice);
        end if;
    end procedure;

end package body;