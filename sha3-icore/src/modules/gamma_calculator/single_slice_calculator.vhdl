library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.util.all;

entity single_slice_calculator is
    port(
        slice : in slice_t;
        prev_sums : in std_logic_vector(4 downto 0);
        theta_only : in std_logic;
        no_theta : in std_logic;
        round_constant_bit : in std_logic;
        result : out slice_t;
        slice_sums : out std_logic_vector(4 downto 0)
    );
end entity;

architecture arch of single_slice_calculator is

    signal pi_chi_result : slice_t;
    signal beta_result : slice_t;
    signal theta_input : slice_t;
    signal theta_result : slice_t;
    signal slice_sums_temp : std_logic_vector(4 downto 0);
begin

    pi_chi_result <= chi(pi(slice));
    beta_result <= pi_chi_result(24 downto 1) & (pi_chi_result(0) xor round_constant_bit);

    slice_sums_temp <= theta_sums(theta_input);
    theta_result <= theta(prev_sums, slice_sums_temp, theta_input);
    slice_sums <= slice_sums_temp;

    theta_input <= slice when theta_only = '1' else beta_result;
    result <= beta_result when no_theta = '1' else theta_result;

end architecture;