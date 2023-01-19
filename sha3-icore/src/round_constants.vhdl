
library IEEE;

use IEEE.std_logic_1164.all;
use work.util.all;
use work.state.all;

package round_constants is

    function get(round_index : round_index_t) return lane_t;

end package;

package body round_constants is

    function get(round_index : round_index_t) return lane_t is
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

end package body;
