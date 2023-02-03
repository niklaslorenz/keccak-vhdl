library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.state.all;
use work.slice_manager;

entity slice_manager_test is
end entity;

architecture arch of slice_manager_test is
    component slice_manager
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
    end component;
    -- control
    signal clk : std_logic := '0';
    signal rst : std_logic;
    signal init : std_logic;
    signal enable : std_logic;
    signal atom_index : atom_index_t;
    
    -- data
    signal own_data : tile_computation_data_t;
    signal incoming_transmission : lane_t;
    signal calculation_results : computation_data_t;

    -- data signals
    signal outgoing_transmission : lane_t;
    signal own_result_wb : tile_computation_data_t;
    signal own_result_wb_index : computation_data_index_t;
    signal remote_result_wb : tile_computation_data_t;
    signal remote_result_wb_index : computation_data_index_t;
    signal own_data_request_index : computation_data_index_t;
    signal calculation_data : computation_data_t;
    signal calculation_data_index : computation_data_index_t;
    
    -- control signals
    signal enable_own_wb : std_logic;
    signal enable_remote_wb : std_logic;
    signal enable_own_data_request : std_logic;
    signal calculate_first : std_logic;
    signal calculate_loop : std_logic;
    signal calculate_edge : std_logic;
    signal manager_finished : std_logic;

    signal finished : boolean := false;

    signal calculation_data0, calculation_data1 : slice_t;
    signal incoming_transmission_buffer : lane_t;
begin

    own_data <= ((others => 'X'), (others => 'X')) when enable_own_data_request = '0' else
        (std_logic_vector(to_unsigned(own_data_request_index * 2, tile_slice_t'length)), std_logic_vector(to_unsigned(own_data_request_index * 2 + 1, tile_slice_t'length)));

    calculation_data0 <= calculation_data(0);
    calculation_data1 <= calculation_data(1);

    manager : slice_manager port map(clk, rst, init, enable, atom_index, own_data, incoming_transmission, calculation_results,
        outgoing_transmission, own_result_wb, own_result_wb_index, remote_result_wb, remote_result_wb_index, own_data_request_index,
        calculation_data, calculation_data_index, enable_own_wb, enable_remote_wb, enable_own_data_request, calculate_first,
        calculate_loop, calculate_edge, manager_finished);

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    process(clk) is
    begin
        if rising_edge(clk) then
            incoming_transmission <= incoming_transmission_buffer;
            incoming_transmission_buffer <= outgoing_transmission;
            calculation_results <= calculation_data;
        end if;
    end process;

    test : process is
    begin
        wait for 2ns;
        rst <= '1';
        init <= '0';
        enable <= '0';
        atom_index <= 0;
        wait for 2ns;
        rst <= '0';
        wait until rising_edge(clk);
        init <= '1';
        wait until rising_edge(clk);
        init <= '0';
        enable <= '1';
        for i in 0 to 30 loop
            wait until rising_edge(clk);
        end loop;
        

        finished <= true;
        wait;
    end process;
    

end architecture;