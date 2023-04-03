library IEEE;
use IEEE.std_logic_1164.all;

entity single_lane_buffer is
    port(
        clk : in std_logic;
        right_shift : in std_logic;
        distance : in natural range 0 to 31;
        input : in std_logic_vector(3 downto 0);
        output : out std_logic_vector(3 downto 0)
    );
end entity;

architecture arch of single_lane_buffer is

    signal buf : std_logic_vector(31 downto 0);
    signal combined : std_logic_vector(35 downto 0);

begin

    combined <= buf & input when right_shift = '1' else input & buf;
    
    process(clk) is
    begin
        if rising_edge(clk) then
            if right_shift = '1' then
                buf <= buf(27 downto 0) & input;
                output <= combined(3 + distance downto distance);
            else
                buf <= input & buf(31 downto 4);
                output <= combined(35 - distance downto 32 - distance);
            end if;
        end if;
    end process;

end architecture arch;