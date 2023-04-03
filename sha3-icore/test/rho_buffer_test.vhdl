library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
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
            gam_port_a_out : in tile_computation_data_t;
            gam_port_b_in : out mem_port_input;
            gam_port_b_out : in tile_computation_data_t;
            res_port_a_in : out mem_port_input;
            res_port_a_out : in tile_computation_data_t;
            res_port_b_in : out mem_port_input;
            res_port_b_out : in tile_computation_data_t
        );
    end component;

    component manual_port_memory_block is
        port(
            clk : in std_logic;
            manual : in std_logic;
            manual_in : in mem_port_input;
            port_a_in : in mem_port_input;
            port_a_out : out tile_computation_data_t;
            port_b_in : in mem_port_input;
            port_b_out : out tile_computation_data_t
        );
    end component;

    component block_visualizer is
        port(state : in block_t);
    end component;

    signal clk : std_logic := '0';
    signal finished : boolean := false;

    signal gam_a_in, gam_b_in, res_a_in, res_b_in : mem_port_input;
    signal gam_a_out, gam_b_out, res_a_out, res_b_out : tile_computation_data_t;

    signal init : std_logic := '0';
    signal enable : std_logic := '0';
    signal atom_index : atom_index_t := 0;
    signal gam_manual : std_logic := '0';
    signal res_manual : std_logic := '0';
    signal manual_in : mem_port_input := (addr => 0, data => (others => (others => '0')), en => '0', we => '0');

    signal initial_state : block_t;

    signal gam_a_out_0, gam_a_out_1 : tile_slice_t;
    signal manual_in_0, manual_in_1 : tile_slice_t;

begin

    initial_visual : block_visualizer port map(initial_state);

    gam_mem : manual_port_memory_block port map(clk, gam_manual, manual_in, gam_a_in, gam_a_out, gam_b_in, gam_b_out);
    res_mem : manual_port_memory_block port map(clk, res_manual, manual_in, res_a_in, res_a_out, res_b_in, res_b_out);

    buf : rho_buffer port map(clk, init, enable, atom_index, gam_a_in, gam_a_out, gam_b_in, gam_b_out, res_a_in, res_a_out, res_b_in, res_b_out);

    gam_a_out_0 <= gam_a_out(0);
    gam_a_out_1 <= gam_a_out(1);
    manual_in_0 <= manual_in.data(0);
    manual_in_1 <= manual_in.data(1);

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
        wait until rising_edge(clk);
        gam_manual <= '1';
        manual_in.en <= '1';
        manual_in.we <= '1';
        for i in 0 to 31 loop
            manual_in.data <= (get_slice_tile(initial_state, i * 2 + 1), get_slice_tile(initial_state, i * 2));
            manual_in.addr <= i;
            wait until rising_edge(clk);
        end loop;
        manual_in.we <= '0';
        for i in 0 to 31 loop
            manual_in.addr <= i;
            wait until rising_edge(clk);
            assert gam_a_out = (get_slice_tile(initial_state, i * 2 + 1), get_slice_tile(initial_state, i * 2));
        end loop;

        finished <= true;
        wait;
    end process;

end architecture;