library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
use work.util.all;


package slice_buffer is

    type buffer_data_t is array(natural range 0 to 1) of slice_t;

    subtype buffer_t is natural range 0 to 22;

    subtype transmission_word_t is std_logic_vector(31 downto 0);

    procedure init_buffer(iterator : inout buffer_t);

    procedure sync(
        iterator : inout buffer_t;
        state : inout block_t;
        atom_index : in atom_index_t;
        input : in lane_t;
        results : in buffer_data_t;
        output : out lane_t;
        data : out buffer_data_t;
        -- control signals
        computeFirst : out std_logic;
        computeLoop : out std_logic;
        computeEdgeCase : out std_logic;
        current_slice : out slice_index_t;
        finished : out std_logic
    );

end package;

package body slice_buffer is

    procedure init_buffer(iterator : inout buffer_t) is
    begin
        iterator := 0;
    end procedure;

    procedure sync(
        iterator : inout buffer_t;
        state : inout block_t;
        atom_index : in atom_index_t;
        input : in lane_t;
        results : in buffer_data_t;
        output : out lane_t;
        data : out buffer_data_t;
        -- control signals
        computeFirst : out std_logic;
        computeLoop : out std_logic;
        computeEdgeCase : out std_logic;
        current_slice : out slice_index_t;
        finished : out std_logic
    ) is

        constant zero : transmission_word_t := (others => '0');

        variable outgoing_state_transmission : transmission_word_t;
        variable outgoing_result_transmission : transmission_word_t;

        variable incoming_state_transmission : transmission_word_t;
        variable incoming_result_transmission : transmission_word_t;

    begin
        incoming_state_transmission := input(31 downto 0);
        incoming_result_transmission := input(63 downto 32);

        -- transmit own state
        if iterator <= 15 then
            if atom_index = 1 then
                outgoing_state_transmission := x"0" & get_slice_tile(state, 2 * iterator + 1)(12 downto 1)
                                            &  x"0" & get_slice_tile(state, 2 * iterator    )(12 downto 1);
            else
                outgoing_state_transmission := x"0" & get_slice_tile(state, 2 * iterator + 33)(11 downto 0)
                                            &  x"0" & get_slice_tile(state, 2 * iterator + 32)(11 downto 0);
            end if;
        else
            outgoing_state_transmission := zero;
        end if;
        
        -- transmit own results
        if iterator >= 3 and iterator <= 18 then
            if atom_index = 1 then
                outgoing_result_transmission := "000" & results(1)(12 downto 0)
                                             &  "000" & results(0)(12 downto 0);
            else
                outgoing_result_transmission := "000" & results(1)(24 downto 12)
                                             &  "000" & results(0)(24 downto 12);
            end if;
        else
            outgoing_result_transmission := zero;
        end if;

        --finalize own results
        if iterator >= 3 and iterator <= 17 then
            if atom_index = 1 then
                set_slice_tile(state, results(1)(24 downto 12), iterator * 2 + 29);
                set_slice_tile(state, results(0)(24 downto 12), iterator * 2 + 28);
            else
                set_slice_tile(state, results(1)(12 downto 0), iterator * 2 - 3);
                set_slice_tile(state, results(0)(12 downto 0), iterator * 2 - 4);
            end if;
        elsif iterator = 18 then
            if atom_index = 1 then
                set_slice_tile(state, results(1)(24 downto 12), 33);
                set_slice_tile(state, results(0)(24 downto 12), 32);
            else
                set_slice_tile(state, results(1)(12 downto 0), 1);
                set_slice_tile(state, results(0)(12 downto 0), 0);
            end if;
        end if;

        -- provide computation data
        if iterator >= 1 and iterator <= 16 then
            if atom_index = 1 then
                data(1) := get_slice_tile(state, iterator * 2 + 31) & incoming_state_transmission(27 downto 16);
                data(0) := get_slice_tile(state, iterator * 2 + 30) & incoming_state_transmission(11 downto  0);
                current_slice := iterator * 2 + 30;
            else
                data(1) := incoming_state_transmission(27 downto 16) & get_slice_tile(state, iterator * 2 - 1);
                data(0) := incoming_state_transmission(11 downto  0) & get_slice_tile(state, iterator * 2 - 2);
                current_slice := iterator * 2 - 2;
            end if;
        else
            data(0) := (others => '1');
            data(1) := (others => '1');
            current_slice := 0;
        end if;

        -- finalize incoming result transmission
        if iterator >= 4 and iterator <= 18 then
            if atom_index = 1 then
                set_slice_tile(state, incoming_result_transmission(28 downto 16), iterator * 2 - 5);
                set_slice_tile(state, incoming_result_transmission(12 downto  0), iterator * 2 - 6);
            else
                set_slice_tile(state, incoming_result_transmission(28 downto 16), iterator * 2 + 27);
                set_slice_tile(state, incoming_result_transmission(12 downto  0), iterator * 2 + 26);
            end if;
        elsif iterator = 19 then
            if atom_index = 1 then
                set_slice_tile(state, incoming_result_transmission(28 downto 16), 1);
                set_slice_tile(state, incoming_result_transmission(12 downto  0), 0);
            else
                set_slice_tile(state, incoming_result_transmission(28 downto 16), 33);
                set_slice_tile(state, incoming_result_transmission(12 downto  0), 32);
            end if;
        end if;

        computeFirst := asBit(iterator = 1);
        computeLoop := asBit(iterator >= 2 and iterator <= 16);
        computeEdgeCase := asBit(iterator = 17); -- so that the results of this last computation can be transmitted in iteration 18 and arrives in 19
        finished := asBit(iterator >= 19);
        output := outgoing_result_transmission & outgoing_state_transmission;
        iterator := iterator + 1;
    end procedure;

end package body;