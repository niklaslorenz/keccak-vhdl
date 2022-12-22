
library IEEE;
use IEEE.std_logic_1164.all;

-- The statemachine for the write phase
entity sm_write is
port(
    clk : in std_logic;
    rst : in std_logic;
    enabled : in std_logic;
    init : in std_logic;

    target : out natural range 0 to 12;
    done : out std_logic;
    valid : out std_logic
);
end entity;

architecture arch of sm_write is
    signal index : natural range 0 to 12;
    signal vld : std_logic;
begin

    process(clk, rst) is
    begin
        if rst = '1' then
            index <= 0;
            vld <= '0';
        elsif rising_edge(clk) then
            if init = '1' then
                index <= 0;
            elsif enabled = '1' and not done = '1' then
                index <= index + 1;
            end if;

            if not init = '1' and enabled = '1' and not done = '1' then
                vld <= '1';
            else
                vld <= '0';
            end if;
        end if;
    end process;

    target <= index;
    done <= index = 12;
    valid <= vld;

end architecture arch;
