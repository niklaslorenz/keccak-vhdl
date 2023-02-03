library IEEE;

use IEEE.std_logic_1164.all;
use work.state.all;

entity reader is
    port(
        clk : in std_logic;
        rst : in std_logic;
        init : in std_logic;
        enable : in std_logic;
        atom_index : in atom_index_t;
        index : out lane_index_t;
        valid : out std_logic;
        finished : out std_logic
    );
end entity;

architecture arch of reader is

    subtype iterator_t is natural range 0 to 16;

    signal iterator : iterator_t := 0;
    signal is_valid : std_logic;

begin

    is_valid <= '1' when (iterator <= 12 and atom_index = 0) or (iterator >= 12 and atom_index = 1) else '0';
    index <= 0          when is_valid = '0'   else
             iterator   when atom_index = 0   else
             iterator - 12;
    finished <= '1' when iterator = 16 else '0';
    valid <= is_valid;

    process(clk, rst) is
    begin
        if rst = '1' then
            iterator <= 0;
        elsif rising_edge(clk) then
            if init = '1' then
                iterator <= 0;
            elsif enable = '1' and iterator < 16 then
                iterator <= iterator + 1;
            end if;
        end if;
    end process;

end architecture;