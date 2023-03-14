library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.state.all;

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

	signal port_a_out_temp, port_b_out_temp : std_logic_vector(25 downto 0);

	signal port_a_in_slice_0 : tile_slice_t;
	signal port_a_in_slice_1 : tile_slice_t;
	signal port_a_out_slice_0 : tile_slice_t;
	signal port_a_out_slice_1 : tile_slice_t;
	signal port_b_in_slice_0 : tile_slice_t;
	signal port_b_in_slice_1 : tile_slice_t;
	signal port_b_out_slice_0 : tile_slice_t;
	signal port_b_out_slice_1 : tile_slice_t;

begin
	
	BRAM_PORTA_0_dout <= port_a_out_temp;
	BRAM_PORTB_0_dout <= port_b_out_temp;

	port_a_in_slice_0 <= BRAM_PORTA_0_din(12 downto 0);
	port_a_in_slice_1 <= BRAM_PORTA_0_din(25 downto 13);
	port_a_out_slice_0 <= port_a_out_temp(12 downto 0);
	port_a_out_slice_1 <= port_a_out_temp(25 downto 13);
	port_b_in_slice_0 <= BRAM_PORTB_0_din(12 downto 0);
	port_b_in_slice_1 <= BRAM_PORTB_0_din(25 downto 13);
	port_b_out_slice_0 <= port_b_out_temp(12 downto 0);
	port_b_out_slice_1 <= port_b_out_temp(25 downto 13);

	process(clk) is
	begin
		if rising_edge(clk) then
			if BRAM_PORTA_0_en = '1' then
				port_a_out_temp <= mem(to_integer(unsigned(BRAM_PORTA_0_addr)));
			end if;
			if BRAM_PORTB_0_en = '1' then
				port_b_out_temp <= mem(to_integer(unsigned(BRAM_PORTB_0_addr)));
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