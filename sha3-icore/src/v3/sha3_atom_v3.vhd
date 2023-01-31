
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.state_array_wrapper;

entity sha3_atom_v3 is
Port (
    clk : in std_logic;
    rst : in std_logic
);
end sha3_atom_v3;

architecture Behavioral of sha3_atom_v3 is
    
    component state_array_wrapper is
    port (
        BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 31 downto 0 );
        BRAM_PORTA_0_clk : in STD_LOGIC;
        BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 31 downto 0 );
        BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
        BRAM_PORTA_0_en : in STD_LOGIC;
        BRAM_PORTA_0_rst : in STD_LOGIC;
        BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 3 downto 0 );
        BRAM_PORTB_0_addr : in STD_LOGIC_VECTOR ( 31 downto 0 );
        BRAM_PORTB_0_clk : in STD_LOGIC;
        BRAM_PORTB_0_din : in STD_LOGIC_VECTOR ( 31 downto 0 );
        BRAM_PORTB_0_dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
        BRAM_PORTB_0_en : in STD_LOGIC;
        BRAM_PORTB_0_rst : in STD_LOGIC;
        BRAM_PORTB_0_we : in STD_LOGIC_VECTOR ( 3 downto 0 )
    );
    end component;
    
begin

    memory : state_array_wrapper port map();

end Behavioral;
