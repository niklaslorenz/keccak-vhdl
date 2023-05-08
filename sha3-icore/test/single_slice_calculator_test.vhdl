library IEEE;

use IEEE.std_logic_1164.all;
use work.state.all;
use work.single_slice_calculator;
use work.slice_functions.all;

entity single_slice_calculator_test is
end entity;

architecture arch of single_slice_calculator_test is
    component single_slice_calculator is
        port(
            slice : in slice_t;
            prev_sums : in std_logic_vector(4 downto 0);
            theta_only : in std_logic;
            no_theta : in std_logic;
            round_constant_bit : in std_logic;
            result : out slice_t;
            slice_sums : out std_logic_vector(4 downto 0)
        );
    end component;

    signal slice : slice_t;
    signal prev_sums : std_logic_vector(4 downto 0);
    signal theta_only : std_logic;
    signal no_theta : std_logic;
    signal round_constant_bit : std_logic;
    signal result : slice_t;
    signal slice_sums : std_logic_vector(4 downto 0);

    signal expected_theta_only_slice_sums : std_logic_vector(4 downto 0);
    signal expected_theta : slice_t;

    signal expected_no_theta : slice_t;

    signal expected_gamma : slice_t;
    signal expected_gamma_sums : std_logic_vector(4 downto 0);
begin

    calc : single_slice_calculator port map(slice, prev_sums, theta_only, no_theta, round_constant_bit, result, slice_sums);

    expected_theta_only_slice_sums <= theta_sums(slice);
    expected_theta <= theta(prev_sums, expected_theta_only_slice_sums, slice);

    expected_no_theta <= chi(pi(slice)) xor ("000000000000000000000000" & round_constant_bit);

    expected_gamma <= theta(prev_sums, theta_sums(expected_no_theta), expected_no_theta);
    expected_gamma_sums <= theta_sums(expected_no_theta);

    test : process is
    begin
        slice <= "1001010101101001110101110";
        prev_sums <= "10011";
        round_constant_bit <= '1';
        theta_only <= '1';
        no_theta <= '0';
        wait for 1ns;
        assert slice_sums = expected_theta_only_slice_sums;
        assert result = expected_theta;
        theta_only <= '0';
        no_theta <= '1';
        wait for 1ns;
        assert result = expected_no_theta;
        theta_only <= '0';
        no_theta <= '0';
        wait for 1ns;
        assert result = expected_gamma;
        assert slice_sums = expected_gamma_sums;
        wait;
    end process;

end architecture;