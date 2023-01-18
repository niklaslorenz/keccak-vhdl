library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.state.all;
use work.util.all;

package slice_functions is

    function pi(slice : slice_t) return slice_t;
    function chi(slice : slice_t) return slice_t;

    function theta_sums(slice : slice_t) return std_logic_vector;
    function theta(lower_sums : std_logic_vector(4 downto 0); higher_sums : std_logic_vector(4 downto 0); slice : slice_t) return slice_t;
    function theta(previous_slice : slice_t; this_slice : slice_t) return slice_t;

end package slice_functions;

package body slice_functions is

    function pi(slice : slice_t) return slice_t is
        variable result : slice_t(24 downto 0);
    begin
        perm_y : for y in 0 to 4 generate
            perm_x : for x in 0 to 4 generate
                result(full_lane_index(x, y)) := slice(full_lane_index((x + 3 * y) mod 5, x));
            end generate;
        end generate;
        return result;
    end function;

    function chi(slice : slice_t) return slice_t is
        variable result : slice_t(24 downto 0);
    begin
        gen_y : for y in 0 to 4 generate
            gen_x : for x in 0 to 4 generate
                result(full_lane_index(x, y)) <= slice(full_lane_index(x, y)) xor (not slice(full_lane_index((x + 1) mod 5, y)) and slice(full_lane_index((x + 2) mod 5, y)));
            end generate;
        end generate;
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

end package body;