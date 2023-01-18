LIBRARY IEEE;

use IEEE.std_logic_1164.all;
use std.textio.all;
use IEEE.numeric_std.all;

use work.state.all;
use work.util.all;

entity state_test is
end entity;

architecture arch of state_test is

    constant zero : lane_t := (others => '0');

    signal clk : std_logic := '0';
    signal finished : boolean := false;

begin

    clk_process : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    test_process : process is
        variable state : block_t;
    begin
        wait for 2ns;
        reset(state);
        wait for 2ns;
        for i in 0 to 12 loop
            assert get_lane(state, lane_index_t(i)) = zero report "expected state to be zero" SEVERITY FAILURE;
        end loop;
        wait until rising_edge(clk);
        set_lane(state, to_lane(x"0123456789abcdef"), 4);
        wait until rising_edge(clk);
        for i in 0 to 12 loop
            if i = 4 then
                assert get_lane(state, 4) = to_lane(x"0123456789abcdef") report "state(4) has wrong value" SEVERITY FAILURE;
            else
                assert get_lane(state, lane_index_t(i)) = zero report "expected zero in lane " & integer'image(i) SEVERITY FAILURE;
            end if;
        end loop;
        
        set_slice_tile(state, (others => '1'), 1);
        set_slice_tile(state, (others => '0'), 0);
        wait until rising_edge(clk);
        for i in 0 to 12 loop
            if i = 4 then
                assert get_lane(state, 4) = to_lane(x"0123456789abcdee") report "wrong value" SEVERITY FAILURE;
            else
                assert get_lane(state, i) = to_lane(x"0000000000000002") report "expected two in lane " & integer'image(i) SEVERITY FAILURE;
            end if;
        end loop;
        wait until rising_edge(clk);
        reset(state);
        finished <= true;
        wait;
    end process;

end architecture;
