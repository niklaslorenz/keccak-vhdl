library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;

entity rho_manager_control_timings is
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
end entity;

architecture arch of rho_manager_control_timings is
    constant pre_read_offset : rho_manager_iterator_t := 0;
    constant pre_read_duration : rho_manager_iterator_t := 8;
    constant normal_read_duration : rho_manager_iterator_t := 18;
    constant write_offset : rho_manager_iterator_t := 10;
    constant write_duration : rho_manager_iterator_t := 16;

    signal gam_mem_addr, res_mem_addr : mem_addr_t;
begin
    gam_mem_en <= enable;
    process(enable, gam_mem_addr, res_mem_addr) is
    begin
        if enable = '1' then
            gam_mem_a_addr <= 2 * gam_mem_addr;
            gam_mem_b_addr <= 2 * gam_mem_addr + 1;
            res_mem_a_addr <= 2 * res_mem_addr;
            res_mem_b_addr <= 2 * res_mem_addr + 1;
        else
            gam_mem_a_addr <= 0;
            gam_mem_b_addr <= 0;
            res_mem_a_addr <= 0;
            res_mem_b_addr <= 0;
        end if;
    end process;
    process(iterator, enable) is
    begin
        if iterator >= pre_read_offset and iterator < pre_read_duration then
            gam_mem_addr <= pre_read_duration + iterator;
        elsif iterator < pre_read_duration + normal_read_duration then
            gam_mem_addr <= iterator - pre_read_duration;
        else
            gam_mem_addr <= 0;
        end if;
        if iterator >= write_offset and iterator < write_offset + write_duration then
            gam_mem_we <= enable;
        else
            gam_mem_we <= '0';
        end if;
    end process;

end architecture arch;