library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
use work.slice_functions.all;
use work.single_slice_calculator;

entity double_slice_calculator is
    port(
        data : in double_slice_t;
        prev_sums : in std_logic_vector(4 downto 0);
        theta_only : in std_logic;
        no_theta : in std_logic;
        round_constant : in std_logic_vector(1 downto 0);
        result : out double_slice_t;
        slice_sums : out std_logic_vector(4 downto 0)
    );
end entity;

architecture arch of double_slice_calculator is
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

    signal lower_sums : std_logic_vector(4 downto 0);

begin

    lower_calc : single_slice_calculator port map(data(0), prev_sums, theta_only, no_theta, round_constant(0), result(0), lower_sums);
    upper_calc : single_slice_calculator port map(data(1), lower_sums, theta_only, no_theta, round_constant(1), result(1), slice_sums);

end architecture;