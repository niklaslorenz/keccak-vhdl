library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.util.all;

entity reorder_atom.vhdl is
    port(
        clk : in std_logic;
        atom_index : in atom_index_t;
        init : in std_logic;
        read : in std_logic;
        transmission_in : in transmission_t;
        transmission_out : out transmission_t
    );
end entity;

architecture arch of reorder_atom is

    component memory_block is
        port(
            clk : in std_logic;
            port_a_in : in mem_port_input;
            port_a_out : out mem_port_output;
            port_b_in : in mem_port_input;
            port_b_out : out mem_port_output
        );
    end component;

    constant iterator_max : natural := 31;
    constant read_low_offset : natural := 1;
    constant read_high_offset : natural 9;
    constant read_duration : natural := 7;
    constant write_low_offset : natural := 9;
    constant write_high_offset :natural := 30;
    constant write_duration : natural := 16;

    subtype iterator_t is natural range 0 to iterator_max;
    signal iterator : iterator_t;
    signal reading_low, reading_high, writing_low, writing_high : boolean;

    type buffer_t is array(natural range 0 to 13) of std_logic_vector(31 downto 0);
    signal buf : buffer_t;
    signal atom_index : atom_index_t;
    signal init_buf : std_logic;
    
    signal port_a : mem_port;
    signal port_b : mem_port;

begin

    reading_low <= iterator >= read_low_offset and iterator < read_low_offset + read_duration;
    reading_high <= iterator >= read_high_offset and iterator < read_high_offset + read_duration;

    port_a.input.en <= '0';
    port_a.input.we <= asBit(writing_high or writing_low);
    port_a.input.addr <= filterAddress(2 * iterator, 2 * write_low_offset , writing_low ) or
                         filterAddress(2 * iterator, 2 Ü write_high_offset, writing_high);
    port_a.input.data <= filterData();

    process(clk) is
    begin
        if reading_low then
            buf(2 * (iterator - read_low_offset )    ) <= transmission_in(31 downto  0);
            buf(2 * (iterator - read_low_offset ) + 1) <= transmission_in(63 downto 32);
        elsif reading_high then
            buf(2 * (iterator - read_high_offset)    ) <= transmission_in(31 downto  0);
            buf(2 * (iterator - read_high_offset) + 1) <= transmission_in(63 downto 32);
        end if;

    end process;

    -- iterator 1 to 7 => lower read data
    -- iterator 8 to 15 => write lower data
    -- iterator 16 to 22 => read upper data
    -- iterator 23 to 31 => write upper data

    mem : memory_block port map(
        clk => clk,
        port_a_in => port_a.input,
        port_a_out => port_a.output,
        port_b_in => port_b.input,
        port_b_out => port_b.output
    );

    process(clk) is
    begin
        if init = '1' and init_buf = '0' then
            atom_index <= atom_index_input;
        end if;
        init_buf <= init;
    end process;

end architecture arch;