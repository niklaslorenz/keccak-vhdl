library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
use work.rho_shift_buffer;

entity rho_shift_buffer_test is
end entity;

architecture arch of rho_shift_buffer_test is

    component rho_shift_buffer is
        Port (
            clk : in std_logic;
            atom_index : in atom_index_t;
            left_shift : in std_logic;
            data_in : in rho_calc_t;
            data_out : out rho_calc_t
        );
    end component;

    signal clk : std_logic := '0';
    signal finished : boolean := false;

    signal state : block_t;

begin

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    test : process is
    begin
        for i in 1 to 63 loop
            state(i) <= (others => '0');
        end loop;
        state(0) <= (others => '1');
        

        finished <= true;
        wait;
    end process;

end architecture;