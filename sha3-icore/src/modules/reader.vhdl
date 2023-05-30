library IEEE;

use IEEE.std_logic_1164.all;
use work.types.all;
use work.util.all;

entity reader is
    port(
        clk : in std_logic;
        init : in std_logic;
        enable : in std_logic;
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
    constant writing_offset : integer := 4;
    constant writing_duration : integer := 32;


    subtype iterator_t is integer range 0 to iterator_max;
    signal iterator : iterator_t := 0;

    signal transmission_low, transmission_high : std_logic_vector(31 downto 0);
    signal data : quad_tile_slice_t;
    signal writing_data : double_tile_slice_t;

begin

    transmission_low <= transmission(31 downto 0);
    transmission_high <= transmission(63 downto 32);

    data(0) <= transmission_low (12 downto  0);
    data(1) <= transmission_low (28 downto 16);
    data(2) <= transmission_high(12 downto  0);
    data(3) <= transmission_high(28 downto  16);

    writing_data <= (data(1), data(0)) when (iterator - writing_offset) mod 2 = 0 else (data(3), data(2));

    mem_input_a.en <= asBit(iterator >= reading_offset and iterator < reading_offset + reading_duration);
    mem_input_a.we <= '0';
    mem_input_a.addr <= 0;
    mem_input_a.data <= ((others => '0'), (others => '0'));

    mem_input_b.en <= '0';
    mem_input_b.we <= asBit(iterator >= writing_offset and iterator < writing_offset + writing_duration);
    mem_input_b.addr <= iterator - writing_offset;
    mem_input_b.data <= writing_data xor mem_output_a.data when enable = '1' else ((others => '0'), (others => '0'));

    ready <= asBit(iterator = iterator_max);

    process(clk) is
    begin
        if rising_edge(clk) and enable = '1' then
            if init = '1' then
                iterator <= 0;
            elsif iterator < iterator_max then
                iterator <= iterator + 1;
            end if;
        end if;
    end process;

end architecture arch;
