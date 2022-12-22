
library IEEE;
use IEEE.std_locic_1164.all;
use work.slices.all;

-- An atom that can calculate sha3 hash values. You need two atoms,
-- one which has it's index set to 0 and one with an index of 1.
-- Both atoms each hold about the half of the entire keccak state-array.
--
-- ctl format (from msb to lsb):
-- +---+-------+------------------------+
-- |bit|name   | description            |
-- +---+-------+------------------------+
-- |  7|rst    | reset                  |
-- |  6|clk    | clock                  |
-- |  5|index  | atom index             |
-- |  4|step   | make next step
-- |  3|clr_stg| clear the stage        |
-- |2-0|mode   | see (modes)            |
-- +---+-------+------------------------+
entity sha_atom is
port(
    data_HI : in std_logic_vector(31 downto 0);
    data_LOW : in std_logic_vector(31 downto 0);
    ctl : in std_logic_vector(7 downto 0);
    res_HI : out std_logic_vector(31 downto 0);
    res_LOW : out std_logic_vector(31 downto 0)
);
end entity;

architecture arch of sha_atom is

    component state_array_loader is
    port(
        clk : in std_logic;
        rst : in std_logic;
        enabled : in std_logic;
        init : in std_logic;

        target : out natural range 0 to 12;
        done : out std_logic;
        valid : out std_logic;
    );
    end component;

    component gamma_slice is
    port(
        slice_li : in std_logic_vector(24 downto 0);
        slice_hi : in std_logic_vector(24 downto 0);
        sum_bufi : in std_logic_vector(4 downto 0);
        theta_only : in std_logic;
        round : in natural range 0 to 23;
        slice : in natural range 0 to 31;

        slice_lo : out std_logic_vector(24 downto 0);
        slice_ho : out std_logic_vector(24 downto 0);
        sum_bufo : out std_logic_vector(4 downto 0)
    );
    end component;

    -- constants
    type rho_offset_t is array(0 to 24) of natural;
	constant rho_offsets : rho_offset_t := (0, 1, 62, 28, 27, 36, 44, 6, 55, 20, 3, 10, 43, 25, 39, 41, 45, 15, 21, 8, 18, 2, 61, 56, 14);

    -- interface
    -- bound
    signal data : std_logic_vector(63 downto 0);
    signal rst : std_logic;
    signal clk : std_logic;
    signal index : std_logic;
    signal clr_stg : std_logic;
    signal step : std_logic;
    signal mode : std_logic_vector(3 downto 0);  -- make mode 4 bits long so it can be represented by a hex character (msb is always 0)
    signal res : std_logic_vector(63 downto 0);

    -- state (free)
    signal round : natural range 0 to 23;
    signal done : std_logic;

    type stage_t is (READ, THETA, RHO, GAMMA);
    signal stage : stage_t;

    type state_t is array range 0 to 12 of std_logic_vector(63 downto 0);
    signal state : state_t;

    -- functionality
    procedure clear_state(state : inout state_t) is
    begin
        for i in 0 to 12 loop
            state(i) <= (others => '0');
        end loop;
    end procedure;

    -- READ


    -- bound
    signal READ_target : natural range 0 to 12;
    signal READ_done : std_logic;
    signal READ_valid : std_logic;
    signal READ_enabled : std_logic;
    signal READ_init : std_logic;

    -- rho

    --gamma


    -- free
    signal GAMMA_slice_low_in : std_logic_vector(24 downto 0);
    signal GAMMA_slice_high_in : std_logic_vector(24 downto 0);
    signal GAMMA_sum_buf_in : std_logic_vector(4 downto 0);
    signal GAMMA_theta_only : std_logic;
    signal GAMMA_slice : std_logic;

    -- bound
    signal GAMMA_slice_low_out : std_logic_vector(24 downto 0);
    signal GAMMA_slice_high_out : std_logic_vector(24 downto 0);
    signal GAMMA_sum_buf_out : std_logic_vector(4 downto 0);

