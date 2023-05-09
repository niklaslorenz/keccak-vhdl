library IEEE;
use IEEE.std_logic_1164.all;

entity writer is
    port(
        clk : in std_logic;
        rst : in std_logic;
        init : in std_logic;
        enable : in std_logic;
        atom_index : in atom_index_t;
        mem_input_a : out mem_port_input;
        mem_output_a : in mem_port_output;
        mem_input_b : out mem_port_input;
        mem_output_b : in mem_port_output;
        transmission : out transmission_t;
        transmission_active : out std_logic;
        ready : out std_logic
    );
end entity;

architecture arch of writer is

    subtype iterator_t is natural range 0 to 21;
    signal iterator : iterator_t;

    type hash_t is array(natural range 0 to 3) of std_logic_vector(63 downto 0);
    signal hash : hash_t;

    signal active_mem_input_a, active_mem_input_b : mem_port_input;

begin

    mem_input_a <= active_mem_input_a when atom_index = 0 else mem_port_input_init;
    mem_input_b <= active_mem_input_b when atom_index = 0 else mem_port_input_init;

    active_mem_input_a.en <= asBit(iterator > 0 and iterator <= 16);
    active_mem_input_b.en <= asBit(iterator > 0 and iterator <= 16);

    active_mem_input_a.we <= '0';
    active_mem_input_b.we <= '0';

    ready <= asBit(iterator = 21);

    process(clk) is
    begin
        if rising_edge(clk) and enable = '1' then
            if iterator >= 3 and iterator <= 18 then
                for i in 0 to 3 loop
                    hash(i)((iterator - 3) * 4 + 3 downto (iterator - 3) * 4) <= (mem_output_b(1)(i), mem_output_b(0)(i), mem_output_a(1)(i), mem_output(0)(i));
                end loop;
            end if;
        end if;
    end process;

    process(iterator) is
    begin
        if iterator = 0 then
            active_mem_input_a.addr <= 0;
            active_mem_input_b.addr <= 0;
        elsif iterator <= 16 then
            active_mem_input_a.addr <= (iterator - 1) * 2;
            active_mem_input_b.addr <= (iterator - 1) * 2 + 1;
        else
            active_mem_input_a.addr <= 0;
            active_mem_input_b.addr <= 0;
        end if;
    end process;

    process(iterator) is
    begin
        if iterator >= 17 and iterator <= 20 then
            transmission <= hash(iterator - 17);
            tramsmission_active <= '1';
        else
            transmission <= (others => '0');
            transmission_active <= '0';
        end if;
    end process;

    process(clk) is
    begin
        if rising_edge(clk) and enable = '1' then
            if init = '1' then
                iterator <= 0;
            elsif iterator < 21 then
                iterator <= iterator + 1;
            end if;
        end if;
    end process;

end architecture;