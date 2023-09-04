library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.util.all;
use work.gamma_calculator;
use work.manual_port_memory_block;
use work.test_types.all;
use work.test_data;
use work.test_util.all;

entity gamma_calculator_test is
end entity;

architecture arch of gamma_calculator_test is

    component manual_port_memory_block is
        port(
            clk : in std_logic;
            manual : in std_logic;
            manual_in : in mem_port_input;
            port_a_in : in mem_port_input;
            port_a_out : out mem_port_output;
            port_b_in : in mem_port_input;
            port_b_out : out mem_port_output
        );
    end component;

    component gamma_calculator is
        port(
            clk : in std_logic;
            init : in std_logic;
            atom_index : in atom_index_t;
            round : in round_index_t;
            theta_only : in std_logic;
            no_theta : in std_logic;
            res_mem_port_a_in : out mem_port_input;
            res_mem_port_a_out : in mem_port_output;
            res_mem_port_b_in : out mem_port_input;
            res_mem_port_b_out : in mem_port_output;
            gam_mem_port_a_in : out mem_port_input;
            gam_mem_port_b_in : out mem_port_input;
            transmission_in : in transmission_t;
            transmission_out : out transmission_t;
            ready : out std_logic
        );
    end component;

    component block_visualizer is
        port(state : in block_t);
    end component;

    signal clk : std_logic := '0';
    signal finished : boolean := false;

    signal atom_0_gam_manual : std_logic := '0';
    signal atom_0_res_manual : std_logic := '0';
    signal atom_0_gam_manual_in : mem_port_input := mem_port_init.input;
    signal atom_0_res_manual_in : mem_port_input := mem_port_init.input;

    signal atom_0_gam_a : mem_port := mem_port_init;
    signal atom_0_gam_b : mem_port := mem_port_init;
    signal atom_0_res_a : mem_port := mem_port_init;
    signal atom_0_res_b : mem_port := mem_port_init;

    signal atom_1_gam_manual : std_logic := '0';
    signal atom_1_res_manual : std_logic := '0';
    signal atom_1_gam_manual_in : mem_port_input := mem_port_init.input;
    signal atom_1_res_manual_in : mem_port_input := mem_port_init.input;

    signal atom_1_gam_a : mem_port := mem_port_init;
    signal atom_1_gam_b : mem_port := mem_port_init;
    signal atom_1_res_a : mem_port := mem_port_init;
    signal atom_1_res_b : mem_port := mem_port_init;

    signal init : std_logic := '0';
    signal round : round_index_t := 0;
    signal theta_only : std_logic := '0';
    signal no_theta : std_logic := '0';
    signal atom_0_ready : std_logic := '0';
    signal atom_1_ready : std_logic := '0';

    signal atom_0_transmission_in : transmission_t := (others => '0');
    signal atom_0_transmission_out : transmission_t := (others => '0');
    signal atom_1_transmission_in : transmission_t := (others => '0');
    signal atom_1_transmission_out : transmission_t := (others => '0');

    signal theta_only_result_0, theta_only_result_1 : block_t;

    signal gamma_result_0, gamma_result_1 : block_t;

