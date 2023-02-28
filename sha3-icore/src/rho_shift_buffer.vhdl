library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.state.all;

entity rho_shift_buffer is
    Port (
        clk : in std_logic;
        atom_index : in atom_index_t;
        left_shift : in std_logic;
        data_in : in rho_calc_t;
        data_out : out rho_calc_t
    );
end entity;

architecture arch of rho_shift_buffer is
    
    type buffer_chunk_t is array(natural range 3 downto 0) of std_logic_vector(6 downto 0);
    type buffer_t is array(natural range 7 downto 0) of buffer_chunk_t;
    signal extracted_data : buffer_chunk_t;
    signal inserted_data : rho_calc_t;
    signal buf : buffer_t;
    
    type buffer_queues_t is array(natural range 0 to 12) of natural range 0 to 7;
    constant atom0_left_shift_queues : buffer_queues_t := (7, 0, 7, 1, 2, 7, 7, 3, 7, 4, 5, 6, 7);
    constant atom0_right_shift_queues : buffer_queues_t := (7, 7, 0, 7, 7, 1, 2, 7, 3, 7, 7, 7, 4);
    constant atom1_left_shift_queues : buffer_queues_t := (7, 0, 7, 7, 7, 1, 2, 3, 4, 5, 7, 7, 6);
    constant atom1_right_shift_queues : buffer_queues_t := (0, 7, 1, 2, 3, 7, 7, 7, 7, 7, 4, 5, 7);
    
    type offsets_t is array(natural range 0 to 6) of natural range 0 to 31;
    constant atom0_left_shift_offsets : offsets_t := (1, 28, 27, 6, 20, 3, 10);
    constant atom0_right_shift_offsets : offsets_t := (2, 28, 20, 9, 21, 0, 0);
    constant atom1_left_shift_offsets : offsets_t := (25, 15, 21, 8, 18, 2, 14);
    constant atom1_right_shift_offsets : offsets_t := (21, 25, 23, 19, 3, 8, 0);

    signal extracted0, extracted1, extracted2, extracted3 : std_logic_vector(6 downto 0);

    function reverse(data : buffer_chunk_t) return buffer_chunk_t is
    begin
        return (data(0), data(1), data(2), data(3));
    end function;

begin

    data_out <= inserted_data;
    extracted0 <= extracted_data(0);
    extracted1 <= extracted_data(1);
    extracted2 <= extracted_data(2);
    extracted3 <= extracted_data(3);

    insert : process(atom_index, left_shift, data_in, buf) is

        variable buffer_queues : buffer_queues_t;
        variable buffer_offsets : offsets_t;

        variable buffer_index : natural range 0 to 31;
        variable buffer_queue_index : natural range 0 to 6;
        variable buffer_slice_index : natural range 0 to 3;
        variable buffer_chunk_index : natural range 0 to 7;

    begin
        if atom_index = 0 then
            if left_shift = '1' then
                buffer_queues := atom0_left_shift_queues;
                buffer_offsets := atom0_left_shift_offsets;
            else
                buffer_queues := atom0_right_shift_queues;
                buffer_offsets := atom0_right_shift_offsets;
            end if;
        else
            if left_shift = '1' then
                buffer_queues := atom1_left_shift_queues;
                buffer_offsets := atom1_left_shift_offsets;
            else
                buffer_queues := atom1_right_shift_queues;
                buffer_offsets := atom1_right_shift_offsets;
            end if;
        end if;
        for slice in 3 downto 0 loop
            for lane in 0 to 12 loop
                if buffer_queues(lane) /= 7 then
                    buffer_queue_index := buffer_queues(lane);
                    buffer_index := (slice + buffer_offsets(buffer_queue_index)) mod 32;
                    buffer_chunk_index := buffer_index / 4;
                    buffer_slice_index := (buffer_index mod 4);
                    if left_shift = '1' then
                        inserted_data(slice)(lane) <= reverse(buf(buffer_chunk_index))(buffer_slice_index)(buffer_queue_index);
                    else
                        inserted_data(slice)(lane) <= buf(buffer_chunk_index)(buffer_slice_index)(buffer_queue_index);
                    end if;
                else
                    inserted_data(slice)(lane) <= data_in(slice)(lane);
                end if;
            end loop;
        end loop;
    end process;

    extract : process(atom_index, left_shift, data_in) is
    begin

        if atom_index = 0 then
            if left_shift = '1' then
                for slice in 3 downto 0 loop
                    for lane in 0 to 12 loop
                        if atom0_left_shift_queues(lane) /= 7 then
                            extracted_data(slice)(atom0_left_shift_queues(lane)) <= data_in(slice)(lane);
                        end if;
                    end loop;
                end loop;
            else
                for slice in 3 downto 0 loop
                    for lane in 0 to 12 loop
                        if atom0_right_shift_queues(lane) /= 7 then
                            extracted_data(slice)(atom0_right_shift_queues(lane)) <= data_in(slice)(lane);
                        end if;
                    end loop;
                    extracted_data(slice)(5) <= '0';
                    extracted_data(slice)(6) <= '0';
                end loop;
            end if;
        else
            if left_shift = '1' then
                for slice in 3 downto 0 loop
                    for lane in 0 to 12 loop
                        if atom1_left_shift_queues(lane) /= 7 then
                            extracted_data(slice)(atom1_left_shift_queues(lane)) <= data_in(slice)(lane);
                        end if;
                    end loop;
                end loop;
            else
                for slice in 3 downto 0 loop
                    for lane in 0 to 12 loop
                        if atom1_right_shift_queues(lane) /= 7 then
                            extracted_data(slice)(atom1_right_shift_queues(lane)) <= data_in(slice)(lane);
                        end if;
                    end loop;
                    extracted_data(slice)(6) <= '0';
                end loop;
            end if;
        end if;
    end process;

    process(clk) is

    begin
        if rising_edge(clk) then
            if left_shift = '1' then
                for i in 0 to 6 loop
                    buf(i + 1) <= buf(i);
                end loop;
                buf(0) <= reverse(extracted_data);
            else
                for i in 0 to 6 loop
                    buf(i + 1) <= buf(i);
                end loop;
                buf(0) <= extracted_data;
            end if;
        end if;
    end process;

end architecture;
