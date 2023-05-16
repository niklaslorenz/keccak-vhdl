library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.memory_block;
use work.reader;
use work.gamma_calculator;
use work.rho_buffer;
use work.writer;

entity sha3_atom is
    port(
        clk : in std_logic;
        enable : in std_logic;
        init : in std_logic;
        atom_index_input : in atom_index_t;
        read : in std_logic;
        write : in std_logic;
        ready : out std_logic;
        transmission_active : out std_logic;
        transmission_in : in transmission_t;
        transmission_out : out transmission_t
    );
end entity;

architecture arch of sha3_atom is

    component memory_block is
        port(
            clk : in std_logic;
            port_a_in : in mem_port_input;
            port_a_out : out mem_port_output;
            port_b_in : in mem_port_input;
            port_b_out : out mem_port_output
        );
    end component;

    component sha3_atom_controller is
        port(
            clk : in std_logic;
            enable : in std_logic;
            init : in std_logic;
            start_read : in std_logic;
            start_write : in std_logic;
            ready : out std_logic;
            purger_start : out std_logic;
            purger_ready : in std_logic;
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
            rho_ready : in std_logic;
            writer_init : out std_logic;
            writer_enable : out std_logic;
            writer_ready : in std_logic;
            round : out round_index_t
        );
    end component;

    component purger is
        port(
            clk : in std_logic;
            start : in std_logic;
            port_a_in : out mem_port_input;
            port_b_in : out mem_port_input;
            ready : out std_logic
        );
    end component;

    component reader is
        port(
            clk : in std_logic;
            init : in std_logic;
            enable : in std_logic;
            atom_index : in atom_index_t;
            transmission : in transmission_t;
            mem_input : out mem_port_input;
            ready : out std_logic
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
            transmission_out : out transmission_t;
            ready : out std_logic
        );
    end component;

    component rho_buffer is
        port(
            clk : in std_logic;
            init : in std_logic;
            enable : in std_logic;
            atom_index : in atom_index_t;
            gam_port_a_in : out mem_port_input;
            gam_port_a_out : in mem_port_output;
            gam_port_b_in : out mem_port_input;
            gam_port_b_out : in mem_port_output;
            res_port_a_in : out mem_port_input;
            res_port_a_out : in mem_port_output;
            res_port_b_in : out mem_port_input;
            res_port_b_out : in mem_port_output;
            ready : out std_logic
        );
    end component;

    component writer is
        port(
            clk : in std_logic;
            init : in std_logic;
            enable : in std_logic;
            atom_index : in atom_index_t;
            mem_input_a : out mem_port_input;
            mem_output_a : in mem_port_output;
            mem_input_b : out mem_port_input;
            mem_output_b : in mem_port_output;
            transmission : out transmission_t;
            transmission_active : out std_logic;
            ready : out std_logic
        );
    end component;

    signal res_mem_port_a : mem_port;
    signal res_mem_port_b : mem_port;
    signal gam_mem_port_a : mem_port;
    signal gam_mem_port_b : mem_port;

    -- controller signals

    signal purger_start : std_logic;
    signal purger_ready : std_logic;

    signal reader_init : std_logic;
    signal reader_enable : std_logic;
    signal reader_ready : std_logic;

    signal gamma_enable : std_logic;
    signal gamma_init : std_logic;
    signal gamma_theta_only : std_logic;
    signal gamma_no_theta : std_logic;
    signal gamma_ready : std_logic;

    signal rho_init : std_logic;
    signal rho_enable : std_logic;
    signal rho_ready : std_logic;

    signal writer_init : std_logic;
    signal writer_enable : std_logic;
    signal writer_ready : std_logic;

    signal round : round_index_t;

    -- data signals

    signal buffered_transmission_in : transmission_t;

    signal atom_index : atom_index_t;

begin

    process(clk) is
    begin
        if rising_edge(clk) then
            buffered_transmission_in <= transmission_in;
            if init = '1' then
                atom_index <= atom_index_input;
            end if;
        end if;
    end process;

    res_mem : memory_block port map(
        clk => clk,
        port_a_in => res_mem_port_a.input,
        port_a_out => res_mem_port_a.output,
        port_b_in => res_mem_port_b.input,
        port_b_out => res_mem_port_b.output
    );

    gam_mem : memory_block port map(
        clk => clk,
        port_a_in => gam_mem_port_a.input,
        port_a_out => gam_mem_port_a.output,
        port_b_in => gam_mem_port_b.input,
        port_b_out => gam_mem_port_b.output
    );

    controller : sha3_atom_controller port map(
        clk => clk,
        enable => enable,
        init => init,
        start_read => read,
        start_write => write,
        ready => ready,
        purger_start => purger_start,
        purger_ready => purger_ready,
        reader_init => reader_init,
        reader_enable => reader_enable,
        reader_ready => reader_ready,
        gamma_enable => gamma_enable,
        gamma_init => gamma_init,
        gamma_theta_only => gamma_theta_only,
        gamma_no_theta => gamma_no_theta,
        gamma_ready => gamma_ready,
        rho_init => rho_init,
        rho_enable => rho_enable,
        rho_ready => rho_ready,
        writer_init => writer_init,
        writer_enable => writer_enable,
        writer_ready => writer_ready,
        round => round
    );

    prgr : purger port map(
        clk => clk,
        start => purger_start,
        port_a_in => res_mem_port_a.input,
        port_b_in => res_mem_port_b.input,
        ready => purger_ready
    );

    rdr : reader port map(
        clk => clk,
        init => reader_init,
        enable => reader_enable,
        atom_index => atom_index,
        transmission => transmission_in,
        mem_input => res_mem_port_a.input,
        ready => reader_ready
    );

    gamma : gamma_calculator port map(
        clk => clk,
        enable => gamma_enable,
        init => gamma_init,
        atom_index => atom_index,
        round => round,
        theta_only => gamma_theta_only,
        no_theta => gamma_no_theta,
        res_mem_port_a_in => res_mem_port_a.input,
        res_mem_port_a_out => res_mem_port_a.output,
        res_mem_port_b_in => res_mem_port_b.input,
        res_mem_port_b_out => res_mem_port_b.output,
        gam_mem_port_a_in => gam_mem_port_a.input,
        gam_mem_port_b_in => gam_mem_port_b.input,
        transmission_in => buffered_transmission_in,
        transmission_out => transmission_out,
        ready => gamma_ready
    );

    rho : rho_buffer port map(
        clk => clk,
        init => rho_init,
        enable => rho_enable,
        atom_index => atom_index,
        gam_port_a_in => gam_mem_port_a.input,
        gam_port_a_out => gam_mem_port_a.output,
        gam_port_b_in => gam_mem_port_b.input,
        gam_port_b_out => gam_mem_port_b.output,
        res_port_a_in => res_mem_port_a.input,
        res_port_a_out => res_mem_port_a.output,
        res_port_b_in => res_mem_port_b.input,
        res_port_b_out => res_mem_port_b.output,
        ready => rho_ready
    );

    wrtr : writer port map(
        clk => clk,
        init => writer_init,
        enable => writer_enable,
        atom_index => atom_index,
        mem_input_a => res_mem_port_a.input,
        mem_output_a => res_mem_port_a.output,
        mem_input_b => res_mem_port_b.input,
        mem_output_b => res_mem_port_b.output,
        transmission => transmission_out,
        transmission_active => transmission_active,
        ready => writer_ready
    );

end architecture arch;