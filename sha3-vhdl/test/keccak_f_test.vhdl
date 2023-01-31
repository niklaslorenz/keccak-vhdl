
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.all;
use work.keccak_types.all;
use work.testutil.all;

entity keccak_f_test is
end entity keccak_f_test;

architecture arch of keccak_f_test is

	component keccak_f is
		port(
			input : in StateArray;
            rst : in std_logic;
            clk : in std_logic;
            start : in std_logic;
            output : out StateArray;
            ready : out std_logic
		);
	end component keccak_f;

	file challenge_buf : text;
	file result_buf : text;
	
	signal input : StateArray;
	signal reset : std_logic;
	signal clock : std_logic := '0';
	signal start : std_logic;
	signal output : StateArray;
	signal ready : std_logic;
	
	signal finished : boolean := false;
	signal debug_input_vector : std_logic_vector(1599 downto 0);
begin

	f : keccak_f port map(input => input, rst => reset, clk => clock, start => start, output => output, ready => ready);
    
    clk : process
    begin
        while not finished loop
            clock <= not clock;
            wait for 5ns;
        end loop;
        wait;
    end process;
    
	verify : process
		variable challenge : line;
		variable result : line;
		variable result_state : StateArray;
		variable input_state : StateArray;
		begin
			file_open(challenge_buf, "../test_instances/raw_state_arrays.txt", read_mode);
			file_open(result_buf, "../test_solutions/keccak_f.txt", read_mode);
			while not endfile(challenge_buf) loop
				assert not endfile(result_buf) report "Expected test result in result file" severity FAILURE;
				readline(challenge_buf, challenge);
				readline(result_buf, result);
				convertInput(challenge, input_state);
				convertInput(result, result_state);
                debug_input_vector <= to_std_logic_vector(input_state);
				start <= '0';
				reset <= '1';
				wait until falling_edge(clock);
				reset <= '0';
				input <= input_state;
				wait until rising_edge(clock);
				start <= '1';
				wait until rising_edge(clock);
				start <= '0';
				wait until rising_edge(clock);
				for i in 0 to 23 loop
                    assert ready = '0' report "Expected the calculation to be running but it signaled 'ready' in clock cycle " & integer'image(i) severity ERROR;
                    wait until rising_edge(clock);
				end loop;
				assert ready = '1' report "Expected the calculation to be done but it was not yet" severity ERROR;
				assert output = result_state report "Failed keccak_f Test: Expected: " & convertOutput(result_state) & " But got: " & convertOutput(output) severity ERROR;
			end loop;
			assert endfile(result_buf) report "Expected end of result file" severity FAILURE;
			finished <= true;
			wait;
	end process verify;
end architecture arch;
