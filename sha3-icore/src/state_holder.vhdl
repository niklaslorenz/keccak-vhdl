
library IEEE;
use IEEE.std_logic_1164.all;
use work.slices.all;

entity state_holder is
port(
    clk : in std_logic;
    rst : in std_logic;

    lane_data : in std_logic_vector(63 downto 0);
    lane_index : in natural range 0 to 12;
    lane_write : in std_logic;

    slice_tile_data : in slice_tile_t;
    slice_tile_index : in natural range 0 to 31;
    slice_tile_write : in std_logic;

    state : out state_slice_t
);
end entity;

architecture arch of state_holder is
    signal data : state_slice_t;
begin

    process(clk, rst) is
    begin
        if rst = '1' then
            for i in 0 to 12 loop
                data(i) <= (others => '0');
            end loop;
        elsif rising_edge(clk) then
            if lane_write = '1' then
                data(lane_index) <= lane_data;
            elsif slice_tile_write = '1' then
                for i in 0 to 12 loop
                    data(i)(slice_tile_index * 2) <= slice_tile_data(0)(i);
                    data(i)(slice_tile_index * 2 + 1) <= slice_tile_data(1)(i);
                end loop;
            end if;
        end if;
    end process;

    state <= data;

end architecture arch;
