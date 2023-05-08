library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.gamma_calculator;
use work.manual_port_memory_block;

entity gamma_calculator_test is
end entity;

architecture arch of gamma_calculator_test is

    component manual_port_memory_block is
        port(
            clk : in std_logic;
            manual : in std_logic;
            manual_in : in mem_port_input;
            port_a_in : in mem_port_input;
            port_a_out : out mem_port_output;
            port_b_in : in mem_port_input;
            port_b_out : out mem_port_output
        );
    end component;

    component gamma_calculator is
        port(
            clk : in std_logic;
            enable : in std_logic;
            init : in std_logic;
            atom_index : in atom_index_t;
            round : in round_index_t;
            theta_only : in std_logic;
            no_theta : in std_logic;
            res_mem_port_a_in : out mem_port_input;
            res_mem_port_a_out : in mem_port_output;
            res_mem_port_b_in : out mem_port_input;
            res_mem_port_b_out : in mem_port_output;
            gam_mem_port_a_in : out mem_port_input;
            gam_mem_port_b_in : out mem_port_input;
            transmission_in : in transmission_t;
            transmission_out : out transmission_t
        );
    end component;

    signal clk : std_logic := '0';
    signal finished : boolean := false;

    signal atom_0_gam_manual : std_logic := '0';
    signal atom_0_res_manual : std_logic := '0';
    signal atom_0_gam_manual_in : mem_port_input := mem_port_init.input;
    signal atom_0_res_manual_in : mem_port_input := mem_port_init.input;

    signal atom_0_gam_a : mem_port := mem_port_init;
    signal atom_0_gam_b : mem_port := mem_port_init;
    signal atom_0_res_a : mem_port := mem_port_init;
    signal atom_0_res_b : mem_port := mem_port_init;

    signal atom_1_gam_manual : std_logic := '0';
    signal atom_1_res_manual : std_logic := '0';
    signal atom_1_gam_manual_in : mem_port_input := mem_port_init.input;
    signal atom_1_res_manual_in : mem_port_input := mem_port_init.input;

    signal atom_1_gam_a : mem_port := mem_port_init;
    signal atom_1_gam_b : mem_port := mem_port_init;
    signal atom_1_res_a : mem_port := mem_port_init;
    signal atom_1_res_b : mem_port := mem_port_init;

    signal enable : std_logic := '0';
    signal init : std_logic := '0';
    signal round : round_index_t := 0;
    signal theta_only : std_logic := '0';
    signal no_theta : std_logic := '0';

    signal atom_0_transmission_in : transmission_t := (others => '0');
    signal atom_0_transmission_out : transmission_t := (others => '0');
    signal atom_1_transmission_in : transmission_t := (others => '0');
    signal atom_1_transmission_out : transmission_t := (others => '0');

begin

    atom_0_gam_mem : manual_port_memory_block port map(
        clk => clk,
        manual => atom_0_gam_manual,
        manual_in => atom_0_gam_manual_in,
        port_a_in => atom_0_gam_a.input,
        port_a_out => atom_0_gam_a.output,
        port_b_in => atom_0_gam_b.input,
        port_b_out => atom_0_gam_b.output
    );

    atom_0_res_mem : manual_port_memory_block port map(
        clk => clk,
        manual => atom_0_res_manual,
        manual_in => atom_0_res_manual_in,
        port_a_in => atom_0_res_a.input,
        port_a_out => atom_0_res_a.output,
        port_b_in => atom_0_res_b.input,
        port_b_out => atom_0_res_b.output
    );

    atom_0_calc : gamma_calculator port map(
        clk => clk,
        enable => enable,
        init => init,
        atom_index => 0,
        round => round,
        theta_only => theta_only,
        no_theta => no_theta,
        res_mem_port_a_in => atom_0_res_a.input,
        res_mem_port_a_out => atom_0_res_a.output,
        res_mem_port_b_in => atom_0_res_b.input,
        res_mem_port_b_out => atom_0_res_b.output,
        gam_mem_port_a_in => atom_0_gam_a.input,
        gam_mem_port_b_in => atom_0_gam_b.input,
        transmission_in => atom_0_transmission_in,
        transmission_out => atom_0_transmission_out
    );

    atom_1_gam_mem : manual_port_memory_block port map(
        clk => clk,
        manual => atom_1_gam_manual,
        manual_in => atom_1_gam_manual_in,
        port_a_in => atom_1_gam_a.input,
        port_a_out => atom_1_gam_a.output,
        port_b_in => atom_1_gam_b.input,
        port_b_out => atom_1_gam_b.output
    );

    atom_1_res_mem : manual_port_memory_block port map(
        clk => clk,
        manual => atom_1_res_manual,
        manual_in => atom_1_res_manual_in,
        port_a_in => atom_1_res_a.input,
        port_a_out => atom_1_res_a.output,
        port_b_in => atom_1_res_b.input,
        port_b_out => atom_1_res_b.output
    );

    atom_1_calc : gamma_calculator port map(
        clk => clk,
        enable => enable,
        init => init,
        atom_index => 1,
        round => round,
        theta_only => theta_only,
        no_theta => no_theta,
        res_mem_port_a_in => atom_1_res_a.input,
        res_mem_port_a_out => atom_1_res_a.output,
        res_mem_port_b_in => atom_1_res_b.input,
        res_mem_port_b_out => atom_1_res_b.output,
        gam_mem_port_a_in => atom_1_gam_a.input,
        gam_mem_port_b_in => atom_1_gam_b.input,
        transmission_in => atom_1_transmission_in,
        transmission_out => atom_1_transmission_out
    );

    env : process(clk) is
    begin
        if rising_edge(clk) then
            atom_0_transmission_in <= atom_1_transmission_out;
            atom_1_transmission_in <= atom_0_transmission_out;
        end if;
    end process;

    test : process is
    begin
        wait until rising_edge(clk);
        

        finished <= true;
        wait;
    end process;

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

end architecture arch;