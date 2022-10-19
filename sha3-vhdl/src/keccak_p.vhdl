
library IEEE;

use work.keccak_types.all;
use work.all;

entity keccak_p is
port(
	input : in StateArray;
	roundIndex : in natural range 0 to 23;
	output : out StateArray
);
end entity keccak_p;

architecture arch of keccak_p is
	
	component keccak_theta is
		port(
			input : in StateArray;
			output : out StateArray
		);
	end component;
	
	component keccak_rho is
		port(
			input : in StateArray;
			output : out StateArray
		);
	end component;
	
	component keccak_pi is
		port(
			input : in StateArray;
			output : out StateArray
		);
	end component;
	
	component keccak_chi is
		port(
			input : in StateArray;
			output : out StateArray
		);
	end component;
	
	component keccak_iota is
		port(
			input : in StateArray;
			roundIndex : Natural range 0 to 23;
			output : out StateArray
		);
	end component;
	
	signal theta_out : StateArray;
	signal rho_out : StateArray;
	signal pi_out : StateArray;
	signal chi_out : StateArray;
begin
	theta : keccak_theta port map(input => input, output => theta_out);
	rho : keccak_rho port map(input => theta_out, output => rho_out);
	pi : keccak_pi port map(input => rho_out, output => pi_out);
	chi : keccak_chi port map(input => pi_out, output => chi_out);
	iota : keccak_iota port map(input => chi_out, roundIndex => roundIndex, output => output);
end architecture arch;
