LIBRARY IEEE;

use IEEE.std_logic_1164.all;
use work.slices.all;
use std.textio.all;
use IEEE.numeric_std.all;

entity state_holder_test is
end entity;

architecture arch of state_holder_test is

    component state_holder is
    port(
        clk : in std_logic;
        rst : in std_logic;

        lane_data : in std_logic_vector(63 downto 0);
        lane_index : in natural range 0 to 12;
        lane_write : in std_logic;

        slice_tile_data : in slice_tile_t;
        slice_tile_index : in natural range 0 to 31;
        slice_tile_write : in std_logic;

        state : out state_slice_t
    );
    end component;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal lane_index : natural range 0 to 12 := 0;
    signal lane_data : std_logic_vector(63 downto 0) := (others => '0');
    signal lane_write : std_logic := '0';
    signal slice_tile_data : slice_tile_t;
    signal slice_tile_index : natural range 0 to 31 := 0;
    signal slice_tile_write : std_logic := '0';
    signal state : state_slice_t;
    signal finished : boolean := false;

    constant zero : std_logic_vector(63 downto 0) := (others => '0');

    signal lane0, lane4 : std_logic_vector(63 downto 0);

begin

    holder : state_holder port map(clk, reset, lane_data, lane_index, lane_write, slice_tile_data, slice_tile_index, slice_tile_write, state);

    clk_process : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    test_process : process is
    begin
        wait for 2ns;
        reset <= '1';
        wait for 2ns;
        reset <= '0';
        for i in 0 to 12 loop
            assert state(i) = zero report "state should be zero" SEVERITY FAILURE;
        end loop;
        wait until rising_edge(clk);
        lane_write <= '1';
        lane_index <= 4;
        lane_data <= x"0123456789abcdef";
        wait until rising_edge(clk);
        lane_write <= '0';
        for i in 0 to 12 loop
            if i = 4 then
                assert state(i) = x"0123456789abcdef" report "state(4) has wrong value" SEVERITY FAILURE;
            else
                assert state(i) = zero report "expected zero in lane " & integer'image(i) SEVERITY FAILURE;
            end if;
        end loop;
        wait until rising_edge(clk);
        slice_tile_write <= '1';
        slice_tile_data(0) <= (others => '0');
        slice_tile_data(1) <= (others => '1');
        slice_tile_index <= 0;
        wait until rising_edge(clk);
        slice_tile_write <= '0';
        wait until rising_edge(clk);
        for i in 0 to 12 loop
            if i = 4 then
                assert state(i) = x"0123456789abcdee" report "wrong value" SEVERITY FAILURE;
            else
                assert state(i) = x"0000000000000002" report "expected two in lane " & integer'image(i) SEVERITY FAILURE;
            end if;
        end loop;
        wait until rising_edge(clk);
        reset <= '1';
        finished <= true;
        wait;
    end process;

    lane0 <= state(0);
    lane4 <= state(4);

end architecture;
