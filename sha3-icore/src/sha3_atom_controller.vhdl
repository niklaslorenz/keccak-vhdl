library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;

entity sha3_atom_controller is
    port(
        clk : in std_logic;
        enable : in std_logic;
        init : in std_logic;
        read : in std_logic;
        write : in std_logic;
        ready : out std_logic;
        reader_init : out std_logic;
        reader_enable : out std_logic;
        reader_ready : in std_logic;
        gamma_enable : out std_logic;
        gamma_init : out std_logic;
        gamma_theta_only : out std_logic;
        gamma_no_theta : out std_logic;
        gamma_ready : in std_logic;
        rho_init : out std_logic;
        rho_enable : out std_logic;
        tho_ready : in std_logic;
        writer_init : out std_logic;
        writer_enable : out std_logic;
        writer_ready : in std_logic;
        round : out round_index_t
    );
end entity;

architecture arch of sha3_atom_controller is

    type stage_t is (read, theta, gamma, rho, valid, write);

    signal stage : stage_t := valid;

    signal current_round : round_index_t;

begin



end architecture arch;