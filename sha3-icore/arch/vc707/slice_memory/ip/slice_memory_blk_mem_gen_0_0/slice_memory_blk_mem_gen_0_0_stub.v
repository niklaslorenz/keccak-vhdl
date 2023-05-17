// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
// Date        : Wed May 17 12:43:42 2023
// Host        : i80pc129 running 64-bit Ubuntu 14.04.6 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/lornik00/Dokumente/keccak/sha3-icore/arch/vc707/slice_memory/ip/slice_memory_blk_mem_gen_0_0/slice_memory_blk_mem_gen_0_0_stub.v
// Design      : slice_memory_blk_mem_gen_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx485tffg1761-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_3,Vivado 2019.1" *)
module slice_memory_blk_mem_gen_0_0(clka, ena, wea, addra, dina, douta, clkb, enb, web, addrb, 
  dinb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[6:0],dina[25:0],douta[25:0],clkb,enb,web[0:0],addrb[6:0],dinb[25:0],doutb[25:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [6:0]addra;
  input [25:0]dina;
  output [25:0]douta;
  input clkb;
  input enb;
  input [0:0]web;
  input [6:0]addrb;
  input [25:0]dinb;
  output [25:0]doutb;
endmodule
