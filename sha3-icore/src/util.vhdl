LIBRARY IEEE;

use IEEE.std_logic_1164.all;
use work.state.all;

package util is

    function to_lane(vec : std_ulogic_vector) return lane_t;

end package;

package body util is

    function to_lane(vec : std_ulogic_vector) return lane_t is
    begin
        return lane_t(vec);
    end function;

end package body;