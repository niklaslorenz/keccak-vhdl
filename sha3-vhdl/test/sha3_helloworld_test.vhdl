
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.keccak_types.all;
use work.sha3_types.all;
use work.testutil.all;
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

    constant t : sha3_type := sha256;
    constant input_text : string := "Hello World!";
    constant input_block : std_logic_vector := sha_pad(input_text, t);
    constant raw_hash : std_logic_vector(255 downto 0) := x"d0e47486bbf4c16acac26f8b653592973c1362909f90262877089f9c8a4536af";
    constant hash : std_logic_vector(255 downto 0) := reverseByteOrder(raw_hash);

    signal rst : boolean := true;
    signal clk : std_logic := '0';
    signal start : boolean := false;
    signal output : std_logic_vector(getHashSize(t) - 1 downto 0);
    signal ready : boolean;
    signal finished : boolean := false;
    signal debug_padded : std_logic_vector(511 downto 0) := input_block(511 downto 0);
    signal hash_debug : std_logic_vector(255 downto 0) := hash;
begin

    sha : sha3 generic map (t => t) port map(input => input_block, rst => rst, clk => clk, start => start, mode => init, output => output, ready => ready);

    clock : process
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    verify : process
    begin
        wait until falling_edge(clk);
        rst <= false;
        start <= true;
        wait until rising_edge(clk);
        start <= false;
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        while not ready loop
            wait until rising_edge(clk);
        end loop;
        assert hash = output report "Failed test sha3_helloworld:" severity ERROR;
        finished <= true;
        wait;
    end process;


end architecture arch;
