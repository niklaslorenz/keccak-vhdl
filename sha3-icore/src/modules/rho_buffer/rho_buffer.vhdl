library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.util.all;
use work.multi_lane_buffer;
use work.rho_buffer_filter;
use work.rho_controller;

entity rho_buffer is
    port(
        clk : in std_logic;
        init : in std_logic;
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
            input : in buffer_data_t;
            output : out buffer_data_t
        );
    end component;

    component rho_buffer_filter is
        port(
            clk : in std_logic;
            atom_index : in atom_index_t;
            right_shift : in std_logic;
            data_in : in quad_tile_slice_t;
            data_out : out quad_tile_slice_t;
            filtered_in : in buffer_data_t;
            filtered_out : out buffer_data_t
        );
    end component;

    component rho_controller is
        port(
            clk : in std_logic;
            init : in std_logic;
            right_shift : out std_logic;
            addr_high : out mem_addr_t;
            addr_low : out mem_addr_t;
            gam_en : out std_logic;
            gam_we : out std_logic;
            res_en : out std_logic;
            res_we : out std_logic;
            ready : out std_logic
        );
    end component;

    signal running : boolean;
    signal right_shift : std_logic;

    signal ctl_ready : std_logic;

    signal addr_high : mem_addr_t;
    signal addr_low : mem_addr_t;
    signal gam_en : std_logic;
    signal gam_we : std_logic;
    signal res_en : std_logic;
    signal res_we : std_logic;

    signal data_from_mem : quad_tile_slice_t;
    signal data_to_mem : quad_tile_slice_t;
    signal filtered_from_mem : buffer_data_t;
    signal filtered_to_mem : buffer_data_t;

    signal data_to_mem0, data_to_mem1, data_to_mem2, data_to_mem3 : tile_slice_t; -- TODO: Debug signals

begin

    running <= ctl_ready /= '1';

    data_to_mem0 <= data_to_mem(0);
    data_to_mem1 <= data_to_mem(1);
    data_to_mem2 <= data_to_mem(2);
    data_to_mem3 <= data_to_mem(3);

    -- combine data from both memory blocks since only one is reading at a time
    data_from_mem <= (gam_port_b_out.data(1) or res_port_b_out.data(1),
                      gam_port_b_out.data(0) or res_port_b_out.data(0),
                      gam_port_a_out.data(1) or res_port_a_out.data(1),
                      gam_port_a_out.data(0) or res_port_a_out.data(0));

    -- link addresses, control signals and data to the port inputs
    gam_port_a_in <= (addr => addr_low,  data => filterData((data_to_mem(1), data_to_mem(0)), running), en => gam_en, we => gam_we);
    gam_port_b_in <= (addr => addr_high, data => filterData((data_to_mem(3), data_to_mem(2)), running), en => gam_en, we => gam_we);
    res_port_a_in <= (addr => addr_low,  data => filterData((data_to_mem(1), data_to_mem(0)), running), en => res_en, we => res_we);
    res_port_b_in <= (addr => addr_high, data => filterData((data_to_mem(3), data_to_mem(2)), running), en => res_en, we => res_we);

    ready <= ctl_ready;

    filter : rho_buffer_filter port map(
        clk => clk,
        atom_index => atom_index,
        right_shift => right_shift,
        data_in => data_from_mem,
        data_out => data_to_mem,
        filtered_in => filtered_to_mem,
        filtered_out => filtered_from_mem);

    buf : multi_lane_buffer port map(
        clk => clk,
        atom_index => atom_index,
        right_shift => right_shift,
        input => filtered_from_mem,
        output => filtered_to_mem);
    
    control : rho_controller port map(
        clk => clk,
        init => init,
        right_shift => right_shift,
        addr_high => addr_high,
        addr_low => addr_low,
        gam_en => gam_en,
        gam_we => gam_we,
        res_en => res_en,
        res_we => res_we,
        ready => ctl_ready);

end architecture;