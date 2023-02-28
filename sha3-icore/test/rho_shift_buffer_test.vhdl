library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.state.all;
use work.rho_shift_buffer;

entity rho_shift_buffer_test is
end entity;

architecture arch of rho_shift_buffer_test is

    component rho_shift_buffer is
        Port (
            clk : in std_logic;
            atom_index : in atom_index_t;
            left_shift : in std_logic;
            data_in : in rho_calc_t;
            data_out : out rho_calc_t
        );
    end component;

    component block_visualizer is
        port(state : in block_t);
    end component;

    signal clk : std_logic := '0';
    signal finished : boolean := false;
    signal left_shift : std_logic := '1';
    signal data_in : rho_calc_t;
    signal data_out : rho_calc_t;

    signal state : block_t;
    signal result : block_t;

    signal inserted0, inserted1, inserted2, inserted3 : tile_slice_t;
    signal iteration : natural;

begin

    state_visual : block_visualizer port map(state);
    result_visual : block_visualizer port map(result);

    shifter : rho_shift_buffer port map(clk, 0, left_shift, data_in, data_out);

    inserted0 <= data_out(0);
    inserted1 <= data_out(1);
    inserted2 <= data_out(2);
    inserted3 <= data_out(3);

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    test : process is

        constant ONE : lane_t := std_logic_vector(to_unsigned(1, 64));

        function const(index : natural range 0 to 63) return lane_t is
        begin
            return lane_t(to_stdlogicvector(to_bitvector(one) rol index));
        end function;

    begin

        for i in 1 to 63 loop
            state(i) <= (others => '0');
        end loop;
        state(0) <= (others => '1');
        
        for i in 7 to 15 loop
            data_in <= get_rho_data(state, i);
            wait until rising_edge(clk);
        end loop;
        for i in 0 to 15 loop
            iteration <= i;
            wait for 1ns;
            data_in <= get_rho_data(state, i);
            wait until rising_edge(clk);
            wait for 1ns;
            for j in 0 to 3 loop
                result(i * 4 + j) <= data_out(j);
            end loop;
            wait for 1ns;
        end loop;

        assert get_lane(result, 0) = const(0) severity FAILURE;
        assert get_lane(result, 1) = const(1) severity FAILURE;
        assert get_lane(result, 2) = const(0) severity FAILURE;
        assert get_lane(result, 3) = const(28) severity FAILURE;
        assert get_lane(result, 4) = const(27) severity FAILURE;
        assert get_lane(result, 5) = const(0) severity FAILURE;
        assert get_lane(result, 6) = const(0) severity FAILURE;
        assert get_lane(result, 7) = const(6) severity FAILURE;
        assert get_lane(result, 8) = const(0) severity FAILURE;
        assert get_lane(result, 9) = const(20) severity FAILURE;
        assert get_lane(result, 10) = const(3) severity FAILURE;
        assert get_lane(result, 11) = const(10) severity FAILURE;
        assert get_lane(result, 12) = const(0) severity FAILURE;

        wait until rising_edge(clk);
        wait until rising_edge(clk);

        for i in 0 to 63 loop
            result(i) <= (others => 'U');
        end loop;
        left_shift <= '0';
        for i in 8 downto 0 loop
            data_in <= get_rho_data(state, i);
            wait until rising_edge(clk);
        end loop;
        for i in 15 downto 0 loop
            iteration <= i;
            wait for 1ns;
            data_in <= get_rho_data(state, i);
            wait until rising_edge(clk);
            wait for 1ns;
            for j in 0 to 3 loop
                result(i * 4 + j) <= data_out(j);
            end loop;
            wait for 1ns;
        end loop;

        assert get_lane(result, 0) = const(0) severity FAILURE;
        assert get_lane(result, 1) = const(0) severity FAILURE;
        assert get_lane(result, 2) = const(62) severity FAILURE;
        assert get_lane(result, 3) = const(0) severity FAILURE;
        assert get_lane(result, 4) = const(0) severity FAILURE;
        assert get_lane(result, 5) = const(36) severity FAILURE;
        assert get_lane(result, 6) = const(44) severity FAILURE;
        assert get_lane(result, 7) = const(0) severity FAILURE;
        assert get_lane(result, 8) = const(55) severity FAILURE;
        assert get_lane(result, 9) = const(0) severity FAILURE;
        assert get_lane(result, 10) = const(0) severity FAILURE;
        assert get_lane(result, 11) = const(0) severity FAILURE;
        assert get_lane(result, 12) = const(43) severity FAILURE;

        wait until rising_edge(clk);
        wait until rising_edge(clk);
        finished <= true;
        wait;
    end process;

end architecture;