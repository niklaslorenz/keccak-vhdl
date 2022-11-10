 
library IEEE;
use IEEE.std_logic_1164.all;
use work.keccak_types.all;
use work.sha3_types.all;
use work.all;

entity sha3 is
generic (t : sha3_type := sha256);
port(
    input : in std_logic_vector(1599 - 2 * getHashSize(t) downto 0);
    rst : in std_logic;
    clk : in std_logic;
    start : in std_logic;
    mode : in sha3_mode;
    output : out std_logic_vector(getHashSize(t) - 1 downto 0);
    ready : out std_logic
);
end entity sha3;

architecture arch of sha3 is
    component keccak_f is
    port(
        input : in StateArray;
        rst : in std_logic;
        clk : in std_logic;
        start : in std_logic;
        output : out StateArray;
        ready : out std_logic
    );
    end component keccak_f;
    signal f_input : StateArray;
    signal f_output : StateArray;
    signal padded_input : std_logic_vector(1599 downto 0);
    constant zero : std_logic_vector(2 * getHashSize(t) - 1 downto 0) := (others => '0');
begin
    
    f : keccak_f port map(input => f_input, rst => rst, clk => clk, start => start, output => f_output, ready => ready);
    
    padded_input <= zero & input;
    
    with mode select f_input <=
        to_StateArray(padded_input) when init,
        to_StateArray(to_std_logic_vector(f_output) xor padded_input) when append;
    
    output <= to_std_logic_vector(f_output)(getHashSize(t) - 1 downto 0);
    
end architecture arch;
