library IEEE;

use IEEE.std_logic_1164.all;

package util is

    type state_t is array(natural range 0 to 12) of std_logic_vector(63 downto 0);

    type slice_tile_t is array(natural range 1 downto 0) of std_logic_vector(12 downto 0);

    function at(x : natural range 0 to 4; y : natural range 0 to 4) return natural;

    function rotl(lane : std_logic_vector(63 downto 0); shift : natural range 1 to 63) return std_logic_vector;

end package;

package state is

    procedure set_lane(state: inout state_t; lane : in std_logic_vector(63 downto 0); index : in natural range 0 to 12);

    procedure set_slice_tile(state : inout state_t; data : in slice_tile_t; index : in natural range 0 to 31);

    procedure reset(state : inout state_t);

end package;

package body util is

    function at(x : natural range 0 to 4; y : natural range 0 to 4) return natural is
    begin
        return y * 5 + x;
    end function;

    function rotl(lane : std_logic_vector(63 downto 0); shift : natural range 1 to 63) return std_logic_vector is
    begin
        return lane(63 - shift downto 0) & lane(63 downto 63 - shift + 1);
    end function;

end package body;

package body state is

    procedure set_lane(state: inout state_t; data : in std_logic_vector(63 downto 0); index : in natural range 0 to 12) is
    begin
        state(index) <= data;
    end procedure;

    procedure set_slice_tile(state : inout state_t; data : in slice_tile_t; index : in natural range 0 to 31) is
    begin
        for i in 0 to 12 loop
            state(i)(index * 2) <= data(0)(i);
            state(i)(index * 2 + 1) <= data(1)(i);
        end loop;
    end procedure;

    procedure reset(state : inout state_t) is
    begin
        for i in 0 to 12 loop
            state(i) <= (others => '0');
        end loop;
    end procedure;

end package body;
