library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.util.all;

entity writer is
    port(
        clk : in std_logic;
        init : in std_logic;
        atom_index : in atom_index_t;
        mem_input_a : out mem_port_input;
        mem_output_a : in mem_port_output;
        mem_input_b : out mem_port_input;
        mem_output_b : in mem_port_output;
        transmission : out transmission_t;
        ready : out std_logic
    );
end entity;

architecture arch of writer is

    constant iterator_max : natural := 25;
    constant read_offset : natural := 1;
    constant read_duration : natural := 16;
    constant write_offset : natural := 2;
    constant write_duration : natural := 16;
    constant transmit_offset : natural := 20;
    constant transmit_duration : natural := 4;

    subtype iterator_t is natural range 0 to iterator_max;
    signal iterator : iterator_t := iterator_max;

    type hash_t is array(natural range 0 to 3) of std_logic_vector(63 downto 0);
    signal hash : hash_t;

    signal running : boolean;
    signal reading : boolean;
    signal writing : boolean;
    signal transmitting : boolean;

begin

    running <= iterator < iterator_max or init = '1';
    reading <= iterator >= read_offset and iterator < read_offset + read_duration and atom_index = 0;
    writing <= iterator >= write_offset and iterator < write_offset + write_duration and atom_index = 0;
    transmitting <= iterator >= transmit_offset and iterator < transmit_offset + transmit_duration and atom_index = 0;
    
    mem_input_a.en <= asBit(reading);
    mem_input_a.we <= '0';
    mem_input_a.addr <= filterAddress(2 * iterator    , 2 * read_offset, reading);
    mem_input_a.data <= dt_zero;

    mem_input_b.en <= asBit(reading);
    mem_input_b.we <= '0';
    mem_input_b.addr <= filterAddress(2 * iterator + 1, 2 * read_offset, reading);
    mem_input_b.data <= dt_zero;

    ready <= asBit(not running);

    process(clk) is
    begin
        if rising_edge(clk) then
            if writing then
                for i in 0 to 3 loop
                    hash(i)((iterator - write_offset) * 4 + 3 downto (iterator - write_offset) * 4) <= (mem_output_b.data(1)(i), mem_output_b.data(0)(i), mem_output_a.data(1)(i), mem_output_a.data(0)(i));
                end loop;
            end if;
            if transmitting then
                transmission <= hash(iterator - transmit_offset);
            else
                transmission <= (others => '0');
            end if;
        end if;
    end process;

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

end architecture;