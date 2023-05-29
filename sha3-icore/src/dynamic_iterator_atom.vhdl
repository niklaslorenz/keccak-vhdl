library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Atom;

architecture dynamic_iterator_atom of Atom is

    -- inputs
    signal init : std_logic;
    signal step : std_logic;
    signal reset : std_logic;
    signal target_in : natural;

    -- outputs
    signal jump : std_logic;
    signal target : natural;
    signal iterator : natural;

    -- dynamic control step length adaption
    signal step_clk : std_logic; -- modified clock signal
    signal control_step_iterator : natural;
    signal control_step_length : natural;
    signal init_buf : std_logic; -- for edge detection

begin

    -- interface
    init <= control(0);
    reset <= control(1);
    step <= control(2);
    target_in <= to_integer(unsigned(input0(30 downto 0))); -- lower 31 bits interpreted as unsigned, msb is ignored
    
    for i in 0 to 7 generate
        status(i) <= jump;
    end generate;
    output0 <= std_logic_vector(to_unsigned(iterator, 32));
    output1 <= std_logic_vector(to_unsigned(target, 32));
    
    -- logic
    jump <= '1' when (iterator < target) else '0';

    process(step_clk) is
    begin
        if rising_edge(step_clk) then
            if reset = '1' then
                iterator <= '0';
            elsif step = '1' and iterator < target then
                iterator <= iterator + 1;
            end if;
        end if;
    end process;

    process(clk) is
    begin
        if falling_edge(clk) then
            step_clk <= '0';
        end if;
        if rising_edge(clk) then
            if init = '1' then
                if init_buf = '0' then -- first init clock cycle
                    control_step_length <= 0;
                    control_step_iterator <= 0;
                    target <= target_in;
                    iterator <= 0;
                else -- consecutive init clock cycles
                    control_step_length <= control_step_length + 1;
                end if;
                step_clk <= '0';
            else
                if control_step_iterator >= control_step_length then
                    step_clk <= '1';
                    control_step_iterator <= 0;
                else
                    control_step_iterator <= control_step_iterator + 1;
                end if;
            end if;
            init_buf <= init;
        end if;
    end process;

end architecture;