library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.state.all;
use work.reader.all;
use work.util.all;
use work.slice_buffer.all;
use work.slice_functions.all;
use work.block_visualizer;

entity sha3_atom is
    port(
        clk : in std_logic;
        update : in std_logic;
        rst : in std_logic;
        enable : in std_logic;
        write_data : in std_logic;
        read_data : in std_logic;
        atom_index : in atom_index_t;
        data_in : in lane_t;

        data_out : out lane_t;
        ready : out std_logic
        );
end entity;

architecture arch of sha3_atom is

    component reader is
        port(
            clk : in std_logic;
            rst : in std_logic;
            init : in std_logic;
            enable : in std_logic;
            atom_index : in atom_index_t;
            index : out lane_index_t;
            valid : out std_logic;
            finished : out std_logic
        );
    end component;

    component slice_manager is
        port(
            -- control
            clk : in std_logic;
            rst : in std_logic;
            atom_index : in atom_index_t;
            init : in std_logic;
            enable : in std_logic;
            round : in round_index_t;
            theta : in std_logic;
    
            -- data
            own_data : in tile_computation_data_t;
            incoming_transmission : in lane_t;
    
            -- data signals
            outgoing_transmission : out lane_t;
            own_result_wb : out tile_computation_data_t;
            own_result_wb_index : out computation_data_index_t;
            remote_result_wb : out tile_computation_data_t;
            remote_result_wb_index : out computation_data_index_t;
            own_data_request_index : out computation_data_index_t;
            
            -- control signals
            enable_own_wb : out std_logic;
            enable_remote_wb : out std_logic;
            enable_own_data_request : out std_logic;
            finished : out std_logic
        );
    end component;

    component block_visualizer is
        port(state : in block_t);
    end component;

    constant zero : lane_t := (others => '0');

    -- Reader
    -- Input
    signal reader_init : std_logic;
    signal reader_enable : std_logic;
    -- Output
    signal reader_index : lane_index_t;
    signal reader_valid : std_logic;
    signal reader_finished : std_logic;

    -- Slice Manager
    -- Input
    signal sm_init : std_logic;
    signal sm_enable : std_logic;
    signal sm_theta : std_logic;
    signal sm_own_data : tile_computation_data_t;

    -- Output
    signal sm_outgoing_transmission : lane_t;
    signal sm_own_result_wb : tile_computation_data_t;
    signal sm_own_result_wb_index : computation_data_index_t;
    signal sm_remote_result_wb : tile_computation_data_t;
    signal sm_remote_result_wb_index : computation_data_index_t;
    signal sm_own_data_request_index : computation_data_index_t;
    signal sm_calculation_data : computation_data_t;
    signal sm_enable_own_wb : std_logic;
    signal sm_enable_remote_wb : std_logic;
    signal sm_enable_own_data_request : std_logic;
    signal sm_finished : std_logic;

    -- calculator
    -- inputs
    signal calc_input : computation_data_t;
    signal calc_prev_sums : std_logic_vector(4 downto 0);
    signal calc_theta_only : std_logic;
    signal calc_no_theta : std_logic;
    signal calc_round_constant : std_logic_vector(0 to 1);
    -- outputs
    signal calc_result : computation_data_t;
    signal calc_slice_sums : std_logic_vector(4 downto 0);

    type mode_t is (read_init, read, theta, rho, gamma, valid, write);
    signal mode : mode_t := read_init;
    signal state : block_t;
    signal round : round_index_t;

    -- Debug Signals
    signal dbg_state : block_t;
    signal dbg_reader_iterator : std_logic_vector(5 downto 0);
    signal dbg_reading, dbg_theta, dbg_rho, dbg_gamma, dbg_buf_first, dbg_buf_loop, dbg_edge_case : std_logic;
    signal dbg_round : std_logic_vector(4 downto 0);
    signal dbg_slice : std_logic_vector(6 downto 0);
    signal dbg_buf_iterator : std_logic_vector(5 downto 0);
    signal dbg_result0, dbg_result1 : slice_t;

