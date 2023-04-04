library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;

entity memory_block_test is
end entity;

architecture arch of memory_block_test is

    component memory_block is
        port(
            clk : in std_logic;
            port_a_in : in mem_port_input;
            port_a_out : out mem_port_output;
            port_b_in : in mem_port_input;
            port_b_out : out mem_port_output
        );
    end component;

    signal clk : std_logic := '0';
    signal finished : boolean := false;

    signal port_a, port_b : mem_port := mem_port_init;

    signal a_in_0, a_in_1 : tile_slice_t;
    signal a_out_0, a_out_1 : tile_slice_t;

    constant slice0 : tile_computation_data_t := ("1101010010000", "1100100011100");
    constant slice1 : tile_computation_data_t := ("1001001000110", "1010001000010");
    constant slice2 : tile_computation_data_t := ("0000001010101", "0011000100000");

begin

    a_in_0 <= port_a.input.data(0);
    a_in_1 <= port_a.input.data(1);
    a_out_0 <= port_a.output.data(0);
    a_out_1 <= port_a.output.data(1);

    mem : memory_block port map(clk, port_a.input, port_a.output, port_b.input, port_b.output);

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    test : process is
    begin
        wait until rising_edge(clk); -- 0
        wait until rising_edge(clk); -- 10
        port_a.input.en <= '1';
        port_a.input.we <= '1';
        port_a.input.addr <= 0;
        port_a.input.data <= slice0;
        wait until rising_edge(clk); -- 20
        port_a.input.addr <= 1;
        port_a.input.data <= slice1;
        wait until rising_edge(clk); -- 30
        port_a.input.addr <= 5;
        port_a.input.data <= slice2;
        wait until rising_edge(clk); -- 40
        port_a.input.we <= '0';
        wait until rising_edge(clk); -- 50
        port_a.input.addr <= 0;
        wait until rising_edge(clk); -- 60
        port_a.input.addr <= 1;
        wait until rising_edge(clk); -- 70
        assert port_a.output.data = slice2 severity FAILURE;
        wait until rising_edge(clk); -- 80
        assert port_a.output.data = slice0 severity FAILURE;
        wait until rising_edge(clk); -- 90
        assert port_a.output.data = slice1 severity FAILURE;

        finished <= true;
        wait;
    end process;

end architecture;