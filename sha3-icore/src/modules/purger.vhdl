library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.util.all;

entity purger is
    port(
        clk : in std_logic;
        start : in std_logic;
        port_a_in : out mem_port_input;
        port_b_in : out mem_port_input;
        ready : out std_logic
    );
end entity;

architecture arch of purger is
    subtype iterator_t is natural range 0 to 16;
    signal iterator : iterator_t := 16;
    signal running : boolean;
begin

    running <= iterator < 16;

    port_a_in.data <= ((others => '0'), (others => '0'));
    port_b_in.data <= ((others => '0'), (others => '0'));

    port_a_in.en <= '0';
    port_b_in.en <= '0';

    port_a_in.we <= asBit(running);
    port_b_in.we <= asBit(running);

    ready <= asBit(not running and start /= '1');

    process(iterator, running) is
    begin
        if running then
            port_a_in.addr <= iterator;
            port_b_in.addr <= iterator + 16;
        else
            port_a_in.addr <= 0;
            port_b_in.addr <= 0;
        end if;
    end process;

    process(clk) is
    begin
        if rising_edge(clk) then
            if running then
                iterator <= iterator + 1;
            elsif start = '1' then
                iterator <= 0;
            end if;
        end if;
    end process;


end architecture arch;