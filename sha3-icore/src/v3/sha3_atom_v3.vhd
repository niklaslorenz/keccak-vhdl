
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.sha3_atom;
use work.state_array_wrapper;

architecture arch_v3 of sha3_atom is

    component state_array_wrapper is
    port (
        BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 4 downto 0 );
        BRAM_PORTA_0_clk : in STD_LOGIC;
        BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 63 downto 0 );
        BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 63 downto 0 );
        BRAM_PORTA_0_en : in STD_LOGIC;
        BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 );
        BRAM_PORTB_0_addr : in STD_LOGIC_VECTOR ( 4 downto 0 );
        BRAM_PORTB_0_clk : in STD_LOGIC;
        BRAM_PORTB_0_din : in STD_LOGIC_VECTOR ( 63 downto 0 );
        BRAM_PORTB_0_dout : out STD_LOGIC_VECTOR ( 63 downto 0 );
        BRAM_PORTB_0_en : in STD_LOGIC;
        BRAM_PORTB_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
    );
    end component;
    
begin

    

end architecture;
