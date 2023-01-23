library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;

package reader is

    subtype reader_t is natural range 0 to 16;

    procedure init_reader(iterator : inout reader_t);
    
    procedure read(iterator : inout reader_t; state : inout block_t; lane : lane_t; atom_index : atom_index_t; ready : out std_logic);

end package;

package body reader is

    procedure init_reader(iterator : inout reader_t) is
    begin
        iterator := 0;
    end procedure;

    procedure read(iterator : inout reader_t; state : inout block_t; lane : lane_t; atom_index : atom_index_t; ready : out std_logic) is
    begin
        if atom_index = 0 then
            if iterator <= 12 then
                state(iterator) := lane;
            end if;
        else
            if iterator >= 12 then
                state(iterator - 12) := lane;
            end if;
        end if;
        if iterator = 16 then
            ready := '1';
        else
            iterator := iterator + 1;
            ready := '0';
        end if;
    end procedure;

end package body;