
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.all;
use work.keccak_types.all;
use work.testutil.all;

entity keccak_iota_test is
end entity keccak_iota_test;

architecture arch of keccak_iota_test is

	component keccak_iota is
		port(
			input : in StateArray;
			roundIndex : in natural;
			output : out StateArray
		);
	end component keccak_iota;

	file challenge_buf : text;
	file result_0_buf, result_11_buf, result_23_buf : text;
	
	signal input : StateArray;
	signal output : StateArray;
	signal roundIndex : natural range 0 to 23;
begin

	iota : keccak_iota port map(input => input, roundIndex => roundIndex, output => output);

	verify : process
		variable challenge : line;
		variable result : line;
		variable result_state : StateArray;
		variable input_state : StateArray;
		begin
			file_open(challenge_buf, "../test_instances/raw_state_arrays.txt", read_mode);
			file_open(result_0_buf, "../test_solutions/iota_0.txt", read_mode);
			file_open(result_11_buf, "../test_solutions/iota_11.txt", read_mode);
			file_open(result_23_buf, "../test_solutions/iota_23.txt", read_mode);
			while not endfile(challenge_buf) loop
				readline(challenge_buf, challenge);
				convertInput(challenge, input_state);
				input <= input_state;
				
				assert not endfile(result_0_buf) report "Expected test result in result file" severity FAILURE;
				readline(result_0_buf, result);
				convertInput(result, result_state);
				roundIndex <= 0;
				wait for 10ns;
				assert output = result_state report "Failed keccak_iota_0 Test: Expected: " & convertOutput(result_state) & " But got: " & convertOutput(output) severity ERROR;
				
				assert not endfile(result_11_buf) report "Expected test result in result file" severity FAILURE;
				readline(result_11_buf, result);
				convertInput(result, result_state);
				roundIndex <= 11;
				wait for 10ns;
				assert output = result_state report "Failed keccak_iota_11 Test: Expected: " & convertOutput(result_state) & " But got: " & convertOutput(output) severity ERROR;
				
				assert not endfile(result_23_buf) report "Expected test result in result file" severity FAILURE;
				readline(result_23_buf, result);
				convertInput(result, result_state);
				roundIndex <= 23;
				wait for 10ns;
				assert output = result_state report "Failed keccak_iota_23 Test: Expected: " & convertOutput(result_state) & " But got: " & convertOutput(output) severity ERROR;
			end loop;
			assert endfile(result_0_buf) report "Expected end of result file" severity FAILURE;
			assert endfile(result_11_buf) report "Expected end of result file" severity FAILURE;
			assert endfile(result_23_buf) report "Expected end of result file" severity FAILURE;
			wait;
	end process verify;
end architecture arch;
