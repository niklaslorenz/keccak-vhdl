library IEEE;
use IEEE.std_logic_1164.all;
use work.multi_lane_buffer;
use work.state.all;

entity multi_lane_buffer_test is
end entity;

architecture arch of multi_lane_buffer_test is

    component multi_lane_buffer is
        port(
            clk : in std_logic;
            atom_index : atom_index_t;
            right_shift : in std_logic;
            input : in multi_buffer_data_t;
            output : out multi_buffer_data_t
        );
    end component;

    type data_array_t is array(natural range 0 to 6) of std_logic_vector(63 downto 0);

    signal clk : std_logic := '0';
    signal finished : boolean := false;

    signal atom_index : atom_index_t;
    signal right_shift : std_logic;
    signal input : multi_buffer_data_t;
    signal output : multi_buffer_data_t;

    signal data : std_logic_vector(63 downto 0);
    signal data_in : data_array_t;
    signal expected : data_array_t;
    signal result : data_array_t;

    signal e0, e1, e2, e3, e4, e5, e6 : std_logic_vector(63 downto 0);
    signal r0, r1, r2, r3, r4, r5, r6 : std_logic_vector(63 downto 0);

begin

    e0 <= expected(0);
    e1 <= expected(1);
    e2 <= expected(2);
    e3 <= expected(3);
    e4 <= expected(4);
    e5 <= expected(5);
    e6 <= expected(6);

    r0 <= result(0);
    r1 <= result(1);
    r2 <= result(2);
    r3 <= result(3);
    r4 <= result(4);
    r5 <= result(5);
    r6 <= result(6);

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    buf : multi_lane_buffer port map(clk, atom_index, right_shift, input, output);

    test : process is

        type mode_t is (atom0_left, atom0_right, atom1_left, atom1_right);

        procedure calculate(dat : in std_logic_vector(63 downto 0); mode : in mode_t) is
            function ls(d : std_logic_vector(63 downto 0); dis : natural range 0 to 63) return std_logic_vector is
            begin
                return d(63 - dis downto 0) & d(63 downto 63 - dis + 1);
            end function;
    
            function rs(d : std_logic_vector(63 downto 0); dis : natural range 0 to 63) return std_logic_vector is
            begin
                return d(dis - 1 downto 0) & d(63 downto dis);
            end function;
        begin
            if mode = atom0_left then
                atom_index <= 0;
                right_shift <= '0';
                expected(0) <= ls(dat, 1);
                expected(1) <= ls(dat, 28);
                expected(2) <= ls(dat, 27);
                expected(3) <= ls(dat, 6);
                expected(4) <= ls(dat, 20);
                expected(5) <= ls(dat, 3);
                expected(6) <= ls(dat, 10);
            elsif mode = atom0_right then
                atom_index <= 0;
                right_shift <= '1';
                expected(0) <= rs(dat, 2);
                expected(1) <= rs(dat, 28);
                expected(2) <= rs(dat, 20);
                expected(3) <= rs(dat, 9);
                expected(4) <= rs(dat, 21);
            elsif mode = atom1_left then
                atom_index <= 1;
                right_shift <= '0';
                expected(0) <= ls(dat, 25);
                expected(1) <= ls(dat, 15);
                expected(2) <= ls(dat, 21);
                expected(3) <= ls(dat, 8);
                expected(4) <= ls(dat, 18);
                expected(5) <= ls(dat, 2);
                expected(6) <= ls(dat, 14);
            elsif mode = atom1_right then
                atom_index <= 1;
                right_shift <= '1';
                expected(0) <= rs(dat, 21);
                expected(1) <= rs(dat, 25);
                expected(2) <= rs(dat, 23);
                expected(3) <= rs(dat, 19);
                expected(4) <= rs(dat, 3);
                expected(5) <= rs(dat, 8);
            end if;
            data <= dat;
            data_in <= (dat, dat, dat, dat, dat, dat, dat);
            wait until rising_edge(clk);
            if right_shift = '1' then
                for i in 7 downto 0 loop
                    for j in 0 to 6 loop
                        input(j) <= data_in(j)(i * 4 + 3 downto i * 4);
                    end loop;
                    wait until rising_edge(clk);
                end loop;
                for i in 17 downto 0 loop
                    for j in 0 to 6 loop
                        if i >= 2 then
                            input(j) <= data_in(j)((i - 2) * 4 + 3 downto (i - 2) * 4);
                        end if;
                        if i <= 15 then
                            result(j)(i * 4 + 3 downto i * 4) <= output(j);
                        end if;
                    end loop;
                    wait until rising_edge(clk);
                end loop;
            else
                for i in 8 to 15 loop
                    for j in 0 to 6 loop
                        input(j) <= data_in(j)(i * 4 + 3 downto i * 4);
                    end loop;
                    wait until rising_edge(clk);
                end loop;
                for i in 0 to 17 loop
                    for j in 0 to 6 loop
                        if i <= 15 then
                            input(j) <= data_in(j)(i * 4 + 3 downto i * 4);
                        end if;
                        if i >= 2 then
                            result(j)((i - 2) * 4 + 3 downto (i - 2) * 4) <= output(j);
                        end if;
                    end loop;
                    wait until rising_edge(clk);
                end loop;
            end if;
            if right_shift = '0' then
                for i in 0 to 6 loop
                    assert expected(i) = result(i) report "unexpected result" severity FAILURE;
                end loop;
            elsif atom_index = 0 then
                for i in 0 to 4 loop
                    assert expected(i) = result(i) report "unexpected result" severity FAILURE;
                end loop;
            else
                for i in 0 to 5 loop
                    assert expected(i) = result(i) report "unexpected result" severity FAILURE;
                end loop;
            end if;
        end procedure;
    begin
        calculate(x"5759c8d7542fb452", atom0_left);
        calculate(x"5759c8d7542fb452", atom0_right);
        calculate(x"5759c8d7542fb452", atom1_left);
        calculate(x"5759c8d7542fb452", atom1_right);
        finished <= true;
        wait;
    end process;

end architecture arch;