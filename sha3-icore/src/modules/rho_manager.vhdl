library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
use work.rho_manager_control_timings;
use work.rho_shift_buffer;

entity rho_manager is
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
end entity;

architecture arch of rho_manager is
    
    component rho_manager_control_timings is
        port(
            iterator : in rho_manager_iterator_t;
            enable : in std_logic;
            gam_mem_en : out std_logic;
            gam_mem_we : out std_logic;
            gam_mem_a_addr : out mem_addr_t;
            gam_mem_b_addr : out mem_addr_t;
            res_mem_en : out std_logic;
            res_mem_we : out std_logic;
            res_mem_a_addr : out mem_addr_t;
            res_mem_b_addr : out mem_addr_t;
            left_shift : out std_logic
        );
    end component;

    component rho_shift_buffer is
        Port (
            clk : in std_logic;
            atom_index : in atom_index_t;
            left_shift : in std_logic;
            data_in : in rho_calc_t;
            data_out : out rho_calc_t
        );
    end component;
    
    constant right_shift_offset : rho_manager_iterator_t := 40;

    signal iterator : rho_manager_iterator_t;

    signal gam_mem_din : rho_calc_t;
    signal gam_mem_dout : rho_calc_t;
    signal res_mem_din : rho_calc_t;
    signal res_mem_dout : rho_calc_t;

    signal tmg_gam_en : std_logic;
    signal tmg_gam_we : std_logic;
    signal tmg_gam_a_addr : mem_addr_t;
    signal tmg_gam_b_addr : mem_addr_t;
    signal tmg_res_en : std_logic;
    signal tmg_res_we : std_logic;
    signal tmg_res_a_addr : mem_addr_t;
    signal tmg_res_b_addr : mem_addr_t;

    signal buf_left_shift : std_logic;
    signal buf_data_in : rho_calc_t;
    signal buf_data_out : rho_calc_t;

begin

    -- Interface
    gam_mem_port_a_in.addr <= tmg_gam_a_addr;
    gam_mem_port_a_in.data <= tile_computation_data_t(gam_mem_din(1 downto 0));
    gam_mem_port_a_in.en <= tmg_gam_en;
    gam_mem_port_a_in.we <= tmg_gam_we;

    gam_mem_port_b_in.addr <= tmg_gam_b_addr;
    gam_mem_port_b_in.data <= tile_computation_data_t(gam_mem_din(3 downto 2));
    gam_mem_port_b_in.en <= tmg_gam_en;
    gam_mem_port_b_in.we <= tmg_gam_we;

    res_mem_port_a_in.addr <= tmg_res_a_addr;
    res_mem_port_a_in.data <= tile_computation_data_t(res_mem_din(1 downto 0));
    res_mem_port_a_in.en <= tmg_res_en;
    res_mem_port_a_in.we <= tmg_res_we;

    res_mem_port_b_in.addr <= tmg_res_b_addr;
    res_mem_port_b_in.data <= tile_computation_data_t(res_mem_din(3 downto 2));
    res_mem_port_b_in.en <= tmg_res_en;
    res_mem_port_b_in.we <= tmg_res_we;

    -- Combined Ports
    gam_mem_din <= buf_data_out;
    gam_mem_dout <= (gam_mem_port_b_out(1), gam_mem_port_b_out(0), gam_mem_port_a_out(1), gam_mem_port_a_out(0));

    res_mem_din <= buf_data_out;
    res_mem_dout <= (res_mem_port_b_out(1), res_mem_port_b_out(0), res_mem_port_a_out(1), res_mem_port_a_out(0));

    -- Timings
    timings : rho_manager_control_timings port map(iterator, enable,
        tmg_gam_en, tmg_gam_we, tmg_gam_a_addr, tmg_gam_b_addr,
        tmg_res_en, tmg_res_we, tmg_res_a_addr, tmg_res_b_addr);

    -- Buffer
    buf : rho_shift_buffer port map(clk, atom_index, buf_left_shift, buf_data_in, buf_data_out);
    buf_data_in <= gam_mem_dout;
    process(iterator) is
    begin
        if iterator < right_shift_offset then
            buf_left_shift <= '1';
        else
            buf_left_shift <= '0';
        end if;
    end process;

    -- Iterator
    process(clk) is
    begin
        if rising_edge(clk) and enable = '1' then
            if init = '1' then
                iterator <= 0;
            else
                iterator <= iterator + 1;
            end if;
        end if;
    end process;

end architecture;