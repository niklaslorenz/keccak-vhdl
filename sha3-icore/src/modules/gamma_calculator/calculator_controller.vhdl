library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
use work.util.all;
use work.round_constants.all;

entity calculator_controller is
    port(
        clk : in std_logic;
        enable : in std_logic;
        init : in std_logic;
        atom_index : in atom_index_t;
        round : in round_index_t;
        round_constant : out std_logic_vector(1 downto 0);
        res_a_en : out std_logic;
        res_a_addr : out mem_addr_t;
        res_b_en : out std_logic;
        res_b_addr : out mem_addr_t;
        gam_a_en : out std_logic;
        gam_a_we : out std_logic;
        gam_a_addr : out mem_addr_t;
        gam_b_en : out std_logic;
        gam_b_we : out std_logic;
        gam_b_addr : out mem_addr_t
    );
end entity;

architecture arch of calculator_controller is

    subtype iterator_t is natural range 0 to 50;

    signal iterator : iterator_t;
    signal local_offset, remote_offset : natural range 0 to 16;

begin

    remote_offset <= 16 when atom_index = 0 else 0;
    local_offset <= 0 when atom_index = 0 else 16;

    res_a_en <= asBit(iterator >= 2 and iterator <= 18);
    res_b_en <= asBit(iterator >= 1 and iterator <= 17);

    gam_a_en <= '0';
    gam_b_en <= '0';

    gam_a_we <= asBit(iterator >= 6 and iterator <= 21);
    gam_b_we <= asBit(iterator >= 7 and iterator <= 22);

    process(iterator, atom_index) is
    begin
        if iterator >= 5 and iterator <= 20 then
            round_constant <= round_constants.get(round)((iterator - 5) * 2 + 1 downto (iterator - 5) * 2);
        else
            round_constant <= "00";
        end if;

        if iterator = 2 then
            res_a_addr <= 15 + local_offset;
        elsif iterator >= 3 and iterator <= 18 then
            res_a_addr <= iterator - 3 + local_offset;
        else
            res_a_addr <= 0;
        end if;

        if iterator = 1 then
            res_b_addr <= 15 + remote_offset;
        elsif iterator >= 2 and iterator <= 17 then
            res_b_addr <= iterator - 2 + remote_offset;
        else
            res_b_addr <= 0;
        end if;

        if iterator >= 6 and iterator <= 21 then
            gam_a_addr <= iterator - 6 + local_offset;
        else
            gam_a_addr <= 0;
        end if;

        if iterator >= 7 and iterator <= 22 then
            gam_b_addr <= iterator - 7 + remote_offset;
        else
            gam_b_addr <= 0;
        end if;
    end process;

    process(clk) is
    begin
        if rising_edge(clk) and enable = '1' then
            if init = '1' then
                iterator <= 0;
            elsif iterator <= 50 then
                iterator <= iterator + 1;
            end if;
        end if;
    end process;

end architecture arch;