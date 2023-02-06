library IEEE;
use IEEE.std_logic_1164.all;

entity writer is
    port(
        clk : in std_logic;
        rst : in std_logic;
        init : in std_logic;
        enable : in std_logic;
        index : out natural range 0 to 3;
        finished : out std_logic
    );
end entity;

architecture arch of writer is
    subtype iterator_t is natural range 0 to 3;
    signal iterator : iterator_t;
    signal finished_temp : std_logic;
begin

    index <= iterator;
    finished_temp <= '1' when iterator = 3 else '0';
    finished <= finished_temp;

    process(clk, rst) is
    begin
        if rst = '1' then
            iterator <= 0;
        elsif rising_edge(clk) and enable = '1' then
            if init = '1' then
                iterator <= 0;
            else
                if finished_temp = '0' then
                    iterator <= iterator + 1;
                end if;
            end if;
        end if;
    end process;

end architecture;