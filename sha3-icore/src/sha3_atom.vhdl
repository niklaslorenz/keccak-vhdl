library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
use work.reader.all;
use work.util.all;
use work.slice_buffer.all;
use work.slice_functions.all;

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
    type mode_t is (read, theta, rho, gamma, valid);
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
        variable slice_index : natural range 0 to 63;

        --modules
        variable reader : reader_t;
        variable reader_ready : std_logic;

        variable slice_buffer : buffer_t;
        variable slice_buffer_ready : std_logic;

        procedure enter_read(mode : inout mode_t; reader : inout reader_t) is
        begin
            init_reader(reader);
            mode := read;
        end procedure;

        procedure enter_theta(mode : inout mode_t) is
        begin
            init_buffer(slice_buffer);
            mode := theta;
        end procedure;

        procedure enter_rho(mode : inout mode_t) is
        begin
            mode := rho;
        end procedure;

        procedure enter_gamma(mode : inout mode_t; buf : inout buffer_t) is
        begin
            init_buffer(buf);
            mode := gamma;
        end procedure;

    begin
        if rst = '1' then
            reset(state);
            enter_read(mode, reader);
            round := 0;
            slice_index := 0;

            data_out <= (others => '0');
            ready <= '0';
        elsif rising_edge(clk) then
            if enable = '1' then
                if mode = read then
                    read(reader, state, data_in, atom_index, reader_ready);
                    if reader_ready = '1' then
                        enter_theta(mode);
                    end if;
                elsif mode = theta then
                    -- TODO calculate theta here
                    if slice_index = 63 then
                        slice_index := 0;
                        enter_rho(mode);
                    else
                        slice_index := slice_index + 1;
                    end if;
                elsif mode = rho then
                    rho(state, atom_index);
                    enter_gamma(mode, slice_buffer);
                elsif mode = gamma then
                    -- TODO calculate gamma here and remember, last round no theta
                    if slice_index = 63 then
                        slice_index := 0;
                        if round = 23 then
                            round := 0;
                            mode := valid;
                        else
                            round := round + 1;
                            mode := rho;
                        end if;
                    else
                        slice_index := slice_index + 1;
                    end if;
                end if;
            end if;
        end if;
        dbg_state <= state;
    end process;

end architecture;