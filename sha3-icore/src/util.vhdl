LIBRARY IEEE;

use IEEE.std_logic_1164.all;
use work.state.all;

package util is

    function to_lane(vec : std_ulogic_vector) return lane_t;

    function full_lane_index(x : natural range 0 to 4; y : natural range 0 to 4) return full_lane_index_t;

end package;

package body util is

    function to_lane(vec : std_ulogic_vector) return lane_t is
    begin
        return lane_t(vec);
    end function;

    function full_lane_index(x : natural range 0 to 4; y : natural range 0 to 4) return full_lane_index_t is
    begin
        return y * 5 + x;
    end function;

end package body;