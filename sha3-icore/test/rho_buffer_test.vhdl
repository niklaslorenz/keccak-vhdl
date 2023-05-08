library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.test_types.all;
use work.test_util.all;
use work.rho_buffer;
use work.manual_port_memory_block;

entity rho_buffer_test is
end entity;

architecture arch of rho_buffer_test is

    component rho_buffer is
        port(
            clk : in std_logic;
            init : in std_logic;
            enable : in std_logic;
            atom_index : in atom_index_t;
            gam_port_a_in : out mem_port_input;
            gam_port_a_out : in mem_port_output;
            gam_port_b_in : out mem_port_input;
            gam_port_b_out : in mem_port_output;
            res_port_a_in : out mem_port_input;
            res_port_a_out : in mem_port_output;
            res_port_b_in : out mem_port_input;
            res_port_b_out : in mem_port_output;
            ready : out std_logic
        );
    end component;

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

    component block_visualizer is
        port(state : in block_t);
    end component;

    type stage_t is (initialize, shift, read_left_shift_result, read_right_shift_result);
    signal stage : stage_t := initialize;

    signal clk : std_logic := '0';
    signal finished : boolean := false;

    signal gam_a, gam_b, res_a, res_b : mem_port := mem_port_init;

    signal init : std_logic := '0';
    signal enable : std_logic := '0';
    signal atom_index : atom_index_t := 0;
    signal ready : std_logic;
    signal gam_manual : std_logic := '0';
    signal res_manual : std_logic := '0';
    signal manual_in : mem_port_input := mem_port_init.input;

    signal initial_state, ls_result, lrs_result, ls_expectation, lrs_expectation : block_t;

    signal gam_a_out_0, gam_a_out_1 : tile_slice_t;

