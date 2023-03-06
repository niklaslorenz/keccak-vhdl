library IEEE;
use IEEE.std_logic_1164.all;

entity slice_memory_test is
end entity;

architecture arch of slice_memory_test is

    component slice_memory_wrapper is
        port (
            BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 6 downto 0 );
            BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 25 downto 0 );
            BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 25 downto 0 );
            BRAM_PORTA_0_en : in STD_LOGIC;
            BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 );
            BRAM_PORTB_0_addr : in STD_LOGIC_VECTOR ( 6 downto 0 );
            BRAM_PORTB_0_din : in STD_LOGIC_VECTOR ( 25 downto 0 );
            BRAM_PORTB_0_dout : out STD_LOGIC_VECTOR ( 25 downto 0 );
            BRAM_PORTB_0_en : in STD_LOGIC;
            BRAM_PORTB_0_we : in STD_LOGIC_VECTOR ( 0 to 0 );
            clk : in STD_LOGIC
        );
    end component;

    signal clk : std_logic := '0';
    signal finished : boolean := false;

    signal porta_addr, portb_addr : std_logic_vector(6 downto 0);
    signal porta_din, porta_dout, portb_din, portb_dout : std_logic_vector(25 downto 0);
    signal porta_en, porta_we, portb_en, portb_we : std_logic;
    signal porta_we_v, portb_we_v : std_logic_vector(0 downto 0);
begin

    porta_we_v(0) <= porta_we;
    portb_we_v(0) <= portb_we;

    mem : slice_memory_wrapper port map(porta_addr, porta_din, porta_dout, porta_en, porta_we_v, portb_addr, portb_din, portb_dout, portb_en, portb_we_v, clk);

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5ns;
        end loop;
        wait;
    end process;

    test : process is
    begin

        wait until rising_edge(clk);

        porta_we <= '1';
        portb_we <= '1';
        porta_addr <= "0000001";
        portb_addr <= "0010001";
        porta_din <= x"000000" & "00";
        portb_din <= x"FFFFFF" & "11";
        porta_en <= '1';
        portb_en <= '1';

        wait until rising_edge(clk);

        porta_we <= '0';
        portb_din <= x"0000FF" & "11";

        wait until rising_edge(clk);

        portb_we <= '0';

        wait until rising_edge(clk);

        porta_addr <= "0010001";
        portb_addr <= "0000001";

        wait until rising_edge(clk);
        wait until rising_edge(clk);

        finished <= true;
        wait;
    end process;

end architecture;