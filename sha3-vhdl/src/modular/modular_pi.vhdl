
library IEEE;
use IEEE.std_logic_1164.all;

use work.modular.all;

entity modular_pi is
generic(width : natural range 1 to 64);
port(
	input : std_logic_vector(25 * width - 1 downto 0);
	output : std_logic_vector(25 * width - 1 downto 0);
);
end entity;

architecture arch of modular_pi is
begin
	perm_y : for y in 0 to 4 generate
		perm_x : for x in 0 to 4 generate
			output(getLane(x,y,width) + width - 1 downto getLane(x,y,width)) <= input(getLane(y,(x + 3 * y) mod 5, width) + width - 1 downto getLane(y, (x + 3 * y) mod 5, width));
		end generate;
	end generate;
end architecture arch;
