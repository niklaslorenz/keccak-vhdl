LIBRARY IEEE;

use IEEE.std_logic_1164.all;
use std.textio.all;
use IEEE.numeric_std.all;

use work.types.all;
use work.util.all;

entity theta_test is
end entity;

architecture arch of theta_test is

    constant zero : lane_t := (others => '0');

    signal clk : std_logic := '0';
    signal finished : boolean := false;
    signal result : slice_t;
    signal slice1_sums, slice2_sums : std_logic_vector(4 downto 0);

begin

    clk_process : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    test_process : process is
        constant slice_1 : slice_t := "1101001001011111000101100";
        constant slice_2 : slice_t := "1010101101001001111110101";
        constant expected : slice_t := "0100010000110010001001000";
    begin
        wait for 2 ns;
        wait until rising_edge(clk);
        slice1_sums <= theta_sums(slice_1);
        slice2_sums <= theta_sums(slice_2);
        result <= theta(slice_1, slice_2);
        wait until rising_edge(clk);
        assert slice1_sums = "00001" report "Wrong theta sum for slice 1" severity FAILURE;
        assert slice2_sums = "10110" report "Wrong theta sum for slice 2" severity FAILURE;
        assert result = expected report "Wrong result for theta" severity FAILURE;
        finished <= true;
        wait;
    end process;

end architecture;
