
entity theta_controller is
port(
    rst : in std_logic;
    clk : in std_logic;
    enabled : in std_logic;
    init : in std_logic;

    transfer_state : out std_logic;
    transfer_state_slice : out natural range 0 to 15;
    valid : out std_logic;
    done : out std_logic
);
end entity;

architecture arch of theta_controller is
    signal step : natural;
    signal vld : std_logic;
begin

    process(rst, clk) is
    begin
        if rst = '1' then
            step <= 0;
        elsif rising_edge(clk) then
            if init = '1' then
                step <= 0;
            elsif enabled = '1' and not done = '1' then
                step <= step + 1;
            end if;

            if not init = '1' and enabled = '1' and not done = '1' then
                vld <= '1';
            else
                vld <= '0';
            end if;

        end if;
    end process;

    transfer_state <= step <= 15;
    transfer_state_slice <= step;
    save_result <= step >= 1 and step <= 16;
    done <= step >= 16;
    valid <= vld;

end architecture arch;
