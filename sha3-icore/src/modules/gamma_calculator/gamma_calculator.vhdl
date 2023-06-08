library IEEE;

use IEEE.std_logic_1164.all;
use work.types.all;
use work.clocked_double_slice_calculator;
use work.calculator_controller;

entity gamma_calculator is
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
end entity;

architecture arch of gamma_calculator is

    component calculator_transmission_converter is
        port(
            running : in std_logic;
            transmission_in : in transmission_t;
            transmission_out : out transmission_t;
            data_slice_receive : out double_tile_slice_t;
            result_slice_receive : out double_tile_slice_t;
            data_slice_send : in double_tile_slice_t;
            result_slice_send : in double_tile_slice_t
        );
    end component;

    component calculator_data_combiner is
        port(
            atom_index : in atom_index_t;
            running : in std_logic;
            data : out double_slice_t;
            remote_data : in double_tile_slice_t;
            local_data : in double_tile_slice_t;
            result : in double_slice_t;
            remote_result : out double_tile_slice_t;
            local_result : out double_tile_slice_t
        );
    end component;

    component calculator_controller is
        port(
            clk : in std_logic;
            init : in std_logic;
            atom_index : in atom_index_t;
            round : in round_index_t;
            round_constant_slice : out std_logic_vector(1 downto 0);
            res_a_en : out std_logic;
            res_a_addr : out mem_addr_t;
            res_b_en : out std_logic;
            res_b_addr : out mem_addr_t;
            gam_a_en : out std_logic;
            gam_a_we : out std_logic;
            gam_a_addr : out mem_addr_t;
            gam_b_en : out std_logic;
            gam_b_we : out std_logic;
            gam_b_addr : out mem_addr_t;
            ready : out std_logic
        );
    end component;

    component clocked_double_slice_calculator is
        port(
            clk : in std_logic;
            data : in double_slice_t;
            theta_only : in std_logic;
            no_theta : in std_logic;
            round_constant : in std_logic_vector(1 downto 0);
            result : out double_slice_t
        );
    end component;

    signal running : std_logic;
    signal ctl_ready : std_logic;

    signal round_constant : std_logic_vector(1 downto 0);

    -- data
    signal received_data : double_tile_slice_t;
    signal received_result : double_tile_slice_t;

    signal combined_data : double_slice_t;

    signal combined_data_0 : slice_t;
    signal combined_data_1 : slice_t;

    signal result : double_slice_t;
    signal result_remote_part : double_tile_slice_t;

begin

    running <= not ctl_ready;
    ready <= ctl_ready;

    combined_data_0 <= combined_data(0);
    combined_data_1 <= combined_data(1);

    converter : calculator_transmission_converter port map(
        running => running,
        transmission_in => transmission_in,
        transmission_out => transmission_out,
        data_slice_receive => received_data,
        result_slice_receive => gam_mem_port_b_in.data,
        data_slice_send => res_mem_port_b_out.data,
        result_slice_send => result_remote_part
    );

    combiner : calculator_data_combiner port map(
        atom_index => atom_index,
        running => running,
        data => combined_data,
        remote_data => received_data,
        local_data => res_mem_port_a_out.data,
        result => result,
        remote_result => result_remote_part,
        local_result => gam_mem_port_a_in.data
    );

    controller : calculator_controller port map(
        clk => clk,
        init => init,
        atom_index => atom_index,
        round => round,
        round_constant_slice => round_constant,
        res_a_en => res_mem_port_a_in.en,
        res_a_addr => res_mem_port_a_in.addr,
        res_b_en => res_mem_port_b_in.en,
        res_b_addr => res_mem_port_b_in.addr,
        gam_a_en => gam_mem_port_a_in.en,
        gam_a_we => gam_mem_port_a_in.we,
        gam_a_addr => gam_mem_port_a_in.addr,
        gam_b_en => gam_mem_port_b_in.en,
        gam_b_we => gam_mem_port_b_in.we,
        gam_b_addr => gam_mem_port_b_in.addr,
        ready => ctl_ready
    );

    calc : clocked_double_slice_calculator port map(
        clk => clk,
        data => combined_data,
        theta_only => theta_only,
        no_theta => no_theta,
        round_constant => round_constant,
        result => result
    );

    res_mem_port_a_in.data <= ((others => '0'), (others => '0'));
    res_mem_port_a_in.we <= '0';
    
    res_mem_port_b_in.data <= ((others => '0'), (others => '0'));
    res_mem_port_b_in.we <= '0';

end architecture arch;