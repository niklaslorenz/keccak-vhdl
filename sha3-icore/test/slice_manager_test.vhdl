library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.state.all;
use work.slice_manager;
use work.util.all;

entity slice_manager_test is
end entity;

architecture arch of slice_manager_test is
    component slice_manager
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

    component block_visualizer is
        port(state : in block_t);
    end component;

    -- control
    signal clk : std_logic := '0';
    signal rst : std_logic;
    signal init : std_logic;
    signal enable : std_logic;
    signal atom_index : atom_index_t;
    signal round : round_index_t := 0;
    signal gamma : std_logic := '1';
    
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
    
    -- control signals
    signal enable_own_wb : std_logic;
    signal enable_remote_wb : std_logic;
    signal enable_own_data_request : std_logic;
    signal manager_finished : std_logic;

    signal finished : boolean := false;

    signal incoming_transmission_buffer : lane_t;

    signal own_wb0, own_wb1, remote_wb0, remote_wb1 : tile_slice_t;
    signal result_state : block_t;
begin

    own_data <= ((others => 'X'), (others => 'X')) when enable_own_data_request = '0' else
        (std_logic_vector(to_unsigned(own_data_request_index * 2, tile_slice_t'length)), std_logic_vector(to_unsigned(own_data_request_index * 2 + 1, tile_slice_t'length)));

    manager : slice_manager port map(clk, rst, atom_index, init, enable, round, gamma, own_data, incoming_transmission,
        outgoing_transmission, own_result_wb, own_result_wb_index, remote_result_wb, remote_result_wb_index, own_data_request_index,
        enable_own_wb, enable_remote_wb, enable_own_data_request, manager_finished);

    result_visual : block_visualizer port map(result_state);

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    process(clk) is
        variable temp_state : block_t;
    begin
        if rising_edge(clk) then
            temp_state := result_state;
            incoming_transmission <= outgoing_transmission;
            if enable = '1' and enable_own_wb = '1' then
                set_computation_data(temp_state, own_result_wb, own_result_wb_index);
            end if;
            if enable = '1' and enable_remote_wb = '1' then
                set_computation_data(temp_state, remote_result_wb, remote_result_wb_index);
            end if;
            result_state <= temp_state;
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
    
    own_wb0 <= own_result_wb(0);
    own_wb1 <= own_result_wb(1);
    remote_wb0 <= remote_result_wb(0);
    remote_wb1 <= remote_result_wb(1);

end architecture;