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

    component buffer_visualizer is
        port(
            buf : in buffer_t
        );
    end component;

    type extracted_data_t is array(natural range 3 downto 0) of std_logic_vector(6 downto 0);
    signal extracted_data : extracted_data_t;
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

begin

    buffer_visual : buffer_visualizer port map(buf);

    data_out <= inserted_data;
    extracted0 <= extracted_data(0);
    extracted1 <= extracted_data(1);
    extracted2 <= extracted_data(2);
    extracted3 <= extracted_data(3);

    insert : process(atom_index, left_shift, data_in, buf, extracted_data, inserted_data) is

        variable buffer_queues : buffer_queues_t;
        variable buffer_offsets : offsets_t;

        variable buffer_index : natural range 0 to 35;
        variable buffer_queue_index : natural range 0 to 6;

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
                    if left_shift = '1' then
                        buffer_index := (36 - slice + buffer_offsets(buffer_queue_index)) mod 36;
                    else
                        buffer_index := (36 + slice - buffer_offsets(buffer_queue_index)) mod 36;
                    end if;
                    inserted_data(slice)(lane) <= buf(buffer_index)(buffer_queue_index);
                else
                    inserted_data(slice)(lane) <= data_in(slice)(lane);
                end if;
            end loop;
        end loop;
    end process;

    extract : process(atom_index, left_shift, data_in, buf, extracted_data, inserted_data) is
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
            for i in 0 to 7 loop
                buf((i + 1) * 4) <= buf(i * 4);
                buf((i + 1) * 4 + 1) <= buf(i * 4 + 1);
                buf((i + 1) * 4 + 2) <= buf(i * 4 + 2);
                buf((i + 1) * 4 + 3) <= buf(i * 4 + 3);
            end loop;
            for i in 0 to 3 loop
                buf(i) <= extracted_data(i);
            end loop;
        end if;
    end process;

end architecture;