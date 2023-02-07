-- This is a manual test, since the atom's
-- state is not accessible at this stage yet.
-- Use the generated wave form to verify
-- the correctnes of this stage

library IEEE;

use IEEE.std_logic_1164.all;
use work.state.all;
use work.round_constants;

entity atom_read_test is
end entity;

architecture arch of atom_read_test is

    component sha3_atom is
        port(
            clk : in std_logic;
            rst : in std_logic;
            enable : in std_logic;
            atom_index : in atom_index_t;
            data_in : in lane_t;
    
            data_out : out lane_t
            );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal enable : std_logic := '0';
    signal data_in : lane_t;
    signal data_out_0 : lane_t;
    signal data_out_1 : lane_t;

    signal finished : boolean := false;
begin

    clk_process : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    atom_0 : sha3_atom port map(clk, rst, enable, 0, data_in, data_out_0);
    atom_1 : sha3_atom port map(clk, rst, enable, 1, data_in, data_out_1);

    test_process : process is
        variable state : block_t;
    begin
        wait for 2ns;
        rst <= '1';
        wait for 2ns;
        rst <= '0';
        wait until rising_edge(clk);
        enable <= '1';
        for i in 0 to 16 loop
            data_in <= round_constants.get(i);
            wait until rising_edge(clk);
        end loop;
        enable <= '0';
        wait until rising_edge(clk);
        finished <= true;
        wait;
    end process;
    
end architecture;