library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
use work.reader.all;
use work.util.all;

entity sha3_atom is
    port(
        clk : in std_logic;
        rst : in std_logic;
        enable : in std_logic;
        atom_index : in atom_index_t;
        data_in : in lane_t;

        data_out : out lane_t;
        ready : out std_logic
        );
end entity;

architecture arch of sha3_atom is
    type mode_t is (read, theta, gamma);
    -- Debug Signals
    signal dbg_state : block_t;
    signal lane0, lane1, lane4, lane5, lane10, lane12 : lane_t;

begin

    lane0 <= dbg_state(0);
    lane1 <= dbg_state(1);
    lane4 <= dbg_state(4);
    lane5 <= dbg_state(5);
    lane10 <= dbg_state(10);
    lane12 <= dbg_state(12);

    process(clk, rst) is
        variable state : block_t;
        variable mode : mode_t;
        variable round : round_index_t;
        variable read_iterator : natural range 0 to 16;

    begin
        if rst = '1' then
            reset(state);
            mode := read;
            round := 0;
            read_iterator := 0;

            data_out <= (others => '0');
            ready <= '0';
        elsif rising_edge(clk) then
            if enable = '1' then
                if mode = read then
                    read(state, data_in, read_iterator, atom_index);
                    if read_iterator = 16 then
                        read_iterator := 0;
                        mode := gamma;
                    else
                        read_iterator := read_iterator + 1;
                    end if;
                elsif mode = gamma then
                    
                end if;
            end if;
        end if;
        dbg_state <= state;
    end process;

end architecture;