library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.state.all;
use work.slice_memory_wrapper;

entity memory_block is
    port(
        clk : in std_logic;
        port_a_in : in mem_port_input;
        port_a_out : out mem_port_output;
        port_b_in : in mem_port_input;
        port_b_out : out mem_port_output
    );
end entity;

architecture arch of memory_block is
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

    signal a_addr : std_logic_vector ( 6 downto 0 );
    signal a_din : std_logic_vector ( 25 downto 0 );
    signal a_dout : std_logic_vector ( 25 downto 0 );
    signal a_en : std_logic;
    signal a_we : std_logic_vector(0 to 0);

    signal b_addr : std_logic_vector ( 6 downto 0 );
    signal b_din : std_logic_vector ( 25 downto 0 );
    signal b_dout : std_logic_vector ( 25 downto 0 );
    signal b_en : std_logic;
    signal b_we : std_logic_vector(0 to 0);

begin

    mem : slice_memory_wrapper port map(a_addr, a_din, a_dout, a_en, a_we, b_addr, b_din, b_dout, b_en, b_we, clk);

    a_addr <= std_logic_vector(to_unsigned(port_a_in.addr, 7));
    a_din <= port_a_in.data(1) & port_a_in.data(0);
    a_en <= port_a_in.en;
    a_we(0) <= port_a_in.we;
    port_a_out.data(0) <= a_dout(12 downto 0);
    port_a_out.data(1) <= a_dout(25 downto 13);

    b_addr <= std_logic_vector(to_unsigned(port_b_in.addr, 7));
    b_din <= port_b_in.data(1) & port_b_in.data(0);
    b_en <= port_b_in.en;
    b_we(0) <= port_b_in.we;
    port_b_out.data(0) <= b_dout(12 downto 0);
    port_b_out.data(1) <= b_dout(25 downto 13);

end architecture arch;