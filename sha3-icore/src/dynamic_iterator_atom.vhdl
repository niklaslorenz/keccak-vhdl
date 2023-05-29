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

    -- for edge detection on control signals to handle different lengths of control steps
    signal init_buf : std_logic;
    signal reset_buf : std_logic;
    signal step_buf : std_logic;
    
    -- internal state and outputs
    signal target : natural;
    signal iterator : natural;

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
    process(clk) is
    begin
        if rising_edge(clk) then
            if init = '1' and init_buf = '0' then
                iterator <= 0;
                target <= target_in;
            elsif reset = '1' and reset_buf = '0' then
                iterator <= 0;
            elsif step = '1' and step_buf = '0' and iterator < target then
                iterator <= iterator + 1;
            end if;
            init_buf <= init;
            reset_buf <= reset;
            step_buf <= step;
        end if;
    end process;

end architecture;