library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
use work.result_writer;
use work.round_constants;
use work.block_visualizer;

entity result_writer_test is
end entity;

architecture arch of result_writer_test is

    component block_visualizer is
        port(state : in block_t);
    end component;

    component result_writer is
        port(
            clk : in std_logic;
            rst : in std_logic;
            enable : in std_logic;
            init : in std_logic;
            state : in block_t;
            output : out lane_t;
            finished : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal finished : boolean := false;

    signal rst : std_logic := '0';
    signal enable : std_logic := '0';
    signal init : std_logic := '0';
    signal state : block_t;
    signal output : lane_t ;
    signal ready : std_logic;

    constant zero : lane_t := (others => '0');
begin

    writer : result_writer port map(clk, rst, enable, init, state, output, ready);

    visualizer : block_visualizer port map(state);

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    test : process is
        variable state_temp : block_t;
    begin
        for i in 0 to 12 loop
            state_temp(i) := round_constants.get(i);
        end loop;
        wait for 2ns;
        state <= state_temp;
        rst <= '1';
        wait for 2ns;
        rst <= '0';
        enable <= '1';
        wait until rising_edge(clk);
        assert output = zero severity FAILURE;
        wait until rising_edge(clk);
        for i in 0 to 3 loop
            assert output = round_constants.get(i) severity FAILURE;
            if i >= 2 then
                assert ready = '1' severity FAILURE;
            else
                assert ready = '0' severity FAILURE;
            end if;
            wait until rising_edge(clk);
        end loop;

        finished <= true;
        wait;
    end process;

end architecture;