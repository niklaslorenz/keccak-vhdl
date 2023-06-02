library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.util.all;

entity calculator_controller is
    port(
        clk : in std_logic;
        enable : in std_logic;
        init : in std_logic;
        atom_index : in atom_index_t;
        round : in round_index_t;
        round_constant_slice : out std_logic_vector(1 downto 0);
        res_a_en : out std_logic;
        res_a_addr : out mem_addr_t;
        res_b_en : out std_logic;
        res_b_addr : out mem_addr_t;
        gam_a_en : out std_logic;
        gam_a_we : out std_logic;
        gam_a_addr : out mem_addr_t;
        gam_b_en : out std_logic;
        gam_b_we : out std_logic;
        gam_b_addr : out mem_addr_t;
        ready : out std_logic
    );
end entity;

architecture arch of calculator_controller is

    constant iterator_max : natural := 22;
    constant reading_local_offset : natural := 1;
    constant reading_remote_offset : natural := 2;
    constant reading_duration : natural := 19;
    constant writing_local_offset : natural := 5;
    constant writing_remote_offset : natural := 6;
    constant writing_duration : natural := 16;

    subtype iterator_t is natural range 0 to iterator_max;
    signal iterator : iterator_t;
    signal local_offset, remote_offset : natural range 0 to 16;

    signal reading_local : boolean;
    signal reading_remote : boolean;
    signal writing_local : boolean;
    signal writing_remote : boolean;

begin

    remote_offset <= 16 when atom_index = 0 else 0;
    local_offset <= 0 when atom_index = 0 else 16;

    reading_local <= iterator >= reading_local_offset and iterator < reading_local_offset + reading_duration;
    reading_remote <= iterator >= reading_remote_offset and iterator < reading_remote_offset + reading_duration;
    writing_local  <= iterator >= writing_local_offset and iterator < writing_local_offset + writing_duration;
    writing_remote <= iterator >= writing_remote_offset and iterator < writing_remote_offset + writing_duration;

    res_a_en <= asBit(reading_remote);
    res_b_en <= asBit(reading_local);

    gam_a_en <= '0';
    gam_a_we <= asBit(writing_local);
    gam_a_addr <= filterAddress(iterator + local_offset, writing_local_offset, writing_local);

    gam_b_en <= '0';
    gam_b_we <= asBit(writing_remote);
    gam_b_addr <= filterAddress(iterator + remote_offset, writing_remote_offset, writing_remote);

    ready <= asBit(iterator = 22);

    process(iterator, atom_index) is
    begin
        if iterator >= 5 and iterator <= 20 then
            round_constant_slice <= round_constant(round)((iterator - 5) * 2 + 1 downto (iterator - 5) * 2);
        else
            round_constant_slice <= "00";
        end if;

        if iterator = 2 then
            res_a_addr <= 15 + remote_offset;
        elsif iterator >= 3 and iterator <= 18 then
            res_a_addr <= iterator - 3 + local_offset;
        else
            res_a_addr <= 0;
        end if;

        if iterator = 1 then
            res_b_addr <= 15 + local_offset;
        elsif iterator >= 2 and iterator <= 17 then
            res_b_addr <= iterator - 2 + remote_offset;
        else
            res_b_addr <= 0;
        end if;
    end process;

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