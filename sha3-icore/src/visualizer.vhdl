
library IEEE;

use IEEE.std_logic_1164.all;
use work.state.all;

entity block_visualizer is
    port(state : in block_t);
end entity;

architecture arch of block_visualizer is
    signal lane0, lane1, lane2, lane3, lane4, lane5, lane6, lane7, lane8, lane9, lane10, lane11, lane12 : lane_t;
    signal slice0, slice1, slice2, slice3, slice4, slice5, slice6, slice7, slice8, slice9,
        slice10, slice11, slice12, slice13, slice14, slice15, slice16, slice17, slice18, slice19,
        slice20, slice21, slice22, slice23, slice24, slice25, slice26, slice27, slice28, slice29,
        slice30, slice31, slice32, slice33, slice34, slice35, slice36, slice37, slice38, slice39,
        slice40, slice41, slice42, slice43, slice44, slice45, slice46, slice47, slice48, slice49,
        slice50, slice51, slice52, slice53, slice54, slice55, slice56, slice57, slice58, slice59,
        slice60, slice61, slice62, slice63 : tile_slice_t;
    
begin
    lane0 <= get_lane(state, 0);
    lane1 <= get_lane(state, 1);
    lane2 <= get_lane(state, 2);
    lane3 <= get_lane(state, 3);
    lane4 <= get_lane(state, 4);
    lane5 <= get_lane(state, 5);
    lane6 <= get_lane(state, 6);
    lane7 <= get_lane(state, 7);
    lane8 <= get_lane(state, 8);
    lane9 <= get_lane(state, 9);
    lane10 <= get_lane(state, 10);
    lane11 <= get_lane(state, 11);
    lane12 <= get_lane(state, 12);

    slice0 <= get_slice_tile(state, 0);
    slice1 <= get_slice_tile(state, 1);
    slice2 <= get_slice_tile(state, 2);
    slice3 <= get_slice_tile(state, 3);
    slice4 <= get_slice_tile(state, 4);
    slice5 <= get_slice_tile(state, 5);
    slice6 <= get_slice_tile(state, 6);
    slice7 <= get_slice_tile(state, 7);
    slice8 <= get_slice_tile(state, 8);
    slice9 <= get_slice_tile(state, 9);

    slice10 <= get_slice_tile(state, 10);
    slice11 <= get_slice_tile(state, 11);
    slice12 <= get_slice_tile(state, 12);
    slice13 <= get_slice_tile(state, 13);
    slice14 <= get_slice_tile(state, 14);
    slice15 <= get_slice_tile(state, 15);
    slice16 <= get_slice_tile(state, 16);
    slice17 <= get_slice_tile(state, 17);
    slice18 <= get_slice_tile(state, 18);
    slice19 <= get_slice_tile(state, 19);

    slice20 <= get_slice_tile(state, 20);
    slice21 <= get_slice_tile(state, 21);
    slice22 <= get_slice_tile(state, 22);
    slice23 <= get_slice_tile(state, 23);
    slice24 <= get_slice_tile(state, 24);
    slice25 <= get_slice_tile(state, 25);
    slice26 <= get_slice_tile(state, 26);
    slice27 <= get_slice_tile(state, 27);
    slice28 <= get_slice_tile(state, 28);
    slice29 <= get_slice_tile(state, 29);

    slice30 <= get_slice_tile(state, 30);
    slice31 <= get_slice_tile(state, 31);
    slice32 <= get_slice_tile(state, 32);
    slice33 <= get_slice_tile(state, 33);
    slice34 <= get_slice_tile(state, 34);
    slice35 <= get_slice_tile(state, 35);
    slice36 <= get_slice_tile(state, 36);
    slice37 <= get_slice_tile(state, 37);
    slice38 <= get_slice_tile(state, 38);
    slice39 <= get_slice_tile(state, 39);

    slice40 <= get_slice_tile(state, 40);
    slice41 <= get_slice_tile(state, 41);
    slice42 <= get_slice_tile(state, 42);
    slice43 <= get_slice_tile(state, 43);
    slice44 <= get_slice_tile(state, 44);
    slice45 <= get_slice_tile(state, 45);
    slice46 <= get_slice_tile(state, 46);
    slice47 <= get_slice_tile(state, 47);
    slice48 <= get_slice_tile(state, 48);
    slice49 <= get_slice_tile(state, 49);

    slice50 <= get_slice_tile(state, 50);
    slice51 <= get_slice_tile(state, 51);
    slice52 <= get_slice_tile(state, 52);
    slice53 <= get_slice_tile(state, 53);
    slice54 <= get_slice_tile(state, 54);
    slice55 <= get_slice_tile(state, 55);
    slice56 <= get_slice_tile(state, 56);
    slice57 <= get_slice_tile(state, 57);
    slice58 <= get_slice_tile(state, 58);
    slice59 <= get_slice_tile(state, 59);

    slice60 <= get_slice_tile(state, 60);
    slice61 <= get_slice_tile(state, 61);
    slice62 <= get_slice_tile(state, 62);
    slice63 <= get_slice_tile(state, 63);

end architecture;