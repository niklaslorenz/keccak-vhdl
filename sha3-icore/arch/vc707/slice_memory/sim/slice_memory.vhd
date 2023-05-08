--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
--Date        : Tue Feb 14 13:28:37 2023
--Host        : i80pc129 running 64-bit Ubuntu 14.04.6 LTS
--Command     : generate_target slice_memory.bd
--Design      : slice_memory
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity slice_memory is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 6 downto 0 );
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 49 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 49 downto 0 );
    BRAM_PORTA_0_en : in STD_LOGIC;
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 );
    BRAM_PORTB_0_addr : in STD_LOGIC_VECTOR ( 6 downto 0 );
    BRAM_PORTB_0_din : in STD_LOGIC_VECTOR ( 49 downto 0 );
    BRAM_PORTB_0_dout : out STD_LOGIC_VECTOR ( 49 downto 0 );
    BRAM_PORTB_0_en : in STD_LOGIC;
    BRAM_PORTB_0_we : in STD_LOGIC_VECTOR ( 0 to 0 );
    clk : in STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of slice_memory : entity is "slice_memory,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=slice_memory,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of slice_memory : entity is "slice_memory.hwdef";
end slice_memory;

architecture STRUCTURE of slice_memory is
  component slice_memory_blk_mem_gen_0_0 is
  port (
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 6 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 49 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 49 downto 0 );
    clkb : in STD_LOGIC;
    enb : in STD_LOGIC;
    web : in STD_LOGIC_VECTOR ( 0 to 0 );
    addrb : in STD_LOGIC_VECTOR ( 6 downto 0 );
    dinb : in STD_LOGIC_VECTOR ( 49 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 49 downto 0 )
  );
  end component slice_memory_blk_mem_gen_0_0;
  signal BRAM_PORTA_0_1_ADDR : STD_LOGIC_VECTOR ( 6 downto 0 );
  signal BRAM_PORTA_0_1_DIN : STD_LOGIC_VECTOR ( 49 downto 0 );
  signal BRAM_PORTA_0_1_DOUT : STD_LOGIC_VECTOR ( 49 downto 0 );
  signal BRAM_PORTA_0_1_EN : STD_LOGIC;
  signal BRAM_PORTA_0_1_WE : STD_LOGIC_VECTOR ( 0 to 0 );
  signal BRAM_PORTB_0_1_ADDR : STD_LOGIC_VECTOR ( 6 downto 0 );
  signal BRAM_PORTB_0_1_DIN : STD_LOGIC_VECTOR ( 49 downto 0 );
  signal BRAM_PORTB_0_1_DOUT : STD_LOGIC_VECTOR ( 49 downto 0 );
  signal BRAM_PORTB_0_1_EN : STD_LOGIC;
  signal BRAM_PORTB_0_1_WE : STD_LOGIC_VECTOR ( 0 to 0 );
  signal clk_1 : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of BRAM_PORTA_0_en : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTA_0 EN";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_en : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 EN";
  attribute X_INTERFACE_INFO of BRAM_PORTA_0_addr : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTA_0 ADDR";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of BRAM_PORTA_0_addr : signal is "XIL_INTERFACENAME BRAM_PORTA_0, MASTER_TYPE OTHER, MEM_ECC NONE, MEM_SIZE 8192, MEM_WIDTH 32, READ_LATENCY 1";
  attribute X_INTERFACE_INFO of BRAM_PORTA_0_din : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTA_0 DIN";
  attribute X_INTERFACE_INFO of BRAM_PORTA_0_dout : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTA_0 DOUT";
  attribute X_INTERFACE_INFO of BRAM_PORTA_0_we : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTA_0 WE";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_addr : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 ADDR";
  attribute X_INTERFACE_PARAMETER of BRAM_PORTB_0_addr : signal is "XIL_INTERFACENAME BRAM_PORTB_0, MASTER_TYPE OTHER, MEM_ECC NONE, MEM_SIZE 8192, MEM_WIDTH 32, READ_LATENCY 1";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_din : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 DIN";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_dout : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 DOUT";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_we : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 WE";
begin
  BRAM_PORTA_0_1_ADDR(6 downto 0) <= BRAM_PORTA_0_addr(6 downto 0);
  BRAM_PORTA_0_1_DIN(49 downto 0) <= BRAM_PORTA_0_din(49 downto 0);
  BRAM_PORTA_0_1_EN <= BRAM_PORTA_0_en;
  BRAM_PORTA_0_1_WE(0) <= BRAM_PORTA_0_we(0);
  BRAM_PORTA_0_dout(49 downto 0) <= BRAM_PORTA_0_1_DOUT(49 downto 0);
  BRAM_PORTB_0_1_ADDR(6 downto 0) <= BRAM_PORTB_0_addr(6 downto 0);
  BRAM_PORTB_0_1_DIN(49 downto 0) <= BRAM_PORTB_0_din(49 downto 0);
  BRAM_PORTB_0_1_EN <= BRAM_PORTB_0_en;
  BRAM_PORTB_0_1_WE(0) <= BRAM_PORTB_0_we(0);
  BRAM_PORTB_0_dout(49 downto 0) <= BRAM_PORTB_0_1_DOUT(49 downto 0);
  clk_1 <= clk;
blk_mem_gen_0: component slice_memory_blk_mem_gen_0_0
     port map (
      addra(6 downto 0) => BRAM_PORTA_0_1_ADDR(6 downto 0),
      addrb(6 downto 0) => BRAM_PORTB_0_1_ADDR(6 downto 0),
      clka => clk_1,
      clkb => clk_1,
      dina(49 downto 0) => BRAM_PORTA_0_1_DIN(49 downto 0),
      dinb(49 downto 0) => BRAM_PORTB_0_1_DIN(49 downto 0),
      douta(49 downto 0) => BRAM_PORTA_0_1_DOUT(49 downto 0),
      doutb(49 downto 0) => BRAM_PORTB_0_1_DOUT(49 downto 0),
      ena => BRAM_PORTA_0_1_EN,
      enb => BRAM_PORTB_0_1_EN,
      wea(0) => BRAM_PORTA_0_1_WE(0),
      web(0) => BRAM_PORTB_0_1_WE(0)
    );
end STRUCTURE;
