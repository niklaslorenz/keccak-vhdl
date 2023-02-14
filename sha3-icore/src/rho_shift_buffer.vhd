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
end rho_shift_buffer;

architecture arch of rho_shift_buffer is
    
    type buffer_slice_t is array(natural range 3 downto 0) of std_logic_vector(6 downto 0);
    type buffer_t is array(natural range 7 downto 0) of buffer_slice_t;
    signal buf : buffer_t;
    
    function extract_data(data_in : rho_calc_t; atom_index : atom_index_t; left_shift : std_logic) return buffer_slice_t is
        variable result : buffer_slice_t;
    begin
        if atom_index = 0 then
            if left_shift = '1' then
                for slice in 3 downto 0 loop
                    result(slice)(0) := data_in(slice)(1);
                    result(slice)(1) := data_in(slice)(3);
                    result(slice)(2) := data_in(slice)(4);
                    result(slice)(3) := data_in(slice)(7);
                    result(slice)(4) := data_in(slice)(9);
                    result(slice)(5) := data_in(slice)(10);
                    result(slice)(6) := data_in(slice)(11);
                end loop;
            else
                for slice in 3 downto 0 loop
                    result(slice)(0) := data_in(slice)(2);
                    result(slice)(1) := data_in(slice)(5);
                    result(slice)(2) := data_in(slice)(6);
                    result(slice)(3) := data_in(slice)(8);
                    result(slice)(4) := data_in(slice)(12);
                    result(slice)(3) := '0';
                    result(slice)(4) := '0';
                end loop;
            end if;
        else
            if left_shift = '1' then
            
            else
            
            end if;
        end if;
        return result;
    end function;
    
begin

    data_out <= insert_data();

    process(clk) is
    begin
        for i in 0 to 6 loop
            buf(i + 1) <= buf(i);
        end loop;
        buf(0) <= extract_data(data_in, atom_index, left_shift);
    end process;

end arch;
