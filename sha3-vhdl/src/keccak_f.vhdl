
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.all;
use work.keccak_types.all;

entity keccak_f is
generic(
	InputSize : Natural range 576 to 1152
);
port(
	input : in std_logic_vector(InputSize - 1 downto 0);
	rst : in boolean;
	clk : in std_logic;
	start : in boolean;
	output : out StateArray;
	ready : out boolean
);
end entity keccak_f;

architecture arch of keccak_f is

	component keccak_p is
		port(
			input : in StateArray;
			roundIndex : in Natural range 0 to 23;
			output : out StateArray
		);
	end component;

	signal permutation_input : StateArray;
	signal current_round : Natural range 0 to 23;
	signal permutation_output : StateArray;
	signal running : boolean := false;
begin
	
	permutation : keccak_p port map(input => permutation_input, roundIndex => current_round, output => permutation_output);
	
	process(clk, rst) is
	begin
		if rst = true then
			permutation_input <= to_StateArray(std_logic_vector(to_unsigned(0, 1600)));
			running <= false;
			current_round <= 0;
		elsif rising_edge(clk) then
			if not running then
				if start then
					running <= true;
					current_round <= 0;
				end if;
				permutation_input <= to_StateArray(input & std_logic_vector(to_unsigned(0, 1600 - InputSize)));
			else
				permutation_input <= permutation_output;
				if current_round = 23 then
					running <= false;
				else
					current_round <= current_round + 1;
				end if;
			end if;
		end if;
	end process;
	
	output <= permutation_output;
	ready <= not running;
	
end architecture arch;