library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;

package reader is
    
    procedure read(state : inout block_t; lane : lane_t; iteration : natural range 0 to 16; atom_index : atom_index_t);

end package;

package body reader is

    procedure read(state : inout block_t; lane : lane_t; iteration : natural range 0 to 16; atom_index : atom_index_t) is
    begin
        if atom_index = 0 then
            if iteration <= 12 then
                state(iteration) := lane;
            end if;
        else
            if iteration >= 12 then
                state(iteration - 12) := lane;
            end if;
        end if;
    end procedure;

end package body;