library IEEE;
use IEEE.std_logic_1164.all;
use icore.gamma_s;

entity gamma_stack is
generic(
	slice_count : positive;
);
port(
	theta_only : in std_logic;
	alpha_only : in std_logic;
	input_stack : in slice_stack_t(slice_count - 1 downto 0);
	round_constant : in std_logic_vector(slice_count - 1 downto 0);
	previous_column_sums : in std_logic_vector(4 downto 0);
	output_stack : out slice_stack_t(slice_count - 1 downto 0);
	current_column_sums : out std_logic_vector(4 downto 0);
);
end gamma_stack;

architecture implementation of gamma_stack is
	
	component gamma_s is
	port(
		theta_only : in std_logic;
		alpha_only : in std_logic;
		data_in : in slice_t;
		round_constant : in std_logic;
		previous_column_sums : in std_logic_vector(4 downto 0);
		data_out : out slice_t;
		current_column_sums : out std_logic_vector(4 downto 0);
	);
	end gamma_s;
	
	type column_sum_stack_t is array(slice_count - 1 downto 0) of std_logic_vector(4 downto 0);
	signal column_inputs : column_sum_stack_t;
	signal column_outputs : column_sum_stack_t;
	
begin

	column_inputs(0) <= previous_column_sums;
	column_link_for : for i in 1 to slice_count - 1 generate
		column_inputs(i) <= column_outputs(i - 1);
	end generate;

	gamma_s_for : for i in 0 to slice_count - 1 generate
		gam : gamma_s port map(
			theta_only => theta_only,
			alpha_only => alpha_only,
			data_in => input_stack(i),
			round_constant => round_constant(i),
			previous_column_sums => column_inputs(i),
			data_out => output_stack(i),
			current_column_sums => column_outputs(i)
			);
	end generate;

	current_column_sums <= column_outputs(slice_count - 1);

end implementation;