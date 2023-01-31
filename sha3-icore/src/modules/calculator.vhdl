library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
use work.slice_functions.all;

entity calculator is
    port(
        slice : in slice_t;
        prev_sums : in std_logic_vector(4 downto 0);
        theta_only : in std_logic;
        no_theta : in std_logic;
        round_constant_bit : in std_logic;
        result : out slice_t;
        slice_sums : out std_logic_vector(4 downto 0);
    );
end entity;

architecture arch of calculator is

    signal pi_chi_result : slice_t;
    signal beta_result : slice_t;
    signal theta_input : slice_t;
    signal theta_result : slice_t;
    signal theta_sums : std_logic_vector(4 downto 0);
begin

    pi_chi_result <= chi(pi(slice));
    beta_result <= pi_chi_result(24 downto 1) & (pi_chi_result(0) xor round_constant_bit);

    theta_sums <= theta_sums(theta_input);
    theta_result <= theta(prev_sums, theta_sums, theta_input);
    slice_sums <= theta_sums;

    if theta_only = '1' then
        theta_input <= slice;
    else
        theta_input <= beta_result;
    end if;

    if no_theta = '1' then
        result <= beta_result;
    else
        result <= theta_result;
    end if;
end architecture;