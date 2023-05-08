library IEEE;

use IEEE.std_logic_1164.all;
use work.types.all;

entity reader is
    port(
        clk : in std_logic;
        rst : in std_logic;
        init : in std_logic;
        enable : in std_logic;
        atom_index : in atom_index_t;
        data_in : in lane_t;
        index : out natural range 0 to 31;
        data_out : out std_logic_vector(25 downto 0);
        write_enable : out std_logic;
        finished : out std_logic
    );
end entity;

architecture arch of reader is

    subtype iterator_t is natural range 0 to 32;

    signal iterator : iterator_t := 0;

begin

    process(iterator, atom_index, data_in) is
    begin
        if iterator /= 32 then
            write_enable <= '1';
            index <= iterator;
            if atom_index = 0 then
                data_out <= data_in(44 downto 32) & data_in(12 downto 0);
            else
                data_out <= data_in(56 downto 44) & data_in(24 downto 12);
            end if;
        else
            data_out <= (others => '0');
            write_enable <= '0';
            index <= 0;
        end if;
        if iterator >= 31 then
            finished <= '1';
        else
            finished <= '0';
        end if;
    end process;

    process(clk, rst) is
    begin
        if rst = '1' then
            iterator <= 0;
        elsif rising_edge(clk) then
            if init = '1' then
                iterator <= 0;
            elsif enable = '1' and iterator < 32 then
                iterator <= iterator + 1;
            end if;
        end if;
    end process;

end architecture;