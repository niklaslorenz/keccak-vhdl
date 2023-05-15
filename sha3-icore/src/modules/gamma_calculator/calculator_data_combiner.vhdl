library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;

entity calculator_data_combiner is
    port(
        atom_index : in atom_index_t;
        enable : in std_logic;
        data : out double_slice_t;
        remote_data : in double_tile_slice_t;
        local_data : in double_tile_slice_t;
        result : in double_slice_t;
        remote_result : out double_tile_slice_t;
        local_result : out double_tile_slice_t
    );
end entity;

architecture arch of calculator_data_combiner is
begin

    process(atom_index, remote_data, local_data) is
    begin
        if atom_index = 0 then
            data <= (remote_data(1)(12 downto 1) & local_data(1), remote_data(0)(12 downto 1) & local_data(0));
        else
            data <= (local_data(1) & remote_data(1)(11 downto 0), local_data(0) & remote_data(0)(11 downto 0));
        end if;
    end process;

    process(atom_index, enable, result) is
    begin
        if atom_index = 0 then
            if enable = '1' then
                local_result <= (result(1)(12 downto  0), result(0)(12 downto  0));
            else
                local_result <= ((others => '0'), (others => '0'));
            end if;
            remote_result <= (result(1)(24 downto 12), result(0)(24 downto 12));
        else
            if enable = '1' then
                local_result  <= (result(1)(24 downto 12), result(0)(24 downto 12));
            else
                local_result <= ((others => '0'), (others => '0'));
            end if;
            remote_result <= (result(1)(12 downto  0), result(0)(12 downto  0));
        end if;
    end process;

end architecture arch;