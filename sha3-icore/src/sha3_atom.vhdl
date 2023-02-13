library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.state.all;
use work.reader;
use work.util.all;
use work.slice_functions.all;
use work.block_visualizer;
use work.slice_manager;

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

    component slice_manager is
        port(
            -- control
            clk : in std_logic;
            rst : in std_logic;
            atom_index : in atom_index_t;
            init : in std_logic;
            enable : in std_logic;
            round : in round_index_t;
            gamma : in std_logic;
    
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

    component writer is
        port(
            clk : in std_logic;
            rst : in std_logic;
            init : in std_logic;
            enable : in std_logic;
            index : out natural range 0 to 3;
            finished : out std_logic
        );
    end component;

    component block_visualizer is
        port(state : in block_t);
    end component;

    constant zero : lane_t := (others => '0');

    signal reader_index : slice_index_t;
    signal reader_offset : natural range 0 to 31;

    -- Slice Manager
    -- Input
    signal sm_init : std_logic;
    signal sm_enable : std_logic;
    signal sm_gamma : std_logic;
    signal sm_own_data : tile_computation_data_t;
    -- Output
    signal sm_outgoing_transmission : lane_t;
    signal sm_own_result_wb : tile_computation_data_t;
    signal sm_own_result_wb_index : computation_data_index_t;
    signal sm_remote_result_wb : tile_computation_data_t;
    signal sm_remote_result_wb_index : computation_data_index_t;
    signal sm_own_data_request_index : computation_data_index_t;
    signal sm_enable_own_wb : std_logic;
    signal sm_enable_remote_wb : std_logic;
    signal sm_enable_own_data_request : std_logic;
    signal sm_finished : std_logic;

    signal rho_result : lane_t;
    signal rho_lane_index : lane_index_t;
    signal rho_lane_offset : full_lane_index_t;

    -- Writer
    signal writer_index : natural range 0 to 3;
    signal writer_data : lane_t;

    type mode_t is (read_init, read, calc_init, calc, rho_init, rho, valid, write_init, write);
    signal mode : mode_t := read_init;
    signal state : block_t;
    signal round : round_index_t;

begin

    manager : slice_manager port map(clk, rst, atom_index, sm_init, sm_enable, round, sm_gamma, sm_own_data, data_in, sm_outgoing_transmission,
        sm_own_result_wb, sm_own_result_wb_index, sm_remote_result_wb, sm_remote_result_wb_index, sm_own_data_request_index,
        sm_enable_own_wb, sm_enable_remote_wb, sm_enable_own_data_request, sm_finished);

    state_visual : block_visualizer port map(state);

    reader_offset <= 12 when atom_index = 1 else 0;

    sm_enable <= '1' when enable = '1' and (mode = calc_init or mode = calc) else '0';
    sm_init <= '1' when mode = calc_init else '0';
    sm_own_data <= state(sm_own_data_request_index * 2 + 1) & state(sm_own_data_request_index * 2);

    rho_result <= rho_lane(get_lane(state, rho_lane_index), rho_lane_index + rho_lane_offset);
    rho_lane_offset <= 12 when atom_index = 1 else 0;

    data_out <= sm_outgoing_transmission or writer_data;

    ready <= '1' when mode = valid else '0';

    process(clk, rst) is
    begin
        if rst = '1' then
            for i in 0 to 63 loop
                state(i) <= (others => '0');
            end loop;
            reader_index <= 0;
            writer_data <= (others => '0');
            writer_index <= 0;
            rho_lane_index <= 0;
            mode <= read_init;
            sm_gamma <= '0';
            round <= 0;
        elsif rising_edge(clk) then
            if enable = '1' then
                if mode = read_init then -- Reader
                    reader_index <= 0;
                    mode <= read;
                elsif mode = read then
                    state(reader_index * 2 + 1) <= data_in(25 + reader_offset downto 12 + reader_offset);
                    state(reader_index * 2) <= data_in(12 + reader_offset downto reader_offset);
                    if reader_index = 31 then
                        mode <= calc_init;
                        sm_gamma <= '0';
                    else
                        reader_index <= reader_index + 1;
                    end if;
                elsif mode = calc_init then -- Slice Manager
                    mode <= calc;
                elsif mode = calc then
                    if sm_enable_own_wb = '1' then
                        state(sm_own_result_wb_index * 2 + 1) <= sm_own_result_wb(1);
                        state(sm_own_result_wb_index * 2) <= sm_own_result_wb(0);
                    end if;
                    if sm_enable_remote_wb = '1' then
                        state(sm_remote_result_wb_index * 2 + 1) <= sm_remote_result_wb(1);
                        state(sm_remote_result_wb_index * 2) <= sm_remote_result_wb(0);
                    end if;
                    if sm_finished = '1' then
                        if round = 23 then
                            mode <= valid;
                        else
                            mode <= rho_init;
                        end if;
                    end if;
                elsif mode = rho_init then
                    rho_lane_index <= 0;
                    mode <= rho;
                elsif mode = rho then
                    for i in 0 to 63 loop
                        state(i)(rho_lane_index) <= rho_result(i);
                    end loop;
                    if rho_lane_index = 12 then
                        sm_gamma <= '1';
                        round <= round + 1;
                        mode <= calc_init;
                    else
                        rho_lane_index <= rho_lane_index + 1;
                    end if;
                elsif mode = valid then
                    if read_data = '1' then
                        mode <= read_init;
                    elsif write_data = '1' then
                        mode <= write_init;
                    end if;
                elsif mode = write_init then -- Writer
                    writer_index <= 0;
                    mode <= write;
                elsif mode = write then
                    if atom_index = 0 then
                        writer_data <= get_lane(state, writer_index);
                    end if;
                    if writer_index = 3 then
                        mode <= valid;
                    else
                        writer_index <= writer_index + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture;