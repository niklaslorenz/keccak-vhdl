
library IEEE;

use IEEE.std_logic_1164.all;
use work.slices.all;

entity theta_slice is
port(
    slice_li : in std_logic_vector(24 downto 0);
    slice_hi : in std_logic_vector(24 downto 0);
    sum_bufi : in std_logic_vector(4 downto 0);

    slice_lo : out std_logic_vector(24 downto 0);
    slice_ho : out std_logic_vector(24 downto 0);
    sum_bufo : out std_logic_vector(4 downto 0)
);
end entity;

architecture arch of theta_slice is
    signal column_sums_h : std_logic_vector(4 downto 0);
    signal column_sums_l : std_logic_vector(4 downto 0);
    signal column_modifiers_h : std_logic_vector(4 downto 0);
    signal column_modifiers_l : std_logic_vector(4 downto 0);
begin
    theta_sums: for x in 0 to 4 generate
        column_sums_h(x) <= iota_slh(at(x, 0)) xor iota_slh(at(x, 1)) xor iota_slh(at(x, 2)) xor iota_slh(at(x, 3)) xor iota_slh(at(x, 4));
        column_sums_l(x) <= iota_sll(at(x, 0)) xor iota_sll(at(x, 1)) xor iota_sll(at(x, 2)) xor iota_sll(at(x, 3)) xor iota_sll(at(x, 4));
    end generate;
    theta_modifiers: for x in 0 to 4 generate
        column_modifiers_h(x) <= column_sums_h((x + 4) mod 5) xor column_sums_l((x + 1) mod 5);
        column_modifiers_l(x) <= column_sums_l((x + 4) mod 5) xor sum_bufi((x + 1) mod 5);
    end generate;
end architecture;
