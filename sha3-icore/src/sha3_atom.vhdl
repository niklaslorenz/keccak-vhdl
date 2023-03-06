library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.state.all;
use work.reader;
use work.util.all;
use work.slice_functions.all;
use work.block_visualizer;
use work.slice_manager;
use work.slice_memory_wrapper;

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

    component reader is
        port(
            clk : in std_logic;
            rst : in std_logic;
            init : in std_logic;
            enable : in std_logic;
            atom_index : in atom_index_t;
            data_in : in std_logic_vector(25 downto 0);
            index : out natural range 0 to 31;
            data_out : out std_logic_vector(25 downto 0);
            write_enable : out std_logic;
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

    component slice_memory_wrapper is
        port (
            BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 6 downto 0 );
            BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 25 downto 0 );
            BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 25 downto 0 );
            BRAM_PORTA_0_en : in STD_LOGIC;
            BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 );
            BRAM_PORTB_0_addr : in STD_LOGIC_VECTOR ( 6 downto 0 );
            BRAM_PORTB_0_din : in STD_LOGIC_VECTOR ( 25 downto 0 );
            BRAM_PORTB_0_dout : out STD_LOGIC_VECTOR ( 25 downto 0 );
            BRAM_PORTB_0_en : in STD_LOGIC;
            BRAM_PORTB_0_we : in STD_LOGIC_VECTOR ( 0 to 0 );
            clk : in STD_LOGIC
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

    constant zero : lane_t := (others => '0');

    -- Memory
    signal mem_a_addr, mem_b_addr : std_logic_vector(6 downto 0);
    signal mem_a_din, mem_a_dout, mem_b_din, mem_b_dout : std_logic_vector(25 downto 0);
    signal mem_a_we, mem_b_en : std_logic;

    -- Writer
    signal rdr_init : std_logic;
    signal rdr_enable : std_logic;
    signal rdr_addr : natural range 0 to 31;
    signal rdr_dout : std_logic_vector(25 downto 0);
    signal rdr_we : std_logic;
    signal rdr_finished : std_logic;

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

    -- Writer
    signal writer_offset : natural range 0 to 12;
    signal writer_index : natural range 0 to 31;
    signal writer_data : lane_t;

    type mode_t is (read_init, read, gamma_init, gamma, rho_init, rho, valid, write_init, write);
    signal mode : mode_t := read_init;    
    signal round : round_index_t;

begin

    rdr : reader port map(clk, rst, rdr_init, rdr_enable, atom_index, data_in, rdr_addr, rdr_dout, rdr_we, rdr_finished);

    memory : slice_memory_wrapper port map(mem_a_addr, mem_a_din, mem_a_dout, "1", mem_a_we, mem_b_addr, mem_b_din, mem_b_dout, "1", mem_b_we, clk);

    manager : slice_manager port map(clk, rst, atom_index, sm_init, sm_enable, round, sm_gamma, sm_own_data, data_in, sm_outgoing_transmission,
        sm_own_result_wb, sm_own_result_wb_index, sm_remote_result_wb, sm_remote_result_wb_index, sm_own_data_request_index,
        sm_enable_own_wb, sm_enable_remote_wb, sm_enable_own_data_request, sm_finished);

    writer_offset <= 12 when atom_index = 1 else 0;

    ready <= '1' when mode = valid else '0';

    
    
    mem_a_we <= rdr_we;
    mem_a_addr <= rdr_addr;
    mem_a_din <= rdr_dout;
    mem_b_we <= '0';
    mem_b_addr <= 0;
    mem_b_din <= (others => '0');
    
    reader_ctl : process(mode, enable) is
    begin
        if mode = read_init or mode = read then
            rdr_enable <= enable;
        else
            rdr_enable <= '0';
        end if;
        if mode = read_init then
            rdr_init <= '1';
        else
            rdr_init <= '0';
        end if;
    end process;

    sm_own_data <= mem_a_dout;
    slice_manager_ctl : process(mode, enable) is
    begin
        if enable = '1' and (mode = gamma_init or mode = gamma) then
            sm_enable <= '1';
        else
            sm_enable <= '0';
        end if;
        if mode = gamma_init then
            sm_init <= '1';
        else
            sm_init <= '0';
        end if;
    end process;

    data_out_process : process(mode, sm_outgoing_transmission, writer_data) is
    begin
        if mode = gamma then
            data_out <= sm_outgoing_transmission;
        elsif mode = write then
            data_out <= writer_data;
        else
            data_out <= (others => '0');
        end if;
    end process;

    process(clk, rst) is
    begin
        if rst = '1' then
            for i in 0 to 63 loop
                state(i) <= (others => '0');
            end loop;
            reader_index <= 0;
            writer_data <= (others => '0');
            writer_index <= 0;
            mode <= read_init;
            sm_gamma <= '0';
            round <= 0;
        elsif rising_edge(clk) then
            if enable = '1' then
                if mode = read_init then
                    mode <= read;
                elsif mode = read then
                    if rdr_finished = '1' then
                        mode <= gamma_init;
                    end if;
                elsif mode = gamma_init then
                    mem_a_we <= '0';
                    mem_b_we <= '0';
                    mode <= gamma;
                elsif mode = gamma then
                    if gamma_iterator < 16 then
                        if atom_index = 0 then
                            mem_b_addr <= 16 + iterator;
                        else
                            mem_b_addr <= iterator;
                        end if;
                    end if;
                    if gamma_iterator >= 2 and gamma_iterator < 18 then

                    end if;
                elsif mode = rho_init then

                elsif mode = rho then

                elsif mode = valid then

                elsif mode = write_init then

                elsif mode = write then

                end if;




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
                            mode <= rho;
                        end if;
                    end if;
                elsif mode = rho then
                    state <= rho_function(state, atom_index);
                    sm_gamma <= '1';
                    round <= round + 1;
                    mode <= calc_init;
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