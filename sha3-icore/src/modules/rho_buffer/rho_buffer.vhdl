library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
use work.multi_lane_buffer;
use work.rho_buffer_filter;
use work.rho_controller;

entity rho_buffer is
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
end entity;

architecture arch of rho_buffer is

    component multi_lane_buffer is
        port(
            clk : in std_logic;
            atom_index : atom_index_t;
            right_shift : in std_logic;
            input : in multi_buffer_data_t;
            output : out multi_buffer_data_t
        );
    end component;

    component rho_buffer_filter is
        port(
            atom_index : in atom_index_t;
            right_shift : in std_logic;
            data_in : in rho_calc_t;
            buffer_out : in multi_buffer_data_t;
            data_out : out rho_calc_t;
            buffer_in : out multi_buffer_data_t
        );
    end component;

    component rho_controller is
        port(
            clk : in std_logic;
            init : in std_logic;
            enable : in std_logic;
            right_shift : out std_logic;
            addr : out mem_addr_t;
            gam_en : out std_logic;
            gam_we : out std_logic;
            res_en : out std_logic;
            res_we : out std_logic
        );
    end component;

    signal filtered_data_in : multi_buffer_data_t;
    signal filtered_data_out : multi_buffer_data_t;

    signal ctl_right_shift : std_logic;
    signal ctl_addr : mem_addr_t;
    signal ctl_gam_en : std_logic;
    signal ctl_gam_we : std_logic;
    signal ctl_res_en : std_logic;
    signal ctl_res_we : std_logic;

    signal mem_data_out : rho_calc_t;
    signal mem_data_in : rho_calc_t;

begin

    mem_data_out <= (gam_port_b_out(1) or res_port_b_out(1),
                            gam_port_b_out(0) or res_port_b_out(0),
                            gam_port_a_out(1) or res_port_a_out(1),
                            gam_port_a_out(0) or res_port_a_out(0));

    gam_port_a_in.addr <= ctl_addr when enable = '1' else 0;
    gam_port_b_in.addr <= ctl_addr + 1 when enable = '1' else 0;
    res_port_a_in.addr <= ctl_addr when enable = '1' else 0;
    res_port_b_in.addr <= ctl_addr + 1 when enable = '1' else 0;

    gam_port_a_in.en <= ctl_gam_en and enable;
    gam_port_b_in.en <= ctl_gam_en and enable;
    res_port_a_in.en <= ctl_res_en and enable;
    res_port_b_in.en <= ctl_res_en and enable;

    gam_port_a_in.we <= ctl_gam_we and enable;
    gam_port_b_in.we <= ctl_gam_we and enable;
    res_port_a_in.we <= ctl_res_we and enable;
    res_port_b_in.we <= ctl_res_we and enable;

    gam_port_a_in.data <= (mem_data_in(1), mem_data_in(0));
    gam_port_b_in.data <= (mem_data_in(3), mem_data_in(2));
    res_port_a_in.data <= (mem_data_in(1), mem_data_in(0));
    res_port_b_in.data <= (mem_data_in(3), mem_data_in(2));

    filter : rho_buffer_filter port map(atom_index, ctl_right_shift, mem_data_out, filtered_data_out, mem_data_in, filtered_data_in);

    buf : multi_lane_buffer port map(clk, atom_index, ctl_right_shift, filtered_data_in, filtered_data_out);
    
    control : rho_controller port map(clk, init, enable, ctl_right_shift, ctl_addr, ctl_gam_en, ctl_gam_we, ctl_res_en, ctl_res_we);

end architecture arch;