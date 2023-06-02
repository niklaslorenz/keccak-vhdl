library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.test_types.all;
use work.test_util.all;

entity sha3_atom_test is
end entity;

architecture arch of sha3_atom_test is

    component sha3_atom is
        port(
            clk : in std_logic;
            enable : in std_logic;
            init : in std_logic;
            atom_index_input : in atom_index_t;
            read : in std_logic;
            write : in std_logic;
            ready : out std_logic;
            transmission_in : in transmission_t;
            transmission_out : out transmission_t
        );
    end component;

    component block_visualizer is
        port(state : in block_t);
    end component;

    signal clk : std_logic := '0';
    signal finished : boolean := false;
    signal reading : boolean := false;

    constant text : string := "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam";
    constant hex_text : std_logic_vector(1087 downto 0) := x"4c6f72656d20697073756d20646f6c6f722073697420616d65742c20636f6e736574657475722073616469707363696e6720656c6974722c20736564206469616d206e6f6e756d79206569726d6f642074656d706f7220696e766964756e74207574206c61626f726520657420646f6c6f7265206d61676e6120616c69717579616d060000000080";
    constant full_text_block : full_lane_aligned_block_t := block_from_hex_text(hex_text);
    constant upper : block_t := upper_block(full_text_block);
    constant lower : block_t := lower_block(full_text_block);

    signal enable : std_logic := '0';
    signal init : std_logic := '0';
    signal read : std_logic := '0';
    signal write : std_logic := '0';
    signal ready0 : std_logic;
    signal ready1 : std_logic;
    signal transmission0_in : transmission_t;
    signal transmission0_out : transmission_t;
    signal transmission1_in : transmission_t;
    signal transmission1_out : transmission_t;
    signal data_transmission0 : transmission_t;
    signal data_transmission1 : transmission_t;
    signal transmission0_out_buf : transmission_t;
    signal transmission1_out_buf : transmission_t;

begin

    visual0 : block_visualizer port map(lower);

    visual1 : block_visualizer port map(upper);

    atom0 : sha3_atom port map(
        clk => clk,
        enable => enable,
        init => init,
        atom_index_input => 0,
        read => read,
        write => write,
        ready => ready0,
        transmission_in => transmission0_in,
        transmission_out => transmission0_out
    );

    atom1 : sha3_atom port map(
        clk => clk,
        enable => enable,
        init => init,
        atom_index_input => 1,
        read => read,
        write => '0',
        ready => ready1,
        transmission_in => transmission1_in,
        transmission_out => transmission1_out
    );

    transmission0_in <= data_transmission0 when reading else transmission1_out_buf;
    transmission1_in <= data_transmission1 when reading else transmission0_out_buf;

    environment : process(clk) is
    begin
        if rising_edge(clk) then
            transmission0_out_buf <= transmission0_out;
            transmission1_out_buf <= transmission1_out;
        end if;
    end process;

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
        wait until rising_edge(clk);
        enable <= '1';
        init <= '1';
        wait until rising_edge(clk);
        init <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        while ready0 /= '1' or ready1 /= '1' loop
            wait until rising_edge(clk);
        end loop;
        read <= '1';
        reading <= true;
        wait until rising_edge(clk);
        read <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        for i in 0 to 15 loop
            data_transmission0 <= "000" & lower(4 * i + 3) & "000" & lower(4 * i + 2) & "000" & lower(4 * i + 1) & "000" & lower(4 * i);
            data_transmission1 <= "000" & upper(4 * i + 3) & "000" & upper(4 * i + 2) & "000" & upper(4 * i + 1) & "000" & upper(4 * i);
            wait until rising_edge(clk);
            wait until rising_edge(clk);
        end loop;
        reading <= false;
        while ready0 /= '1' or ready1 /= '1' loop
            wait until rising_edge(clk);
        end loop;
        write <= '1';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        write <= '0';
        while ready0 /= '1' loop
            wait until rising_edge(clk);
        end loop;
        wait until rising_edge(clk);

        finished <= true;
        wait;
    end process;

end architecture arch;