begin
    --interface
    res_HIGH <= res(63 downto 32);
    res_LOW <= res(31 downto 0);
    data <= data_HIGH & data_LOW;
    rst <= ctl(7);
    clk <= ctl(6);
    index <= ctl(5);
    step <= ctl(4);
    clr_stg <= ctl(3);
    mode <= "0" & ctl(2 downto 0);

    with stage select res <=
        (others => '0') when READ,
        (others => '0') when others;

    --read
    loader: state_array_loader port map(
        clk => clk,
        rst => rst,
        enabled => READ_enabled,
        from_zero => READ_from_zero,
        target => READ_target,
        done => READ_done,
        valid => READ_valid);

    if stage = READ then
        READ_enabled <= step;
        READ_init <= '0';
    else
        READ_enabled <= '0';
        READ_init <= '1';
    end if;

    --legacy

    gamma: gamma_slice port map(
        slice_li => GAMMA_slice_low_in,
        slice_hi => GAMMA_slice_high_in,
        sum_bufi => GAMMA_sum_buf_in,
        theta_only => GAMMA_theta_only,
        round => round,
        slice => GAMMA_slice,
        slice_lo => GAMMA_slice_low_out,
        slice_ho => GAMMA_slice_high_out,
        sum_bufo => GAMMA_sum_buf_out);

    process(clk, rst) is
    begin
        if rst = '1' then
            -- reset all free signals
            -- reset interface
            res <= (others <= '0');
            -- reset state
            round <= 0;
            done <= '0';
            stage <= READ;
            clear_state(state);

            -- reset gamma interface
            slice_li <= (others => '0');
            slice_hi <= (others => '0');
            sum_bufi <= (others => '0');
            theta_only <= '0';
        elsif rising_edge(clk) then
            -- clearing the stage prevents all other calculations
            if clear_stage = '1' then
                stage <= READ;
            else
                if stage = READ then
                    if READ_valid then
                        state(READ_target) <= data;
                    end if;
                    if READ_done = '1' then
                        stage <= THETA;
                    end if;
                end if;

                if stage = THETA then
                    if THETA_valid then

                    end if;
                    if THETA_done then
                        stage <= RHO;
                    end if;
                end if;












                if mode = x"1" then
                    -- fill (merge message block into state)
                    -- DEPENDING ON THE VARIANT OF SHA-3 that is implemented,
                    -- you might not need to iterate over every lane. Example:
                    --   sha3-256 uses blocks of 1088bits = 17 Lanes each, so
                    --   you just need to iterate over the lanes 0 to 16.
                    -- The atoms know which lanes they need to update.
                    -- If you ever need to pause the transmission, you can always
                    -- set the mode to 0 and continue whenever you want.
                    -- Requirements:
                    --   stage cleared
                    -- Usage:
                    --   set mode to 1 in cycle (x)
                    --   provide the state-lane l (0 to 24) in the cycle (x + l)
                    if index = '0' then
                        if stage <= 12 then
                            state(stage) <= state(stage) xor data;
                        end if;
                    else
                        if stage >= 12 and stage <= 24 then
                            state(stage - 12) <= state(stage) xor data;
                        end if;
                    end if;
                end if;
                if mode = x"2" then
                    -- theta
                    -- Used to calculate theta in the first iteration of keccak-f
                    -- Requrements:
                    --   stage cleared
                    -- Usage:
                    --   set mode to 2
                    --   hold for TODO(How Many?) cycles


                end if;
                if mode = x"3" then
                    -- rho
                    -- Used to calculate rho in every iteration of keccak-f
                    -- Requirements:
                    --   (none)
                    -- Usage:
                    --   set mode to 3 for EXACTLY 1 cycle
                    if index = '0' then
                        for lane in 0 to 12 loop
                            state(lane) <= rotl(state(lane), rho_offsets(lane));
                        end loop;
                    else
                        for lane in 0 to 12 loop
                            state(lane) <= rotl(state(lane), offsets(12 + lane));
                        end loop;
                    end if;
                end if;
                if mode = x"4" then
                    -- gamma
                    -- Used to calculate gamma in every iteration of keccak-f
                    -- and also to reverse (just skip) the last theta.
                    -- Requirements:
                    --

                    -- atom 0 calculates slices 0 to 31,
                    -- atom 2 calculates slices 32 to 63
                    if slice = 0 then
                        case stage is
                            when 0 =>
                                sum_bufi <= (others <= '0');
                                res <= export_slice(slice + offset);
                            when 1 =>
                                import_slices(slice_hi, slice_li, data, slice, offset);
                            when 2 =>

                                slice <= slice + 1;
                        end case;
                    elsif slice = 15 then

                    else

                    end if;
                end if;
                if mode /= x"0" then
                     <= stage + 1;
                end if;
            end if;
        end if;
    end process;

end architecture;
