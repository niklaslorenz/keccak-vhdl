library IEEE;
use IEEE.std_logic_1164.all;
use work.multi_lane_buffer;
use work.state.all;

entity multi_lane_buffer_test is
end entity;

architecture arch of multi_lane_buffer_test is

    component multi_lane_buffer is
        port(
            clk : in std_logic;
            atom_index : atom_index_t;
            right_shift : in std_logic;
            input : in multi_buffer_data_t;
            output : out multi_buffer_data_t
        );
    end component;

    signal clk : std_logic := '0';
    signal finished : boolean := false;

    signal atom_index : atom_index_t;
    signal right_shift : std_logic;
    signal input : multi_buffer_data_t;
    signal output : multi_buffer_data_t;

begin

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    buf : multi_lane_buffer port map(clk, atom_index, right_shift, input, output);

    test : process is
    begin
        
        finished <= true;
        wait;
    end process;

end architecture arch;