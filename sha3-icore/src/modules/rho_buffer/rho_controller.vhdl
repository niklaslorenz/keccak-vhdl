library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
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
        res_we : out std_logic
    );
end entity;

architecture arch of rho_controller is

    signal iterator : natural range 0 to 28;

begin

    right_shift <= asBit(iterator > 28);

    -- addr
    process(iterator) is
    begin
        -- left shift from gam_mem into gam_mem
        if iterator = 0 then
            addr <= 0;
        elsif iterator >= 1 and iterator <= 8 then
            addr <= iterator + 7; -- read slices 8 to 15 into buffer (iteration 1 to 8)
        elsif iterator <= 27 then
            addr <= iterator - 9; -- read slices 0 to 15 into buffer (iteration 9 to 24)
        end if;

        -- right shift from gam_mem into res_mem
        --elsif iterator >= 1 and iterator <= 8 then
        --    addr <= iterator - 1; -- read slices 0 to 7 into buffer
        --elsif iterator <= 27 then
        --    addr <= iterator - 9; -- read slices 0 to 15 into buffer 
        --end if;
    end process;

    -- gam_en, gam_we
    process(iterator) is
    begin
        -- left shift
        if iterator >= 1 and iterator <= 26 then
            gam_en <= '1';
        else
            gam_en <= '0';
        end if;
        if iterator >= 12 and iterator <= 27 then
            gam_we <= '1';
        else
            gam_we <= '0';
        end if;
    end process;

    process(clk) is
    begin
        if rising_edge(clk) and enable = '1' then
            if init = '1' then
                iterator <= 0;
            elsif iterator < 28 then
                iterator <= iterator + 1;
            end if;
        end if;
    end process;

end architecture arch;