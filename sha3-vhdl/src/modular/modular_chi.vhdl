
library IEEE;
use IEEE.std_logic_1164.all;

use work.modular.all;

entity modular_chi is
generic(width : natural range 1 to 64);
port(
	input : in std_logic_vector(25 * width - 1 downto 0);
	output : out std_logic_vector(25 * width - 1 downto 0);
);
end entity modular_chi;

architecture arch of modular_chi is

begin
	gen_y : for y in 0 to 4 generate
		gen_x : for x in 0 to 4 generate
			output(getLane(x,y,width) <= input(getLane(x,y,width)) xor ((not input(getLane((x + 1) mod 5,y,width)) and input(getLane((x + 2) mod 5,y,width)));
		end generate;
	end generate;
end architecture arch;
