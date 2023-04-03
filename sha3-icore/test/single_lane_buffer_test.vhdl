library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.single_lane_buffer;

entity single_lane_buffer_test is
end entity;

architecture arch of single_lane_buffer_test is

    component single_lane_buffer is
        port(
            clk : in std_logic;
            right_shift : in std_logic;
            distance : in natural range 0 to 31;
            input : in std_logic_vector(3 downto 0);
            output : out std_logic_vector(3 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    signal finished : boolean := false;

    signal distance : natural range 0 to 31;
    signal input : std_logic_vector(3 downto 0);
    signal output : std_logic_vector(3 downto 0);

    signal right_shift : std_logic;
    signal data : std_logic_vector(63 downto 0);
    signal result : std_logic_vector(63 downto 0);
    signal expected : std_logic_vector(63 downto 0);

begin

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    buf : single_lane_buffer port map(clk, right_shift, distance, input, output);

    test : process is

        type mode_t is (left,right);

        procedure calculate(dat : in std_logic_vector(63 downto 0); dis : natural range 0 to 31; mode : mode_t) is
        begin
            data <= dat;
            distance <= dis;
            if mode = right then
                right_shift <= '1';
                expected <= dat(dis - 1 downto 0) & dat(63 downto dis);
            else
                right_shift <= '0';
                expected <= dat(63 - dis downto 0) & dat(63 downto 63 - dis + 1);
            end if;
            wait until rising_edge(clk);
            if right_shift = '1' then
                for i in 7 downto 0 loop
                    input <= data(i * 4 + 3 downto i * 4);
                    wait until rising_edge(clk);
                end loop;
                for i in 17 downto 0 loop
                    if i >= 2 then
                        input <= data((i - 2) * 4 + 3 downto (i - 2) * 4);
                    end if;
                    if i <= 15 then
                        result(i * 4 + 3 downto i * 4) <= output;
                    end if;
                    wait until rising_edge(clk);
                end loop;
            else
                for i in 8 to 15 loop
                    input <= data(i * 4 + 3 downto i * 4);
                    wait until rising_edge(clk);
                end loop;
                for i in 0 to 17 loop
                    if i <= 15 then
                        input <= data(i * 4 + 3 downto i * 4);
                    end if;
                    if i >= 2 then
                        result((i - 2) * 4 + 3 downto (i - 2) * 4) <= output;
                    end if;
                    wait until rising_edge(clk);
                end loop;
            end if;
            wait until rising_edge(clk);
            assert expected = result report "unexpected result" severity FAILURE;
        end procedure;

    begin
        --calculate(x"5759c8d7542fb452", 8, right);
        --calculate(x"5759c8d7542fb452", 9, right);
        --calculate(x"5759c8d7542fb452", 1, right);
        --calculate(x"5759c8d7542fb452", 12, right);
        --calculate(x"5759c8d7542fb452", 30, right);
        --calculate(x"5759c8d7542fb452", 31, right);

        calculate(x"5759c8d7542fb452", 8, left);



        finished <= true;
        wait;
    end process;

end architecture;