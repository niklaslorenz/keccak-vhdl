
library IEEE;

use IEEE.std_logic_1164.all;
use work.slices.all;
use work.all;

entity gamma_slice is
port(
    slice_li : in std_logic_vector(24 downto 0);
    slice_hi : in std_logic_vector(24 downto 0);
    sum_bufi : in std_logic_vector(4 downto 0);
    theta_only : in std_logic;
    round : in positive range 0 to 23;
    slice : in positive range 0 to 31;

    slice_lo : out std_logic_vector(24 downto 0);
    slice_ho : out std_logic_vector(24 downto 0);
    sum_bufo : out std_logic_vector(4 downto 0)
);
end entity;

architecture arch of gamma_slice is

    component round_constant_selector is
    port(
        round_index : in natural range 0 to 23;
        slice : in natural range 0 to 31;
        round_constant : out std_logic_vector(63 downto 0)
    );
    end component;

    signal pi_slh : std_logic_vector(24 downto 0);
    signal pi_sll : std_logic_vector(24 downto 0);

    signal chi_slh : std_logic_vector(24 downto 0);
    signal chi_sll : std_logic_vector(24 downto 0);

    signal iota_slh : std_logic_vector(24 downto 0);
    signal iota_sll : std_logic_vector(24 downto 0);
    signal round_constant : std_logic_vector(1 downto 0);

    signal theta_sli : std_logic_vector(24 downto 0);
    signal theta_shi : std_logic_vector(24 downto 0);

    signal theta_slh : std_logic_vector(24 downto 0);
    signal theta_sll : std_logic_vector(24 downto 0);

begin
    -- pi
    pi_x: for x in 0 to 4 generate
        pi_y: for y in 0 to 4 generate
            pi_slh(at(x, y)) <= slice_hi(at((x * 3 + y) mod 5, x));
            pi_sll(at(x, y)) <= slice_li(at((x * 3 + y) mod 5, x));
        end generate;
    end generate;
    -- chi
    chi_y: for y in 0 to 4 generate
        chi_x: for x in 0 to 4 generate
            chi_slh(at(x, y)) <= pi_slh(at(x, y)) xor (not pi_slh(at((x + 1) mod 5, y)) and pi_slh(at((x + 4) mod 5, y)));
            chi_sll(at(x, y)) <= pi_sll(at(x, y)) xor (not pi_sll(at((x + 1) mod 5, y)) and pi_sll(at((x + 4) mod 5, y)));
        end generate;
    end generate;
    -- iota
    constant_selector: round_constant_selector port map(round_index => round, slice => slice, round_constant => round_constant);
    iota_slh(24 downto 1) <= chi_slh(24 downto 1);
    iota_sll(24 downto 1) <= chi_sll(24 downto 1);
    iota_slh(0) <= chi_slh(0) xor round_constant(1);
    iota_sll(0) <= chi_sll(0) xor round_constant(0);
    -- theta
    theta: theta_slice port map(slice_li => iota_sll, slice_hi => iota_slh, sum_bufi => sum_bufi, slice_lo => theta_sll, slice_ho => theta_slh, sum_bufo => sum_bufo);
    if theta_only = '1' then
        theta_sli <= slice_li;
        theta_shi <= slice_hi;
    else
        theta_sli <= iota_sll;
        theta_shi <= iota_slh;
    end if;
    -- result
    if round /= 23 or theta_only = '1' then
        slice_lo <= theta_sll;
        slice_ho <= theta_slh;
    else
        slice_lo <= iota_sll;
        slice_ho <= iota_slh;
    end if;
    sum_bufo <= column_sums_h;

end architecture;
