
library IEEE;
use IEEE.std_logic_1164.all;

package keccak_types is

subtype Lane is std_logic_vector(63 downto 0);

type StateArray is array(24 downto 0) of Lane;
function "=" (a : StateArray; b : StateArray) return boolean;

function to_StateArray(v : std_logic_vector(1599 downto 0)) return StateArray;
function to_std_logic_vector(s : StateArray) return std_logic_vector;

end package keccak_types;

package body keccak_types is

function "=" (a : StateArray; b : StateArray) return boolean is
begin
	for i in 0 to 24 loop
		if a(i) /= b(i) then
			return false;
		end if;
	end loop;
	return true;
end function;

function to_StateArray(v : std_logic_vector(1599 downto 0)) return StateArray is
	variable s : StateArray;
begin
	for i in 0 to 24 loop
		s(i) := v(i * 64 + 63 downto i * 64);
	end loop;
	return s;
end function to_StateArray;

function to_std_logic_vector(s : StateArray) return std_logic_vector is
	variable v : std_logic_vector(1599 downto 0);
begin
	for i in 0 to 24 loop
		v(i * 64 + 63 downto i * 64) := s(i);
	end loop;
	return v;
end function to_std_logic_vector;

end package body keccak_types;