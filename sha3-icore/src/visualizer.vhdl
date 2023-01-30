
library IEEE;

use IEEE.std_logic_1164.all;
use work.state.all;

entity block_visualizer is
    port(state : in block_t);
end entity;

architecture arch of block_visualizer is
    signal lane0, lane1, lane2, lane3, lane4, lane5, lane6, lane7, lane8, lane9, lane10, lane11, lane12 : lane_t;
begin
    lane0 <= state(0);
    lane1 <= state(1);
    lane2 <= state(2);
    lane3 <= state(3);
    lane4 <= state(4);
    lane5 <= state(5);
    lane6 <= state(6);
    lane7 <= state(7);
    lane8 <= state(8);
    lane9 <= state(9);
    lane10 <= state(10);
    lane11 <= state(11);
    lane12 <= state(12);
end architecture;