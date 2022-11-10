
library IEEE;
use IEEE.std_logic_1164.all;

package modular is

	function getLane(x : natural range 0 to 4; y : natural range 0 to 4, width : natural range 1 to 64) return natural;

end package modular;

package body modular is
	
	function getLane(x : natural range 0 to 4; y : natural range 0 to 4, width : natural range 1 to 64) return natural is
	begin
		return width * (y * 5 + x);
	end function;

end package body;
