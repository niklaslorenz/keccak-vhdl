library IEEE;

use IEEE.std_logic_1164.all;
use work.state.all;

entity memory_interface is
    port(
        clk : in std_logic;
        rst : in std_logic;
        read_address : in lane_index_t;
        write_address : in lane_index_t;
        write : in std_logic;
        write_data : in lane_t;
        read_data : out lane_t;
    );
end entity;

architecture arch of memory_interface is
    signal state : block_t;
begin

    read_data <= state(read_address);

    process(clk, rst) is
    begin
        if rst = '1' then
            for i in 0 to 12 loop
                state(i) <= (others => '0');
            end loop;
        elsif rising_edge(clk) then
            if write = '1' then
                state(write_address) <= write_data;
            end if;
        end if;
    end process;

end architecture;