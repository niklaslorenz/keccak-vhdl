library IEEE;

use IEEE.std_logic_1164.all;
use work.types.all;
use work.util.all;

entity reader is
    port(
        clk : in std_logic;
        init : in std_logic;
        enable : in std_logic;
        atom_index : in std_logic;
        transmission : in transmission_t;
        mem_input : out mem_port_input;
        ready : out std_logic
    );
end entity;

architecture arch of reader is

    subtype iterator_t is natural range 0 to 33;

    signal iterator : iterator_t := 0;

    signal transmission_low, transmission_hgh : std_logic_vector(31 downto 0);

    signal slice_high, slice_low : slice_t;

    signal tile_high, tile_low : tile_slice_t;

    signal data : double_tile_slice_t;

begin

    transmission_low <= transmission(31 downto 0);
    transmission_high <= transmission(63 downto 32);

    slice_high <= transmission_high(24 downto 0);
    slice_low <= transmission_low(24 downto 0);

    tile_high <= slice_high(12 downto 0) when atom_index = 0 else slice_high(24 downto 12);
    tile_low <= slice_low(12 downto 0) when atom_index = 0 else slice_low(24 downto 12);
    
    data <= (tile_high, tile_low);

    mem_input.en <= 0;
    mem_input.we <= asBit(iterator >= 1 and iterator <= 32);
    mem_input.data <= data when enable = '1' else ((others => '0'), (others => '0'))

    ready <= asBit(iterator = 17);

    process(iterator) is
    begin
        if iterator = 0 then
            mem_input.addr <= 0
        elsif iterator <= 32 then
            mem_input.addr <= iterator - 1;
        else
            mem_input.addr <= 0;
        end if;
    end process;

    process(clk) is
    begin
        if rising_edge(clk) and enable = '1' then
            if init = '1' then
                iterator <= 0;
            elsif iterator < 33 then
                iterator <= iterator + 1;
            end if;
        end if;
    end process;

end architecture arch;
