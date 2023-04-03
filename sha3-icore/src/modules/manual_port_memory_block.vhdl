library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;

entity manual_port_memory_block is
    port(
        clk : in std_logic;
        manual : in std_logic;
        manual_in : in mem_port_input;
        port_a_in : in mem_port_input;
        port_a_out : out tile_computation_data_t;
        port_b_in : in mem_port_input;
        port_b_out : out tile_computation_data_t
    );
end entity;

architecture arch of manual_port_memory_block is

    component memory_block is
        port(
            clk : in std_logic;
            port_a_in : in mem_port_input;
            port_a_out : out tile_computation_data_t;
            port_b_in : in mem_port_input;
            port_b_out : out tile_computation_data_t
        );
    end component;

    signal a_in : mem_port_input;
    signal b_in : mem_port_input;

begin

    a_in <= manual_in when manual = '1' else port_a_in;
    b_in <= (addr => 0, data => (others => (others => '0')), en => '0', we => '0') when manual = '1' else port_b_in;

    mem : memory_block port map(clk, a_in, port_a_out, b_in, port_b_out);

end architecture;