library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
use work.gamma_calculator;
use work.manual_port_memory_block;

entity gamma_calculator_test is
end entity;

architecture arch of gamma_calculator_test is

    signal clk : std_logic := '0';
    signal finished : boolean := false;

begin

    test : process is
    begin
        


        finished <= true;
        wait;
    end process;

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

end architecture arch;