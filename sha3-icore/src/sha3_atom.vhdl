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
        atom_index : in atom_index_t;
        read : in std_logic;
        write : in std_logic;
        ready : out std_logic;
        transmission_active : out std_logic;
        transmission_in : in transmission_t;
        transmission_out : out transmission_t
    );
end entity;

architecture arch of sha3_atom is

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

    component memory_block is
        port(
            clk : in std_logic;
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
    signal tho_ready : std_logic;

    signal writer_init : std_logic;
    signal writer_enable : std_logic;
    signal writer_ready : std_logic;

    signal round : round_index_t;

    -- data signals

    signal buffered_transmission_in : transmission_t;

begin

    process(clk) is
    begin
        if rising_edge(clk) then
            buffered_transmission_in <= transmission_in;
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
        gam_mem_port_a_in => gam_mem_port_a.input,
        gam_mem_port_a_out => gam_mem_port_a.output,
        gam_mem_port_b_in => gam_mem_port_b.input,
        gam_mem_port_b_out => gam_mem_port_b.output,
        res_mem_port_a_in => res_mem_port_a.input,
        res_mem_port_a_out => res_mem_port_a.output,
        res_mem_port_b_in => res_mem_port_b.input,
        res_mem_port_b_out => res_mem_port_b.output,
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