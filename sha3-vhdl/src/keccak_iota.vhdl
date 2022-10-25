
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

	function create(i1, i2, i3, i4 : natural range 0 to 65535) return unsigned(63 downto 0) is
	begin
		return std_logic_vector(i1) & std_logic_vector(i2) & std_logic_vector(i3) & std_logic_vector(i4);
	end function create;

	type constants_t is array(0 to 23) of unsigned(63 downto 0);
	constant constants : constants_t := (1,
            32898,
            9223372036854808714,
            9223372039002292224,
            32907,
            2147483649,
            9223372039002292353,
            9223372036854808585,
            138,
            136,
            2147516425,
            2147483658,
            2147516555,
            9223372036854775947,
            9223372036854808713,
            9223372036854808579,
            9223372036854808578,
            9223372036854775936,
            32778,
            9223372039002259466,
            9223372039002292353,
            9223372036854808704,
            2147483649,
            9223372039002292232);

	signal debug_roundIndex : natural range 0 to 23;
	signal debug_const : natural;

begin
	output(0) <= input(0) xor Lane(std_logic_vector(to_unsigned(constants(roundIndex), 64)));
	forward : for i in 1 to 24 generate
		output(i) <= input(i);
	end generate;
end architecture arch;