begin

    input_visual_0_visual : block_visualizer port map(test_data.test_block_0);

    input_visual_1_visual : block_visualizer port map(test_data.test_block_1);

    theta_only_result_0_visual : block_visualizer port map(theta_only_result_0);

    theta_only_result_1_visual : block_visualizer port map(theta_only_result_1);

    theta_only_expectation_0_visual : block_visualizer port map(test_data.theta_result_0);

    theta_only_expectation_1_visual : block_visualizer port map(test_data.theta_result_1);

    gamma_result_0_visual : block_visualizer port map(gamma_result_0);

    gamma_result_1_visual : block_visualizer port map(gamma_result_1);

    gamma_expectation_0_visual : block_visualizer port map(test_data.gamma_result_0);

    gamma_expectation_1_visual : block_visualizer port map(test_data.gamma_result_1);

    atom_0_gam_mem : manual_port_memory_block port map(
        clk => clk,
        manual => atom_0_gam_manual,
        manual_in => atom_0_gam_manual_in,
        port_a_in => atom_0_gam_a.input,
        port_a_out => atom_0_gam_a.output,
        port_b_in => atom_0_gam_b.input,
        port_b_out => atom_0_gam_b.output
    );

    atom_0_res_mem : manual_port_memory_block port map(
        clk => clk,
        manual => atom_0_res_manual,
        manual_in => atom_0_res_manual_in,
        port_a_in => atom_0_res_a.input,
        port_a_out => atom_0_res_a.output,
        port_b_in => atom_0_res_b.input,
        port_b_out => atom_0_res_b.output
    );

    atom_0_calc : gamma_calculator port map(
        clk => clk,
        init => init,
        atom_index => 0,
        round => round,
        theta_only => theta_only,
        no_theta => no_theta,
        res_mem_port_a_in => atom_0_res_a.input,
        res_mem_port_a_out => atom_0_res_a.output,
        res_mem_port_b_in => atom_0_res_b.input,
        res_mem_port_b_out => atom_0_res_b.output,
        gam_mem_port_a_in => atom_0_gam_a.input,
        gam_mem_port_b_in => atom_0_gam_b.input,
        transmission_in => atom_0_transmission_in,
        transmission_out => atom_0_transmission_out,
        ready => atom_0_ready
    );

    atom_1_gam_mem : manual_port_memory_block port map(
        clk => clk,
        manual => atom_1_gam_manual,
        manual_in => atom_1_gam_manual_in,
        port_a_in => atom_1_gam_a.input,
        port_a_out => atom_1_gam_a.output,
        port_b_in => atom_1_gam_b.input,
        port_b_out => atom_1_gam_b.output
    );

    atom_1_res_mem : manual_port_memory_block port map(
        clk => clk,
        manual => atom_1_res_manual,
        manual_in => atom_1_res_manual_in,
        port_a_in => atom_1_res_a.input,
        port_a_out => atom_1_res_a.output,
        port_b_in => atom_1_res_b.input,
        port_b_out => atom_1_res_b.output
    );

    atom_1_calc : gamma_calculator port map(
        clk => clk,
        init => init,
        atom_index => 1,
        round => round,
        theta_only => theta_only,
        no_theta => no_theta,
        res_mem_port_a_in => atom_1_res_a.input,
        res_mem_port_a_out => atom_1_res_a.output,
        res_mem_port_b_in => atom_1_res_b.input,
        res_mem_port_b_out => atom_1_res_b.output,
        gam_mem_port_a_in => atom_1_gam_a.input,
        gam_mem_port_b_in => atom_1_gam_b.input,
        transmission_in => atom_1_transmission_in,
        transmission_out => atom_1_transmission_out,
        ready => atom_1_ready
    );

    env : process(clk) is
    begin
        if rising_edge(clk) then
            atom_0_transmission_in <= atom_1_transmission_out;
            atom_1_transmission_in <= atom_0_transmission_out;
        end if;
    end process;

    test : process is
        variable slice0, slice1 : slice_t;
        variable theta_slice : slice_t;
    begin
        -- read test data into memory
        wait until rising_edge(clk);
        atom_0_res_manual <= '1';
        atom_1_res_manual <= '1';
        atom_0_res_manual_in.we <= '1';
        atom_1_res_manual_in.we <= '1';
        for i in 0 to 31 loop
            atom_0_res_manual_in.addr <= i;
            atom_1_res_manual_in.addr <= i;
            atom_0_res_manual_in.data <= get_double_tile_slice(test_data.test_block_0, i);
            atom_1_res_manual_in.data <= get_double_tile_slice(test_data.test_block_1, i);
            wait until rising_edge(clk);
        end loop;
        atom_0_res_manual <= '0';
        atom_1_res_manual <= '0';
        atom_0_res_manual_in <= mem_port_init.input;
        atom_1_res_manual_in <= mem_port_init.input;
        wait until rising_edge(clk);
        -- test theta only
        init <= '1';
        theta_only <= '1';
        wait until rising_edge(clk);
        init <= '0';
        while atom_0_ready = '0' loop
            wait until rising_edge(clk);
        end loop;
        assert atom_1_ready = '1' report "expected atom 1 to be ready" severity FAILURE;
        atom_0_gam_manual <= '1';
        atom_1_gam_manual <= '1';
        atom_0_gam_manual_in.en <= '1';
        atom_1_gam_manual_in.en <= '1';
        for i in 0 to 33 loop
            if i <= 31 then
                atom_0_gam_manual_in.addr <= i;
                atom_1_gam_manual_in.addr <= i;
            end if;
            wait until rising_edge(clk);
            if i >= 2 then
                theta_only_result_0(2 * (i - 2) + 1) <= atom_0_gam_a.output.data(1);
                theta_only_result_0(2 * (i - 2))     <= atom_0_gam_a.output.data(0);
                theta_only_result_1(2 * (i - 2) + 1) <= atom_1_gam_a.output.data(1);
                theta_only_result_1(2 * (i - 2))     <= atom_1_gam_a.output.data(0);
            end if;
        end loop;
        atom_0_gam_manual <= '0';
        atom_1_gam_manual <= '0';
        atom_0_gam_manual_in <= mem_port_init.input;
        atom_1_gam_manual_in <= mem_port_init.input;
        wait until rising_edge(clk);
        -- check theta only result
        for i in 0 to 63 loop
            assert test_data.theta_result_0(i) = theta_only_result_0(i) report "Theta only failed for atom 0" severity FAILURE;
            assert test_data.theta_result_1(i) = theta_only_result_1(i) report "Theta only failed for atom 1" severity FAILURE;
        end loop;

        -- test gamma
        init <= '1';
        theta_only <= '0';
        round <= 5;
        wait until rising_edge(clk);
        init <= '0';
        wait until rising_edge(clk);
        while atom_0_ready = '0' loop
            wait until rising_edge(clk);
        end loop;
        assert atom_1_ready = '1' report "expected atom 1 to be ready" severity FAILURE;
        
        -- read gamma result
        atom_0_gam_manual <= '1';
        atom_1_gam_manual <= '1';
        atom_0_gam_manual_in.en <= '1';
        atom_1_gam_manual_in.en <= '1';
        for i in 0 to 33 loop
            if i <= 31 then
                atom_0_gam_manual_in.addr <= i;
                atom_1_gam_manual_in.addr <= i;
            end if;
            wait until rising_edge(clk);
            if i >= 2 then
                gamma_result_0(2 * (i - 2) + 1) <= atom_0_gam_a.output.data(1);
                gamma_result_0(2 * (i - 2))     <= atom_0_gam_a.output.data(0);
                gamma_result_1(2 * (i - 2) + 1) <= atom_1_gam_a.output.data(1);
                gamma_result_1(2 * (i - 2))     <= atom_1_gam_a.output.data(0);
            end if;
        end loop;
        atom_0_gam_manual <= '0';
        atom_1_gam_manual <= '0';
        atom_0_gam_manual_in <= mem_port_init.input;
        atom_1_gam_manual_in <= mem_port_init.input;
        wait until rising_edge(clk);

        -- check gamma result
        for i in 0 to 63 loop
            assert test_data.gamma_result_0(i) = gamma_result_0(i) report "Gamma failed for atom 0" severity FAILURE;
            assert test_data.gamma_result_1(i) = gamma_result_1(i) report "Gamma failed for atom 1" severity FAILURE;
        end loop;

        wait until rising_edge(clk);
        finished <= true;
        wait;
    end process;

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

end architecture arch;