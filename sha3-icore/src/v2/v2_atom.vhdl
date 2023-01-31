library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
use work.v2_state.all;
use work.sha3_atom;

architecture arch_v2 of sha3_atom is
	
	component v2_reader is
    port(
        clk : in std_logic;
        rst : in std_logic;
        init : in std_logic;
        enable : in std_logic;
        atom_index : in v2_atom_index_t;
        data_in : in lane_t;
        data_out : out lane_part_t;
        index : out lane_index_t;
        valid : out std_logic;
        finished : out std_logic
    );
    end component;
    
    component calculator is
    port(
        slice : in slice_t;
        prev_sums : in std_logic_vector(4 downto 0);
        theta_only : in std_logic;
        no_theta : in std_logic;
        round_constant_bit : in std_logic;
        result : out slice_t;
        slice_sums : out std_logic_vector(4 downto 0)
    );
    end component;
	
	type mode_t is (read_init, read, theta, rho, gamma, valid, write_init, write);
	signal state : v2_block_t;
    signal mode : mode_t;
    
    -- reader
    -- inputs
    signal reader_init : std_logic;
    signal reader_enable : std_logic;
    -- outputs
    signal reader_data_out : lane_part_t;
    signal reader_index : lane_index_t;
    signal reader_valid : std_logic;
    signal reader_finished : std_logic;
    
    -- slice manager
    
    -- calculator
    -- inputs
    signal calc_input_slice : slice_t;
    signal calc_prev_sums : std_logic_vector(4 downto 0);
    signal calc_theta_only : std_logic;
    signal calc_no_theta : std_logic;
    signal calc_round_constant_bit : std_logic;
    -- outputs
    signal calc_result : slice_t;
    signal calc_slice_sums : std_logic_vector(4 downto 0);
    
    -- lane manager
    
    -- writer
    
    
begin

    reader : v2_reader port map(clk, rst, reader_init, reader_enable, atom_index, data_in, reader_data_out, reader_index, reader_valid, reader_finished);

    

    calc : calculator port map(calc_input_slice, calc_prev_sums, calc_theta_only, calc_no_theta, calc_round_constant_bit, calc_result, calc_slice_sums);

    process(clk) is
    begin
        -- reader
        if mode = read_init then
            reader_init <= '1';
            reader_enable <= '0';
            mode <= read; -- read_init -> read
        elsif mode = read then
            reader_init <= '0';
            reader_enable <= '1';
            if reader_valid = '1' then
                state(reader_index) <= reader_data_out;
            end if;
            if reader_finished = '1' then
                mode <= theta; -- read -> theta
            end if;
        else
            reader_init <= '0';
            reader_enable <= '0';
        end if;
        
        -- theta / gamma
        
        -- rho
        
        -- reader
        
    end process;

end architecture;