begin

    read : reader port map(clk, rst, reader_init, reader_enable, atom_index, reader_index, reader_valid, reader_finished);

    manager : slice_manager port map(clk, rst, atom_index, sm_init, sm_enable, round, sm_theta, sm_own_data, calc_results, sm_outgoing_transmission,
        sm_own_result_wb, sm_own_result_wb_index, sm_remote_result_wb, sm_remote_result_wb_index, sm_own_data_request_index,
        calc_input, calc_round_constant, sm_enable_own_wb, sm_enable_remote_wb, sm_enable_own_data_request, sm_finished);

    calc : chunk_calculator port map(calc_input, calc_prev_sums, calc_theta_only, calc_no_theta, calc_round_constant, calc_result, calc_slice_sums);

    state_visual : block_visualizer port map(dbg_state);

    data_out <= sm_outgoing_transmission;

    process(clk, rst, update) is

        variable round : round_index_t;

        variable buf : buffer_t;
        -- sync inputs
        variable buf_results : buffer_data_t;
        variable buf_out : lane_t;
        variable buf_data : buffer_data_t;
        -- sync control signals
        variable buf_computeFirst : std_logic;
        variable buf_computeLoop : std_logic;
        variable buf_computeEdgeCase : std_logic;
        variable buf_index : slice_index_t;
        variable buf_finished : std_logic;
        -- buffer computation data
        variable buf_lowEdgeData : slice_t;
        variable buf_edgeCaseUpperSlice : slice_t;
        variable theta_sums0 : std_logic_vector(4 downto 0);
        variable theta_sums1 : std_logic_vector(4 downto 0);

    begin
        if rst = '1' then
            for i in 0 to 12 loop
                state(i) <= (others => '0');
            end loop;
            mode <= read_init;
            round := 0;
            data_out <= zero;
            ready <= '0';
        elsif rising_edge(clk) then
            if enable = '1' then
                -- Reader
                if mode = read_init then
                    reader_enable <= '0';
                    reader_init <= '1';
                    mode <= read;
                elsif mode = read then
                    reader_enable <= '1';
                    reader_init <= '0';
                    if reader_valid = '1' then
                        state(reader_index) <= data_in;
                    end if;
                    if reader_finished = '1' then
                        mode <= theta;
                    end if;
                else
                    reader_enable <= '0';
                    reader_init <= '0';
                end if;

                -- Slice Manager
                if mode = theta or mode = gamma or mode = theta_init or mode = gamma_init then
                    sm_init <= '1' when mode = theta_init or mode = gamma_init;
                    sm_enable <= enable;
                    sm_theta <= '1' when mode = theta_init or mode = theta else '0';
                    if sm_enable_own_data_request = '1' then
                        sm_own_data <= get_computation_data(state, sm_own_data_request_index);
                    else
                        sm_own_data <= (others => (others => '0'));
                    end if;
                    if sm_enable_own_wb = '1' then
                        set_computation_data(state, sm_own_result_wb, sm_own_result_wb_index);
                    end if;
                    if sm_enable_remote_wb = '1' then
                        set_computation_data(state, sm_remote_result_wb, sm_remote_result_wb_index); -- Duplicate!
                    end if;

                else
                    sm_init <= '0';
                    sm_enable <= '0';
                    sm_theta <= '0';
                    sm_own_data <= (others => (others => '0'));
                end if;

                -- Theta / Gamma

                if mode = theta then
                    sync(buf, state, atom_index, data_in, buf_results, buf_out, buf_data, buf_computeFirst, buf_computeLoop, buf_computeEdgeCase, buf_index, buf_finished);
                    if buf_computeFirst = '1' then
                        buf_lowEdgeData := buf_data(0);
                        theta_sums0 := theta_sums(buf_data(0));
                        theta_sums1 := theta_sums(buf_data(1));
                        buf_edgeCaseUpperSlice := theta(theta_sums0, theta_sums1, buf_data(1));
                    elsif buf_computeLoop = '1' then
                        theta_sums0 := theta_sums(buf_data(0));
                        buf_results(0) := theta(theta_sums1, theta_sums0, buf_data(0));
                        theta_sums1 := theta_sums(buf_data(1));
                        buf_results(1) := theta(theta_sums0, theta_sums1, buf_data(1));
                    elsif buf_computeEdgeCase = '1' then
                        theta_sums0 := theta_sums(buf_lowEdgeData);
                        buf_results(0) := theta(theta_sums1, theta_sums0, buf_lowEdgeData);
                        buf_results(1) := buf_edgeCaseUpperSlice;
                    end if;
                    data_out <= buf_out;
                    ready <= '0';
                    if buf_finished = '1' then
                        enter_rho(mode);
                    end if;
                elsif mode = rho then
                    rho(state, atom_index);
                    data_out <= zero;
                    ready <= '0';
                    enter_gamma(mode);
                elsif mode = gamma then
                    -- TODO calculate gamma here and remember, last round no theta
                    sync(buf, state, atom_index, data_in, buf_results, buf_out, buf_data, buf_computeFirst, buf_computeLoop, buf_computeEdgeCase, buf_index, buf_finished);
                    if buf_computeFirst = '1' then
                        buf_lowEdgeData := buf_data(0);
                        gamma((others => '0'), buf_data(0), buf_index, round, round = 23, theta_sums0, buf_edgeCaseUpperSlice);
                        gamma(theta_sums0, buf_data(1), buf_index + 1, round, round = 23, theta_sums1, buf_edgeCaseUpperSlice);
                    elsif buf_computeLoop = '1' then
                        gamma(theta_sums1, buf_data(0), buf_index, round, round = 23, theta_sums0, buf_results(0));
                        gamma(theta_sums0, buf_data(0), buf_index + 1, round, round = 23, theta_sums1, buf_results(1));
                    elsif buf_computeEdgeCase = '1' then
                        if atom_index = 0 then
                            gamma(theta_sums1, buf_lowEdgeData, 0, round, round = 23, theta_sums0, buf_results(0));
                        else
                            gamma(theta_sums1, buf_lowEdgeData, 32, round, round = 23, theta_sums0, buf_results(0));
                        end if;
                        buf_results(1) := buf_edgeCaseUpperSlice;
                    end if;
                    data_out <= buf_out;
                    ready <= '0';
                    if buf_finished = '1' then
                        if round = 23 then
                            round := 0;
                            enter_valid(mode);
                        else
                            round := round + 1;
                            enter_rho(mode);
                        end if;
                    end if;
                elsif mode = valid then
                    if write_data = '1' then
                        enter_write(mode);
                    elsif read_data = '1' then
                        enter_read(mode);
                    end if;
                    data_out <= zero;
                    ready <= '1';
                elsif mode = write then
                    write(reader, state, atom_index, reader_out, reader_ready);
                    if reader_ready = '1' then
                        enter_valid(mode);
                    end if;
                    data_out <= reader_out;
                    ready <= '0';
                end if;
                assert isValid(state) severity FAILURE;
            end if;
        end if;
        dbg_state <= state;
        dbg_reading <= asBit(mode = read);
        dbg_theta <= asBit(mode = theta);
        dbg_rho <= asBit(mode = rho);
        dbg_gamma <= asBit(mode = gamma);
        dbg_reader_iterator <= std_logic_vector(to_unsigned(reader, dbg_reader_iterator'length));
        dbg_round <= std_logic_vector(to_unsigned(round, dbg_round'length));
        dbg_slice <= std_logic_vector(to_unsigned(buf_index, dbg_slice'length));
        dbg_result0 <= buf_results(0);
        dbg_result1 <= buf_results(1);
        dbg_buf_first <= buf_computeFirst;
        dbg_buf_loop <= buf_computeLoop;
        dbg_edge_case <= buf_computeEdgeCase;
        dbg_buf_iterator <= std_logic_vector(to_unsigned(buf, dbg_buf_iterator'length));
    end process;

end architecture;