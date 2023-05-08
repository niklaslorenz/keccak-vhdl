library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;

entity rho_buffer_filter is
    port(
        clk : in std_logic;
        atom_index : in atom_index_t;
        right_shift : in std_logic;
        data_in : in quad_tile_slice_t;
        data_out : out quad_tile_slice_t;
        filtered_in : in buffer_data_t;
        filtered_out : out buffer_data_t
    );
end entity;

architecture arch of rho_buffer_filter is

    type buffer_queues_t is array(natural range 0 to 12) of natural range 0 to 7;
    constant atom0_left_shift_queues : buffer_queues_t := (7, 0, 7, 1, 2, 7, 7, 3, 7, 4, 5, 6, 7);
    constant atom0_right_shift_queues : buffer_queues_t := (7, 7, 0, 7, 7, 1, 2, 7, 3, 7, 7, 7, 4);
    constant atom1_left_shift_queues : buffer_queues_t := (7, 0, 7, 7, 7, 1, 2, 3, 4, 5, 7, 7, 6);
    constant atom1_right_shift_queues : buffer_queues_t := (0, 7, 1, 2, 3, 7, 7, 7, 7, 7, 4, 5, 7);

    type buffer_lanes_t is array(natural range 0 to 6) of natural range 0 to 12;
    constant atom0_left_shift_lanes : buffer_lanes_t := (1, 3, 4, 7, 9, 10, 11);
    constant atom0_right_shift_lanes : buffer_lanes_t := (2, 5, 6, 8, 12, 0, 0);
    constant atom1_left_shift_lanes : buffer_lanes_t := (1, 5, 6, 7, 8, 9, 12);
    constant atom1_right_shift_lanes : buffer_lanes_t := (0, 2, 3, 4, 10, 11, 0);

    signal current_queue : buffer_queues_t;
    signal current_lanes : buffer_lanes_t;

    signal din_buf : quad_tile_slice_t;

    signal data_out_temp : quad_tile_slice_t;

    signal data_in_0, data_in_1, data_in_2, data_in_3 : tile_slice_t;

    signal data_out_0, data_out_1, data_out_2, data_out_3 : tile_slice_t;

    signal filtered_in_0, filtered_in_1, filtered_in_2, filtered_in_3, filtered_in_4, filtered_in_5, filtered_in_6 : std_logic_vector(3 downto 0);

begin

    data_out <= data_out_temp;

    data_in_0 <= data_in(0);
    data_in_1 <= data_in(1);
    data_in_2 <= data_in(2);
    data_in_3 <= data_in(3);

    data_out_0 <= data_out_temp(0);
    data_out_1 <= data_out_temp(1);
    data_out_2 <= data_out_temp(2);
    data_out_3 <= data_out_temp(3);

    filtered_in_0 <= filtered_in(0);
    filtered_in_1 <= filtered_in(1);
    filtered_in_2 <= filtered_in(2);
    filtered_in_3 <= filtered_in(3);
    filtered_in_4 <= filtered_in(4);
    filtered_in_5 <= filtered_in(5);
    filtered_in_6 <= filtered_in(6);
    
    buffer_lane_for : for lane in 0 to 6 generate
        buffer_slice_for : for i in 0 to 3 generate
            filtered_out(lane)(i) <= data_in(i)(current_lanes(lane));
        end generate;
    end generate;

    data_slice_for : for i in 0 to 3 generate
        data_lane_for : for lane in 0 to 12 generate
            data_out_temp(i)(lane) <= filtered_in(current_queue(lane))(i) when current_queue(lane) /= 7 else din_buf(i)(lane);
        end generate;
    end generate;

    process(clk) is
    begin
        if rising_edge(clk) then
            din_buf <= data_in;
        end if;
    end process;

    process(atom_index, right_shift) is
    begin
        if atom_index = 0 then
            if right_shift = '1' then
                current_queue <= atom0_right_shift_queues;
                current_lanes <= atom0_right_shift_lanes;
            else
                current_queue <= atom0_left_shift_queues;
                current_lanes <= atom0_left_shift_lanes;
            end if;
        else
            if right_shift = '1' then
                current_queue <= atom1_right_shift_queues;
                current_lanes <= atom1_right_shift_lanes;
            else
                current_queue <= atom1_left_shift_queues;
                current_lanes <= atom1_left_shift_lanes;
            end if;
        end if;
    end process;

end architecture arch;