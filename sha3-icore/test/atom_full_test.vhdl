library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;
use work.sha3_atom;

entity atom_full_test is
end entity;

architecture arch of atom_full_test is

    component sha3_atom is
        port(
            clk : in std_logic;
            rst : in std_logic;
            enable : in std_logic;
            write_data : in std_logic;
            read_data : in std_logic;
            atom_index : in atom_index_t;
            data_in : in lane_t;
    
            data_out : out lane_t;
            ready : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal finished : boolean := false;
    
    signal rst : std_logic := '0';
    signal enable : std_logic := '0';
    signal read : std_logic := '0';
    signal write : std_logic := '0';
    signal atom0_in, atom0_out, atom1_in, atom1_out, global_data_in, global_data_out : lane_t;
    signal atom0_ready, atom1_ready : std_logic;
    signal hash : std_logic_vector(255 downto 0) := (others => '0');

begin

    atom0_in <= global_data_in OR atom1_out;
    atom1_in <= global_data_in OR atom0_out;
    global_data_out <= atom0_out OR atom1_out;

    clock : process is
    begin
        while not finished loop
            clk <= not clk;
            wait for 5 ns;
        end loop;
        wait;
    end process;

    atom0 : sha3_atom port map(clk, rst, enable, write, read, 0, atom0_in, atom0_out, atom0_ready);
    atom1 : sha3_atom port map(clk, rst, enable, write, read, 1, atom1_in, atom1_out, atom1_ready);

    test : process is

    begin
        wait for 2ns;
        rst <= '1';
        wait for 2ns;
        rst <= '0';
        global_data_in <= (others => '0');
        global_data_in(1) <= '1';
        global_data_in(2) <= '1';
        wait until rising_edge(clk);
        enable <= '1';
        wait until rising_edge(clk);
        global_data_in <= (others => '0');
        for i in 1 to 15 loop
            wait until rising_edge(clk);
        end loop;
        global_data_in(63) <= '1';
        wait until rising_edge(clk);
        global_data_in <= (others => '0');
        while atom0_ready = '0' loop
            wait until rising_edge(clk);
        end loop;
        enable <= '0';
        wait until rising_edge(clk);
        enable <= '1';
        write <= '1';
        wait until rising_edge(clk);
        write <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        for i in 0 to 3 loop
            hash(64 * i + 63 downto 64 * i) <= global_data_out;
            wait until rising_edge(clk);
        end loop;
        enable <= '0';
        wait until rising_edge(clk);
        finished <= true;
        wait;
    end process;

end architecture;