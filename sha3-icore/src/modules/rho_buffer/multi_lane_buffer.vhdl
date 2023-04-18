library IEEE;
use IEEE.std_logic_1164.all;
use work.single_lane_buffer;
use work.state.all;

entity multi_lane_buffer is
    port(
        clk : in std_logic;
        atom_index : atom_index_t;
        right_shift : in std_logic;
        input : in multi_buffer_data_t;
        output : out multi_buffer_data_t
    );
end entity;

architecture arch of multi_lane_buffer is

    type shifts_array_t is array(natural range 0 to 6) of natural range 0 to 31;
    constant atom0_left_shifts: shifts_array_t := (1, 28, 27, 6, 20, 3, 10);
    constant atom0_right_shifts : shifts_array_t := (2, 28, 20, 9, 21, 0, 0);
    constant atom1_left_shifts : shifts_array_t := (25, 15, 21, 8, 18, 2, 14);
    constant atom1_right_shifts : shifts_array_t := (21, 25, 23, 19, 3, 8, 0);

    component single_lane_buffer is
        port(
            clk : in std_logic;
            right_shift : in std_logic;
            distance : in natural range 0 to 31;
            input : in std_logic_vector(3 downto 0);
            output : out std_logic_vector(3 downto 0)
        );
    end component;

    signal current_shifts : shifts_array_t;

begin

    bufs : for i in 0 to 6 generate
        buf : single_lane_buffer port map(clk, right_shift, current_shifts(i), input(i), output(i));
    end generate;

    process(atom_index, right_shift) is
    begin
        if atom_index = 0 then
            if right_shift = '1' then
                current_shifts <= atom0_right_shifts;
            else
                current_shifts <= atom0_left_shifts;
            end if;
        else
            if right_shift = '1' then
                current_shifts <= atom1_right_shifts;
            else
                current_shifts <= atom1_left_shifts;
            end if;
        end if;
    end process;

end architecture arch;