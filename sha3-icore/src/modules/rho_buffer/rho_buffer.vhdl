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
        gam_port_a_out : in mem_port_output;
        gam_port_b_in : out mem_port_input;
        gam_port_b_out : in mem_port_output;
        res_port_a_in : out mem_port_input;
        res_port_a_out : in mem_port_output;
        res_port_b_in : out mem_port_input;
        res_port_b_out : in mem_port_output;
        ready : out std_logic
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
            clk : in std_logic;
            atom_index : in atom_index_t;
            right_shift : in std_logic;
            data_in : in rho_calc_t;
            data_out : out rho_calc_t;
            filtered_in : in multi_buffer_data_t;
            filtered_out : out multi_buffer_data_t
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
            res_we : out std_logic;
            ready : out std_logic
        );
    end component;


    signal ctl_right_shift : std_logic;
    signal ctl_addr : mem_addr_t;
    signal ctl_gam_en : std_logic;
    signal ctl_gam_we : std_logic;
    signal ctl_res_en : std_logic;
    signal ctl_res_we : std_logic;

    signal gam_a, gam_b, res_a, res_b : mem_port := mem_port_init;

    signal data_from_mem : rho_calc_t;
    signal data_to_mem : rho_calc_t;
    signal filtered_from_mem : multi_buffer_data_t;
    signal filtered_to_mem : multi_buffer_data_t;

    signal addr_high, addr_low : mem_addr_t;
    signal gam_en, gam_we, res_en, res_we : std_logic;

    signal data_to_mem0, data_to_mem1, data_to_mem2, data_to_mem3 : tile_slice_t;

begin

    data_to_mem0 <= data_to_mem(0);
    data_to_mem1 <= data_to_mem(1);
    data_to_mem2 <= data_to_mem(2);
    data_to_mem3 <= data_to_mem(3);

    -- linking ports with interface
    gam_port_a_in <= gam_a.input;
    gam_port_b_in <= gam_b.input;
    res_port_a_in <= res_a.input;
    res_port_b_in <= res_b.input;
    gam_a.output <= gam_port_a_out;
    gam_b.output <= gam_port_b_out;
    res_a.output <= res_port_a_out;
    res_b.output <= res_port_b_out;

    -- combine data from both memory blocks since only one is reading at a time
    data_from_mem <= (gam_b.output.data(1) or res_b.output.data(1),
                      gam_b.output.data(0) or res_b.output.data(0),
                      gam_a.output.data(1) or res_a.output.data(1),
                      gam_a.output.data(0) or res_a.output.data(0));

    -- calculating addresses for the different ports from the controller address
    addr_high <= 2 * ctl_addr + 1 when enable = '1' else 0;
    addr_low <=  2 * ctl_addr     when enable = '1' else 0;

    -- calculate enable and write signals from the controller signals
    gam_en <= ctl_gam_en and enable;
    gam_we <= ctl_gam_we and enable;
    res_en <= ctl_res_en and enable;
    res_we <= ctl_res_we and enable;

    -- link addresses, control signals and data to the port inputs
    gam_a.input <= (addr => addr_low,  data => (data_to_mem(1), data_to_mem(0)), en => gam_en, we => gam_we);
    gam_b.input <= (addr => addr_high, data => (data_to_mem(3), data_to_mem(2)), en => gam_en, we => gam_we);
    res_a.input <= (addr => addr_low,  data => (data_to_mem(1), data_to_mem(0)), en => res_en, we => res_we);
    res_b.input <= (addr => addr_high, data => (data_to_mem(3), data_to_mem(2)), en => res_en, we => res_we);

    filter : rho_buffer_filter port map(
        clk => clk,
        atom_index => atom_index,
        right_shift => ctl_right_shift,
        data_in => data_from_mem,
        data_out => data_to_mem,
        filtered_in => filtered_to_mem,
        filtered_out => filtered_from_mem);

    buf : multi_lane_buffer port map(
        clk => clk,
        atom_index => atom_index,
        right_shift => ctl_right_shift,
        input => filtered_from_mem,
        output => filtered_to_mem);
    
    control : rho_controller port map(
        clk => clk,
        init => init,
        enable => enable,
        right_shift => ctl_right_shift,
        addr => ctl_addr,
        gam_en => ctl_gam_en,
        gam_we => ctl_gam_we,
        res_en => ctl_res_en,
        res_we => ctl_res_we,
        ready => ready);

end architecture;