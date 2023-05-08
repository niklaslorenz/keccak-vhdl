library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.util.all;

entity rho_controller is
    port(
        clk : in std_logic;
        init : in std_logic;
        enable : in std_logic;
        right_shift : out std_logic;
        addr : out mem_addr_t;
        gam_en : out std_logic;
        gam_we : out std_logic;
        res_en : out std_logic;
        res_we : out std_logic;
        ready : out std_logic
    );
end entity;

architecture arch of rho_controller is

    signal iterator : natural range 0 to 55;

begin

    right_shift <= asBit(iterator > 27);

    -- addr
    process(iterator) is
    begin
        -- left shift from gam_mem into gam_mem
        if iterator = 0 then
            addr <= 0;
        elsif iterator <= 8 then
            addr <= iterator + 7;  -- left shift: read slices 8 to 15 into buffer (iteration 1 to 8)
        elsif iterator <= 27 then
            addr <= iterator - 9;  -- left shift: read slices 0 to 15 into buffer (iteration 9 to 24)
                                   --             write back results into memory (iteration 12 to 27)
        elsif iterator <= 35 then
            addr <= 3 + 35 - iterator; -- right shift: read slices 7 down to 0 into buffer (iteration 28 to 35)
        elsif iterator <= 54 then
            addr <= 54 - iterator; -- right shift: read slices 15 down to 0 into buffer (iteration 36 to 51)
                                   --              write back results into memory (iteration 39 to 54)
        end if;
    end process;

    gam_en <= asBit((iterator >= 1 and iterator <= 26) or (iterator >= 28 and iterator <= 53));
    gam_we <= asBit(iterator >= 12 and iterator <= 27);

    res_en <= '0';
    res_we <= asBit(iterator >= 39 and iterator <= 54);

    ready <= asBit(iterator = 55);

    process(clk) is
    begin
        if rising_edge(clk) and enable = '1' then
            if init = '1' then
                iterator <= 0;
            elsif iterator < 55 then
                iterator <= iterator + 1;
            end if;
        end if;
    end process;

end architecture arch;