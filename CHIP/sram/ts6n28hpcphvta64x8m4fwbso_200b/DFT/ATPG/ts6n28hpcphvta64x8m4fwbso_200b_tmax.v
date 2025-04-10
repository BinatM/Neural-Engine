//****************************************************************************** */
//*                                                                              */
//*STATEMENT OF USE                                                              */
//*                                                                              */
//*This information contains confidential and proprietary information of TSMC.   */
//*No part of this information may be reproduced, transmitted, transcribed,      */
//*stored in a retrieval system, or translated into any human or computer        */
//*language, in any form or by any means, electronic, mechanical, magnetic,      */
//*optical, chemical, manual, or otherwise, without the prior written permission */
//*of TSMC. This information was prepared for informational purpose and is for   */
//*use by TSMC's customers only. TSMC reserves the right to make changes in the  */
//*information at any time and without notice.                                   */
//*                                                                              */
//* Template Version : S_05_52902                                               */
//****************************************************************************** */
//****************************************************************************** */
//*        Software         : TSMC MEMORY COMPILER tsn28hpm2prf_2012.02.00.d.200b */
//*        Technology       : TSMC 28nm CMOS LOGIC High Performance Compact Mobile Computing Plus 1P10M HKMG CU_ELK 0.9V */
//*        Memory Type      : TSMC 28nm High Performance Compact Mobile Computing Plus Two Port Register File */
//*                         : with d240 bit cell HVT periphery */
//*        Library Name     : ts6n28hpcphvta64x8m4fwbso (user specify : TS6N28HPCPHVTA64X8M4FWBSO) */
//*        Library Version  : 200b */
//*        Generated Time   : 2025/04/08, 10:16:27 */
//*************************************************************************** ** */
`timescale 1ns/1ps
`define read_write readx

module TS6N28HPCPHVTA64X8M4FWBSO (
                        AA,
			D, 
			BWEB,
			WEB, CLKW,
			AB,
			REB, CLKR,
                        AMA,
  			DM,
  			BWEBM,
  			WEBM,
  			AMB,
  			REBM,BIST,
                        SLP,
                        SD,
                        Q
			);
		

parameter  N = 8;
parameter  W = 64;
parameter  M = 6;

// Input-Output declarations
   input [M-1:0] AA;                // Address write bus
   input [N-1:0] D;                 // Date input bus
   input [N-1:0] BWEB;              // BW data input bus
   input         WEB;               // Active-low Write enable
   input         CLKW;              // Clock A
   input [M-1:0] AB;                // Address write bus 
   input         REB;               // Active-low Read enable
   input         CLKR;              // Clock B
   input [M-1:0] AMA;               // Address write bus 
   input [N-1:0] DM;                // Date input bus  
   input [N-1:0] BWEBM;             // BW data input bus
   input         WEBM;              // Active-low Read enable
   input [M-1:0] AMB;               // Address write bus 
   input         REBM;              // Active-low Read enable 
   input         BIST;
   input SLP;
   input SD;
   output [N-1:0] Q;                 // Data output bus

// Test Mode


//=== Data Structure ===//

wire [N-1:0] Q;
wire [M-1:0] iAA = BIST ? AMA : AA;
wire [M-1:0] iAB = BIST ? AMB : AB;
wire [N-1:0] iBWEB = BIST ? BWEBM : BWEB;
wire iWEB = BIST ? WEBM : WEB;
wire iREB = BIST ? REBM : REB;
wire [N-1:0] iD = BIST ? DM : D;

wire pd_mode = SD | SLP;

wire [N-1:0] Q_bistx;
wire [N-1:0] Q_ram;
wire [N-1:0] Q_tmp;

//=== Operation ===//

//  SRAM instantiation
TS6N28HPCPHVTA64X8M4FWBSO_RAM_1bit sram_IO0 (iAA, CLKW, iWEB, iBWEB[0], iAB, CLKR, iREB, iD[0], Q_ram[0]);
TS6N28HPCPHVTA64X8M4FWBSO_RAM_1bit sram_IO1 (iAA, CLKW, iWEB, iBWEB[1], iAB, CLKR, iREB, iD[1], Q_ram[1]);
TS6N28HPCPHVTA64X8M4FWBSO_RAM_1bit sram_IO2 (iAA, CLKW, iWEB, iBWEB[2], iAB, CLKR, iREB, iD[2], Q_ram[2]);
TS6N28HPCPHVTA64X8M4FWBSO_RAM_1bit sram_IO3 (iAA, CLKW, iWEB, iBWEB[3], iAB, CLKR, iREB, iD[3], Q_ram[3]);
TS6N28HPCPHVTA64X8M4FWBSO_RAM_1bit sram_IO4 (iAA, CLKW, iWEB, iBWEB[4], iAB, CLKR, iREB, iD[4], Q_ram[4]);
TS6N28HPCPHVTA64X8M4FWBSO_RAM_1bit sram_IO5 (iAA, CLKW, iWEB, iBWEB[5], iAB, CLKR, iREB, iD[5], Q_ram[5]);
TS6N28HPCPHVTA64X8M4FWBSO_RAM_1bit sram_IO6 (iAA, CLKW, iWEB, iBWEB[6], iAB, CLKR, iREB, iD[6], Q_ram[6]);
TS6N28HPCPHVTA64X8M4FWBSO_RAM_1bit sram_IO7 (iAA, CLKW, iWEB, iBWEB[7], iAB, CLKR, iREB, iD[7], Q_ram[7]);



//  Q bypass
assign Q_tmp = Q_ram;
//  BIST x handling
assign Q_bistx[0] = (BIST === 1'bx) ? 1'bx : Q_tmp[0];
assign Q_bistx[1] = (BIST === 1'bx) ? 1'bx : Q_tmp[1];
assign Q_bistx[2] = (BIST === 1'bx) ? 1'bx : Q_tmp[2];
assign Q_bistx[3] = (BIST === 1'bx) ? 1'bx : Q_tmp[3];
assign Q_bistx[4] = (BIST === 1'bx) ? 1'bx : Q_tmp[4];
assign Q_bistx[5] = (BIST === 1'bx) ? 1'bx : Q_tmp[5];
assign Q_bistx[6] = (BIST === 1'bx) ? 1'bx : Q_tmp[6];
assign Q_bistx[7] = (BIST === 1'bx) ? 1'bx : Q_tmp[7];
//  Output Q
assign Q = pd_mode ? {N{1'b0}} : Q_bistx;

endmodule

// 1 bit SRAM 
module TS6N28HPCPHVTA64X8M4FWBSO_RAM_1bit (AA_i, CLKW_i, WEB_i, BWEB_i, AB_i, CLKR_i, REB_i, D_i, Q_i);


parameter  N = 8;
parameter  W = 64;
parameter  M = 6;

input CLKW_i, CLKR_i;
input WEB_i, REB_i;
input [0:0] BWEB_i;
input [M-1:0] AA_i, AB_i;
input [0:0] D_i;

output [0:0] Q_i;

reg [0:0]Q_i;
reg [0:0] MEMORY [W-1:0];


event WRITE_OP;

// Write Mode
and u_aw1_0 (WB, !WEB_i, !BWEB_i);

always @ (posedge CLKW_i)
  if (WB) begin
    MEMORY[AA_i] = D_i;
    #0; -> WRITE_OP;
  end

// READ Mode
always @ (posedge CLKR_i)
  if (!REB_i) begin
     Q_i = MEMORY[AB_i];
  end


endmodule

`undef read_write
