library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;

entity sha3_atom is
    port(
        clk : in std_logic;
        rst : in std_logic;
        enable : in std_logic;
        atom_index : in atom_index_t;
        data_in : in lane_t;

        data_out : out lane_t
        );
end entity;

architecture arch of sha3_atom is
    type mode_t is (read, gamma);
begin

    process(clk, rst) is
        variable state : state_t;
        variable mode : mode_t;
        variable mode_iterator : natural range 0 to 16;
    begin
        if reset = '1' then
            reset(state);
            mode := read;
            mode_iterator := 0;
        elsif rising_edge(clk) then
            if enable = '1' then
                if mode = read then
                    read(state, data_in, mode_iterator, atom_index);
                    if mode_iterator = 16 then
                        mode := gamma;
                    end;
                end if;
            end if;
        end if;
    end process;

end architecture;