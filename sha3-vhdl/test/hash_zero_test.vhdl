library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.keccak_types.all;
use work.keccak_p;

entity hash_zero_test is
end entity;

architecture arch of hash_zero_test is

    component keccak_p is
        port(
            input : in StateArray;
            roundIndex : in natural range 0 to 23;
            output : out StateArray
        );
    end component keccak_p;

    signal clk : std_logic := '0';
    signal finished : boolean := false;
    signal state : StateArray;
    signal theta_in : StateArray;
    signal p_output : StateArray;
    signal p_round  : natural range 0 to 23 := 0;
    signal lane0, lane1, lane2, lane3, lane4, lane5, lane6, lane7, lane8, lane9, lane10, lane11, lane12,
        lane13, lane14, lane15, lane16, lane17, lane18, lane19, lane20, lane21, lane22, lane23, lane24 : Lane;

begin

    p : keccak_p port map(state, p_round, p_output);

    lane0 <= state(0);
    lane1 <= state(1);
    lane2 <= state(2);
    lane3 <= state(3);
    lane4 <= state(4);
    lane5 <= state(5);
    lane6 <= state(6);
    lane7 <= state(7);
    lane8 <= state(8);
    lane9 <= state(9);
    lane10 <= state(10);
    lane11 <= state(11);
    lane12 <= state(12);
    lane13 <= state(13);
    lane14 <= state(14);
    lane15 <= state(15);
    lane16 <= state(16);
    lane17 <= state(17);
    lane18 <= state(18);
    lane19 <= state(19);
    lane20 <= state(20);
    lane21 <= state(21);
    lane22 <= state(22);
    lane23 <= state(23);
    lane24 <= state(24);

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
        wait for 2ns;
        theta_in <= to_StateArray(std_logic_vector(to_unsigned(0, 1600)));
        theta_in(0)(1) <= '1';
        theta_in(0)(2) <= '1';
        theta_in(16)(63) <= '1';
        for i in 0 to 23 loop
            p_round <= i;
            wait until rising_edge(clk);
            state <= p_output;
        end loop;
        wait until rising_edge(clk);
        finished <= true;
        wait;
    end process;

end architecture;