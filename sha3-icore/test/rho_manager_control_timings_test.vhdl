library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;

entity rho_manager_control_timings_test is
end entity;

architecture arch of rho_manager_control_timings_test is

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

    signal clk : std_logic := '0';
    signal finished : boolean := false;
    
    signal iterator : rho_manager_iterator_t;

begin

    timings : rho_manager_control_timings port map(iterator, '1');

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    test : process is
    begin
        iterator <= 0;
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        for i in 0 to 30 loop
            iterator <= iterator + 1;
            wait until rising_edge(clk);
        end loop;
        wait until rising_edge(clk);

        finished <= true;
        wait;
    end process;

end architecture arch;