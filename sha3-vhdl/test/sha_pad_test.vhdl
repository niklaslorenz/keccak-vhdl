
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;
use std.textio.all;

use work.sha3_types.all;

entity sha_pad_test is
end entity sha_pad_test;

architecture arch of sha_pad_test is

	procedure toVector(l : inout line; res : out std_logic_vector) is
        variable v : std_logic_vector(1087 downto 0);
        variable good : boolean;
	begin
        hread(l, v, good);
        assert good report "Could not read input" severity error;
        for i in 0 to (1088 / 8) - 1 loop
            res(i * 8 + 7 downto i * 8) := v(1087 - i * 8 downto 1087 - i * 8 - 7);
        end loop;
	end procedure;

	function toString(v : std_logic_vector) return string is
        variable res : std_logic_vector(1087 downto 0);
        variable str : line;
	begin
        for i in 0 to (1088 / 8) - 1 loop
            res(i * 8 + 7 downto i * 8) := v(1087 - i * 8 downto 1087 - i * 8 - 7);
        end loop;
        hwrite(str, res);
        return str.all;
	end function toString;

        file challenge_buf : text;
        file result_buf : text;
		signal result_vector : std_logic_vector(1087 downto 0);
        signal output : std_logic_vector(1087 downto 0);

begin

    verify : process
		variable challenge : line;
		variable result : line;
		variable result_vec_temp : std_logic_vector(1087 downto 0);
    begin
        file_open(challenge_buf, "../test_instances/text_inputs.txt", read_mode);
        file_open(result_buf, "../test_solutions/pad256.txt", read_mode);
        while not endfile(challenge_buf) loop
			assert not endfile(result_buf) report "Expected test result in result file" severity FAILURE;
			readline(challenge_buf, challenge);
			readline(result_buf, result);
			toVector(result, result_vec_temp);
			result_vector <= result_vec_temp;
            output <= sha_pad(challenge.all, sha256);
            wait for 10ns;
			assert output = result_vector report "Failed sha_pad Test, Expected: " & toString(result_vector) & " But got: " & toString(output) severity ERROR;
		end loop;
		wait;
    end process;


end architecture arch;
