
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.keccak_types.all;

package testutil is

	procedure convertInput(input_line : inout line; res : out StateArray);

	function convertOutput(state : in StateArray) return string;

end package testutil;

package body testutil is

	procedure convertInput(input_line : inout line; res : out StateArray) is
		variable good : boolean;
		variable hex_raw : std_logic_vector(1599 downto 0);
		variable hex : std_logic_vector(1599 downto 0);
	begin
		hread(input_line, hex_raw, good);
		assert good severity FAILURE;
		for i in 0 to 199 loop
			hex(i * 8 + 7 downto i * 8) := hex_raw(1599 - (i * 8) downto 1599 - (i * 8 + 7));
		end loop;
		res := to_StateArray(hex);
	end procedure convertInput;

	function convertOutput(state : in StateArray) return string is
		variable hex_raw : std_logic_vector(1599 downto 0);
		variable hex : std_logic_vector(1599 downto 0);
		variable str : line;
	begin
		hex_raw := to_std_logic_vector(state);
		for i in 0 to 199 loop
			hex(i * 8 + 7 downto i * 8) := hex_raw(1599 - (i * 8) downto 1599 - (i * 8 + 7));
		end loop;
		hwrite(str, hex);
		return str.all;
	end function convertOutput;

end package body testutil;