
library IEEE;
use IEEE.std_logic_1164.all;

use work.keccak_types.all;
use work.sha3_types.all;
use work.all;

entity sha3_helloworld_test is
end entity sha3_helloworld_test;

architecture arch of sha3_helloworld_test is
    component sha3 is
    generic(t : sha3_type);
    port(
        input : in std_logic_vector(1599 - 2 * getHashSize(t) downto 0);
        rst : in boolean;
        clk : in std_logic;
        start : in boolean;
        mode : in sha3_mode;
        output : out std_logic_vector(getHashSize(t) - 1 downto 0);
        ready : out boolean
    );
    end component sha3;
    constant input_text : string := "Hello World!";
begin
    
end architecture arch;
