library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
use work.util.all;
use work.chunk_calculator;
use work.round_constants;

entity slice_manager is
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
end entity;

architecture arch of slice_manager is

    constant zero : transmission_word_t := (others => '0');

    component chunk_calculator is
        port(
            data : in computation_data_t;
            prev_sums : in std_logic_vector(4 downto 0);
            theta_only : in std_logic;
            no_theta : in std_logic;
            round_constant : in std_logic_vector(0 to 1);
            result : out computation_data_t;
            slice_sums : out std_logic_vector(4 downto 0)
        );
    end component;

    signal calc_result : computation_data_t;
    signal calc_result_sums : std_logic_vector(4 downto 0);

    -- timings
    constant request_offset : natural := 0;
    constant calculate_offset : natural := 1;
    constant own_wb_offset : natural := 2;
    constant remote_wb_offset : natural := 3;
    signal request_phase, calculation_phase, own_wb_phase, remote_wb_phase : boolean;
    signal calculate_first, calculate_edge : boolean;

    -- registered signals
    subtype iterator_t is natural range 0 to 21;
    signal iterator : iterator_t := 0;
    signal own_data_buffer : tile_computation_data_t;
    signal calc_prev_sums : std_logic_vector(4 downto 0);

    -- combinatorial signals
    signal incoming_state_transmission : transmission_word_t;
    signal incoming_result_transmission : transmission_word_t;
    signal outgoing_state_transmission : transmission_word_t;
    signal outgoing_result_transmission : transmission_word_t;

    signal calc_data : computation_data_t;
    signal calc_no_theta : std_logic;
    signal calc_round_constant : std_logic_vector(1 downto 0);
    signal first_data : computation_data_t;
    signal full_round_constant : lane_t;
    signal round_constant_part_index : computation_data_index_t;

    signal finished_temp : std_logic;

    -- debug signals
    signal calc_result0, calc_result1 : slice_t;


begin

    calc : chunk_calculator port map(calc_data, calc_prev_sums, gamma, calc_no_theta, calc_round_constant, calc_result, calc_result_sums);

    -- timings
    request_phase <= (iterator >= request_offset and iterator <= request_offset + 15);
    calculation_phase <= (iterator >= calculate_offset and iterator <= calculate_offset + 16);
    own_wb_phase <= (iterator >= own_wb_offset and iterator <= own_wb_offset + 15);
    remote_wb_phase <= (iterator >= remote_wb_offset and iterator <= remote_wb_offset + 15);
    calculate_first <= iterator = calculate_offset;
    calculate_edge <= iterator = calculate_offset + 16;

    -- combinatorial
    incoming_state_transmission <= incoming_transmission(31 downto 0);
    incoming_result_transmission <= incoming_transmission(63 downto 32);

    outgoing_state_transmission <= zero when not request_phase or enable = '0' else
        x"0" & own_data(1)(12 downto 1) &
        x"0" & own_data(0)(12 downto 1) when atom_index = 1 else
        x"0" & own_data(1)(11 downto 0) &
        x"0" & own_data(0)(11 downto 0);

    outgoing_result_transmission <= zero     when not own_wb_phase or enable = '0' else
        "000" & calc_result(1)(12 downto  0) &
        "000" & calc_result(0)(12 downto  0) when atom_index = 1 else
        "000" & calc_result(1)(24 downto 12) &
        "000" & calc_result(0)(24 downto 12);
    outgoing_transmission <= outgoing_result_transmission & outgoing_state_transmission;

    calc_data <= ((others => '0'), (others => '0')) when not calculation_phase else
        first_data when calculate_edge else
        (incoming_state_transmission(11 downto 0) & own_data_buffer(0), incoming_state_transmission(27 downto 16) & own_data_buffer(1)) when atom_index = 0 else
        (own_data_buffer(0) & incoming_state_transmission(11 downto 0), own_data_buffer(1) & incoming_state_transmission(27 downto 16));

    own_result_wb <= (calc_result(1)(12 downto  0), calc_result(0)(12 downto  0)) when atom_index = 0 else 
                     (calc_result(1)(24 downto 12), calc_result(0)(24 downto 12));

    own_result_wb_index <= 0 when not own_wb_phase else
                           0 when iterator >= own_wb_offset + 15 and atom_index = 0 else
                           16 when iterator >= own_wb_offset + 15 else
                           iterator - own_wb_offset + 1 when atom_index = 0 else
                           iterator + 17 - own_wb_offset;

    remote_result_wb <= (incoming_result_transmission(12 downto 0), incoming_result_transmission(28 downto 16));

    remote_result_wb_index <= 0 when not remote_wb_phase else
                              0 when iterator >= remote_wb_offset + 15 and atom_index = 1 else
                              16 when iterator >= remote_wb_offset + 15 else
                              iterator - remote_wb_offset + 1 when atom_index = 1 else
                              iterator + 17 - remote_wb_offset;

    own_data_request_index <= 0 when not request_phase else
                              iterator - request_offset when atom_index = 0 else
                              iterator + 16 - request_offset;

    full_round_constant <= round_constants.get(round);
    round_constant_part_index <= 0 when not calculation_phase else
                                 0 when calculate_edge and atom_index = 0 else
                                 16 when calculate_edge else
                                 iterator - calculate_offset when atom_index = 0 else
                                 iterator + 16 - calculate_offset;

    calc_round_constant <= full_round_constant(round_constant_part_index * 2 + 1 downto round_constant_part_index * 2);
    
    enable_own_wb <= '1' when own_wb_phase and enable = '1' else '0';

    enable_remote_wb <= '1' when remote_wb_phase and enable = '1' else '0';

    enable_own_data_request <= '1' when request_phase and enable = '1' else '0';

    finished_temp <= '1' when iterator >= remote_wb_offset + 16 else '0';
    finished <= finished_temp;
    
    process(clk, rst) is
    begin
        if rst = '1' then
            iterator <= 0;
        elsif rising_edge(clk) then
            if init = '1' then
                iterator <= 0;
                calc_prev_sums <= (others => '0');
            elsif finished_temp = '0' and enable = '1' then
                own_data_buffer <= own_data;
                if calculation_phase then
                    calc_prev_sums <= calc_result_sums;
                end if;
                if calculate_first then
                    first_data <= calc_data;
                end if;
                iterator <= iterator + 1;
            end if;
        end if;
    end process;

    -- debug signals
    calc_result0 <= calc_result(0);
    calc_result1 <= calc_result(1);

end architecture;