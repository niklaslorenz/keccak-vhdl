library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
use work.reader.all;
use work.util.all;
use work.slice_buffer.all;
use work.slice_functions.all;

entity sha3_atom is
    port(
        clk : in std_logic;
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
    type mode_t is (read, theta, rho, gamma, valid, write);
    -- Debug Signals
    signal dbg_state : block_t;
    signal lane0, lane1, lane4, lane5, lane10, lane12 : lane_t;

begin

    lane0 <= dbg_state(0);
    lane1 <= dbg_state(1);
    lane4 <= dbg_state(4);
    lane5 <= dbg_state(5);
    lane10 <= dbg_state(10);
    lane12 <= dbg_state(12);

    process(clk, rst) is
        constant zero : lane_t := (others => '0');

        variable state : block_t;
        variable mode : mode_t;
        variable round : round_index_t;

        --modules
        variable reader : reader_t;
        variable reader_ready : std_logic;
        variable reader_out : lane_t;

        variable buf : buffer_t;
        variable buf_results : buffer_data_t;
        variable buf_out : lane_t;
        variable buf_data : buffer_data_t;
        variable buf_ready : std_logic;
        variable buf_finished : std_logic;
        variable buf_isFirst : std_logic;
        variable buf_computeEdgeCase : std_logic;
        variable buf_index : slice_index_t;
        variable buf_edgeData : buffer_data_t;
        variable buf_lowEdgeData : slice_t;
        variable buf_firstIterationResult : slice_t;
        variable theta_sums0 : std_logic_vector(4 downto 0);
        variable theta_sums1 : std_logic_vector(4 downto 0);

        procedure enter_read(mode : inout mode_t) is
        begin
            init_reader(reader);
            mode := read;
            round := 0;
        end procedure;

        procedure enter_theta(mode : inout mode_t) is
        begin
            init_buffer(buf);
            buf_results := ((others => '0'), (others => '0'));
            mode := theta;
        end procedure;

        procedure enter_rho(mode : inout mode_t) is
        begin
            mode := rho;
        end procedure;

        procedure enter_gamma(mode : inout mode_t) is
        begin
            init_buffer(buf);
            buf_results := ((others => '0'), (others => '0'));
            mode := gamma;
        end procedure;

        procedure enter_write(mode : inout mode_t) is
        begin
            init_reader(reader);
            mode := write;
        end procedure;

        procedure enter_valid(mode : inout mode_t) is
        begin
            mode := valid;
        end procedure;

    begin
        if rst = '1' then
            reset(state);
            enter_read(mode);
            round := 0;
            data_out <= zero;
            ready <= '0';
        elsif rising_edge(clk) then
            if enable = '1' then
                if mode = read then
                    read(reader, state, data_in, atom_index, reader_ready);
                    if reader_ready = '1' then
                        enter_theta(mode);
                    end if;
                    data_out <= zero;
                    ready <= '0';
                elsif mode = theta then
                    sync(buf, state, atom_index, data_in, buf_results, buf_out, buf_data, buf_ready, buf_finished, buf_isFirst, buf_computeEdgeCase, buf_index);
                    if buf_ready = '1' then
                        if buf_isFirst = '1' then
                            buf_lowEdgeData := buf_data(0);
                            theta_sums0 := theta_sums(buf_data(0));
                            theta_sums1 := theta_sums(buf_data(1));
                            buf_firstIterationResult := theta(theta_sums0, theta_sums1, buf_data(1));
                        else
                            theta_sums0 := theta_sums1;
                            theta_sums1 := theta_sums(buf_data(0));
                            buf_results(0) := theta(theta_sums0, theta_sums1, buf_data(0));
                            theta_sums0 := theta_sums1;
                            theta_sums1 := theta_sums(buf_data(1));
                            buf_results(1) := theta(theta_sums0, theta_sums1, buf_data(1));
                        end if;
                    end if;
                    if buf_computeEdgeCase = '1' then
                        theta_sums0 := theta_sums1;
                        theta_sums1 := theta_sums(buf_lowEdgeData);
                        buf_results(0) := theta(theta_sums0, theta_sums1, buf_lowEdgeData);
                        buf_results(1) := buf_firstIterationResult;
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
                    sync(buf, state, atom_index, data_in, buf_results, buf_out, buf_data, buf_ready, buf_finished, buf_isFirst, buf_computeEdgeCase, buf_index);
                    if buf_ready = '1' then
                        if buf_isFirst = '1' then
                            buf_lowEdgeData := buf_data(0);
                            gamma((others => '0'), buf_data(0), buf_index, round, round = 23, theta_sums0, buf_firstIterationResult);
                            gamma(theta_sums0, buf_data(1), buf_index + 1, round, round = 23, theta_sums1, buf_firstIterationResult);
                        else
                            gamma(theta_sums1, buf_data(0), buf_index, round, round = 23, theta_sums0, buf_results(0));
                            gamma(theta_sums0, buf_data(0), buf_index + 1, round, round = 23, theta_sums1, buf_results(1));
                        end if;
                    end if;
                    if buf_computeEdgeCase = '1' then
                        if atom_index = 0 then
                            gamma(theta_sums1, buf_lowEdgeData, 0, round, round = 23, theta_sums0, buf_results(0));
                        else
                            gamma(theta_sums1, buf_lowEdgeData, 16, round, round = 23, theta_sums0, buf_results(0));
                        end if;
                        buf_results(1) := buf_firstIterationResult;
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
            end if;
        end if;
        dbg_state <= state;
    end process;

end architecture;