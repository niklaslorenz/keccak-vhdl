library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;

entity calculator_transmission_converter is
    port(
        enable : in std_logic;
        transmission_in : in transmission_t;
        transmission_out : out transmission_t;
        data_slice_receive : out double_tile_slice_t;
        result_slice_receive : out double_tile_slice_t;
        data_slice_send : in double_tile_slice_t;
        result_slice_send : in double_tile_slice_t
    );
end entity;

architecture arch of calculator_transmission_converter is
    signal data_transmission_out, result_transmission_out : std_logic_vector(31 downto 0);
    signal data_transmission_in, result_transmission_in : std_logic_vector(31 downto 0);
begin

    -- setup transmission channels for data (upper half) and results (lower half)
    data_transmission_in <= transmission_in(63 downto 32);
    result_transmission_in <= transmission_in(31 downto 0);
    transmission_out <= data_transmission_out & result_transmission_out when enable = '1' else (others => '0');
    
    -- define outgoing transmissions
    data_transmission_out <= "000" & data_slice_send(1) & "000" & data_slice_send(0);
    result_transmission_out <= "000" & result_slice_send(1) & "000" & result_slice_send(0);

    -- define incoming slices
    data_slice_receive <= (data_transmission_in(28 downto 16), data_transmission_in(12 downto 0)) when enable = '1' else ((others => '0'), (others => '0'));
    result_slice_receive <= (result_transmission_in(28 downto 16), result_transmission_in(12 downto 0)) when enable = '1' else ((others => '0'), (others => '0'));

end architecture;