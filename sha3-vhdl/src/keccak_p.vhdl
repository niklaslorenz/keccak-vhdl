
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_VECTOR.all;

entity keccak_p is
port(
	input : in std_logic_vector(1599 downto 0);
	round_index : in std_logic_vector(5 downto 0);
	output : out std_logic_vector(1599 downto 0);
);
end entity keccak_p;
