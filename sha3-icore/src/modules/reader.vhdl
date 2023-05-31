library IEEE;

use IEEE.std_logic_1164.all;
use work.types.all;
use work.util.all;

entity reader is
    port(
        clk : in std_logic;
        init : in std_logic;
        transmission : in transmission_t;
        mem_input_a : out mem_port_input;
        mem_output_a : in mem_port_output;
        mem_input_b : out mem_port_input;
        ready : out std_logic
    );
end entity;

architecture arch of reader is

    constant iterator_max : integer := 50;
    constant reading_offset : integer := 1;
    constant reading_duration : integer := 32;
    constant writing_offset : integer := 2;
    constant writing_duration : integer := 32;


    subtype iterator_t is integer range 0 to iterator_max;
    signal iterator : iterator_t := iterator_max;
    signal reading : boolean;
    signal writing : boolean;

    signal transmission_low, transmission_high : std_logic_vector(31 downto 0);
    signal data : quad_tile_slice_t;
    signal writing_data : double_tile_slice_t;

begin

    reading <= iterator >= reading_offset and iterator < reading_offset + reading_duration;
    writing <= iterator >= writing_offset and iterator < writing_offset + writing_duration;

    transmission_low <= transmission(31 downto 0);
    transmission_high <= transmission(63 downto 32);

    data(0) <= transmission_low (12 downto  0);
    data(1) <= transmission_low (28 downto 16);
    data(2) <= transmission_high(12 downto  0);
    data(3) <= transmission_high(28 downto  16);

    with (iterator - writing_offset) mod 2 select writing_data <=
        double_tile_slice_t(data(1 downto 0)) when 0,
        double_tile_slice_t(data(3 downto 2)) when others;

    mem_input_a.en <= asBit(reading);
    mem_input_a.we <= '0';
    mem_input_a.addr <= filterAddress(iterator, reading_offset, reading);
    mem_input_a.data <= dt_zero;

    mem_input_b.en <= '0';
    mem_input_b.we <= asBit(writing);
    mem_input_b.addr <= filterAddress(iterator, writing_offset, writing);
    mem_input_b.data <= filterData(writing_data xor mem_output_a.data, writing);

    ready <= asBit(iterator = iterator_max);

    process(clk) is
    begin
        if rising_edge(clk) then
            if init = '1' then
                iterator <= 0;
            elsif iterator < iterator_max then
                iterator <= iterator + 1;
            end if;
        end if;
    end process;

end architecture arch;
