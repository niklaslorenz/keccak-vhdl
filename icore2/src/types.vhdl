library IEEE;
use IEEE.std_logic_1164.all;

package types is
	
	type slice_t is std_logic_vector(24 downto 0);
	type slice_stack_t is array(range <>) of slice_t;
	
end types;