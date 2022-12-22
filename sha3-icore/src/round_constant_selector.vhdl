
library IEEE;

use IEEE.std_logic_1164.all;

entity round_constant_selector is
port(
    round_index : in natural range 0 to 23;
    slice : in natural range 0 to 31;
    round_constant : out std_logic_vector(1 downto 0)

);
end entity;

architecture arch of round_constant_selector is
    signal full_constant : std_logic_vector(63 downto 0);
begin

    round_constant <= full_constant(slice * 2 + 1 downto slice * 2);

    with round_index select full_constant <=
            const(x"0000000000000001") when  0,
            const(x"0000000000008082") when  1,
            const(x"800000000000808a") when  2,
            const(x"8000000080008000") when  3,
            const(x"000000000000808b") when  4,
            const(x"0000000080000001") when  5,
            const(x"8000000080008081") when  6,
            const(x"8000000000008009") when  7,
            const(x"000000000000008a") when  8,
            const(x"0000000000000088") when  9,
            const(x"0000000080008009") when 10,
            const(x"000000008000000a") when 11,
            const(x"000000008000808b") when 12,
            const(x"800000000000008b") when 13,
            const(x"8000000000008089") when 14,
            const(x"8000000000008003") when 15,
            const(x"8000000000008002") when 16,
            const(x"8000000000000080") when 17,
            const(x"000000000000800a") when 18,
            const(x"800000008000000a") when 19,
            const(x"8000000080008081") when 20,
            const(x"8000000000008080") when 21,
            const(x"0000000080000001") when 22,
            const(x"8000000080008008") when 23;
end architecture;
