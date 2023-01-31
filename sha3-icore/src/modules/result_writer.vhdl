library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;

entity result_writer is
    port(
        clk : in std_logic;
        rst : in std_logic;
        enable : in std_logic;
        init : in std_logic;
        state : in block_t;
        output : out lane_t;
        finished : out std_logic
    );
end entity;

architecture arch of result_writer is

    signal iterator : natural range 0 to 4 := 0;

begin

    finished <= '1' when iterator >= 3 else '0';

    process(clk, rst) is
    begin
        if rst = '1' then
            iterator <= 0;
            output <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                if init = '1' then
                    output <= state(0);
                    iterator <= 1;
                else
                    if iterator <= 3 then
                        output <= state(iterator);
                        iterator <= iterator + 1;
                    else
                        output <= (others => '0');
                    end if;
                end if;
            else
                output <= (others => '0');
            end if;
        end if;
    end process;

end architecture;