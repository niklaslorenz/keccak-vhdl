--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
--Date        : Tue Jan 31 19:37:58 2023
--Host        : i80pc129 running 64-bit Ubuntu 14.04.6 LTS
--Command     : generate_target state_array_wrapper.bd
--Design      : state_array_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity state_array_wrapper is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 4 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 63 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 63 downto 0 );
    BRAM_PORTA_0_en : in STD_LOGIC;
    BRAM_PORTA_0_rst : in STD_LOGIC;
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 );
    BRAM_PORTB_0_addr : in STD_LOGIC_VECTOR ( 4 downto 0 );
    BRAM_PORTB_0_clk : in STD_LOGIC;
    BRAM_PORTB_0_din : in STD_LOGIC_VECTOR ( 63 downto 0 );
    BRAM_PORTB_0_dout : out STD_LOGIC_VECTOR ( 63 downto 0 );
    BRAM_PORTB_0_en : in STD_LOGIC;
    BRAM_PORTB_0_rst : in STD_LOGIC;
    BRAM_PORTB_0_we : in STD_LOGIC_VECTOR ( 0 to 0 );
    rsta_busy_0 : out STD_LOGIC;
    rstb_busy_0 : out STD_LOGIC
  );
end state_array_wrapper;

architecture STRUCTURE of state_array_wrapper is
  component state_array is
  port (
    rsta_busy_0 : out STD_LOGIC;
    rstb_busy_0 : out STD_LOGIC;
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 4 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 63 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 63 downto 0 );
    BRAM_PORTA_0_en : in STD_LOGIC;
    BRAM_PORTA_0_rst : in STD_LOGIC;
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 );
    BRAM_PORTB_0_addr : in STD_LOGIC_VECTOR ( 4 downto 0 );
    BRAM_PORTB_0_clk : in STD_LOGIC;
    BRAM_PORTB_0_din : in STD_LOGIC_VECTOR ( 63 downto 0 );
    BRAM_PORTB_0_dout : out STD_LOGIC_VECTOR ( 63 downto 0 );
    BRAM_PORTB_0_en : in STD_LOGIC;
    BRAM_PORTB_0_rst : in STD_LOGIC;
    BRAM_PORTB_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component state_array;
begin
state_array_i: component state_array
     port map (
      BRAM_PORTA_0_addr(4 downto 0) => BRAM_PORTA_0_addr(4 downto 0),
      BRAM_PORTA_0_clk => BRAM_PORTA_0_clk,
      BRAM_PORTA_0_din(63 downto 0) => BRAM_PORTA_0_din(63 downto 0),
      BRAM_PORTA_0_dout(63 downto 0) => BRAM_PORTA_0_dout(63 downto 0),
      BRAM_PORTA_0_en => BRAM_PORTA_0_en,
      BRAM_PORTA_0_rst => BRAM_PORTA_0_rst,
      BRAM_PORTA_0_we(0) => BRAM_PORTA_0_we(0),
      BRAM_PORTB_0_addr(4 downto 0) => BRAM_PORTB_0_addr(4 downto 0),
      BRAM_PORTB_0_clk => BRAM_PORTB_0_clk,
      BRAM_PORTB_0_din(63 downto 0) => BRAM_PORTB_0_din(63 downto 0),
      BRAM_PORTB_0_dout(63 downto 0) => BRAM_PORTB_0_dout(63 downto 0),
      BRAM_PORTB_0_en => BRAM_PORTB_0_en,
      BRAM_PORTB_0_rst => BRAM_PORTB_0_rst,
      BRAM_PORTB_0_we(0) => BRAM_PORTB_0_we(0),
      rsta_busy_0 => rsta_busy_0,
      rstb_busy_0 => rstb_busy_0
    );
end STRUCTURE;
