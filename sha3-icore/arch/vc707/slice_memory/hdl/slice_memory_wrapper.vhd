--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
--Date        : Tue Feb 14 13:28:37 2023
--Host        : i80pc129 running 64-bit Ubuntu 14.04.6 LTS
--Command     : generate_target slice_memory_wrapper.bd
--Design      : slice_memory_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
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

architecture STRUCTURE of slice_memory_wrapper is
  component slice_memory is
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
  end component slice_memory;
begin
slice_memory_i: component slice_memory
     port map (
      BRAM_PORTA_0_addr(6 downto 0) => BRAM_PORTA_0_addr(6 downto 0),
      BRAM_PORTA_0_din(25 downto 0) => BRAM_PORTA_0_din(25 downto 0),
      BRAM_PORTA_0_dout(25 downto 0) => BRAM_PORTA_0_dout(25 downto 0),
      BRAM_PORTA_0_en => BRAM_PORTA_0_en,
      BRAM_PORTA_0_we(0) => BRAM_PORTA_0_we(0),
      BRAM_PORTB_0_addr(6 downto 0) => BRAM_PORTB_0_addr(6 downto 0),
      BRAM_PORTB_0_din(25 downto 0) => BRAM_PORTB_0_din(25 downto 0),
      BRAM_PORTB_0_dout(25 downto 0) => BRAM_PORTB_0_dout(25 downto 0),
      BRAM_PORTB_0_en => BRAM_PORTB_0_en,
      BRAM_PORTB_0_we(0) => BRAM_PORTB_0_we(0),
      clk => clk
    );
end STRUCTURE;
