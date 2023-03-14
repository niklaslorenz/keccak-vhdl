library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.state.all;
use work.rho_manager;
use work.memory_block;
use work.slice_functions;

entity rho_manager_test is
end entity;

architecture arch of rho_manager_test is

    component memory_block is
        port(
            clk : in std_logic;
            port_a_in : in mem_port_input;
            port_a_out : out tile_computation_data_t;
            port_b_in : in mem_port_input;
            port_b_out : out tile_computation_data_t
        );
    end component;

    component rho_manager is
        port(
            clk : in std_logic;
            init : in std_logic;
            enable : in std_logic;
            atom_index : in atom_index_t;
            gam_mem_port_a_in : out mem_port_input;
            gam_mem_port_a_out : in tile_computation_data_t;
            gam_mem_port_b_in : out mem_port_input;
            gam_mem_port_b_out : in tile_computation_data_t;
            res_mem_port_a_in : out mem_port_input;
            res_mem_port_a_out : in tile_computation_data_t;
            res_mem_port_b_in : out mem_port_input;
            res_mem_port_b_out : in tile_computation_data_t
        );
    end component;

    component block_visualizer is
        port(state : in block_t);
    end component;

    signal clk : std_logic := '0';
    signal finished : boolean := false;
    signal manual : boolean := true;
    signal manual_gam_a_in : mem_port_input;



    signal mgr_gam_a_in : mem_port_input;

    signal gam_a_in : mem_port_input;
    signal gam_a_out : tile_computation_data_t;
    signal gam_b_in : mem_port_input;
    signal gam_b_out : tile_computation_data_t;

    signal res_a_in : mem_port_input;
    signal res_a_out : tile_computation_data_t;
    signal res_b_in : mem_port_input;
    signal res_b_out : tile_computation_data_t;

    signal init : std_logic;
    signal enable : std_logic;
    constant atom_index : atom_index_t := 0;

    signal test_data : block_t;
    signal expected : block_t;
    signal result : block_t;

begin

    test_data_visual : block_visualizer port map(test_data);
    expected_visual : block_visualizer port map(expected);
    result_visual : block_visualizer port map(result);

    gam_a_in <= mgr_gam_a_in when not manual else manual_gam_a_in;

    gam : memory_block port map(clk, gam_a_in, gam_a_out, gam_b_in, gam_b_out);
    res : memory_block port map(clk, res_a_in, res_a_out, res_b_in, res_b_out);
    manager : rho_manager port map(clk, init, enable, atom_index, mgr_gam_a_in, gam_a_out, gam_b_in, gam_b_out, res_a_in, res_a_out, res_b_in, res_b_out);

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    test : process is
        function rho(data : block_t) return block_t is
            variable res : block_t;
        begin
            res := data;
            slice_functions.rho(res, atom_index);
            return res;
        end function;
        variable data0, data1 : tile_slice_t;
    begin
        init <= '0';
        enable <= '0';
        wait until rising_edge(clk);
        manual_gam_a_in.en <= '1';
        manual_gam_a_in.we <= '1';
        for i in 0 to 31 loop
            if i = 0 then
                data0 := (others => '1');
            else
                data0 := (others => '0');
            end if;
            data1 := (others => '0');
            test_data(2 * i) <= data0;
            test_data(2 * i + 1) <= data1;
            manual_gam_a_in.addr <= i;
            manual_gam_a_in.data <= (data1, data0);
            wait until rising_edge(clk);
        end loop;
        expected <= rho(test_data);
        manual_gam_a_in.we <= '0';
        wait for 2ns;
        manual <= false;
        enable <= '1';
        init <= '1';
        wait until rising_edge(clk);
        init <= '0';
        for i in 0 to 36 loop
            wait until rising_edge(clk);
        end loop;
        enable <= '0';
        manual <= true;
        manual_gam_a_in.addr <= 4;
        wait until rising_edge(clk);
        for i in 0 to 31 loop
            manual_gam_a_in.addr <= i + 5;
            wait until rising_edge(clk);
            result(2 * i) <= gam_a_out(0);
            result(2 * i + 1) <= gam_a_out(1);
        end loop;
        finished <= true;
        wait;
    end process;

end architecture;