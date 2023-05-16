library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.util.all;

entity sha3_atom_controller is
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
end entity;

architecture arch of sha3_atom_controller is

    type stage_t is (purge, valid, read, theta, gamma, rho, write);

    signal stage : stage_t := valid;
    signal current_round : round_index_t := 0;

    signal purger_trigger : std_logic := '0';
    signal reader_trigger : std_logic := '0';
    signal gamma_trigger : std_logic := '0';
    signal rho_trigger : std_logic := '0';
    signal writer_trigger : std_logic := '0';

begin

    ready <= asBit(stage = valid);

    purger_start <= purger_trigger;

    reader_init <= reader_trigger;
    reader_enable <= asBit(stage = read);

    gamma_init <= gamma_trigger;
    gamma_enable <= asBit(stage = gamma or stage = theta);
    gamma_theta_only <= asBit(stage = theta);
    gamma_no_theta <= asBit(current_round = 23);

    rho_init <= rho_trigger;
    rho_enable <= asBit(stage = rho);

    writer_init <= writer_trigger;
    writer_enable <= asBit(stage = write);

    round <= current_round;

    process(clk) is 
    begin
        if rising_edge(clk) and enable = '1' then

            if purger_trigger = '1' then
                purger_trigger <= '0';
            end if;
            if reader_trigger = '1' then
                reader_trigger <= '0';
            end if;
            if gamma_trigger = '1' then
                gamma_trigger <= '0';
            end if;
            if rho_trigger = '1' then
                rho_trigger <= '0';
            end if;
            if writer_trigger = '1' then
                writer_trigger <= '0';
            end if;

            if init = '1' then
                stage <= purge;
                purger_trigger <= '1';
                current_round <= 0;
            elsif stage = purge then
                if purger_ready = '1' then
                    stage <= valid;
                end if;
            elsif stage = valid then
                if start_read = '1' then
                    stage <= read;
                    reader_trigger <= '1';
                    current_round <= 0;
                elsif start_write = '1' then
                    stage <= write;
                    writer_trigger <= '1';
                end if;
            elsif stage = read then
                if reader_ready = '1' then
                    stage <= theta;
                    gamma_trigger <= '1';
                end if;
            elsif stage = theta then
                if gamma_ready = '1' then
                    stage <= rho;
                    rho_trigger <= '1';
                end if;
            elsif stage = rho then
                if rho_ready = '1' then
                    stage <= gamma;
                    gamma_trigger <= '1';
                end if;
            elsif stage = gamma then
                if gamma_ready = '1' then
                    if current_round = 23 then
                        stage <= valid;
                    else
                        stage <= rho;
                        rho_trigger <= '1';
                        current_round <= current_round + 1;
                    end if;
                end if;
            elsif stage = write then
                if writer_ready = '1' then
                    stage <= valid;
                end if;
            end if;
        end if;
    end process;

end architecture arch;