begin

    initial_visual : block_visualizer port map(initial_state);
    ls_result_visual : block_visualizer port map(ls_result);
    lrs_result_visual : block_visualizer port map(lrs_result);

    gam_mem : manual_port_memory_block port map(clk, gam_manual, manual_in, gam_a.input, gam_a.output, gam_b.input, gam_b.output);
    res_mem : manual_port_memory_block port map(clk, res_manual, manual_in, res_a.input, res_a.output, res_b.input, res_b.output);

    buf : rho_buffer port map(clk, init, enable, atom_index,
        gam_a.input, gam_a.output, gam_b.input, gam_b.output,
        res_a.input, res_a.output, res_b.input, res_b.output,
        ready);

    gam_a_out_0 <= gam_a.output.data(0);
    gam_a_out_1 <= gam_a.output.data(1);
    
    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    test : process is
        variable temp_state : block_t;
        variable temp_ls_expectation, temp_lrs_expectation : block_t;
    begin
        wait until rising_edge(clk);
        set_lane(temp_state,  0, x"fc09dc55ea64707e");
        set_lane(temp_state,  1, x"31727c62ccc930c1");
        set_lane(temp_state,  2, x"0a7346af6cfa6a2c");
        set_lane(temp_state,  3, x"45ecb35b9a49bb05");
        set_lane(temp_state,  4, x"18a3f9bc1e4a8c4f");
        set_lane(temp_state,  5, x"d97c8d02ec0d7547");
        set_lane(temp_state,  6, x"24a535c923dd9dc6");
        set_lane(temp_state,  7, x"1998bea97361cb1c");
        set_lane(temp_state,  8, x"b6e88d08da3369d8");
        set_lane(temp_state,  9, x"19ada08eb2f776f4");
        set_lane(temp_state, 10, x"236977ac8a2ba5a8");
        set_lane(temp_state, 11, x"5d34c3d65d3b71eb");
        set_lane(temp_state, 12, x"c19981b38c60aaa2");
        initial_state <= temp_state;

        set_lane(temp_ls_expectation,  0, x"FC09DC55EA64707E");
        set_lane(temp_ls_expectation,  1, x"62E4F8C599926182");
        set_lane(temp_ls_expectation,  2, x"0A7346AF6CFA6A2C");
        set_lane(temp_ls_expectation,  3, x"B9A49BB0545ECB35");
        set_lane(temp_ls_expectation,  4, x"E0F2546278C51FCD");
        set_lane(temp_ls_expectation,  5, x"D97C8D02EC0D7547");
        set_lane(temp_ls_expectation,  6, x"24A535C923DD9DC6");
        set_lane(temp_ls_expectation,  7, x"662FAA5CD872C706");
        set_lane(temp_ls_expectation,  8, x"B6E88D08DA3369D8");
        set_lane(temp_ls_expectation,  9, x"08EB2F776F419ADA");
        set_lane(temp_ls_expectation, 10, x"1B4BBD64515D2D41");
        set_lane(temp_ls_expectation, 11, x"D30F5974EDC7AD74");
        set_lane(temp_ls_expectation, 12, x"C19981B38C60AAA2");
        ls_expectation <= temp_ls_expectation;

        set_lane(temp_lrs_expectation,  0, x"FC09DC55EA64707E");
        set_lane(temp_lrs_expectation,  1, x"62E4F8C599926182");
        set_lane(temp_lrs_expectation,  2, x"029CD1ABDB3E9A8B");
        set_lane(temp_lrs_expectation,  3, x"B9A49BB0545ECB35");
        set_lane(temp_lrs_expectation,  4, x"E0F2546278C51FCD");
        set_lane(temp_lrs_expectation,  5, x"C0D7547D97C8D02E");
        set_lane(temp_lrs_expectation,  6, x"D9DC624A535C923D");
        set_lane(temp_lrs_expectation,  7, x"662FAA5CD872C706");
        set_lane(temp_lrs_expectation,  8, x"EC5b7446846D19B4");
        set_lane(temp_lrs_expectation,  9, x"08EB2F776F419ADA");
        set_lane(temp_lrs_expectation, 10, x"1B4BBD64515D2D41");
        set_lane(temp_lrs_expectation, 11, x"D30F5974EDC7AD74");
        set_lane(temp_lrs_expectation, 12, x"0555160CCC0D9C63");
        lrs_expectation <= temp_lrs_expectation;
        wait until rising_edge(clk);
        -- Write initial data into gam_mem
        gam_manual <= '1';
        manual_in.en <= '1';
        manual_in.we <= '1';
        for i in 0 to 31 loop
            manual_in.data <= (get_slice_tile(initial_state, i * 2 + 1), get_slice_tile(initial_state, i * 2));
            manual_in.addr <= i;
            wait until rising_edge(clk);
        end loop;
        manual_in.we <= '0';
        gam_manual <= '0';
        -- Calculate shifts, left shift result should be in gam_mem from address 6, right shift in res_mem from address 0
        stage <= shift;
        enable <= '1';
        init <= '1';
        wait until rising_edge(clk);
        init <= '0';
        while ready /= '1' loop
            wait until rising_edge(clk);
        end loop;
        -- read gam_mem into ls_result
        stage <= read_left_shift_result;
        gam_manual <= '1';
        manual_in <= mem_port_init.input;
        manual_in.en <= '1';
        wait until rising_edge(clk);
        for i in 0 to 33 loop
            if i <= 31 then
                manual_in.addr <= i + 6;
            end if;
            wait until rising_edge(clk);
            if i >= 2 then
                ls_result(2 * (i - 2)) <= gam_a.output.data(0);
                ls_result(2 * (i - 2) + 1) <= gam_a.output.data(1);
            end if;
        end loop;
        gam_manual <= '0';
        wait until rising_edge(clk);
        -- read res_mem into lrs_result
        stage <= read_right_shift_result;
        res_manual <= '1';
        manual_in <= mem_port_init.input;
        manual_in.en <= '1';
        wait until rising_edge(clk);
        for i in 0 to 33 loop
            if i <= 31 then
                manual_in.addr <= i;
            end if;
            wait until rising_edge(clk);
            if i >= 2 then
                lrs_result(2 * (i - 2)) <= res_a.output.data(0);
                lrs_result(2 * (i - 2) + 1) <= res_a.output.data(1);
            end if;
        end loop;
        res_manual <= '0';
        wait until rising_edge(clk);
        -- check results
        for i in 0 to 63 loop
            assert ls_expectation(i) = ls_result(i) report "Wrong left shift result" severity FAILURE;
        end loop;
        for i in 0 to 63 loop
            assert lrs_expectation(i) = lrs_result(i) report "Wrong right shift result" severity FAILURE;
        end loop;
        finished <= true;
        wait;
    end process;

end architecture;