library IEEE;
use IEEE.std_logic_1164.all;
use icore.types.all;

entity rho_buffer is
generic(
	left_index : natural range 0 to 24;
	left_distance : positive range 1 to 31;
	right_index : natural range 0 to 24;
	right_distance : positive range 1 to 31;
	slice_count : positive
);
port(
	rst : in std_logic;
	clk : in std_logic;
	enable : in std_logic;
	left_mode : in std_logic;
	input_stack : in slice_stack_t(slice_count - 1 downto 0);
	output_stack : out slice_stack_t(slice_count - 1 downto 0)
);
end entity;

architecture implementation of rho_buffer is
	signal extracted_bits : std_logic_vector(slice_count - 1 downto 0);
	signal memorized_bits : std_logic_vector(slice_count - 1 downto 0);
	
	signal buf : std_logic_vector(31 + slice_count downto 0);
	signal delay_stack : slice_stack_t(slice_count - 1 downto 0);
	
begin
	extracted_for : for i in 0 to slice_count - 1 generate
		extracted_bits(i) <= input_stack(i)(left_index) when left_mode = '1' else input_stack(i)(right_index);
	end generate;
	
	memorized_bits <= 	buf(left_distance + slice_count downto left_distance) when left_mode = '1' else
						buf(right_distance + slice_count downto right_distance);
	
	output_for : for i in 0 to slice_count - 1 generate
		output_stack(i) <= 	delay_stack(i)(24 downto left_index + 1) & memorized_bits(left_distance + i) & delay_stack(i)(left_index - 1 downto 0) when left_mode = '1' else
							delay_stack(i)(24 downto right_index + 1) & memorized_bits(right_distance + i) & delay_stack(i)(left_index - 1 downto 0); 
	end generate;
	
	process(clk) is
	begin
		if rst = '1' then
			buf <= (others => '0');
			delay_stack <= (others => (others => '0'));
		else if rising_edge(clk) and enable = '1' then
			buf <= buf(31 downto 0) & extracted_bits;
			delay_stack <= input_stack;
		end if;
	end process;
	
end implementation;