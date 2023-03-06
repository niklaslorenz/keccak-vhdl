library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity slice_memory_wrapper is
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
end slice_memory_wrapper;

architecture arch of slice_memory_wrapper is

	type mem_t is array(natural range 0 to 127) of std_logic_vector(25 downto 0);
	signal mem : mem_t;

begin
	
	process(clk) is
	begin
		if rising_edge(clk) then
			if BRAM_PORTA_0_en = '1' then
				BRAM_PORTA_0_dout <= mem(to_integer(unsigned(BRAM_PORTA_0_addr)));
			end if;
			if BRAM_PORTB_0_en = '1' then
				BRAM_PORTB_0_dout <= mem(to_integer(unsigned(BRAM_PORTB_0_addr)));
			end if;
			if BRAM_PORTA_0_we(0) = '1' then
				mem(to_integer(unsigned(BRAM_PORTA_0_addr))) <= BRAM_PORTA_0_din;
			end if;
			if BRAM_PORTB_0_we(0) = '1' then
				mem(to_integer(unsigned(BRAM_PORTB_0_addr))) <= BRAM_PORTB_0_din;
			end if;
		end if;
	end process;

end architecture;