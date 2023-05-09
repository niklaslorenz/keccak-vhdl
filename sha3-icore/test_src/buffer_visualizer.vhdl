library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.types.all;
use work.test_types.all;

entity buffer_visualizer is
    port(
        buf : in buffer_t
    );
end entity;

architecture arch of buffer_visualizer is
    
    signal slice0  : std_logic_vector(6 downto 0);
    signal slice1  : std_logic_vector(6 downto 0);
    signal slice2  : std_logic_vector(6 downto 0);
    signal slice3  : std_logic_vector(6 downto 0);
    signal slice4  : std_logic_vector(6 downto 0);
    signal slice5  : std_logic_vector(6 downto 0);
    signal slice6  : std_logic_vector(6 downto 0);
    signal slice7  : std_logic_vector(6 downto 0);
    signal slice8  : std_logic_vector(6 downto 0);
    signal slice9  : std_logic_vector(6 downto 0);
    signal slice10  : std_logic_vector(6 downto 0);
    signal slice11  : std_logic_vector(6 downto 0);
    signal slice12  : std_logic_vector(6 downto 0);
    signal slice13  : std_logic_vector(6 downto 0);
    signal slice14  : std_logic_vector(6 downto 0);
    signal slice15  : std_logic_vector(6 downto 0);
    signal slice16  : std_logic_vector(6 downto 0);
    signal slice17  : std_logic_vector(6 downto 0);
    signal slice18  : std_logic_vector(6 downto 0);
    signal slice19  : std_logic_vector(6 downto 0);
    signal slice20  : std_logic_vector(6 downto 0);
    signal slice21  : std_logic_vector(6 downto 0);
    signal slice22  : std_logic_vector(6 downto 0);
    signal slice23  : std_logic_vector(6 downto 0);
    signal slice24  : std_logic_vector(6 downto 0);
    signal slice25  : std_logic_vector(6 downto 0);
    signal slice26  : std_logic_vector(6 downto 0);
    signal slice27  : std_logic_vector(6 downto 0);
    signal slice28  : std_logic_vector(6 downto 0);
    signal slice29  : std_logic_vector(6 downto 0);
    signal slice30  : std_logic_vector(6 downto 0);
    signal slice31  : std_logic_vector(6 downto 0);
    signal slice32  : std_logic_vector(6 downto 0);
    signal slice33  : std_logic_vector(6 downto 0);
    signal slice34  : std_logic_vector(6 downto 0);
    signal slice35  : std_logic_vector(6 downto 0);

begin

    slice0  <= buf( 0);
    slice1  <= buf( 1);
    slice2  <= buf( 2);
    slice3  <= buf( 3);
    slice4  <= buf( 4);
    slice5  <= buf( 5);
    slice6  <= buf( 6);
    slice7  <= buf( 7);
    slice8  <= buf( 8);
    slice9  <= buf( 9);
    slice10 <= buf(10);
    slice11 <= buf(11);
    slice12 <= buf(12);
    slice13 <= buf(13);
    slice14 <= buf(14);
    slice15 <= buf(15);
    slice16 <= buf(16);
    slice17 <= buf(17);
    slice18 <= buf(18);
    slice19 <= buf(19);
    slice20 <= buf(20);
    slice21 <= buf(21);
    slice22 <= buf(22);
    slice23 <= buf(23);
    slice24 <= buf(24);
    slice25 <= buf(25);
    slice26 <= buf(26);
    slice27 <= buf(27);
    slice28 <= buf(28);
    slice29 <= buf(29);
    slice30 <= buf(30);
    slice31 <= buf(31);
    slice32 <= buf(32);
    slice33 <= buf(33);
    slice34 <= buf(34);
    slice35 <= buf(35);

end architecture;