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
    
    type buffer_positions_t is array(natural range 0 to 12) of natural range 0 to 7;
    constant atom0_left_shift_positions : buffer_positions_t := (7, 0, 7, 1, 2, 7, 7, 3, 7, 4, 5, 6, 7);
    constant atom0_right_shift_positions : buffer_positions_t := (7, 7, 0, 7, 7, 1, 2, 7, 3, 7, 7, 7, 4);
    constant atom1_left_shift_positions : buffer_positions_t := (7, 0, 7, 7, 7, 1, 2, 3, 4, 5, 7, 7, 6);
    constant atom1_right_shift_positions : buffer_positions_t := (0, 7, 1, 2, 3, 7, 7, 7, 7, 7, 4, 5, 7);
    
    
    type offsets_t is array(natural range 0 to 6) of natural range 0 to 31;
    constant atom0_left_shift_offsets : offsets_t := (1, 28, 27, 6, 20, 3, 10);
    constant atom0_right_shift_offsets : offsets_t := (2, 28, 20, 9, 21, 0, 0);
    constant atom1_left_shift_offsets : offsets_t := (25, 15, 21, 8, 18, 2, 14);
    constant atom1_right_shift_offsets : offsets_t := (21, 25, 23, 19, 3, 8, 0);
    
begin

    data_out <= inserted_data;

    insert : process(atom_index, left_shift, data_in, buf) is
        function get_chunk(index : natural range 0 to 31) return natural is
        begin
            return index / 4;
        end function;
        function get_slice(index : natural range 0 to 31) return natural is
        begin
            return index mod 4;
        end function;
        
    begin
        if atom_index = 0 then
            if left_shift = '1' then
                for slice in 3 downto 0 loop
                    for lane in 0 to 12 loop
                        if atom0_left_shift_positions(lane) /= 7 then
                            inserted_data(slice)(lane) <= 
                            buf(get_chunk((atom0_left_shift_offsets(lane) + slice) mod 32))
                            -- buf(0)
                            (get_slice((atom0_left_shift_offsets(lane) + slice) mod 32))
                            (atom0_left_shift_positions(lane));
                        else
                            inserted_data(slice)(lane) <= data_in(slice)(lane);
                        end if;
                    end loop;
                end loop;
            else
                for slice in 3 downto 0 loop
                    for lane in 0 to 12 loop
                        if atom0_right_shift_positions(lane) /= 7 then
                            inserted_data(slice)(lane) <= buf(get_chunk((atom0_right_shift_offsets(lane) + slice) mod 32))(get_slice((atom0_right_shift_offsets(lane) + slice) mod 32))(atom0_right_shift_positions(lane));
                        else
                            inserted_data(slice)(lane) <= data_in(slice)(lane);
                        end if;
                    end loop;
                end loop;
            end if;
        else
            if left_shift = '1' then
                for slice in 3 downto 0 loop
                    for lane in 0 to 12 loop
                        if atom1_left_shift_positions(lane) /= 7 then
                            inserted_data(slice)(lane) <= buf(get_chunk(atom1_left_shift_offsets(lane) + slice mod 32))(get_slice(atom1_left_shift_offsets(lane) + slice mod 32))(atom1_left_shift_positions(lane));
                        else
                            inserted_data(slice)(lane) <= data_in(slice)(lane);
                        end if;
                    end loop;
                end loop;
            else
                for slice in 3 downto 0 loop
                    for lane in 0 to 12 loop
                        if atom1_right_shift_positions(lane) /= 7 then
                            inserted_data(slice)(lane) <= buf(get_chunk(atom1_right_shift_offsets(lane) + slice mod 32))(get_slice(atom1_right_shift_offsets(lane) + slice mod 32))(atom1_right_shift_positions(lane));
                        else
                            inserted_data(slice)(lane) <= data_in(slice)(lane);
                        end if;
                    end loop;
                end loop;
            end if;
        end if;
    end process;

    extract : process(atom_index, left_shift, data_in) is
    begin
        if atom_index = 0 then
            if left_shift = '1' then
                for slice in 3 downto 0 loop
                    for lane in 0 to 12 loop
                        if atom0_left_shift_positions(lane) /= 7 then
                            extracted_data(slice)(atom0_left_shift_positions(lane)) <= data_in(slice)(lane);
                        end if;
                    end loop;
                end loop;
            else
                for slice in 3 downto 0 loop
                    for lane in 0 to 12 loop
                        if atom0_right_shift_positions(lane) /= 7 then
                            extracted_data(slice)(atom0_right_shift_positions(lane)) <= data_in(slice)(lane);
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
                        if atom1_left_shift_positions(lane) /= 7 then
                            extracted_data(slice)(atom1_left_shift_positions(lane)) <= data_in(slice)(lane);
                        end if;
                    end loop;
                end loop;
            else
                for slice in 3 downto 0 loop
                    for lane in 0 to 12 loop
                        if atom1_right_shift_positions(lane) /= 7 then
                            extracted_data(slice)(atom1_right_shift_positions(lane)) <= data_in(slice)(lane);
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
            for i in 0 to 6 loop
                buf(i + 1) <= buf(i);
            end loop;
            buf(0) <= extracted_data;
        end if;
    end process;

end architecture;
