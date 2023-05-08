library IEEE;
use IEEE.std_logic_1164.all;

use work.state.all;
use work.double_slice_calculator;

entity clocked_double_slice_calculator is
    port(
        clk : in std_logic;
        data : in double_slice_t;
        theta_only : in std_logic;
        no_theta : in std_logic;
        round_constant : in std_logic_vector(1 downto 0);
        result : out double_slice_t
    );
end entity;

architecture arch of clocked_double_slice_calculator is
    component double_slice_calculator is
        port(
            data : in double_slice_t;
            prev_sums : in std_logic_vector(4 downto 0);
            theta_only : in std_logic;
            no_theta : in std_logic;
            round_constant : in std_logic_vector(1 downto 0);
            result : out double_slice_t;
            slice_sums : out std_logic_vector(4 downto 0)
        );
    end component;

    signal prev_sums, current_sums : std_logic_vector(4 downto 0);

begin

    calc : double_slice_calculator port map(
        data => data,
        prev_sums => prev_sums,
        theta_only => theta_only,
        no_theta => no_theta,
        round_constant => round_constant,
        result => result,
        slice_sums => current_sums
    );

    process(clk) is
    begin
        if rising_edge(clk) then
            prev_sums <= current_sums;
        end if;
    end process;

end architecture arch;