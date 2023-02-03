library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;

entity slice_manager is
    port(
        -- control
        clk : in std_logic;
        rst : in std_logic;
        init : in std_logic;
        enable : in std_logic;
        atom_index : in atom_index_t;
        
        -- data
        own_data : in tile_computation_data_t;
        incoming_transmission : in lane_t;
        calculation_results : in computation_data_t;

        -- data signals
        outgoing_transmission : out lane_t;
        own_result_wb : out tile_computation_data_t;
        own_result_wb_index : out computation_data_index_t;
        remote_result_wb : out tile_computation_data_t;
        remote_result_wb_index : out computation_data_index_t;
        own_data_request_index : out computation_data_index_t;
        calculation_data : out computation_data_t;
        calculation_data_index : out computation_data_index_t;
        
        -- control signals
        enable_own_wb : out std_logic;
        enable_remote_wb : out std_logic;
        enable_own_data_request : out std_logic;
        calculate_first : out std_logic;
        calculate_loop : out std_logic;
        calculate_edge : out std_logic;
        finished : out std_logic
        
    );
end entity;

architecture arch of slice_manager is

    constant zero : transmission_word_t := (others => '0');

    -- timings
    constant request_offset : natural := 0;
    constant data_receive_offset : natural := 2;
    constant own_wb_offset : natural := 4;
    constant result_receive_offset : natural := 6;
    signal request_phase, data_receive_phase, own_wb_phase, result_receive_phase : boolean;

    subtype iterator_t is natural range 0 to 21;
    signal iterator : iterator_t := 0;

    signal own_data0, own_data1 : tile_slice_t;
    signal own_data_buf0, own_data_buf1 : tile_slice_t;
    signal own_data_buffer0 : tile_computation_data_t;
    signal own_data_buffer1 : tile_computation_data_t;

    signal incoming_state_transmission : transmission_word_t;
    signal incoming_result_transmission : transmission_word_t;
    signal outgoing_state_transmission : transmission_word_t;
    signal outgoing_result_transmission : transmission_word_t;

    signal finished_temp : std_logic;


begin

    request_phase <= (iterator >= request_offset and iterator <= request_offset + 15);
    data_receive_phase <= (iterator >= data_receive_offset and iterator <= data_receive_offset + 15);
    own_wb_phase <= (iterator >= own_wb_offset and iterator <= own_wb_offset + 15);
    result_receive_phase <= (iterator >= result_receive_offset and iterator <= result_receive_offset + 15);

    own_data0 <= own_data(0);
    own_data1 <= own_data(1);

    own_data_buf0 <= own_data_buffer1(0);
    own_data_buf1 <= own_data_buffer1(1);

    incoming_state_transmission <= incoming_transmission(31 downto 0);
    incoming_result_transmission <= incoming_transmission(63 downto 32);

    outgoing_state_transmission <= zero when not request_phase or enable = '0' else
        x"0" & own_data(1)(12 downto 1) &
        x"0" & own_data(0)(12 downto 1) when atom_index = 1 else
        x"0" & own_data(1)(11 downto 0) &
        x"0" & own_data(0)(11 downto 0);

    outgoing_result_transmission <= zero             when not own_wb_phase or enable = '0' else
        "000" & calculation_results(1)(12 downto  0) &
        "000" & calculation_results(0)(12 downto  0) when atom_index = 1 else
        "000" & calculation_results(1)(24 downto 12) &
        "000" & calculation_results(0)(24 downto 12);
    outgoing_transmission <= outgoing_result_transmission & outgoing_state_transmission;

    own_result_wb <= ((others => '0'), (others => '0')) when not own_wb_phase or enable = '0' else
                     (calculation_results(1)(12 downto  0), calculation_results(0)(12 downto  0)) when atom_index = 0 else 
                     (calculation_results(1)(24 downto 12), calculation_results(0)(24 downto 12));

    remote_result_wb <= ((others => '0'), (others => '0')) when not result_receive_phase or enable = '0' else
                        (incoming_state_transmission(27 downto 16), incoming_state_transmission(11 downto 0));

    own_data_request_index <= 0             when not request_phase else
                              iterator      when atom_index = 0 else
                              iterator + 16;

    calculation_data <= ((others => '0'), (others => '0')) when not data_receive_phase or enable = '0' else
                        (incoming_state_transmission(11 downto 0) & own_data_buffer1(0), incoming_state_transmission(27 downto 16) & own_data_buffer1(1)) when atom_index = 0 else
                        (own_data_buffer1(0) & incoming_state_transmission(11 downto 0), own_data_buffer1(1) & incoming_state_transmission(27 downto 16));

    own_result_wb_index <= 0 when not own_wb_phase else
                           0 when iterator = own_wb_offset + 15 and atom_index = 0 else
                           16 when iterator = own_wb_offset + 15 else
                           iterator - own_wb_offset when atom_index = 0 else
                           iterator + 16 - own_wb_offset;
    enable_own_wb <= '1' when own_wb_phase else '0';

    enable_own_data_request <= '1' when request_phase and enable = '1' else '0';

    calculate_first <= '1' when iterator = own_wb_offset - 1 else '0';
    calculate_loop <= '1' when iterator >= own_wb_offset and iterator <= own_wb_offset + 14 else '0';
    calculate_edge <= '1' when iterator = own_wb_offset + 15 else '0';

    finished_temp <= '1' when iterator >= data_receive_offset + 16 else '0';
    finished <= finished_temp;
    
    process(clk, rst) is
    begin
        if rst = '1' then
            iterator <= 0;
        elsif rising_edge(clk) then
            own_data_buffer0 <= own_data;
            own_data_buffer1 <= own_data_buffer0;
            if init = '1' then
                iterator <= 0;
            elsif finished_temp = '0' and enable = '1' then
                iterator <= iterator + 1;
            end if;
        end if;
    end process;

end architecture;