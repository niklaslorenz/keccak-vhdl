library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.state.all;

entity buffer_chunk_visualizer is
    port(
        chunk : in buffer_chunk_t
    );
end entity;

architecture arch of buffer_chunk_visualizer is
    signal slice0, slice1, slice2, slice3 : std_logic_vector(6 downto 0);
begin
    slice0 <= chunk(0);
    slice1 <= chunk(1);
    slice2 <= chunk(2);
    slice3 <= chunk(3);
end architecture;