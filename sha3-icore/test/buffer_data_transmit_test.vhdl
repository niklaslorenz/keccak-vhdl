library IEEE;

use IEEE.std_logic_1164.all;
use work.state.all;
use work.util.all;
use work.slice_functions.all;
use work.round_constants;
use work.slice_buffer.all;
use work.block_visualizer;

entity buffer_data_transmit_test is
end entity;

architecture arch of buffer_data_transmit_test is

    component block_visualizer is
        port(state : in block_t);
    end component;

    signal finished : boolean := false;
    signal clk : std_logic := '0';
    signal state0, state1 : block_t;
    signal iteration : natural range 0 to 31;
begin

    state0_visual : block_visualizer port map(state0);
    state1_visual : block_visualizer port map(state1);

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
        variable buf0_first, buf0_finished, buf0_loop, buf0_edgeCase : std_logic;
        variable buf1_first, buf1_finished, buf1_loop, buf1_edgeCase : std_logic;
        variable buf0_current_slice, buf1_current_slice : slice_index_t;
        constant zero : lane_t := (others => '0');

        procedure update is
        begin
            state0 <= buf0_state;
            state1 <= buf1_state;
        end procedure;
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
        update;
        wait until rising_edge(clk);
        -- init states
        for i in 0 to 12 loop
            set_lane(buf0_state, round_constants.get(i), i);
            set_lane(buf1_state, round_constants.get(i + 11), i);
        end loop;
        update;
        wait until rising_edge(clk);
        for i in 0 to 21 loop
            iteration <= i;
            sync(buf0, buf0_state, 0, buf0_input, ((others => '0'), (others => '0')), buf0_output, buf0_data, buf0_first, buf0_loop, buf0_edgeCase, buf0_current_slice, buf0_finished);
            sync(buf1, buf1_state, 1, buf1_input, ((others => '0'), (others => '0')), buf1_output, buf1_data, buf1_first, buf1_loop, buf1_edgeCase, buf1_current_slice, buf1_finished);
            buf0_input := buf1_output;
            buf1_input := buf0_output;
            update;
            if i >= 1 and i <= 16 then
                assert buf0_current_slice = i * 2 - 2 severity FAILURE;
                assert buf1_current_slice = i * 2 + 30 severity FAILURE;
                assert buf0_data(0) = get_slice_tile(buf1_state, i * 2 - 2)(12 downto 1) & get_slice_tile(buf0_state, i * 2 - 2) severity FAILURE;
                assert buf0_data(1) = get_slice_tile(buf1_state, i * 2 - 1)(12 downto 1) & get_slice_tile(buf0_state, i * 2 - 1) severity FAILURE;
                assert buf1_data(0) = get_slice_tile(buf1_state, i * 2 + 30)(12 downto 1) & get_slice_tile(buf0_state, i * 2 + 30) severity FAILURE;
                assert buf1_data(1) = get_slice_tile(buf1_state, i * 2 + 31)(12 downto 1) & get_slice_tile(buf0_state, i * 2 + 31) severity FAILURE;
            end if;
            if i = 17 then
                assert buf0_edgeCase = '1' severity FAILURE;
                assert buf1_edgeCase = '1' severity FAILURE;
            else
                assert buf0_edgeCase = '0' severity FAILURE;
                assert buf1_edgeCase = '0' severity FAILURE;

            end if;
            if i >= 17 then
                assert buf0_current_slice = 0;
                assert buf1_current_slice = 0;
            end if;
            wait until rising_edge(clk);
        end loop;
        wait until rising_edge(clk);

        finished <= true;
        wait;
    end process;

end architecture;