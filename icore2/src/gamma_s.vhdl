library IEEE;
use IEEE.std_logic_1164.all;
use icore.types.all;

entity gamma_s is
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

architecture implementation of gamma_s is
	
	signal pi_output : slice_t;
	signal pi_chi_output : slice_t;
	signal alpha_output : slice_t;
	signal theta_input : slice_t;
	signal theta_column_sums : std_logic_vector(4 downto 0);
	signal theta_output : slice_t;
begin
	
	-- pi
	pi_for_y : for y in 0 to 4 generate
		pi_for_x : for x in 0 to 4 generate
			pi_output(5 * y + x) <= data_in(5 * x + ((3 * x + y) mod 5)); -- A'[x][y] := A[(3x + y) mod 5][x]
		end generate;
	end generate;
	
	-- chi
	chi_for_y : for y in 0 to 4 generate
		chi_for_x : for x in 0 to 4 generate
			pi_chi_output(5 * y + x) <= pi_output(5 * y + x) xor (
										(not pi_output(5 * y + (x + 1 mod 5))) and
										(pi_output(5 * y + (x + 2 mod 5))));
		end generate;
	end generate;
	
	-- iota
	alpha_output(24 downto 1) <= pi_chi_output(24 downto 1);
	alpha_output(0) <= pi_chi_output(0) xor round_constant;
	
	-- theta
	theta_sums_for_x : for x in 0 to 4 generate
		theta_column_sums(x) <= theta_input(x) xor theta_input(5 + x) xor theta_input(10 + x) xor theta_input(15 + x) xor theta_input(20 + x);
	end generate;
	theta_for_y : for y in 0 to 4 generate
		theta_for_x : for x in 0 to 4 generate
			theta_output(5 * y + x) <= theta_input(5 * y + x) xor theta_column_sums(x + 4 mod 5) xor previous_column_sums(x + 1 mod 5);
		end generate;
	end generate;
	
	current_column_sums <= theta_column_sums;
	
	-- data direction multiplexers
	theta_input <= data_in when theta_only = '1' else alpha_output;
	data_out <= alpha_output when alpha_only = '1' else theta_output;

end architecture arch;