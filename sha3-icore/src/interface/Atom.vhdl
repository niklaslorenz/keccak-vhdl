library IEEE;
use IEEE.std_logic_1164.all;

entity Atom is
    port(
        control  : in  std_logic_vector(8 downto 0);
        status   : out std_logic_vector(7 downto 0); -- 8 Bit Integer Wert, welcher angibt welches Atom im Container ist
        clk      : in  std_logic;
        input0   : in  std_logic_vector(31 downto 0);
        input1   : in  std_logic_vector(31 downto 0);
        output0  : out std_logic_vector(31 downto 0);
        output1  : out std_logic_vector(31 downto 0);
        cond_out : out std_logic_vector(1 downto 0) := "--";
        cond_in  : in  std_logic_vector(1 downto 0);
        jmp_ctrl : out std_logic_vector(1 downto 0) := "00";
        exc_ctrl : out std_logic_vector(1 downto 0) := "00";
        si_stall : out std_logic := '1' -- '0' = wait
    );

    attribute mult_style : string;
    attribute mult_style of Atom : entity is "lut";
end Atom;