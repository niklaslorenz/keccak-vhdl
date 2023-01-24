library IEEE;

use IEEE.std_logic_1164.all;
use work.state.all;
use work.slice_functions.all;
use work.round_constants;
use work.slice_buffer.all;

entity buffer_data_transmit_test is
end entity;

architecture arch of buffer_data_transmit_test is

    signal finished : boolean := false;
    signal clk : std_logic := '0';
    signal lane0, lane1, lane11, lane12 : lane_t;
    signal slice0 : slice_t;
begin

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    test : process is
        variable buf0 : buffer_t;
        variable buf1 : buffer_t;
        variable buf0_state : block_t;
        variable buf1_state : block_t;
        variable buf0_output, buf0_input, buf1_input, buf1_output : lane_t;
        variable buf0_data, buf1_data : buffer_data_t;
        variable buf0_ready, buf0_finished, buf0_isFirst, buf0_isLast : std_logic;
        variable buf1_ready, buf1_finished, buf1_isFirst, buf1_isLast : std_logic;
        variable buf0_current_slice, buf1_current_slice : slice_index_t;
        constant zero : lane_t := (others => '0');
    begin
        wait for 2ns;
        -- reset
        init_buffer(buf0);
        init_buffer(buf1);
        reset(buf0_state);
        reset(buf1_state);
        buf0_input := zero;
        buf0_output := zero;
        buf1_input := zero;
        buf1_output := zero;
        wait until rising_edge(clk);
        -- init states
        for i in 0 to 12 loop
            set_lane(buf0_state, round_constants.get(i), i);
            set_lane(buf1_state, round_constants.get(i + 11), i);
        end loop;
        lane0 <= buf0_state(0);
        lane1 <= buf0_state(1);
        lane11 <= buf0_state(11);
        lane12 <= buf0_state(12);
        wait until rising_edge(clk);
        for i in 0 to 10 loop
            sync(buf0, buf0_state, 0, buf0_input, ((others => '0'), (others => '0')), buf0_output, buf0_data, buf0_ready, buf0_finished, buf0_isFirst, buf0_isLast, buf0_current_slice);
            sync(buf1, buf1_state, 1, buf1_input, ((others => '0'), (others => '0')), buf1_output, buf1_data, buf1_ready, buf1_finished, buf1_isFirst, buf1_isLast, buf1_current_slice);
            buf0_input := buf1_output;
            buf1_input := buf0_output;

            if i = 0 then
                assert buf0_ready = '0' severity FAILURE;
                assert buf1_ready = '0' severity FAILURE;
                assert buf0_isFirst = '0' severity FAILURE;
                assert buf1_isFirst = '0' severity FAILURE;
                assert buf0_current_slice = 0;
                assert buf1_current_slice = 0;
                assert buf1_output /= zero severity FAILURE;
            end if;
            if i = 1 then
                assert buf0_isFirst = '1' severity FAILURE;
                assert buf1_isFirst = '1' severity FAILURE;
            end if;
            if i >= 1 and i <= 8 then
                assert buf0_ready = '1' severity FAILURE;
                assert buf1_ready = '1' severity FAILURE;
                assert buf0_current_slice = i * 2 - 2 severity FAILURE;
                assert buf1_current_slice = i * 2 + 14 severity FAILURE;
                slice0 <= buf0_data(0);
                assert buf0_data(0) = get_slice_tile(buf1_state, i * 2 - 2)(12 downto 1) & get_slice_tile(buf0_state, i * 2 - 2) severity FAILURE;
                assert buf0_data(1) = get_slice_tile(buf1_state, i * 2 - 1)(12 downto 1) & get_slice_tile(buf0_state, i * 2 - 1) severity FAILURE;
                assert buf1_data(0) = get_slice_tile(buf1_state, i * 2 + 14)(12 downto 1) & get_slice_tile(buf0_state, i * 2 + 14) severity FAILURE;
                assert buf1_data(1) = get_slice_tile(buf1_state, i * 2 + 15)(12 downto 1) & get_slice_tile(buf0_state, i * 2 + 15) severity FAILURE;
            end if;
            if i >= 9 then
                assert buf0_current_slice = 0;
                assert buf1_current_slice = 0;
                assert buf0_ready = '0';
                assert buf1_ready = '0';
            end if;
            wait until rising_edge(clk);
        end loop;
        wait until rising_edge(clk);

        finished <= true;
        wait;
    end process;

end architecture;