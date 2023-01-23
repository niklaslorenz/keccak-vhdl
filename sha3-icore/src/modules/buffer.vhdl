library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;


package slice_buffer is

    type buffer_data_t is array(natural range 0 to 1) of slice_t;

    subtype buffer_t is natural range 0 to 255;

    procedure init_buffer(iterator : inout buffer_t);

    procedure sync(state : in block_t; iterator : inout buffer_t; slice_buffer : out buffer_data_t; ready : out std_logic);

end package;

package body slice_buffer is

    procedure init_buffer(iterator : inout buffer_t) is
    begin
        iterator := 0;
    end procedure;

    procedure sync(state : in block_t; iterator : inout buffer_t; slice_buffer : out buffer_data_t; ready : out std_logic) is
    begin

        if iterator = 255 then
            ready := '1';
        else
            iterator := iterator + 1;
            ready := '0';
        end if;
    end procedure;

end package body;