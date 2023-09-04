library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.util.all;

entity rho_controller is
    port(
        clk : in std_logic;
        init : in std_logic;
        right_shift : out std_logic;
        addr_high : out mem_addr_t;
        addr_low : out mem_addr_t;
        gam_en : out std_logic;
        gam_we : out std_logic;
        res_en : out std_logic;
        res_we : out std_logic;
        ready : out std_logic
    );
end entity;

architecture arch of rho_controller is

    constant iterator_max : natural := 55;
    constant prepare_ls_buffer_offset : natural := 1;
    constant prepare_buffer_duration : natural := 8;
    constant ls_offset : natural := 9;
    constant shift_duration : natural := 19;
    constant prepare_rs_buffer_offset : natural := 28;
    constant rs_offset : natural := 36;
    
    subtype iterator_t is natural range 0 to iterator_max;
    signal iterator : iterator_t := iterator_max;

    signal addr : mem_addr_t;

    signal running : boolean;
    signal right_shift_part : boolean;
    signal preparing_ls_buffer : boolean;
    signal preparing_rs_buffer : boolean;
    signal perform_ls : boolean;
    signal perform_rs : boolean;
    signal using_memory : boolean;

begin

    running <= iterator < iterator_max or init = '1';
    right_shift_part <= iterator >= prepare_rs_buffer_offset;

    preparing_ls_buffer <= iterator >= prepare_ls_buffer_offset and iterator < prepare_ls_buffer_offset + prepare_buffer_duration;
    preparing_rs_buffer <= iterator >= prepare_rs_buffer_offset and iterator < prepare_rs_buffer_offset + prepare_buffer_duration;
    perform_ls <= iterator >= ls_offset and iterator < ls_offset + shift_duration;
    perform_rs <= iterator >= rs_offset and iterator < rs_offset + shift_duration;
    using_memory <= preparing_ls_buffer or preparing_rs_buffer or perform_ls or perform_rs;

    right_shift <= asBit(right_shift_part);

    addr <= filterAddress(iterator + 8, prepare_ls_buffer_offset, preparing_ls_buffer) or
            filterAddress(iterator, ls_offset, perform_ls) or
            filterAddress(prepare_rs_buffer_offset + prepare_buffer_duration + 2, iterator, preparing_rs_buffer) or
            filterAddress(rs_offset + shift_duration - 1, iterator, perform_rs);

    addr_high <= filterAddress(2 * addr + 1, 0, using_memory);
    addr_low  <= filterAddress(2 * addr    , 0, using_memory);

    -- addr
    --process(iterator) is
    --begin
        -- left shift from gam_mem into gam_mem
        --if iterator = 0 then
        --    addr <= 0;
        --elsif iterator <= 8 then
        --    addr <= iterator + 7;  -- left shift: read slices 8 to 15 into buffer (iteration 1 to 8)
        --elsif iterator <= 27 then
        --    addr <= iterator - 9;  -- left shift: read slices 0 to 15 into buffer (iteration 9 to 24)
        --                           --             write back results into memory (iteration 12 to 27)
        --elsif iterator <= 35 then
        --    addr <= 3 + 35 - iterator; -- right shift: read slices 7 down to 0 into buffer (iteration 28 to 35)
        --elsif iterator <= 54 then
        --    addr <= 54 - iterator; -- right shift: read slices 15 down to 0 into buffer (iteration 36 to 51)
        --                           --              write back results into memory (iteration 39 to 54)
        --end if;
    --end process;

    gam_en <= asBit((iterator >= 1 and iterator <= 53));
    gam_we <= asBit(iterator >= 12 and iterator <= 27);

    res_en <= '0';
    res_we <= asBit(iterator >= 39 and iterator <= 54);

    ready <= asBit(not running);

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