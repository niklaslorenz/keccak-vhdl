
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.keccak_types.all;

entity keccak_iota is
port(
	input : in StateArray;
	roundIndex : in Natural range 0 to 23;
	output : out StateArray
);
end entity keccak_iota;

architecture arch of keccak_iota is

	function const(value : std_logic_vector(63 downto 0)) return Lane is
	begin
		return Lane(value);
	end function const;

	type constants_t is array(0 to 23) of Lane;
	constant constants : constants_t := (
            const(x"0000000000000001"),
            const(x"0000000000008082"),
            const(x"800000000000808a"),
            const(x"8000000080008000"),
            const(x"000000000000808b"),
            const(x"0000000080000001"),
            const(x"8000000080008081"),
            const(x"8000000000008009"),
            const(x"000000000000008a"),
            const(x"0000000000000088"),
            const(x"0000000080008009"),
            const(x"000000008000000a"),
            const(x"000000008000808b"),
            const(x"800000000000008b"),
            const(x"8000000000008089"),
            const(x"8000000000008003"),
            const(x"8000000000008002"),
            const(x"8000000000000080"),
            const(x"000000000000800a"),
            const(x"800000008000000a"),
            const(x"8000000080008081"),
            const(x"8000000000008080"),
            const(x"0000000080000001"),
            const(x"8000000080008008"));

	signal debug_roundIndex : natural range 0 to 23;
	signal debug_const : natural;

begin
	output(0) <= input(0) xor constants(roundIndex);
	forward : for i in 1 to 24 generate
		output(i) <= input(i);
	end generate;
end architecture arch;
