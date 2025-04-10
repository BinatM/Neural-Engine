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
//****************************************************************************** */
//*                                                                              */
//*      Usage Limitation: PLEASE READ CAREFULLY FOR CORRECT USAGE               */
//*                                                                              */
//* The model doesn't support the control enable, data and address signals       */
//* transition at positive clock edge.                                           */
//* Please have some timing delays between control/data/address and clock signals*/
//* to ensure the correct behavior.                                              */
//*                                                                              */
//* Please be careful when using non 2^n  memory.                                */
//* In a non-fully decoded array, a write cycle to a nonexistent address location*/
//* does not change the memory array contents and output remains the same.       */
//* In a non-fully decoded array, a read cycle to a nonexistent address location */
//* does not change the memory array contents but the output becomes unknown.    */
//*                                                                              */
//* In the verilog model, the behavior of unknown clock will corrupt the         */
//* memory data and make output unknown regardless of WEB/REB signal.But in the  */
//* silicon, the unknown clock at WEB/REB high, the memory and output data will  */
//* be held. The verilog model behavior is more conservative in this condition.  */
//*                                                                              */
//* The model doesn't identify physical column and row address                   */
//*                                                                              */
//* The verilog model provides UNIT_DELAY mode for the fast function simulation. */
//* All timing values in the specification are not checked in the UNIT_DELAY mode*/
//* simulation.                                                                  */
//*                                                                              */
//* The critical contention timings, tcc, is not checked in the UNIT_DELAY mode  */
//* simulation.  If addresses of read and write operations are the same and the  */
//* real time of the positive edge of CLKA and CLKB are identical the same,      */
//* it will be treated as a read/write port contention.                          */ 
//*                                                                              */
//* Please use the verilog simulator version with $recrem timing check support.  */
//* Some earlier simulator versions might support $recovery only, not $recrem.   */
//*                                                                              */
//* Template Version : S_01_42102                                       */
//****************************************************************************** */
//*      Macro Usage       : (+define[MACRO] for Verilog compiliers)             */
//* +UNIT_DELAY : Enable fast function simulation.                              */
//* +no_warning : Disable all runtime warnings message from this model.          */
//* +TSMC_INITIALIZE_MEM : Initialize the memory data in verilog format.         */
//* +TSMC_INITIALIZE_FAULT : Initialize the memory fault data in verilog format. */
//* +TSMC_NO_TESTPINS_WARNING : Disable the wrong test pins connection error     */
//*                             message if necessary.                            */
//* +NO_INPUT_FLOATING_CHECK : Turn off floating check for all input pins in     */
//*                            standby mode.                                     */
//****************************************************************************** */
//*******************************************************************************
//*        Software         : TSMC MEMORY COMPILER tsn28hpcp2prf_2012.02.00.d.200b */
//*        Technology       : TSMC 28nm CMOS LOGIC High Performance Compact Mobile Computing Plus 1P10M HKMG CU_ELK 0.9V */
//*        Memory Type      : TSMC 28nm High Performance Compact Mobile Computing Plus Two Port Register File */
//*                         : with d240 bit cell HVT periphery */
//*        Library Name     : ts6n28hpcphvta64x8m4fwbso (user specify : TS6N28HPCPHVTA64X8M4FWBSO) */
//*        Library Version  : 200b */
//*        Generated Time   : 2025/04/08, 10:16:27 */
//*************************************************************************** ** */
`resetall
`celldefine

`timescale 1ns/1ps
`delay_mode_path

`suppress_faults
`enable_portfaults

module TS6N28HPCPHVTA64X8M4FWBSO
  (AA,
  D,
  BWEB,
  WEB,CLKW,
  AB,
  REB,CLKR,
  AMA,
  DM,
  BWEBM,
  WEBM,
  AMB,
  REBM,BIST,
            SLP,
            SD,
  VDD,
  VSS,
  Q);

// Parameter declarations
parameter  N = 8;
parameter  W = 64;
parameter  M = 6;



`ifdef UNIT_DELAY
parameter  SRAM_DELAY = 0.0010;
`endif
`ifdef TSMC_INITIALIZE_MEM
parameter INITIAL_MEM_DELAY = 0.01;
`endif
`ifdef TSMC_INITIALIZE_FAULT
parameter INITIAL_FAULT_DELAY = 0.01;
`endif

// Input-Output declarations
   input [M-1:0] AA;                // Address write bus
   input [N-1:0] D;                 // Date input bus
   input [N-1:0] BWEB;              // BW data input bus
   input         WEB;               // Active-low Write enable
   input         CLKW;              // Clock A
   input [M-1:0] AB;                // Address read bus 
   input         REB;               // Active-low Read enable
   input         CLKR;              // Clock B
// Test Mode
   input SLP;
   input SD;
   input VDD;
   input VSS;

   input [M-1:0] AMA;               // Address write bus 
   input [N-1:0] DM;                // Date input bus  
   input [N-1:0] BWEBM;             // BW data input bus
   input         WEBM;              // Active-low Write enable
   input [M-1:0] AMB;               // Address read bus 
   input         REBM;              // Active-low Read enable 
   input         BIST;
   output [N-1:0] Q;                 // Data output bus


`ifdef no_warning
parameter MES_ALL = "OFF";
`else
parameter MES_ALL = "ON";
`endif

`ifdef TSMC_INITIALIZE_MEM
  parameter cdeFileInit  = "TS6N28HPCPHVTA64X8M4FWBSO_initial.cde";
`endif
`ifdef TSMC_INITIALIZE_FAULT
   parameter cdeFileFault = "TS6N28HPCPHVTA64X8M4FWBSO_fault.cde";
`endif

// Registers
reg [N-1:0] DL;

reg [N-1:0] BWEBL;
reg [N-1:0] bBWEBL;

reg [M-1:0] AAL;
reg [M-1:0] ABL;

reg WEBL;
reg REBL;

wire [N-1:0] QL;

wire bSLP;
wire            bDSLP = 1'b0;
wire bSD;

reg valid_ckr, valid_ckw;
reg valid_wea;
reg valid_reb;
reg valid_aa;
reg valid_ab;
reg valid_pd;
reg valid_contention;
reg valid_d7, valid_d6, valid_d5, valid_d4, valid_d3, valid_d2, valid_d1, valid_d0;
reg valid_bw7, valid_bw6, valid_bw5, valid_bw4, valid_bw3, valid_bw2, valid_bw1, valid_bw0;
reg valid_bist;

reg rstb_toggle_flag;




integer clk_count;

reg EN;
reg RDA, RDB;

reg RCLKW,RCLKR;

wire [N-1:0] bBWEB;

wire [N-1:0] bD;

wire [M-1:0] bAA;
wire [M-1:0] bAB;

wire bWEB;
wire bREB;
wire bCLKW,bCLKR;

// Test Mode

reg [N-1:0] bQ;
wire [N-1:0] bbQ;

wire [N-1:0] bBWEBM;
wire [N-1:0] bDM;
wire [M-1:0] bAMA;
wire [M-1:0] bAMB;
wire bWEBM;
wire bREBM;
wire bBIST;
wire NOBIST;

integer i;
 
// Address Inputs
buf sAA0 (bAA[0], AA[0]);
buf sAB0 (bAB[0], AB[0]);
buf sAA1 (bAA[1], AA[1]);
buf sAB1 (bAB[1], AB[1]);
buf sAA2 (bAA[2], AA[2]);
buf sAB2 (bAB[2], AB[2]);
buf sAA3 (bAA[3], AA[3]);
buf sAB3 (bAB[3], AB[3]);
buf sAA4 (bAA[4], AA[4]);
buf sAB4 (bAB[4], AB[4]);
buf sAA5 (bAA[5], AA[5]);
buf sAB5 (bAB[5], AB[5]);

buf sAMA0 (bAMA[0], AMA[0]);
buf sAMB0 (bAMB[0], AMB[0]);
buf sAMA1 (bAMA[1], AMA[1]);
buf sAMB1 (bAMB[1], AMB[1]);
buf sAMA2 (bAMA[2], AMA[2]);
buf sAMB2 (bAMB[2], AMB[2]);
buf sAMA3 (bAMA[3], AMA[3]);
buf sAMB3 (bAMB[3], AMB[3]);
buf sAMA4 (bAMA[4], AMA[4]);
buf sAMB4 (bAMB[4], AMB[4]);
buf sAMA5 (bAMA[5], AMA[5]);
buf sAMB5 (bAMB[5], AMB[5]);

// Bit Write/Data Inputs 
buf sD0 (bD[0], D[0]);
buf sBWEB0 (bBWEB[0], BWEB[0]);
buf sD1 (bD[1], D[1]);
buf sBWEB1 (bBWEB[1], BWEB[1]);
buf sD2 (bD[2], D[2]);
buf sBWEB2 (bBWEB[2], BWEB[2]);
buf sD3 (bD[3], D[3]);
buf sBWEB3 (bBWEB[3], BWEB[3]);
buf sD4 (bD[4], D[4]);
buf sBWEB4 (bBWEB[4], BWEB[4]);
buf sD5 (bD[5], D[5]);
buf sBWEB5 (bBWEB[5], BWEB[5]);
buf sD6 (bD[6], D[6]);
buf sBWEB6 (bBWEB[6], BWEB[6]);
buf sD7 (bD[7], D[7]);
buf sBWEB7 (bBWEB[7], BWEB[7]);

buf sDM0 (bDM[0], DM[0]);
buf sBWEBM0 (bBWEBM[0], BWEBM[0]);
buf sDM1 (bDM[1], DM[1]);
buf sBWEBM1 (bBWEBM[1], BWEBM[1]);
buf sDM2 (bDM[2], DM[2]);
buf sBWEBM2 (bBWEBM[2], BWEBM[2]);
buf sDM3 (bDM[3], DM[3]);
buf sBWEBM3 (bBWEBM[3], BWEBM[3]);
buf sDM4 (bDM[4], DM[4]);
buf sBWEBM4 (bBWEBM[4], BWEBM[4]);
buf sDM5 (bDM[5], DM[5]);
buf sBWEBM5 (bBWEBM[5], BWEBM[5]);
buf sDM6 (bDM[6], DM[6]);
buf sBWEBM6 (bBWEBM[6], BWEBM[6]);
buf sDM7 (bDM[7], DM[7]);
buf sBWEBM7 (bBWEBM[7], BWEBM[7]);

// Input Controls
buf sWEB (bWEB, WEB);
buf sREB (bREB, REB);
buf sSLP (bSLP, SLP);
buf sSD (bSD, SD);
buf sCLKW (bCLKW, CLKW);
buf sCLKR (bCLKR, CLKR);

buf sWE (WE, !bWEB);
buf sRE (RE, !bREB);



buf sWEBM (bWEBM, WEBM);
buf sREBM (bREBM, REBM);
buf sBIST (bBIST, BIST);

// Test Mode

// Output Data
buf sQ0 (Q[0], bbQ[0]);
//nmos (Q[0], bbQ[0], 1'b1);
buf sQ1 (Q[1], bbQ[1]);
//nmos (Q[1], bbQ[1], 1'b1);
buf sQ2 (Q[2], bbQ[2]);
//nmos (Q[2], bbQ[2], 1'b1);
buf sQ3 (Q[3], bbQ[3]);
//nmos (Q[3], bbQ[3], 1'b1);
buf sQ4 (Q[4], bbQ[4]);
//nmos (Q[4], bbQ[4], 1'b1);
buf sQ5 (Q[5], bbQ[5]);
//nmos (Q[5], bbQ[5], 1'b1);
buf sQ6 (Q[6], bbQ[6]);
//nmos (Q[6], bbQ[6], 1'b1);
buf sQ7 (Q[7], bbQ[7]);
//nmos (Q[7], bbQ[7], 1'b1);

assign bbQ=bQ;

buf sNOBIST (NOBIST, !bBIST);
and sANOBIST (ANOBIST, !bWEB, !bBIST);
and sBNOBIST (BNOBIST, !bREB, !bBIST);

and sABIST (ABIST, !bWEBM, bBIST);
and sBBIST (BBIST, !bREBM, bBIST);

wire AeqB, BeqA;
wire AbeforeB, BbeforeA;

real CLKR_time, CLKW_time;
real tw_ff;
real tr_ff;
 
wire CLK_same;   
assign CLK_same = ((CLKR_time == CLKW_time)?1'b1:1'b0);

wire AeqBL;
assign AeqBL = ( (AAL == ABL) ) ? 1'b1:1'b0;
`ifdef UNIT_DELAY
`else

assign AeqB = ( ((bAA == bAB) && CLK_same && !bBIST) || ((AAL == bAB) && !CLK_same && !bBIST) || ((bAMA == bAMB) && CLK_same && bBIST) || ((AAL == bAMB) && !CLK_same && bBIST)) ? 1'b1:1'b0;
assign BeqA = ( ((bAB == bAA) && CLK_same && !bBIST) || ((ABL == bAA) && !CLK_same && !bBIST) || ((bAMB == bAMA) && CLK_same && bBIST) || ((ABL == bAMA) && !CLK_same && bBIST)) ? 1'b1:1'b0;

assign AbeforeB = (((!bWEB && !bREB && CLK_same && !bBIST) || (!WEBL && !bREB && !CLK_same && !bBIST) || (!bWEBM && !bREBM && CLK_same && bBIST) || (!WEBL && !bREBM && !CLK_same && bBIST )) && AeqB) ? 1'b1:1'b0;
assign BbeforeA = (((!bREB && !bWEB && CLK_same && !bBIST) || (!REBL && !bWEB && !CLK_same && !bBIST) || (!bREBM && !bWEBM && CLK_same && bBIST) || (!REBL && !bWEBM && !CLK_same && bBIST )) && BeqA) ? 1'b1:1'b0;
`endif

wire iREB = (bBIST) ? bREBM : bREB;
wire iWEB = (bBIST) ? bWEBM : bWEB;
wire [N-1:0] iBWEB = (bBIST) ? bBWEBM : bBWEB;


wire check_wk2clkr = ~iREB & ~bSD & ~bDSLP & ~bSLP;
wire check_wk2clkw = ~iWEB & ~bSD & ~bDSLP & ~bSLP;

  
     
wire check_slp_norm = ~SD & ~BIST ;
wire check_slp_bist = ~SD & BIST ;
     
  

wire check_slp = ~bSD & ~bDSLP;

`ifdef UNIT_DELAY
`else
specify

   specparam PATHPULSE$CLKR$Q = ( 0, 0.001 );
   specparam PATHPULSE$SLP$Q = ( 0, 0.001 );
   specparam PATHPULSE$SD$Q = ( 0, 0.001 );


specparam

twckl = 0.3366,
twckh = 0.1896,
trckl = 0.3606,
trckh = 0.1848,
twcyc = 0.6783,
trcyc = 0.7846,
trwcc = 0.7846,
twrcc = 0.7505,
tslp = 0.7846,
tslpwk = 1.3160,
tslpwk2clk = 1.5691,
tslpx = 1.1133,
txslp = 0.0050,


tsd = 0.7846,
tsdwk = 14.1355,
tsdwk2clk = 14.3886,
tsdx = 1.1133,
txsd = 0.0050,

taas = 0.1900,
taah = 0.1522,
tabs = 0.1905,
tabh = 0.1635,
tds = 0.1849,
tdh = 0.1707,
tws = 0.2531,
twh = 0.0600,
trs= 0.2510,
trh = 0.0600,
tbws = 0.1843,
tbwh = 0.1714,

tamas = 0.1900,
tamah = 0.1522,
tambs = 0.1905,
tambh = 0.1635,
tdms = 0.1849,
tdmh = 0.1707,
twms = 0.2531,
twmh = 0.0600,
trms = 0.2510,
trmh = 0.0600,
tbwms = 0.1843,
tbwmh = 0.1714,
tbists= 0.5564,
tbisth = 0.1554,



tqh = 0.0,

tslpq = 0.3255,
tslpqh = 0.0,


tsdq = 0.3190,
tsdqh = 0.0,


tcd = 0.4952,
`ifdef TSMC_CM_READ_X_SQUASHING
thold = 0.4952;
`else
thold = 0.1573;
`endif
$recrem (posedge CLKW, posedge CLKR &&& AbeforeB, twrcc, 0, valid_contention);
$recrem (posedge CLKR, posedge CLKW &&& BbeforeA, trwcc, 0, valid_contention);





  
  
  
  $setuphold (posedge WEB &&& check_slp_norm, posedge SLP, 0, tslp, valid_pd);
  $setuphold (posedge REB &&& check_slp_norm, posedge SLP, 0, tslp, valid_pd);
  $setuphold (posedge WEBM &&& check_slp_bist, posedge SLP, 0, tslp, valid_pd);
  $setuphold (posedge REBM &&& check_slp_bist, posedge SLP, 0, tslp, valid_pd);

  $setuphold (negedge WEB &&& check_slp_norm, negedge SLP, tslpwk, 0, valid_pd);
  $setuphold (negedge REB &&& check_slp_norm, negedge SLP, tslpwk, 0, valid_pd);
  $setuphold (negedge WEBM &&& check_slp_bist, negedge SLP, tslpwk, 0, valid_pd);
  $setuphold (negedge REBM &&& check_slp_bist, negedge SLP, tslpwk, 0, valid_pd);
  
  $setuphold (posedge CLKR &&& check_wk2clkr, negedge SLP, tslpwk2clk, 0, valid_pd);
  $setuphold (posedge CLKW &&& check_wk2clkw, negedge SLP, tslpwk2clk, 0, valid_pd);

  $setuphold (edge[0x] bCLKW &&& check_slp, posedge SLP, tslpx, 0, valid_pd);
  $setuphold (edge[1x] bCLKW &&& check_slp, posedge SLP, tslpx, 0, valid_pd);
  $setuphold (edge[0x] bCLKR &&& check_slp, posedge SLP, tslpx, 0, valid_pd);
  $setuphold (edge[1x] bCLKR &&& check_slp, posedge SLP, tslpx, 0, valid_pd);

  $setuphold (edge[x0] bCLKW &&& check_slp, negedge SLP, 0, txslp, valid_pd);
  $setuphold (edge[x1] bCLKW &&& check_slp, negedge SLP, 0, txslp, valid_pd);
  $setuphold (edge[x0] bCLKR &&& check_slp, negedge SLP, 0, txslp, valid_pd);
  $setuphold (edge[x1] bCLKR &&& check_slp, negedge SLP, 0, txslp, valid_pd);

  $setuphold (edge[0x] bAMA[0] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[1x] bAMA[0] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[0x] bAMB[0] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_ab);
  $setuphold (edge[1x] bAMB[0] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_ab);
  
  $setuphold (edge[x0] bAMA[0] &&& check_slp_bist, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x1] bAMA[0] &&& check_slp_bist, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x0] bAMB[0] &&& check_slp_bist, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[x1] bAMB[0] &&& check_slp_bist, negedge SLP, 0, txslp, valid_ab);
 
  $setuphold (edge[0x] bAA[0] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[1x] bAA[0] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[0x] bAB[0] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_ab);
  $setuphold (edge[1x] bAB[0] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_ab);
  
  $setuphold (edge[x0] bAA[0] &&& check_slp_norm, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x1] bAA[0] &&& check_slp_norm, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x0] bAB[0] &&& check_slp_norm, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[x1] bAB[0] &&& check_slp_norm, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[0x] bAMA[1] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[1x] bAMA[1] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[0x] bAMB[1] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_ab);
  $setuphold (edge[1x] bAMB[1] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_ab);
  
  $setuphold (edge[x0] bAMA[1] &&& check_slp_bist, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x1] bAMA[1] &&& check_slp_bist, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x0] bAMB[1] &&& check_slp_bist, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[x1] bAMB[1] &&& check_slp_bist, negedge SLP, 0, txslp, valid_ab);
 
  $setuphold (edge[0x] bAA[1] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[1x] bAA[1] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[0x] bAB[1] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_ab);
  $setuphold (edge[1x] bAB[1] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_ab);
  
  $setuphold (edge[x0] bAA[1] &&& check_slp_norm, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x1] bAA[1] &&& check_slp_norm, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x0] bAB[1] &&& check_slp_norm, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[x1] bAB[1] &&& check_slp_norm, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[0x] bAMA[2] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[1x] bAMA[2] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[0x] bAMB[2] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_ab);
  $setuphold (edge[1x] bAMB[2] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_ab);
  
  $setuphold (edge[x0] bAMA[2] &&& check_slp_bist, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x1] bAMA[2] &&& check_slp_bist, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x0] bAMB[2] &&& check_slp_bist, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[x1] bAMB[2] &&& check_slp_bist, negedge SLP, 0, txslp, valid_ab);
 
  $setuphold (edge[0x] bAA[2] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[1x] bAA[2] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[0x] bAB[2] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_ab);
  $setuphold (edge[1x] bAB[2] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_ab);
  
  $setuphold (edge[x0] bAA[2] &&& check_slp_norm, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x1] bAA[2] &&& check_slp_norm, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x0] bAB[2] &&& check_slp_norm, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[x1] bAB[2] &&& check_slp_norm, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[0x] bAMA[3] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[1x] bAMA[3] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[0x] bAMB[3] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_ab);
  $setuphold (edge[1x] bAMB[3] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_ab);
  
  $setuphold (edge[x0] bAMA[3] &&& check_slp_bist, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x1] bAMA[3] &&& check_slp_bist, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x0] bAMB[3] &&& check_slp_bist, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[x1] bAMB[3] &&& check_slp_bist, negedge SLP, 0, txslp, valid_ab);
 
  $setuphold (edge[0x] bAA[3] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[1x] bAA[3] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[0x] bAB[3] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_ab);
  $setuphold (edge[1x] bAB[3] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_ab);
  
  $setuphold (edge[x0] bAA[3] &&& check_slp_norm, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x1] bAA[3] &&& check_slp_norm, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x0] bAB[3] &&& check_slp_norm, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[x1] bAB[3] &&& check_slp_norm, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[0x] bAMA[4] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[1x] bAMA[4] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[0x] bAMB[4] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_ab);
  $setuphold (edge[1x] bAMB[4] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_ab);
  
  $setuphold (edge[x0] bAMA[4] &&& check_slp_bist, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x1] bAMA[4] &&& check_slp_bist, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x0] bAMB[4] &&& check_slp_bist, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[x1] bAMB[4] &&& check_slp_bist, negedge SLP, 0, txslp, valid_ab);
 
  $setuphold (edge[0x] bAA[4] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[1x] bAA[4] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[0x] bAB[4] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_ab);
  $setuphold (edge[1x] bAB[4] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_ab);
  
  $setuphold (edge[x0] bAA[4] &&& check_slp_norm, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x1] bAA[4] &&& check_slp_norm, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x0] bAB[4] &&& check_slp_norm, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[x1] bAB[4] &&& check_slp_norm, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[0x] bAMA[5] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[1x] bAMA[5] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[0x] bAMB[5] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_ab);
  $setuphold (edge[1x] bAMB[5] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_ab);
  
  $setuphold (edge[x0] bAMA[5] &&& check_slp_bist, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x1] bAMA[5] &&& check_slp_bist, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x0] bAMB[5] &&& check_slp_bist, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[x1] bAMB[5] &&& check_slp_bist, negedge SLP, 0, txslp, valid_ab);
 
  $setuphold (edge[0x] bAA[5] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[1x] bAA[5] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_aa);
  $setuphold (edge[0x] bAB[5] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_ab);
  $setuphold (edge[1x] bAB[5] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_ab);
  
  $setuphold (edge[x0] bAA[5] &&& check_slp_norm, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x1] bAA[5] &&& check_slp_norm, negedge SLP, 0, txslp, valid_aa);
  $setuphold (edge[x0] bAB[5] &&& check_slp_norm, negedge SLP, 0, txslp, valid_ab);
  $setuphold (edge[x1] bAB[5] &&& check_slp_norm, negedge SLP, 0, txslp, valid_ab);

  $setuphold (edge[0x] bD[0] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_d0);
  $setuphold (edge[1x] bD[0] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_d0);

  $setuphold (edge[x0] bD[0] &&& check_slp_norm, negedge SLP, 0, txslp, valid_d0);
  $setuphold (edge[x1] bD[0] &&& check_slp_norm, negedge SLP, 0, txslp, valid_d0);

  $setuphold (edge[0x] bDM[0] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_d0);
  $setuphold (edge[1x] bDM[0] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_d0);

  $setuphold (edge[x0] bDM[0] &&& check_slp_bist, negedge SLP, 0, txslp, valid_d0);
  $setuphold (edge[x1] bDM[0] &&& check_slp_bist, negedge SLP, 0, txslp, valid_d0);

  $setuphold (edge[0x] bBWEB[0] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_bw0);
  $setuphold (edge[1x] bBWEB[0] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_bw0);
  
  $setuphold (edge[x0] bBWEB[0] &&& check_slp_norm, negedge SLP, 0, txslp, valid_bw0);
  $setuphold (edge[x1] bBWEB[0] &&& check_slp_norm, negedge SLP, 0, txslp, valid_bw0);

  $setuphold (edge[0x] bBWEBM[0] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_bw0);
  $setuphold (edge[1x] bBWEBM[0] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_bw0);
  
  $setuphold (edge[x0] bBWEBM[0] &&& check_slp_bist, negedge SLP, 0, txslp, valid_bw0);
  $setuphold (edge[x1] bBWEBM[0] &&& check_slp_bist, negedge SLP, 0, txslp, valid_bw0);
  $setuphold (edge[0x] bD[1] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_d1);
  $setuphold (edge[1x] bD[1] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_d1);

  $setuphold (edge[x0] bD[1] &&& check_slp_norm, negedge SLP, 0, txslp, valid_d1);
  $setuphold (edge[x1] bD[1] &&& check_slp_norm, negedge SLP, 0, txslp, valid_d1);

  $setuphold (edge[0x] bDM[1] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_d1);
  $setuphold (edge[1x] bDM[1] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_d1);

  $setuphold (edge[x0] bDM[1] &&& check_slp_bist, negedge SLP, 0, txslp, valid_d1);
  $setuphold (edge[x1] bDM[1] &&& check_slp_bist, negedge SLP, 0, txslp, valid_d1);

  $setuphold (edge[0x] bBWEB[1] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_bw1);
  $setuphold (edge[1x] bBWEB[1] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_bw1);
  
  $setuphold (edge[x0] bBWEB[1] &&& check_slp_norm, negedge SLP, 0, txslp, valid_bw1);
  $setuphold (edge[x1] bBWEB[1] &&& check_slp_norm, negedge SLP, 0, txslp, valid_bw1);

  $setuphold (edge[0x] bBWEBM[1] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_bw1);
  $setuphold (edge[1x] bBWEBM[1] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_bw1);
  
  $setuphold (edge[x0] bBWEBM[1] &&& check_slp_bist, negedge SLP, 0, txslp, valid_bw1);
  $setuphold (edge[x1] bBWEBM[1] &&& check_slp_bist, negedge SLP, 0, txslp, valid_bw1);
  $setuphold (edge[0x] bD[2] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_d2);
  $setuphold (edge[1x] bD[2] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_d2);

  $setuphold (edge[x0] bD[2] &&& check_slp_norm, negedge SLP, 0, txslp, valid_d2);
  $setuphold (edge[x1] bD[2] &&& check_slp_norm, negedge SLP, 0, txslp, valid_d2);

  $setuphold (edge[0x] bDM[2] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_d2);
  $setuphold (edge[1x] bDM[2] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_d2);

  $setuphold (edge[x0] bDM[2] &&& check_slp_bist, negedge SLP, 0, txslp, valid_d2);
  $setuphold (edge[x1] bDM[2] &&& check_slp_bist, negedge SLP, 0, txslp, valid_d2);

  $setuphold (edge[0x] bBWEB[2] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_bw2);
  $setuphold (edge[1x] bBWEB[2] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_bw2);
  
  $setuphold (edge[x0] bBWEB[2] &&& check_slp_norm, negedge SLP, 0, txslp, valid_bw2);
  $setuphold (edge[x1] bBWEB[2] &&& check_slp_norm, negedge SLP, 0, txslp, valid_bw2);

  $setuphold (edge[0x] bBWEBM[2] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_bw2);
  $setuphold (edge[1x] bBWEBM[2] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_bw2);
  
  $setuphold (edge[x0] bBWEBM[2] &&& check_slp_bist, negedge SLP, 0, txslp, valid_bw2);
  $setuphold (edge[x1] bBWEBM[2] &&& check_slp_bist, negedge SLP, 0, txslp, valid_bw2);
  $setuphold (edge[0x] bD[3] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_d3);
  $setuphold (edge[1x] bD[3] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_d3);

  $setuphold (edge[x0] bD[3] &&& check_slp_norm, negedge SLP, 0, txslp, valid_d3);
  $setuphold (edge[x1] bD[3] &&& check_slp_norm, negedge SLP, 0, txslp, valid_d3);

  $setuphold (edge[0x] bDM[3] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_d3);
  $setuphold (edge[1x] bDM[3] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_d3);

  $setuphold (edge[x0] bDM[3] &&& check_slp_bist, negedge SLP, 0, txslp, valid_d3);
  $setuphold (edge[x1] bDM[3] &&& check_slp_bist, negedge SLP, 0, txslp, valid_d3);

  $setuphold (edge[0x] bBWEB[3] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_bw3);
  $setuphold (edge[1x] bBWEB[3] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_bw3);
  
  $setuphold (edge[x0] bBWEB[3] &&& check_slp_norm, negedge SLP, 0, txslp, valid_bw3);
  $setuphold (edge[x1] bBWEB[3] &&& check_slp_norm, negedge SLP, 0, txslp, valid_bw3);

  $setuphold (edge[0x] bBWEBM[3] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_bw3);
  $setuphold (edge[1x] bBWEBM[3] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_bw3);
  
  $setuphold (edge[x0] bBWEBM[3] &&& check_slp_bist, negedge SLP, 0, txslp, valid_bw3);
  $setuphold (edge[x1] bBWEBM[3] &&& check_slp_bist, negedge SLP, 0, txslp, valid_bw3);
  $setuphold (edge[0x] bD[4] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_d4);
  $setuphold (edge[1x] bD[4] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_d4);

  $setuphold (edge[x0] bD[4] &&& check_slp_norm, negedge SLP, 0, txslp, valid_d4);
  $setuphold (edge[x1] bD[4] &&& check_slp_norm, negedge SLP, 0, txslp, valid_d4);

  $setuphold (edge[0x] bDM[4] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_d4);
  $setuphold (edge[1x] bDM[4] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_d4);

  $setuphold (edge[x0] bDM[4] &&& check_slp_bist, negedge SLP, 0, txslp, valid_d4);
  $setuphold (edge[x1] bDM[4] &&& check_slp_bist, negedge SLP, 0, txslp, valid_d4);

  $setuphold (edge[0x] bBWEB[4] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_bw4);
  $setuphold (edge[1x] bBWEB[4] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_bw4);
  
  $setuphold (edge[x0] bBWEB[4] &&& check_slp_norm, negedge SLP, 0, txslp, valid_bw4);
  $setuphold (edge[x1] bBWEB[4] &&& check_slp_norm, negedge SLP, 0, txslp, valid_bw4);

  $setuphold (edge[0x] bBWEBM[4] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_bw4);
  $setuphold (edge[1x] bBWEBM[4] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_bw4);
  
  $setuphold (edge[x0] bBWEBM[4] &&& check_slp_bist, negedge SLP, 0, txslp, valid_bw4);
  $setuphold (edge[x1] bBWEBM[4] &&& check_slp_bist, negedge SLP, 0, txslp, valid_bw4);
  $setuphold (edge[0x] bD[5] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_d5);
  $setuphold (edge[1x] bD[5] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_d5);

  $setuphold (edge[x0] bD[5] &&& check_slp_norm, negedge SLP, 0, txslp, valid_d5);
  $setuphold (edge[x1] bD[5] &&& check_slp_norm, negedge SLP, 0, txslp, valid_d5);

  $setuphold (edge[0x] bDM[5] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_d5);
  $setuphold (edge[1x] bDM[5] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_d5);

  $setuphold (edge[x0] bDM[5] &&& check_slp_bist, negedge SLP, 0, txslp, valid_d5);
  $setuphold (edge[x1] bDM[5] &&& check_slp_bist, negedge SLP, 0, txslp, valid_d5);

  $setuphold (edge[0x] bBWEB[5] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_bw5);
  $setuphold (edge[1x] bBWEB[5] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_bw5);
  
  $setuphold (edge[x0] bBWEB[5] &&& check_slp_norm, negedge SLP, 0, txslp, valid_bw5);
  $setuphold (edge[x1] bBWEB[5] &&& check_slp_norm, negedge SLP, 0, txslp, valid_bw5);

  $setuphold (edge[0x] bBWEBM[5] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_bw5);
  $setuphold (edge[1x] bBWEBM[5] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_bw5);
  
  $setuphold (edge[x0] bBWEBM[5] &&& check_slp_bist, negedge SLP, 0, txslp, valid_bw5);
  $setuphold (edge[x1] bBWEBM[5] &&& check_slp_bist, negedge SLP, 0, txslp, valid_bw5);
  $setuphold (edge[0x] bD[6] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_d6);
  $setuphold (edge[1x] bD[6] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_d6);

  $setuphold (edge[x0] bD[6] &&& check_slp_norm, negedge SLP, 0, txslp, valid_d6);
  $setuphold (edge[x1] bD[6] &&& check_slp_norm, negedge SLP, 0, txslp, valid_d6);

  $setuphold (edge[0x] bDM[6] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_d6);
  $setuphold (edge[1x] bDM[6] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_d6);

  $setuphold (edge[x0] bDM[6] &&& check_slp_bist, negedge SLP, 0, txslp, valid_d6);
  $setuphold (edge[x1] bDM[6] &&& check_slp_bist, negedge SLP, 0, txslp, valid_d6);

  $setuphold (edge[0x] bBWEB[6] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_bw6);
  $setuphold (edge[1x] bBWEB[6] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_bw6);
  
  $setuphold (edge[x0] bBWEB[6] &&& check_slp_norm, negedge SLP, 0, txslp, valid_bw6);
  $setuphold (edge[x1] bBWEB[6] &&& check_slp_norm, negedge SLP, 0, txslp, valid_bw6);

  $setuphold (edge[0x] bBWEBM[6] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_bw6);
  $setuphold (edge[1x] bBWEBM[6] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_bw6);
  
  $setuphold (edge[x0] bBWEBM[6] &&& check_slp_bist, negedge SLP, 0, txslp, valid_bw6);
  $setuphold (edge[x1] bBWEBM[6] &&& check_slp_bist, negedge SLP, 0, txslp, valid_bw6);
  $setuphold (edge[0x] bD[7] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_d7);
  $setuphold (edge[1x] bD[7] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_d7);

  $setuphold (edge[x0] bD[7] &&& check_slp_norm, negedge SLP, 0, txslp, valid_d7);
  $setuphold (edge[x1] bD[7] &&& check_slp_norm, negedge SLP, 0, txslp, valid_d7);

  $setuphold (edge[0x] bDM[7] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_d7);
  $setuphold (edge[1x] bDM[7] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_d7);

  $setuphold (edge[x0] bDM[7] &&& check_slp_bist, negedge SLP, 0, txslp, valid_d7);
  $setuphold (edge[x1] bDM[7] &&& check_slp_bist, negedge SLP, 0, txslp, valid_d7);

  $setuphold (edge[0x] bBWEB[7] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_bw7);
  $setuphold (edge[1x] bBWEB[7] &&& check_slp_norm, posedge SLP, tslpx, 0, valid_bw7);
  
  $setuphold (edge[x0] bBWEB[7] &&& check_slp_norm, negedge SLP, 0, txslp, valid_bw7);
  $setuphold (edge[x1] bBWEB[7] &&& check_slp_norm, negedge SLP, 0, txslp, valid_bw7);

  $setuphold (edge[0x] bBWEBM[7] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_bw7);
  $setuphold (edge[1x] bBWEBM[7] &&& check_slp_bist, posedge SLP, tslpx, 0, valid_bw7);
  
  $setuphold (edge[x0] bBWEBM[7] &&& check_slp_bist, negedge SLP, 0, txslp, valid_bw7);
  $setuphold (edge[x1] bBWEBM[7] &&& check_slp_bist, negedge SLP, 0, txslp, valid_bw7);
  



  $setuphold (posedge WEB &&& ~BIST, posedge SD, 0, tsd, valid_pd);
  $setuphold (posedge REB &&& ~BIST, posedge SD, 0, tsd, valid_pd);
  $setuphold (posedge WEBM &&& BIST, posedge SD, 0, tsd, valid_pd);
  $setuphold (posedge REBM &&& BIST, posedge SD, 0, tsd, valid_pd);

  $setuphold (negedge WEB &&& ~BIST, negedge SD, tsdwk, 0, valid_pd);
  $setuphold (negedge REB &&& ~BIST, negedge SD, tsdwk, 0, valid_pd);
  $setuphold (negedge WEBM &&& BIST, negedge SD, tsdwk, 0, valid_pd);
  $setuphold (negedge REBM &&& BIST, negedge SD, tsdwk, 0, valid_pd);
  
  $setuphold (posedge CLKR &&& check_wk2clkr, negedge SD, tsdwk2clk, 0, valid_pd);
  $setuphold (posedge CLKW &&& check_wk2clkw, negedge SD, tsdwk2clk, 0, valid_pd);

  $setuphold (edge[0x] bCLKW, posedge SD, tsdx, 0, valid_pd);
  $setuphold (edge[1x] bCLKW, posedge SD, tsdx, 0, valid_pd);
  $setuphold (edge[0x] bCLKR,  posedge SD, tsdx, 0, valid_pd);
  $setuphold (edge[1x] bCLKR,  posedge SD, tsdx, 0, valid_pd);
  
  $setuphold (edge[x0] bCLKW, negedge SD, 0, txsd, valid_pd);
  $setuphold (edge[x1] bCLKW, negedge SD, 0, txsd, valid_pd);
  $setuphold (edge[x0] bCLKR,  negedge SD, 0, txsd, valid_pd);
  $setuphold (edge[x1] bCLKR,  negedge SD, 0, txsd, valid_pd);
  
  $setuphold (edge[0x] bSLP,  posedge SD, tsdx, 0, valid_pd);
  $setuphold (edge[1x] bSLP,  posedge SD, tsdx, 0, valid_pd);
  
  $setuphold (edge[x0] bSLP,  negedge SD, 0, txsd, valid_pd);
  $setuphold (edge[x1] bSLP,  negedge SD, 0, txsd, valid_pd);
  
  $setuphold (edge[0x] bBIST, posedge SD, tsdx, 0, valid_pd);
  $setuphold (edge[1x] bBIST, posedge SD, tsdx, 0, valid_pd);
  
  $setuphold (edge[x0] bBIST, negedge SD, 0, txsd, valid_pd);
  $setuphold (edge[x1] bBIST, negedge SD, 0, txsd, valid_pd);

  $setuphold (edge[0x] bREB &&& ~BIST, posedge SD, tsdx, 0, valid_pd);
  $setuphold (edge[1x] bREB &&& ~BIST, posedge SD, tsdx, 0, valid_pd);
  $setuphold (edge[0x] bWEB &&& ~BIST, posedge SD, tsdx, 0, valid_pd);
  $setuphold (edge[1x] bWEB &&& ~BIST, posedge SD, tsdx, 0, valid_pd);
  
  $setuphold (edge[x0] bREB &&& ~BIST, negedge SD, 0, txsd, valid_pd);
  $setuphold (edge[x1] bREB &&& ~BIST, negedge SD, 0, txsd, valid_pd);
  $setuphold (edge[x0] bWEB &&& ~BIST, negedge SD, 0, txsd, valid_pd);
  $setuphold (edge[x1] bWEB &&& ~BIST, negedge SD, 0, txsd, valid_pd);
  
  $setuphold (edge[0x] bREBM &&& BIST, posedge SD, tsdx, 0, valid_pd);
  $setuphold (edge[1x] bREBM &&& BIST, posedge SD, tsdx, 0, valid_pd);
  $setuphold (edge[0x] bWEBM &&& BIST, posedge SD, tsdx, 0, valid_pd);
  $setuphold (edge[1x] bWEBM &&& BIST, posedge SD, tsdx, 0, valid_pd);
  
  $setuphold (edge[x0] bREBM &&& BIST, negedge SD, 0, txsd, valid_pd);
  $setuphold (edge[x1] bREBM &&& BIST, negedge SD, 0, txsd, valid_pd);
  $setuphold (edge[x0] bWEBM &&& BIST, negedge SD, 0, txsd, valid_pd);
  $setuphold (edge[x1] bWEBM &&& BIST, negedge SD, 0, txsd, valid_pd);

  $setuphold (edge[0x] bAMA[0] &&& BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[1x] bAMA[0] &&& BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[0x] bAMB[0] &&& BIST, posedge SD, tsdx, 0, valid_ab);
  $setuphold (edge[1x] bAMB[0] &&& BIST, posedge SD, tsdx, 0, valid_ab);
  
  $setuphold (edge[x0] bAMA[0] &&& BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x1] bAMA[0] &&& BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x0] bAMB[0] &&& BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[x1] bAMB[0] &&& BIST, negedge SD, 0, txsd, valid_ab);
 
  $setuphold (edge[0x] bAA[0] &&& ~BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[1x] bAA[0] &&& ~BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[0x] bAB[0] &&& ~BIST, posedge SD, tsdx, 0, valid_ab);
  $setuphold (edge[1x] bAB[0] &&& ~BIST, posedge SD, tsdx, 0, valid_ab);
  
  $setuphold (edge[x0] bAA[0] &&& ~BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x1] bAA[0] &&& ~BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x0] bAB[0] &&& ~BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[x1] bAB[0] &&& ~BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[0x] bAMA[1] &&& BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[1x] bAMA[1] &&& BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[0x] bAMB[1] &&& BIST, posedge SD, tsdx, 0, valid_ab);
  $setuphold (edge[1x] bAMB[1] &&& BIST, posedge SD, tsdx, 0, valid_ab);
  
  $setuphold (edge[x0] bAMA[1] &&& BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x1] bAMA[1] &&& BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x0] bAMB[1] &&& BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[x1] bAMB[1] &&& BIST, negedge SD, 0, txsd, valid_ab);
 
  $setuphold (edge[0x] bAA[1] &&& ~BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[1x] bAA[1] &&& ~BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[0x] bAB[1] &&& ~BIST, posedge SD, tsdx, 0, valid_ab);
  $setuphold (edge[1x] bAB[1] &&& ~BIST, posedge SD, tsdx, 0, valid_ab);
  
  $setuphold (edge[x0] bAA[1] &&& ~BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x1] bAA[1] &&& ~BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x0] bAB[1] &&& ~BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[x1] bAB[1] &&& ~BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[0x] bAMA[2] &&& BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[1x] bAMA[2] &&& BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[0x] bAMB[2] &&& BIST, posedge SD, tsdx, 0, valid_ab);
  $setuphold (edge[1x] bAMB[2] &&& BIST, posedge SD, tsdx, 0, valid_ab);
  
  $setuphold (edge[x0] bAMA[2] &&& BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x1] bAMA[2] &&& BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x0] bAMB[2] &&& BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[x1] bAMB[2] &&& BIST, negedge SD, 0, txsd, valid_ab);
 
  $setuphold (edge[0x] bAA[2] &&& ~BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[1x] bAA[2] &&& ~BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[0x] bAB[2] &&& ~BIST, posedge SD, tsdx, 0, valid_ab);
  $setuphold (edge[1x] bAB[2] &&& ~BIST, posedge SD, tsdx, 0, valid_ab);
  
  $setuphold (edge[x0] bAA[2] &&& ~BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x1] bAA[2] &&& ~BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x0] bAB[2] &&& ~BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[x1] bAB[2] &&& ~BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[0x] bAMA[3] &&& BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[1x] bAMA[3] &&& BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[0x] bAMB[3] &&& BIST, posedge SD, tsdx, 0, valid_ab);
  $setuphold (edge[1x] bAMB[3] &&& BIST, posedge SD, tsdx, 0, valid_ab);
  
  $setuphold (edge[x0] bAMA[3] &&& BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x1] bAMA[3] &&& BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x0] bAMB[3] &&& BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[x1] bAMB[3] &&& BIST, negedge SD, 0, txsd, valid_ab);
 
  $setuphold (edge[0x] bAA[3] &&& ~BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[1x] bAA[3] &&& ~BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[0x] bAB[3] &&& ~BIST, posedge SD, tsdx, 0, valid_ab);
  $setuphold (edge[1x] bAB[3] &&& ~BIST, posedge SD, tsdx, 0, valid_ab);
  
  $setuphold (edge[x0] bAA[3] &&& ~BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x1] bAA[3] &&& ~BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x0] bAB[3] &&& ~BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[x1] bAB[3] &&& ~BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[0x] bAMA[4] &&& BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[1x] bAMA[4] &&& BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[0x] bAMB[4] &&& BIST, posedge SD, tsdx, 0, valid_ab);
  $setuphold (edge[1x] bAMB[4] &&& BIST, posedge SD, tsdx, 0, valid_ab);
  
  $setuphold (edge[x0] bAMA[4] &&& BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x1] bAMA[4] &&& BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x0] bAMB[4] &&& BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[x1] bAMB[4] &&& BIST, negedge SD, 0, txsd, valid_ab);
 
  $setuphold (edge[0x] bAA[4] &&& ~BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[1x] bAA[4] &&& ~BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[0x] bAB[4] &&& ~BIST, posedge SD, tsdx, 0, valid_ab);
  $setuphold (edge[1x] bAB[4] &&& ~BIST, posedge SD, tsdx, 0, valid_ab);
  
  $setuphold (edge[x0] bAA[4] &&& ~BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x1] bAA[4] &&& ~BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x0] bAB[4] &&& ~BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[x1] bAB[4] &&& ~BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[0x] bAMA[5] &&& BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[1x] bAMA[5] &&& BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[0x] bAMB[5] &&& BIST, posedge SD, tsdx, 0, valid_ab);
  $setuphold (edge[1x] bAMB[5] &&& BIST, posedge SD, tsdx, 0, valid_ab);
  
  $setuphold (edge[x0] bAMA[5] &&& BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x1] bAMA[5] &&& BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x0] bAMB[5] &&& BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[x1] bAMB[5] &&& BIST, negedge SD, 0, txsd, valid_ab);
 
  $setuphold (edge[0x] bAA[5] &&& ~BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[1x] bAA[5] &&& ~BIST, posedge SD, tsdx, 0, valid_aa);
  $setuphold (edge[0x] bAB[5] &&& ~BIST, posedge SD, tsdx, 0, valid_ab);
  $setuphold (edge[1x] bAB[5] &&& ~BIST, posedge SD, tsdx, 0, valid_ab);
  
  $setuphold (edge[x0] bAA[5] &&& ~BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x1] bAA[5] &&& ~BIST, negedge SD, 0, txsd, valid_aa);
  $setuphold (edge[x0] bAB[5] &&& ~BIST, negedge SD, 0, txsd, valid_ab);
  $setuphold (edge[x1] bAB[5] &&& ~BIST, negedge SD, 0, txsd, valid_ab);

  $setuphold (edge[0x] bD[0] &&& ~BIST, posedge SD, tsdx, 0, valid_d0);
  $setuphold (edge[1x] bD[0] &&& ~BIST, posedge SD, tsdx, 0, valid_d0);
  
  $setuphold (edge[x0] bD[0] &&& ~BIST, negedge SD, 0, txsd, valid_d0);
  $setuphold (edge[x1] bD[0] &&& ~BIST, negedge SD, 0, txsd, valid_d0);

  $setuphold (edge[0x] bDM[0] &&& BIST, posedge SD, tsdx, 0, valid_d0);
  $setuphold (edge[1x] bDM[0] &&& BIST, posedge SD, tsdx, 0, valid_d0);
  
  $setuphold (edge[x0] bDM[0] &&& BIST, negedge SD, 0, txsd, valid_d0);
  $setuphold (edge[x1] bDM[0] &&& BIST, negedge SD, 0, txsd, valid_d0);

  $setuphold (edge[0x] bBWEB[0] &&& ~BIST, posedge SD, tsdx, 0, valid_bw0);
  $setuphold (edge[1x] bBWEB[0] &&& ~BIST, posedge SD, tsdx, 0, valid_bw0);
  
  $setuphold (edge[x0] bBWEB[0] &&& ~BIST, negedge SD, 0, txsd, valid_bw0);
  $setuphold (edge[x1] bBWEB[0] &&& ~BIST, negedge SD, 0, txsd, valid_bw0);

  $setuphold (edge[0x] bBWEBM[0] &&& BIST, posedge SD, tsdx, 0, valid_bw0);
  $setuphold (edge[1x] bBWEBM[0] &&& BIST, posedge SD, tsdx, 0, valid_bw0);
  
  $setuphold (edge[x0] bBWEBM[0] &&& BIST, negedge SD, 0, txsd, valid_bw0);
  $setuphold (edge[x1] bBWEBM[0] &&& BIST, negedge SD, 0, txsd, valid_bw0);
  $setuphold (edge[0x] bD[1] &&& ~BIST, posedge SD, tsdx, 0, valid_d1);
  $setuphold (edge[1x] bD[1] &&& ~BIST, posedge SD, tsdx, 0, valid_d1);
  
  $setuphold (edge[x0] bD[1] &&& ~BIST, negedge SD, 0, txsd, valid_d1);
  $setuphold (edge[x1] bD[1] &&& ~BIST, negedge SD, 0, txsd, valid_d1);

  $setuphold (edge[0x] bDM[1] &&& BIST, posedge SD, tsdx, 0, valid_d1);
  $setuphold (edge[1x] bDM[1] &&& BIST, posedge SD, tsdx, 0, valid_d1);
  
  $setuphold (edge[x0] bDM[1] &&& BIST, negedge SD, 0, txsd, valid_d1);
  $setuphold (edge[x1] bDM[1] &&& BIST, negedge SD, 0, txsd, valid_d1);

  $setuphold (edge[0x] bBWEB[1] &&& ~BIST, posedge SD, tsdx, 0, valid_bw1);
  $setuphold (edge[1x] bBWEB[1] &&& ~BIST, posedge SD, tsdx, 0, valid_bw1);
  
  $setuphold (edge[x0] bBWEB[1] &&& ~BIST, negedge SD, 0, txsd, valid_bw1);
  $setuphold (edge[x1] bBWEB[1] &&& ~BIST, negedge SD, 0, txsd, valid_bw1);

  $setuphold (edge[0x] bBWEBM[1] &&& BIST, posedge SD, tsdx, 0, valid_bw1);
  $setuphold (edge[1x] bBWEBM[1] &&& BIST, posedge SD, tsdx, 0, valid_bw1);
  
  $setuphold (edge[x0] bBWEBM[1] &&& BIST, negedge SD, 0, txsd, valid_bw1);
  $setuphold (edge[x1] bBWEBM[1] &&& BIST, negedge SD, 0, txsd, valid_bw1);
  $setuphold (edge[0x] bD[2] &&& ~BIST, posedge SD, tsdx, 0, valid_d2);
  $setuphold (edge[1x] bD[2] &&& ~BIST, posedge SD, tsdx, 0, valid_d2);
  
  $setuphold (edge[x0] bD[2] &&& ~BIST, negedge SD, 0, txsd, valid_d2);
  $setuphold (edge[x1] bD[2] &&& ~BIST, negedge SD, 0, txsd, valid_d2);

  $setuphold (edge[0x] bDM[2] &&& BIST, posedge SD, tsdx, 0, valid_d2);
  $setuphold (edge[1x] bDM[2] &&& BIST, posedge SD, tsdx, 0, valid_d2);
  
  $setuphold (edge[x0] bDM[2] &&& BIST, negedge SD, 0, txsd, valid_d2);
  $setuphold (edge[x1] bDM[2] &&& BIST, negedge SD, 0, txsd, valid_d2);

  $setuphold (edge[0x] bBWEB[2] &&& ~BIST, posedge SD, tsdx, 0, valid_bw2);
  $setuphold (edge[1x] bBWEB[2] &&& ~BIST, posedge SD, tsdx, 0, valid_bw2);
  
  $setuphold (edge[x0] bBWEB[2] &&& ~BIST, negedge SD, 0, txsd, valid_bw2);
  $setuphold (edge[x1] bBWEB[2] &&& ~BIST, negedge SD, 0, txsd, valid_bw2);

  $setuphold (edge[0x] bBWEBM[2] &&& BIST, posedge SD, tsdx, 0, valid_bw2);
  $setuphold (edge[1x] bBWEBM[2] &&& BIST, posedge SD, tsdx, 0, valid_bw2);
  
  $setuphold (edge[x0] bBWEBM[2] &&& BIST, negedge SD, 0, txsd, valid_bw2);
  $setuphold (edge[x1] bBWEBM[2] &&& BIST, negedge SD, 0, txsd, valid_bw2);
  $setuphold (edge[0x] bD[3] &&& ~BIST, posedge SD, tsdx, 0, valid_d3);
  $setuphold (edge[1x] bD[3] &&& ~BIST, posedge SD, tsdx, 0, valid_d3);
  
  $setuphold (edge[x0] bD[3] &&& ~BIST, negedge SD, 0, txsd, valid_d3);
  $setuphold (edge[x1] bD[3] &&& ~BIST, negedge SD, 0, txsd, valid_d3);

  $setuphold (edge[0x] bDM[3] &&& BIST, posedge SD, tsdx, 0, valid_d3);
  $setuphold (edge[1x] bDM[3] &&& BIST, posedge SD, tsdx, 0, valid_d3);
  
  $setuphold (edge[x0] bDM[3] &&& BIST, negedge SD, 0, txsd, valid_d3);
  $setuphold (edge[x1] bDM[3] &&& BIST, negedge SD, 0, txsd, valid_d3);

  $setuphold (edge[0x] bBWEB[3] &&& ~BIST, posedge SD, tsdx, 0, valid_bw3);
  $setuphold (edge[1x] bBWEB[3] &&& ~BIST, posedge SD, tsdx, 0, valid_bw3);
  
  $setuphold (edge[x0] bBWEB[3] &&& ~BIST, negedge SD, 0, txsd, valid_bw3);
  $setuphold (edge[x1] bBWEB[3] &&& ~BIST, negedge SD, 0, txsd, valid_bw3);

  $setuphold (edge[0x] bBWEBM[3] &&& BIST, posedge SD, tsdx, 0, valid_bw3);
  $setuphold (edge[1x] bBWEBM[3] &&& BIST, posedge SD, tsdx, 0, valid_bw3);
  
  $setuphold (edge[x0] bBWEBM[3] &&& BIST, negedge SD, 0, txsd, valid_bw3);
  $setuphold (edge[x1] bBWEBM[3] &&& BIST, negedge SD, 0, txsd, valid_bw3);
  $setuphold (edge[0x] bD[4] &&& ~BIST, posedge SD, tsdx, 0, valid_d4);
  $setuphold (edge[1x] bD[4] &&& ~BIST, posedge SD, tsdx, 0, valid_d4);
  
  $setuphold (edge[x0] bD[4] &&& ~BIST, negedge SD, 0, txsd, valid_d4);
  $setuphold (edge[x1] bD[4] &&& ~BIST, negedge SD, 0, txsd, valid_d4);

  $setuphold (edge[0x] bDM[4] &&& BIST, posedge SD, tsdx, 0, valid_d4);
  $setuphold (edge[1x] bDM[4] &&& BIST, posedge SD, tsdx, 0, valid_d4);
  
  $setuphold (edge[x0] bDM[4] &&& BIST, negedge SD, 0, txsd, valid_d4);
  $setuphold (edge[x1] bDM[4] &&& BIST, negedge SD, 0, txsd, valid_d4);

  $setuphold (edge[0x] bBWEB[4] &&& ~BIST, posedge SD, tsdx, 0, valid_bw4);
  $setuphold (edge[1x] bBWEB[4] &&& ~BIST, posedge SD, tsdx, 0, valid_bw4);
  
  $setuphold (edge[x0] bBWEB[4] &&& ~BIST, negedge SD, 0, txsd, valid_bw4);
  $setuphold (edge[x1] bBWEB[4] &&& ~BIST, negedge SD, 0, txsd, valid_bw4);

  $setuphold (edge[0x] bBWEBM[4] &&& BIST, posedge SD, tsdx, 0, valid_bw4);
  $setuphold (edge[1x] bBWEBM[4] &&& BIST, posedge SD, tsdx, 0, valid_bw4);
  
  $setuphold (edge[x0] bBWEBM[4] &&& BIST, negedge SD, 0, txsd, valid_bw4);
  $setuphold (edge[x1] bBWEBM[4] &&& BIST, negedge SD, 0, txsd, valid_bw4);
  $setuphold (edge[0x] bD[5] &&& ~BIST, posedge SD, tsdx, 0, valid_d5);
  $setuphold (edge[1x] bD[5] &&& ~BIST, posedge SD, tsdx, 0, valid_d5);
  
  $setuphold (edge[x0] bD[5] &&& ~BIST, negedge SD, 0, txsd, valid_d5);
  $setuphold (edge[x1] bD[5] &&& ~BIST, negedge SD, 0, txsd, valid_d5);

  $setuphold (edge[0x] bDM[5] &&& BIST, posedge SD, tsdx, 0, valid_d5);
  $setuphold (edge[1x] bDM[5] &&& BIST, posedge SD, tsdx, 0, valid_d5);
  
  $setuphold (edge[x0] bDM[5] &&& BIST, negedge SD, 0, txsd, valid_d5);
  $setuphold (edge[x1] bDM[5] &&& BIST, negedge SD, 0, txsd, valid_d5);

  $setuphold (edge[0x] bBWEB[5] &&& ~BIST, posedge SD, tsdx, 0, valid_bw5);
  $setuphold (edge[1x] bBWEB[5] &&& ~BIST, posedge SD, tsdx, 0, valid_bw5);
  
  $setuphold (edge[x0] bBWEB[5] &&& ~BIST, negedge SD, 0, txsd, valid_bw5);
  $setuphold (edge[x1] bBWEB[5] &&& ~BIST, negedge SD, 0, txsd, valid_bw5);

  $setuphold (edge[0x] bBWEBM[5] &&& BIST, posedge SD, tsdx, 0, valid_bw5);
  $setuphold (edge[1x] bBWEBM[5] &&& BIST, posedge SD, tsdx, 0, valid_bw5);
  
  $setuphold (edge[x0] bBWEBM[5] &&& BIST, negedge SD, 0, txsd, valid_bw5);
  $setuphold (edge[x1] bBWEBM[5] &&& BIST, negedge SD, 0, txsd, valid_bw5);
  $setuphold (edge[0x] bD[6] &&& ~BIST, posedge SD, tsdx, 0, valid_d6);
  $setuphold (edge[1x] bD[6] &&& ~BIST, posedge SD, tsdx, 0, valid_d6);
  
  $setuphold (edge[x0] bD[6] &&& ~BIST, negedge SD, 0, txsd, valid_d6);
  $setuphold (edge[x1] bD[6] &&& ~BIST, negedge SD, 0, txsd, valid_d6);

  $setuphold (edge[0x] bDM[6] &&& BIST, posedge SD, tsdx, 0, valid_d6);
  $setuphold (edge[1x] bDM[6] &&& BIST, posedge SD, tsdx, 0, valid_d6);
  
  $setuphold (edge[x0] bDM[6] &&& BIST, negedge SD, 0, txsd, valid_d6);
  $setuphold (edge[x1] bDM[6] &&& BIST, negedge SD, 0, txsd, valid_d6);

  $setuphold (edge[0x] bBWEB[6] &&& ~BIST, posedge SD, tsdx, 0, valid_bw6);
  $setuphold (edge[1x] bBWEB[6] &&& ~BIST, posedge SD, tsdx, 0, valid_bw6);
  
  $setuphold (edge[x0] bBWEB[6] &&& ~BIST, negedge SD, 0, txsd, valid_bw6);
  $setuphold (edge[x1] bBWEB[6] &&& ~BIST, negedge SD, 0, txsd, valid_bw6);

  $setuphold (edge[0x] bBWEBM[6] &&& BIST, posedge SD, tsdx, 0, valid_bw6);
  $setuphold (edge[1x] bBWEBM[6] &&& BIST, posedge SD, tsdx, 0, valid_bw6);
  
  $setuphold (edge[x0] bBWEBM[6] &&& BIST, negedge SD, 0, txsd, valid_bw6);
  $setuphold (edge[x1] bBWEBM[6] &&& BIST, negedge SD, 0, txsd, valid_bw6);
  $setuphold (edge[0x] bD[7] &&& ~BIST, posedge SD, tsdx, 0, valid_d7);
  $setuphold (edge[1x] bD[7] &&& ~BIST, posedge SD, tsdx, 0, valid_d7);
  
  $setuphold (edge[x0] bD[7] &&& ~BIST, negedge SD, 0, txsd, valid_d7);
  $setuphold (edge[x1] bD[7] &&& ~BIST, negedge SD, 0, txsd, valid_d7);

  $setuphold (edge[0x] bDM[7] &&& BIST, posedge SD, tsdx, 0, valid_d7);
  $setuphold (edge[1x] bDM[7] &&& BIST, posedge SD, tsdx, 0, valid_d7);
  
  $setuphold (edge[x0] bDM[7] &&& BIST, negedge SD, 0, txsd, valid_d7);
  $setuphold (edge[x1] bDM[7] &&& BIST, negedge SD, 0, txsd, valid_d7);

  $setuphold (edge[0x] bBWEB[7] &&& ~BIST, posedge SD, tsdx, 0, valid_bw7);
  $setuphold (edge[1x] bBWEB[7] &&& ~BIST, posedge SD, tsdx, 0, valid_bw7);
  
  $setuphold (edge[x0] bBWEB[7] &&& ~BIST, negedge SD, 0, txsd, valid_bw7);
  $setuphold (edge[x1] bBWEB[7] &&& ~BIST, negedge SD, 0, txsd, valid_bw7);

  $setuphold (edge[0x] bBWEBM[7] &&& BIST, posedge SD, tsdx, 0, valid_bw7);
  $setuphold (edge[1x] bBWEBM[7] &&& BIST, posedge SD, tsdx, 0, valid_bw7);
  
  $setuphold (edge[x0] bBWEBM[7] &&& BIST, negedge SD, 0, txsd, valid_bw7);
  $setuphold (edge[x1] bBWEBM[7] &&& BIST, negedge SD, 0, txsd, valid_bw7);

  $setuphold (posedge CLKW &&& ABIST, posedge AMA[0], tamas, tamah, valid_aa);
  $setuphold (posedge CLKW &&& ABIST, negedge AMA[0], tamas, tamah, valid_aa);
  $setuphold (posedge CLKR &&& BBIST, posedge AMB[0], tambs, tambh, valid_ab);
  $setuphold (posedge CLKR &&& BBIST, negedge AMB[0], tambs, tambh, valid_ab);
 
  $setuphold (posedge CLKW &&& ANOBIST, posedge AA[0], taas, taah, valid_aa);
  $setuphold (posedge CLKW &&& ANOBIST, negedge AA[0], taas, taah, valid_aa);
  $setuphold (posedge CLKR &&& BNOBIST, posedge AB[0], tabs, tabh, valid_ab);
  $setuphold (posedge CLKR &&& BNOBIST, negedge AB[0], tabs, tabh, valid_ab);
  $setuphold (posedge CLKW &&& ABIST, posedge AMA[1], tamas, tamah, valid_aa);
  $setuphold (posedge CLKW &&& ABIST, negedge AMA[1], tamas, tamah, valid_aa);
  $setuphold (posedge CLKR &&& BBIST, posedge AMB[1], tambs, tambh, valid_ab);
  $setuphold (posedge CLKR &&& BBIST, negedge AMB[1], tambs, tambh, valid_ab);
 
  $setuphold (posedge CLKW &&& ANOBIST, posedge AA[1], taas, taah, valid_aa);
  $setuphold (posedge CLKW &&& ANOBIST, negedge AA[1], taas, taah, valid_aa);
  $setuphold (posedge CLKR &&& BNOBIST, posedge AB[1], tabs, tabh, valid_ab);
  $setuphold (posedge CLKR &&& BNOBIST, negedge AB[1], tabs, tabh, valid_ab);
  $setuphold (posedge CLKW &&& ABIST, posedge AMA[2], tamas, tamah, valid_aa);
  $setuphold (posedge CLKW &&& ABIST, negedge AMA[2], tamas, tamah, valid_aa);
  $setuphold (posedge CLKR &&& BBIST, posedge AMB[2], tambs, tambh, valid_ab);
  $setuphold (posedge CLKR &&& BBIST, negedge AMB[2], tambs, tambh, valid_ab);
 
  $setuphold (posedge CLKW &&& ANOBIST, posedge AA[2], taas, taah, valid_aa);
  $setuphold (posedge CLKW &&& ANOBIST, negedge AA[2], taas, taah, valid_aa);
  $setuphold (posedge CLKR &&& BNOBIST, posedge AB[2], tabs, tabh, valid_ab);
  $setuphold (posedge CLKR &&& BNOBIST, negedge AB[2], tabs, tabh, valid_ab);
  $setuphold (posedge CLKW &&& ABIST, posedge AMA[3], tamas, tamah, valid_aa);
  $setuphold (posedge CLKW &&& ABIST, negedge AMA[3], tamas, tamah, valid_aa);
  $setuphold (posedge CLKR &&& BBIST, posedge AMB[3], tambs, tambh, valid_ab);
  $setuphold (posedge CLKR &&& BBIST, negedge AMB[3], tambs, tambh, valid_ab);
 
  $setuphold (posedge CLKW &&& ANOBIST, posedge AA[3], taas, taah, valid_aa);
  $setuphold (posedge CLKW &&& ANOBIST, negedge AA[3], taas, taah, valid_aa);
  $setuphold (posedge CLKR &&& BNOBIST, posedge AB[3], tabs, tabh, valid_ab);
  $setuphold (posedge CLKR &&& BNOBIST, negedge AB[3], tabs, tabh, valid_ab);
  $setuphold (posedge CLKW &&& ABIST, posedge AMA[4], tamas, tamah, valid_aa);
  $setuphold (posedge CLKW &&& ABIST, negedge AMA[4], tamas, tamah, valid_aa);
  $setuphold (posedge CLKR &&& BBIST, posedge AMB[4], tambs, tambh, valid_ab);
  $setuphold (posedge CLKR &&& BBIST, negedge AMB[4], tambs, tambh, valid_ab);
 
  $setuphold (posedge CLKW &&& ANOBIST, posedge AA[4], taas, taah, valid_aa);
  $setuphold (posedge CLKW &&& ANOBIST, negedge AA[4], taas, taah, valid_aa);
  $setuphold (posedge CLKR &&& BNOBIST, posedge AB[4], tabs, tabh, valid_ab);
  $setuphold (posedge CLKR &&& BNOBIST, negedge AB[4], tabs, tabh, valid_ab);
  $setuphold (posedge CLKW &&& ABIST, posedge AMA[5], tamas, tamah, valid_aa);
  $setuphold (posedge CLKW &&& ABIST, negedge AMA[5], tamas, tamah, valid_aa);
  $setuphold (posedge CLKR &&& BBIST, posedge AMB[5], tambs, tambh, valid_ab);
  $setuphold (posedge CLKR &&& BBIST, negedge AMB[5], tambs, tambh, valid_ab);
 
  $setuphold (posedge CLKW &&& ANOBIST, posedge AA[5], taas, taah, valid_aa);
  $setuphold (posedge CLKW &&& ANOBIST, negedge AA[5], taas, taah, valid_aa);
  $setuphold (posedge CLKR &&& BNOBIST, posedge AB[5], tabs, tabh, valid_ab);
  $setuphold (posedge CLKR &&& BNOBIST, negedge AB[5], tabs, tabh, valid_ab);

  $setuphold (posedge CLKW &&& ANOBIST, posedge D[0], tds, tdh, valid_d0);
  $setuphold (posedge CLKW &&& ANOBIST, negedge D[0], tds, tdh, valid_d0);

  $setuphold (posedge CLKW &&& ABIST, posedge DM[0], tdms, tdmh, valid_d0);
  $setuphold (posedge CLKW &&& ABIST, negedge DM[0], tdms, tdmh, valid_d0);

  $setuphold (posedge CLKW &&& ANOBIST, posedge BWEB[0], tbws, tbwh, valid_bw0);
  $setuphold (posedge CLKW &&& ANOBIST, negedge BWEB[0], tbws, tbwh, valid_bw0);

  $setuphold (posedge CLKW &&& ABIST, posedge BWEBM[0], tbwms, tbwmh, valid_bw0);
  $setuphold (posedge CLKW &&& ABIST, negedge BWEBM[0], tbwms, tbwmh, valid_bw0);
  $setuphold (posedge CLKW &&& ANOBIST, posedge D[1], tds, tdh, valid_d1);
  $setuphold (posedge CLKW &&& ANOBIST, negedge D[1], tds, tdh, valid_d1);

  $setuphold (posedge CLKW &&& ABIST, posedge DM[1], tdms, tdmh, valid_d1);
  $setuphold (posedge CLKW &&& ABIST, negedge DM[1], tdms, tdmh, valid_d1);

  $setuphold (posedge CLKW &&& ANOBIST, posedge BWEB[1], tbws, tbwh, valid_bw1);
  $setuphold (posedge CLKW &&& ANOBIST, negedge BWEB[1], tbws, tbwh, valid_bw1);

  $setuphold (posedge CLKW &&& ABIST, posedge BWEBM[1], tbwms, tbwmh, valid_bw1);
  $setuphold (posedge CLKW &&& ABIST, negedge BWEBM[1], tbwms, tbwmh, valid_bw1);
  $setuphold (posedge CLKW &&& ANOBIST, posedge D[2], tds, tdh, valid_d2);
  $setuphold (posedge CLKW &&& ANOBIST, negedge D[2], tds, tdh, valid_d2);

  $setuphold (posedge CLKW &&& ABIST, posedge DM[2], tdms, tdmh, valid_d2);
  $setuphold (posedge CLKW &&& ABIST, negedge DM[2], tdms, tdmh, valid_d2);

  $setuphold (posedge CLKW &&& ANOBIST, posedge BWEB[2], tbws, tbwh, valid_bw2);
  $setuphold (posedge CLKW &&& ANOBIST, negedge BWEB[2], tbws, tbwh, valid_bw2);

  $setuphold (posedge CLKW &&& ABIST, posedge BWEBM[2], tbwms, tbwmh, valid_bw2);
  $setuphold (posedge CLKW &&& ABIST, negedge BWEBM[2], tbwms, tbwmh, valid_bw2);
  $setuphold (posedge CLKW &&& ANOBIST, posedge D[3], tds, tdh, valid_d3);
  $setuphold (posedge CLKW &&& ANOBIST, negedge D[3], tds, tdh, valid_d3);

  $setuphold (posedge CLKW &&& ABIST, posedge DM[3], tdms, tdmh, valid_d3);
  $setuphold (posedge CLKW &&& ABIST, negedge DM[3], tdms, tdmh, valid_d3);

  $setuphold (posedge CLKW &&& ANOBIST, posedge BWEB[3], tbws, tbwh, valid_bw3);
  $setuphold (posedge CLKW &&& ANOBIST, negedge BWEB[3], tbws, tbwh, valid_bw3);

  $setuphold (posedge CLKW &&& ABIST, posedge BWEBM[3], tbwms, tbwmh, valid_bw3);
  $setuphold (posedge CLKW &&& ABIST, negedge BWEBM[3], tbwms, tbwmh, valid_bw3);
  $setuphold (posedge CLKW &&& ANOBIST, posedge D[4], tds, tdh, valid_d4);
  $setuphold (posedge CLKW &&& ANOBIST, negedge D[4], tds, tdh, valid_d4);

  $setuphold (posedge CLKW &&& ABIST, posedge DM[4], tdms, tdmh, valid_d4);
  $setuphold (posedge CLKW &&& ABIST, negedge DM[4], tdms, tdmh, valid_d4);

  $setuphold (posedge CLKW &&& ANOBIST, posedge BWEB[4], tbws, tbwh, valid_bw4);
  $setuphold (posedge CLKW &&& ANOBIST, negedge BWEB[4], tbws, tbwh, valid_bw4);

  $setuphold (posedge CLKW &&& ABIST, posedge BWEBM[4], tbwms, tbwmh, valid_bw4);
  $setuphold (posedge CLKW &&& ABIST, negedge BWEBM[4], tbwms, tbwmh, valid_bw4);
  $setuphold (posedge CLKW &&& ANOBIST, posedge D[5], tds, tdh, valid_d5);
  $setuphold (posedge CLKW &&& ANOBIST, negedge D[5], tds, tdh, valid_d5);

  $setuphold (posedge CLKW &&& ABIST, posedge DM[5], tdms, tdmh, valid_d5);
  $setuphold (posedge CLKW &&& ABIST, negedge DM[5], tdms, tdmh, valid_d5);

  $setuphold (posedge CLKW &&& ANOBIST, posedge BWEB[5], tbws, tbwh, valid_bw5);
  $setuphold (posedge CLKW &&& ANOBIST, negedge BWEB[5], tbws, tbwh, valid_bw5);

  $setuphold (posedge CLKW &&& ABIST, posedge BWEBM[5], tbwms, tbwmh, valid_bw5);
  $setuphold (posedge CLKW &&& ABIST, negedge BWEBM[5], tbwms, tbwmh, valid_bw5);
  $setuphold (posedge CLKW &&& ANOBIST, posedge D[6], tds, tdh, valid_d6);
  $setuphold (posedge CLKW &&& ANOBIST, negedge D[6], tds, tdh, valid_d6);

  $setuphold (posedge CLKW &&& ABIST, posedge DM[6], tdms, tdmh, valid_d6);
  $setuphold (posedge CLKW &&& ABIST, negedge DM[6], tdms, tdmh, valid_d6);

  $setuphold (posedge CLKW &&& ANOBIST, posedge BWEB[6], tbws, tbwh, valid_bw6);
  $setuphold (posedge CLKW &&& ANOBIST, negedge BWEB[6], tbws, tbwh, valid_bw6);

  $setuphold (posedge CLKW &&& ABIST, posedge BWEBM[6], tbwms, tbwmh, valid_bw6);
  $setuphold (posedge CLKW &&& ABIST, negedge BWEBM[6], tbwms, tbwmh, valid_bw6);
  $setuphold (posedge CLKW &&& ANOBIST, posedge D[7], tds, tdh, valid_d7);
  $setuphold (posedge CLKW &&& ANOBIST, negedge D[7], tds, tdh, valid_d7);

  $setuphold (posedge CLKW &&& ABIST, posedge DM[7], tdms, tdmh, valid_d7);
  $setuphold (posedge CLKW &&& ABIST, negedge DM[7], tdms, tdmh, valid_d7);

  $setuphold (posedge CLKW &&& ANOBIST, posedge BWEB[7], tbws, tbwh, valid_bw7);
  $setuphold (posedge CLKW &&& ANOBIST, negedge BWEB[7], tbws, tbwh, valid_bw7);

  $setuphold (posedge CLKW &&& ABIST, posedge BWEBM[7], tbwms, tbwmh, valid_bw7);
  $setuphold (posedge CLKW &&& ABIST, negedge BWEBM[7], tbwms, tbwmh, valid_bw7);

  $setuphold (posedge CLKW &&& NOBIST, posedge WEB, tws, twh, valid_wea);
  $setuphold (posedge CLKW &&& NOBIST, negedge WEB, tws, twh, valid_wea);
  $setuphold (posedge CLKR &&& NOBIST, posedge REB, trs, trh, valid_reb);
  $setuphold (posedge CLKR &&& NOBIST, negedge REB, trs, trh, valid_reb);
 
  $setuphold (posedge CLKW &&& BIST, posedge WEBM, twms, twmh, valid_wea);
  $setuphold (posedge CLKW &&& BIST, negedge WEBM, twms, twmh, valid_wea);
  $setuphold (posedge CLKR &&& BIST, posedge REBM, trms, trmh, valid_reb);
  $setuphold (posedge CLKR &&& BIST, negedge REBM, trms, trmh, valid_reb);
 
  $setuphold (posedge CLKW, posedge BIST, tbists, tbisth, valid_bist);
  $setuphold (posedge CLKW, negedge BIST, tbists, tbisth, valid_bist);
  $setuphold (posedge CLKR, posedge BIST, tbists, tbisth, valid_bist);
  $setuphold (posedge CLKR, negedge BIST, tbists, tbisth, valid_bist);
 
  $width (negedge CLKW, twckl, 0, valid_ckw);
  $width (posedge CLKW, twckh, 0, valid_ckw);
  $width (negedge CLKR, trckl, 0, valid_ckr);
  $width (posedge CLKR, trckh, 0, valid_ckr);
  $period (posedge CLKW, twcyc, valid_ckw);
  $period (negedge CLKW, twcyc, valid_ckw);
  $period (posedge CLKR, trcyc, valid_ckr);
  $period (negedge CLKR, trcyc, valid_ckr);

if (!SD) (posedge SLP => (Q[0] +: 1'bx)) = (0,tslpq,0,0,0,tslpq);
if (!SD) (negedge SLP => (Q[0] +: 1'bx)) = (0,0,tqh,0,tqh,0);
if (!SD) (posedge SLP => (Q[1] +: 1'bx)) = (0,tslpq,0,0,0,tslpq);
if (!SD) (negedge SLP => (Q[1] +: 1'bx)) = (0,0,tqh,0,tqh,0);
if (!SD) (posedge SLP => (Q[2] +: 1'bx)) = (0,tslpq,0,0,0,tslpq);
if (!SD) (negedge SLP => (Q[2] +: 1'bx)) = (0,0,tqh,0,tqh,0);
if (!SD) (posedge SLP => (Q[3] +: 1'bx)) = (0,tslpq,0,0,0,tslpq);
if (!SD) (negedge SLP => (Q[3] +: 1'bx)) = (0,0,tqh,0,tqh,0);
if (!SD) (posedge SLP => (Q[4] +: 1'bx)) = (0,tslpq,0,0,0,tslpq);
if (!SD) (negedge SLP => (Q[4] +: 1'bx)) = (0,0,tqh,0,tqh,0);
if (!SD) (posedge SLP => (Q[5] +: 1'bx)) = (0,tslpq,0,0,0,tslpq);
if (!SD) (negedge SLP => (Q[5] +: 1'bx)) = (0,0,tqh,0,tqh,0);
if (!SD) (posedge SLP => (Q[6] +: 1'bx)) = (0,tslpq,0,0,0,tslpq);
if (!SD) (negedge SLP => (Q[6] +: 1'bx)) = (0,0,tqh,0,tqh,0);
if (!SD) (posedge SLP => (Q[7] +: 1'bx)) = (0,tslpq,0,0,0,tslpq);
if (!SD) (negedge SLP => (Q[7] +: 1'bx)) = (0,0,tqh,0,tqh,0);


  (posedge SD => (Q[0] +: 1'bx)) = (0,tsdq,0,0,0,tsdq);
  (negedge SD => (Q[0] +: 1'bx)) = (0,0,tqh,0,tqh,0);
  (posedge SD => (Q[1] +: 1'bx)) = (0,tsdq,0,0,0,tsdq);
  (negedge SD => (Q[1] +: 1'bx)) = (0,0,tqh,0,tqh,0);
  (posedge SD => (Q[2] +: 1'bx)) = (0,tsdq,0,0,0,tsdq);
  (negedge SD => (Q[2] +: 1'bx)) = (0,0,tqh,0,tqh,0);
  (posedge SD => (Q[3] +: 1'bx)) = (0,tsdq,0,0,0,tsdq);
  (negedge SD => (Q[3] +: 1'bx)) = (0,0,tqh,0,tqh,0);
  (posedge SD => (Q[4] +: 1'bx)) = (0,tsdq,0,0,0,tsdq);
  (negedge SD => (Q[4] +: 1'bx)) = (0,0,tqh,0,tqh,0);
  (posedge SD => (Q[5] +: 1'bx)) = (0,tsdq,0,0,0,tsdq);
  (negedge SD => (Q[5] +: 1'bx)) = (0,0,tqh,0,tqh,0);
  (posedge SD => (Q[6] +: 1'bx)) = (0,tsdq,0,0,0,tsdq);
  (negedge SD => (Q[6] +: 1'bx)) = (0,0,tqh,0,tqh,0);
  (posedge SD => (Q[7] +: 1'bx)) = (0,tsdq,0,0,0,tsdq);
  (negedge SD => (Q[7] +: 1'bx)) = (0,0,tqh,0,tqh,0);

 if (!SD & !SLP & !REB & !BIST)(posedge CLKR => (Q[0] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!SD & !SLP & !REBM & BIST)(posedge CLKR => (Q[0] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!SD & !SLP & !REB & !BIST)(posedge CLKR => (Q[1] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!SD & !SLP & !REBM & BIST)(posedge CLKR => (Q[1] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!SD & !SLP & !REB & !BIST)(posedge CLKR => (Q[2] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!SD & !SLP & !REBM & BIST)(posedge CLKR => (Q[2] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!SD & !SLP & !REB & !BIST)(posedge CLKR => (Q[3] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!SD & !SLP & !REBM & BIST)(posedge CLKR => (Q[3] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!SD & !SLP & !REB & !BIST)(posedge CLKR => (Q[4] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!SD & !SLP & !REBM & BIST)(posedge CLKR => (Q[4] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!SD & !SLP & !REB & !BIST)(posedge CLKR => (Q[5] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!SD & !SLP & !REBM & BIST)(posedge CLKR => (Q[5] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!SD & !SLP & !REB & !BIST)(posedge CLKR => (Q[6] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!SD & !SLP & !REBM & BIST)(posedge CLKR => (Q[6] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!SD & !SLP & !REB & !BIST)(posedge CLKR => (Q[7] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
 if (!SD & !SLP & !REBM & BIST)(posedge CLKR => (Q[7] : 1'bx)) = (tcd,tcd,thold,tcd,thold,tcd);
endspecify
`endif

initial
begin
  assign EN = 1;
  clk_count = 0;
  RDB = 1'b0;
  BWEBL =  {N{1'b1}};
  valid_contention = 0;
  tw_ff = 0;
  tr_ff = 0;
  rstb_toggle_flag = 1'b1;
end

`ifdef TSMC_INITIALIZE_MEM
initial
   begin 
`ifdef TSMC_INITIALIZE_FORMAT_BINARY
     #(INITIAL_MEM_DELAY)  $readmemb(cdeFileInit, MX.mem, 0, W-1);
`else
     #(INITIAL_MEM_DELAY)  $readmemh(cdeFileInit, MX.mem, 0, W-1);
`endif
   end
`endif //  `ifdef TSMC_INITIALIZE_MEM
   
`ifdef TSMC_INITIALIZE_FAULT
initial
   begin
`ifdef TSMC_INITIALIZE_FORMAT_BINARY
     #(INITIAL_FAULT_DELAY) $readmemb(cdeFileFault, MX.mem_fault, 0, W-1);
`else
     #(INITIAL_FAULT_DELAY) $readmemh(cdeFileFault, MX.mem_fault, 0, W-1);
`endif
   end
`endif //  `ifdef TSMC_INITIALIZE_FAULT

always @(posedge CLKR) CLKR_time = $realtime;
always @(posedge CLKW) CLKW_time = $realtime;

`ifdef TSMC_NO_TESTPINS_WARNING
`else
`endif


always @(bBIST) begin
   if (bBIST === 1'bx && bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0) begin
      if( MES_ALL=="ON" && $realtime != 0)
         $display("\nWarning %m BIST unknown, Core Unknown at %t. >>", $realtime);
      
      AAL <= {M{1'bx}};
      BWEBL <= {N{1'b0}};
      bQ = #0.01 {N{1'bx}};
   end
end

always @(bCLKW)
begin

    if (bCLKW === 1'bx && !bSLP && !bDSLP && !bSD && !clk_count) begin
        if( MES_ALL=="ON" && $realtime != 0) $display("\nWarning %m CLKW unknown at %t. >>", $realtime);
        
        AAL <= {M{1'bx}};
        BWEBL <= {N{1'b0}};
    end
    else if (bCLKW === 1'b1 && RCLKW === 1'b0 && bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && clk_count === 1'b0)
    begin
        if (!bBIST)
        begin                             // begin if (!bBIST)
            WEBL = bWEB;
            AAL = bAA;
            if (bWEB === 1'bx && !bBIST) begin
	            if( MES_ALL=="ON" && $realtime != 0) $display("\nWarning %m WEB unknown at %t. >>", $realtime);
	            
                //AAL <= {M{1'bx}};
                DL <= {N{1'bx}};
	            BWEBL <= {N{1'b0}};
            end
            if (^bAA === 1'bx && bWEB === 1'b0 && !bSLP && !bBIST && !bDSLP && !bSD && !clk_count) begin
	            if( MES_ALL=="ON" && $realtime != 0) $display("\nWarning %m WRITE AA unknown at %t. >>", $realtime);
	            
                AAL <= {M{1'bx}};
	            BWEBL <= {N{1'b0}};
            end
            else begin
                if (bWEB !== 1'b1 && bSLP === 1'b0 && bDSLP === 1'b0 && bSD === 1'b0 && clk_count === 1'b0) DL = bD;
                if (bWEB !== 1'b1 && bSLP === 1'b0 && bDSLP === 1'b0 && bSD === 1'b0 && clk_count === 1'b0) begin                         // begin if (bWEB !== 1'b1) 
                    bBWEBL = bBWEB;
	                if (^bBWEB === 1'bx) begin
                        if( MES_ALL=="ON" && $realtime != 0) $display("\nWarning %m BWEB unknown at %t. >>", $realtime);
	                end
                    for (i = 0; i < N; i = i + 1) 
                    begin                      // begin for...
                        if (!bBWEB[i] && !bWEB) BWEBL[i] = 1'b0;
                        if ((bWEB===1'bx) || (bBWEB[i] ===1'bx))
                        begin
                            BWEBL[i] = 1'b0; 
                            DL[i] = 1'bx;
                        end                     // end if (((...
                   end                        // end for (
                end
                if (bWEB !== 1'b1 && bSD !== 1'b0) begin
                    if( MES_ALL=="ON" && $realtime != 0)
                        $display ("\nWarning! In Shut Down Mode, %m:",
                        "\n\t Time %t, Core Unknown.", $realtime);
                    AAL <= {M{1'bx}};
                    BWEBL <= {N{1'b0}};
                end          
                else if (bWEB !== 1'b1 && bDSLP !== 1'b0) begin
                    if( MES_ALL=="ON" && $realtime != 0)
                        $display ("\nWarning! In Deep Sleep Mode, %m:",
                        "\n\t Time %t, Core Unknown.", $realtime);
                        AAL <= {M{1'bx}};
                        BWEBL <= {N{1'b0}};
                end
                else if (bWEB !== 1'b1 && bSLP !== 1'b0) begin
                    if( MES_ALL=="ON" && $realtime != 0)
                    $display ("\nWarning! In Sleep Mode, %m:",
                    "\n\t Time %t, Core Unknown.", $realtime);
                    AAL <= {M{1'bx}};
                    BWEBL <= {N{1'b0}};
                end
            end
        end

        if (bBIST)
        begin                             // begin if (!bBIST)
            WEBL = bWEBM;
            AAL = bAMA; 
            if (bWEBM === 1'bx && bBIST) begin
	            if( MES_ALL=="ON" && $realtime != 0) $display("\nWarning %m WEBM unknown at %t. >>", $realtime);
	            
                DL <= {N{1'bx}};
	            BWEBL <= {N{1'b0}};
            end
            if (^bAMA === 1'bx && bWEBM === 1'b0 && !bSLP && bBIST && !bDSLP && !bSD && !clk_count) begin
	            if( MES_ALL=="ON" && $realtime != 0) $display("\nWarning %m WRITE AMA unknown at %t. >>", $realtime);
	            
                AAL <= {M{1'bx}};
	            BWEBL <= {N{1'b0}};
             end
             else begin
                 if (bWEBM !== 1'b1 && bSLP === 1'b0 && bDSLP === 1'b0 && bSD === 1'b0 && clk_count === 1'b0) DL = bDM;
                 if (bWEBM !== 1'b1 && bSLP === 1'b0 && bDSLP === 1'b0 && bSD === 1'b0 && clk_count === 1'b0) begin                         // begin if (bWEBM !== 1'b1)
                     bBWEBL = bBWEBM;
                     if (^bBWEBM === 1'bx) begin
                         if( MES_ALL=="ON" && $realtime != 0) $display("\nWarning %m BWEBM unknown at %t. >>", $realtime);
	                 end

                     for (i = 0; i < N; i = i + 1) 
                     begin                      // begin for...   
                         if (rstb_toggle_flag == 1'b1 && !bBWEBM[i] && !bWEBM) BWEBL[i] = 1'b0;
                         if ((bWEBM===1'bx) || (bBWEBM[i] ===1'bx))
                         begin                   // if (((...
                             BWEBL[i] = 1'b0; 
                             DL[i] = 1'bx;   
                         end                     // end if (((...  
                     end                        // end for (   
                 end    
                 if (bWEBM !== 1'b1 && bSD !== 1'b0 ) begin
                     if( MES_ALL=="ON" && $realtime != 0)
                         $display ("\nWarning! In Shut Down Mode, %m:",
                         "\n\t Time %t, Core Unknown.", $realtime);
                     AAL <= {M{1'bx}};
                     BWEBL <= {N{1'b0}};
                 end
                 else if (bWEBM !== 1'b1 && bDSLP !== 1'b0 ) begin
                     if( MES_ALL=="ON" && $realtime != 0)
                         $display ("\nWarning! In Deep Sleep Mode, %m:",
                         "\n\t Time %t, Core Unknown.", $realtime);
                     AAL <= {M{1'bx}};
                     BWEBL <= {N{1'b0}};
                 end
                 else if (bWEBM !== 1'b1 && bSLP !== 1'b0 ) begin
                     if( MES_ALL=="ON" && $realtime != 0)
                         $display ("\nWarning! In Sleep Mode, %m:",
                         "\n\t Time %t, Core Unknown.", $realtime);
                     AAL <= {M{1'bx}};
                     BWEBL <= {N{1'b0}};
                 end
            end
        end
    end
    RCLKW = bCLKW;
end // always @ (bCLKW)


always @(bCLKR)
  begin
  
   if (bCLKR === 1'bx && !bSLP && !bDSLP && !bSD && !clk_count) begin
      if( MES_ALL=="ON" && $realtime != 0) $display("\nWarning %m CLKR unknown at %t.>>", $realtime);
      
      bQ = #0.01 {N{1'bx}};
   end
   else if (bCLKR === 1'b1 && RCLKR === 1'b0 && bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && clk_count === 1'b0)
   begin
      if (!bBIST) REBL = bREB;
      if (bREB === 1'bx && !bBIST) begin
           if( MES_ALL=="ON" && $realtime != 0)
              $display("\nWarning %m REB unknown at %t.>>", $realtime);
              bQ = #0.01 {N{1'bx}};
         end
      else if (^bAB === 1'bx && bREB === 1'b0 && !bBIST && !bSLP && !bDSLP && !bSD && !clk_count) begin
           if( MES_ALL=="ON" && $realtime != 0) $display("\nWarning %m READ AB unknown at %t. >>", $realtime);
	      
              bQ = #0.01 {N{1'bx}};
         end
      else begin
      if (!bBIST && bREB !== 1'b1 && bSD !== 1'b0) begin
         if( MES_ALL=="ON" && $realtime != 0)
            $display ("\nWarning! In Shut Down Mode, %m:",
                   "\n\t Time %t, outputs set to unknown.", $realtime);
         end
      else if (!bBIST && bREB !== 1'b1 && bDSLP !== 1'b0) begin
         if( MES_ALL=="ON" && $realtime != 0)
            $display ("\nWarning! In Deep Sleep Mode, %m:",
                   "\n\t Time %t, outputs set to unknown.", $realtime);
         end
      else if (!bBIST && bREB !== 1'b1 && bSLP !== 1'b0) begin
         if( MES_ALL=="ON" && $realtime != 0)
            $display ("\nWarning! In Sleep Mode, %m:",
                   "\n\t Time %t, outputs set to unknown.", $realtime);
         end


      if (rstb_toggle_flag == 1'b1 && !bBIST && !bREB && !bSLP && clk_count == 0 && !bDSLP && !bSD) begin
         ABL = bAB;
         RDB = ~RDB;
      end
      end //end else
      if (bBIST) REBL = bREBM;
      if (bREBM === 1'bx && bBIST) begin
           if( MES_ALL=="ON" && $realtime != 0)
              $display("\nWarning %m REBM unknown at %t.>>", $realtime);
              bQ = #0.01 {N{1'bx}};
         end
      else if (^bAMB === 1'bx && bREBM === 1'b0 && bBIST && !bSLP && !bDSLP && !bSD && !clk_count) begin
           if( MES_ALL=="ON" && $realtime != 0) $display("\nWarning %m READ AMB unknown at %t. >>", $realtime);
	      
              bQ = #0.01 {N{1'bx}};
         end
      else begin
      if (bBIST && bREBM !== 1'b1 && bSD !== 1'b0) begin
         if( MES_ALL=="ON" && $realtime != 0)
            $display ("\nWarning! In Shut Down Mode, %m:",
                   "\n\t Time %t, outputs set to unknown.", $realtime);
         end
      else if (bBIST && bREBM !== 1'b1 && bDSLP !== 1'b0) begin
         if( MES_ALL=="ON" && $realtime != 0)
            $display ("\nWarning! In Deep Sleep Mode, %m:",
                   "\n\t Time %t, outputs set to unknown.", $realtime);
         end
      else if (bBIST && bREBM !== 1'b1 && bSLP !== 1'b0) begin
         if( MES_ALL=="ON" && $realtime != 0)
            $display ("\nWarning! In Sleep Mode, %m:",
                   "\n\t Time %t, outputs set to unknown.", $realtime);
         end
            
      if (bBIST && !bREBM && !bSLP && clk_count == 0 && !bDSLP && !bSD) begin                             // begin if (!bBIST)
         ABL = bAMB;
         RDB = ~RDB;
      end
      end
   end
   RCLKR = bCLKR;
  end


always @(RDB or QL) 
begin
    if (!bSLP && clk_count == 0 && !bDSLP && !bSD)
    begin
`ifdef UNIT_DELAY
        #(SRAM_DELAY);
`else
        bQ = {N{1'bx}};
        #0.01;
`endif
        bQ = QL;

        if (AeqBL && !WEBL && !REBL && CLK_same) 
        begin
            if( MES_ALL=="ON" && $realtime != 0)
            $display("\nWarning %m READ/WRITE contention. If BWEB enables, Outputs set to unknown at %t. >>", $realtime);
            #0.01;
            for (i=0; i<N; i=i+1)
            begin
                if(!bBWEBL[i] || bBWEBL[i]===1'bx)
                begin
                    bQ[i] <= 1'bx;
                end
            end
        end // if (AeqBL && !WEBL && !REBL && CLK_same)

    end // if (!bSLP && clk_count == 0)
end // always @ (RDB or QL)

`ifndef NO_INPUT_FLOATING_CHECK
// input floating check for SLP ... in standby mode and SD mode
always @(negedge bSD) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && SLP === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input SLP high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
end

always @(posedge bSD) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && SLP === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input SLP high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
end

// input floating check for AA, AB, D, BWEB ... in standby mode
always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or AA[0] or AMA[0] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && AA[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[0] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && AMA[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[0] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end 
end

always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or AB[0] or AMB[0] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && AB[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[0] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && AMB[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[0] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end
always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or AA[1] or AMA[1] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && AA[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[1] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && AMA[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[1] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end 
end

always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or AB[1] or AMB[1] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && AB[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[1] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && AMB[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[1] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end
always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or AA[2] or AMA[2] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && AA[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[2] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && AMA[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[2] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end 
end

always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or AB[2] or AMB[2] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && AB[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[2] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && AMB[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[2] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end
always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or AA[3] or AMA[3] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && AA[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[3] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && AMA[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[3] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end 
end

always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or AB[3] or AMB[3] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && AB[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[3] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && AMB[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[3] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end
always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or AA[4] or AMA[4] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && AA[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[4] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && AMA[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[4] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end 
end

always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or AB[4] or AMB[4] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && AB[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[4] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && AMB[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[4] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end
always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or AA[5] or AMA[5] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && AA[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[5] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && AMA[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[5] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end 
end

always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or AB[5] or AMB[5] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && AB[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[5] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && AMB[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[5] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end

always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or BWEB[0] or BWEBM[0] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && BWEB[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[0] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin 
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && BWEBM[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[0] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end

always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or D[0] or DM[0] or bBIST) begin
if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && D[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[0] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && DM[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[0] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end
always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or BWEB[1] or BWEBM[1] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && BWEB[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[1] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin 
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && BWEBM[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[1] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end

always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or D[1] or DM[1] or bBIST) begin
if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && D[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[1] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && DM[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[1] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end
always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or BWEB[2] or BWEBM[2] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && BWEB[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[2] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin 
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && BWEBM[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[2] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end

always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or D[2] or DM[2] or bBIST) begin
if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && D[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[2] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && DM[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[2] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end
always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or BWEB[3] or BWEBM[3] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && BWEB[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[3] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin 
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && BWEBM[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[3] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end

always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or D[3] or DM[3] or bBIST) begin
if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && D[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[3] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && DM[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[3] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end
always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or BWEB[4] or BWEBM[4] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && BWEB[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[4] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin 
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && BWEBM[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[4] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end

always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or D[4] or DM[4] or bBIST) begin
if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && D[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[4] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && DM[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[4] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end
always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or BWEB[5] or BWEBM[5] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && BWEB[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[5] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin 
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && BWEBM[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[5] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end

always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or D[5] or DM[5] or bBIST) begin
if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && D[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[5] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && DM[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[5] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end
always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or BWEB[6] or BWEBM[6] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && BWEB[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[6] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin 
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && BWEBM[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[6] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end

always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or D[6] or DM[6] or bBIST) begin
if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && D[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[6] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && DM[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[6] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end
always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or BWEB[7] or BWEBM[7] or bBIST) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && BWEB[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[7] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin 
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && BWEBM[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[7] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end

always @(bSLP or bDSLP or bSD or bCLKR or bCLKW or bREB or bREBM or bWEB or bWEBM or D[7] or DM[7] or bBIST) begin
if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREB === 1'b1 && bWEB === 1'b1 && D[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[7] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bSLP === 1'b0 && (bCLKR === 1'b0 || bCLKR === 1'b1) && (bCLKW === 1'b0 || bCLKW === 1'b1) && bREBM === 1'b1 && bWEBM === 1'b1 && DM[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[7] high-Z during Standby Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  end
end


`endif

`ifndef NO_INPUT_FLOATING_CHECK
// input floating check for CLKR, CLKW, BWEB, D, AA, AB, BIST... in wake up
always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BIST === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BIST high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
end

always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && CLKR === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input CLKR high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
end

always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && CLKW === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input CLKW high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
end



always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AA[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[0] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AMA[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[0] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AB[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[0] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin  
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AMB[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[0] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end 
end  
always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AA[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[1] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AMA[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[1] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AB[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[1] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin  
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AMB[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[1] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end 
end  
always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AA[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[2] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AMA[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[2] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AB[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[2] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin  
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AMB[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[2] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end 
end  
always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AA[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[3] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AMA[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[3] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AB[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[3] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin  
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AMB[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[3] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end 
end  
always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AA[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[4] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AMA[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[4] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AB[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[4] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin  
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AMB[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[4] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end 
end  
always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AA[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[5] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AMA[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[5] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AB[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[5] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin  
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && AMB[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[5] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end 
end  


always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEB[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[0] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEBM[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[0] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && D[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[0] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && DM[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[0] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end
always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEB[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[1] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEBM[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[1] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && D[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[1] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && DM[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[1] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end
always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEB[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[2] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEBM[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[2] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && D[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[2] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && DM[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[2] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end
always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEB[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[3] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEBM[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[3] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && D[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[3] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && DM[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[3] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end
always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEB[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[4] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEBM[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[4] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && D[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[4] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && DM[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[4] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end
always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEB[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[5] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEBM[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[5] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && D[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[5] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && DM[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[5] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end
always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEB[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[6] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEBM[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[6] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && D[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[6] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && DM[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[6] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end
always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEB[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[7] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEBM[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[7] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(negedge bSLP or negedge bDSLP or negedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && D[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[7] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b0 && DM[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[7] high-Z during Wake Up Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end
`endif

`ifndef NO_INPUT_FLOATING_CHECK
// input floating check for CLKR, CLKW, BWEB, D, AA, AB, BIST ... in SLP, SD mode
always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BIST === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BIST high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BIST === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BIST high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BIST === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BIST high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
end

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && CLKR === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input CLKR high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && CLKR === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input CLKR high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && CLKR === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input CLKR high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
end

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && CLKW === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input CLKW high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && CLKW === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input CLKW high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && CLKW === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input CLKW high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
end




always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AA[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[0] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AA[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[0] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AA[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[0] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AMA[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[0] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AMA[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[0] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AMA[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[0] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AB[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[0] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AB[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[0] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AB[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[0] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin  
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AMB[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[0] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AMB[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[0] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AMB[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[0] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end 
end
always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AA[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[1] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AA[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[1] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AA[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[1] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AMA[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[1] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AMA[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[1] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AMA[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[1] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AB[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[1] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AB[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[1] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AB[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[1] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin  
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AMB[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[1] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AMB[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[1] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AMB[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[1] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end 
end
always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AA[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[2] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AA[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[2] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AA[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[2] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AMA[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[2] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AMA[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[2] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AMA[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[2] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AB[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[2] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AB[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[2] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AB[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[2] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin  
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AMB[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[2] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AMB[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[2] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AMB[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[2] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end 
end
always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AA[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[3] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AA[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[3] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AA[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[3] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AMA[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[3] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AMA[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[3] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AMA[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[3] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AB[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[3] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AB[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[3] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AB[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[3] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin  
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AMB[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[3] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AMB[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[3] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AMB[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[3] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end 
end
always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AA[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[4] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AA[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[4] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AA[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[4] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AMA[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[4] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AMA[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[4] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AMA[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[4] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AB[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[4] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AB[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[4] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AB[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[4] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin  
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AMB[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[4] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AMB[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[4] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AMB[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[4] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end 
end
always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AA[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[5] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AA[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[5] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AA[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AA[5] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AMA[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[5] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AMA[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[5] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AMA[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMA[5] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AB[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[5] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AB[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[5] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AB[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AB[5] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin  
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && AMB[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[5] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && AMB[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[5] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && AMB[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input AMB[5] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end 
end


always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEB[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[0] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BWEB[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[0] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BWEB[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[0] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEBM[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[0] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BWEBM[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[0] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BWEBM[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[0] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && D[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[0] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && D[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[0] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && D[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[0] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && DM[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[0] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && DM[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[0] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && DM[0] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[0] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end  
always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEB[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[1] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BWEB[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[1] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BWEB[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[1] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEBM[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[1] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BWEBM[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[1] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BWEBM[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[1] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && D[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[1] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && D[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[1] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && D[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[1] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && DM[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[1] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && DM[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[1] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && DM[1] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[1] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end  
always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEB[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[2] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BWEB[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[2] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BWEB[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[2] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEBM[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[2] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BWEBM[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[2] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BWEBM[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[2] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && D[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[2] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && D[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[2] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && D[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[2] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && DM[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[2] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && DM[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[2] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && DM[2] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[2] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end  
always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEB[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[3] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BWEB[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[3] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BWEB[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[3] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEBM[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[3] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BWEBM[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[3] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BWEBM[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[3] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && D[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[3] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && D[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[3] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && D[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[3] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && DM[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[3] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && DM[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[3] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && DM[3] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[3] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end  
always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEB[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[4] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BWEB[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[4] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BWEB[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[4] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEBM[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[4] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BWEBM[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[4] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BWEBM[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[4] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && D[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[4] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && D[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[4] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && D[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[4] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && DM[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[4] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && DM[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[4] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && DM[4] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[4] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end  
always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEB[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[5] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BWEB[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[5] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BWEB[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[5] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEBM[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[5] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BWEBM[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[5] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BWEBM[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[5] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && D[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[5] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && D[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[5] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && D[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[5] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && DM[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[5] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && DM[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[5] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && DM[5] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[5] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end  
always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEB[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[6] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BWEB[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[6] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BWEB[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[6] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEBM[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[6] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BWEBM[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[6] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BWEBM[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[6] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && D[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[6] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && D[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[6] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && D[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[6] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && DM[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[6] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && DM[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[6] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && DM[6] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[6] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end  
always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEB[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[7] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BWEB[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[7] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BWEB[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEB[7] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && BWEBM[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[7] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && BWEBM[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[7] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && BWEBM[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input BWEBM[7] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
  if(bBIST === 1'b0 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && D[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[7] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && D[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[7] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && D[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input D[7] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
  else if(bBIST === 1'b1 || BIST === 1'bz) begin
  if (bSD === 1'b1 && bDSLP === 1'b0 && bSLP === 1'b0 && DM[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[7] high-Z during Shut Down Mode, Core Unknown at %t.>>", $realtime);
    end
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
      DL = {N{1'bx}};
`ifdef UNIT_DELAY
      #(SRAM_DELAY);
`endif
      bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b1 && bSLP === 1'b0 && DM[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[7] high-Z during DSLP Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  else if (bSD === 1'b0 && bDSLP === 1'b0 && bSLP === 1'b1 && DM[7] === 1'bz) begin
    if(MES_ALL=="ON" && $realtime != 0) 
    begin
      $display("\nWarning %m input DM[7] high-Z during Power Down Mode, Core Unknown at %t.>>", $realtime);
    end
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    DL = {N{1'bx}};
`ifdef UNIT_DELAY
    #(SRAM_DELAY);
`endif
    bQ = {N{1'bx}};
  end
  end
end  
`endif

always @(posedge bSLP or posedge bDSLP or posedge bSD) begin
    if ((bSD === 1'b1 && clk_count == 0 && (iREB !== 1'b1 || iWEB !== 1'b1))) begin
        if (MES_ALL=="ON" && $realtime != 0)
            $display("\nWarning %m Invalid Shut Down Mode Sequence, Core Unknown at %t. >>", $realtime);
        AAL = {M{1'bx}};
        BWEBL = {N{1'b0}};
        DL = {N{1'bx}};
`ifdef UNIT_DELAY
        #(SRAM_DELAY);
`endif
        bQ = {N{1'bx}};
    end
    else if ((bDSLP === 1'b1 && clk_count == 0 && (iREB !== 1'b1 || iWEB !== 1'b1))) begin
        if (MES_ALL=="ON" && $realtime != 0)
            $display("\nWarning %m Invalid Deep Sleep Mode Sequence, Core Unknown at %t. >>", $realtime);
        AAL = {M{1'bx}};
        BWEBL = {N{1'b0}};
        DL = {N{1'bx}};
`ifdef UNIT_DELAY
          #(SRAM_DELAY);
`endif
        bQ = {N{1'bx}};
    end
    else if ((bSLP === 1'b1 && clk_count == 0 && (iREB !== 1'b1 || iWEB !== 1'b1)))begin
        if (MES_ALL=="ON" && $realtime != 0)
            $display("\nWarning %m Invalid Sleep Mode Sequence, Core Unknown at %t. >>", $realtime);
        AAL = {M{1'bx}};
        BWEBL = {N{1'b0}};
        DL = {N{1'bx}};
`ifdef UNIT_DELAY
        #(SRAM_DELAY);
`endif
        bQ = {N{1'bx}};
    end
end


always @(bSLP or bDSLP or bSD) begin
       if (bBIST !== 1'bx) begin
       if (((bSD === 1'b1) && (iREB === 1'b1 && iWEB === 1'b1) && clk_count == 0) || (bSD === 1'b1 && clk_count == 1)) begin
         clk_count = 1;
`ifdef UNIT_DELAY
         #(SRAM_DELAY);
`else
         bQ = {N{1'bx}};
         #0.01;
`endif
	     AAL = {M{1'bx}};
         BWEBL = {N{1'b0}};
         DL = {N{1'bx}};
 
         bQ = {N{1'b0}};
       end
       else if (((bSLP === 1'b1 || bDSLP === 1'b1) && bSD === 1'b0) && (iREB === 1'b1 && iWEB === 1'b1) && clk_count === 0) begin
         clk_count = 1;
`ifdef UNIT_DELAY
         #(SRAM_DELAY);
`else
         bQ = {N{1'bx}};
         #0.01;
`endif 
         bQ = {N{1'b0}};
       end
       else if (((bSLP === 1'b0 && bDSLP === 1'b0 && bSD === 1'b0) && (iREB !== 1'b1 || iWEB !== 1'b1)) || ((bSLP === 1'b0 && bDSLP === 1'b0 && bSD === 1'b0) && clk_count !== 1)) begin
        if( MES_ALL=="ON" && $realtime != 0) $display("\nWarning %m Invalid Wake Up Sequence, Core Unknown at %t.>>", $realtime);
        
        AAL <= {M{1'bx}};
        BWEBL <= {N{1'b0}};
        bQ = #0.01 {N{1'bx}};
        clk_count = 0;
       end
       else if ((bSLP === 1'b0 && bDSLP === 1'b0 && bSD === 1'b0) && (iREB === 1'b1 && iWEB === 1'b1) && clk_count ===1) begin
         bQ = {N{1'bx}};
         //#0.001;
         clk_count = 0;
       end
       
       end

    if (bSD === 1'bx ) begin
        if (MES_ALL=="ON" && $realtime != 0)
            $display("\nWarning %m SD unknown, Core Unknown at %t. >>", $realtime);
        AAL = {M{1'bx}};
        BWEBL = {N{1'b0}};
        DL = {N{1'bx}};
`ifdef UNIT_DELAY
        #(SRAM_DELAY);
`endif
        bQ = {N{1'bx}};
    end
    else if ((bDSLP === 1'bx && !bSD)) begin
        if (MES_ALL=="ON" && $realtime != 0)
            $display("\nWarning %m DSLP unknown, Core Unknown at %t. >>", $realtime);
        AAL = {M{1'bx}};
        BWEBL = {N{1'b0}};
        DL = {N{1'bx}};
`ifdef UNIT_DELAY
        #(SRAM_DELAY);
`endif
        bQ = {N{1'bx}};
    end  
    else if ((bSLP === 1'bx && !bSD && !bDSLP ))begin
         if (MES_ALL=="ON" && $realtime != 0)
             $display("\nWarning %m SLP unknown, Core Unknown at %t. >>", $realtime);
         AAL = {M{1'bx}};
         BWEBL = {N{1'b0}};
         DL = {N{1'bx}};
`ifdef UNIT_DELAY
         #(SRAM_DELAY);
`endif
         bQ = {N{1'bx}};
    end
end //always


always @(BWEBL) BWEBL = #0.01 {N{1'b1}};


 
always @(posedge AeqBL) begin
   if (!WEBL && !REBL && CLK_same && AeqBL) 
     begin
        if( MES_ALL=="ON" && $realtime != 0)
	    $display("\nWarning %m READ/WRITE contention. If BWEB enables, outputs set to unknown at %t. >>", $realtime);

        #0.01;
	    for (i=0; i<N; i=i+1)
	    begin
           if(!bBWEBL[i] || bBWEBL[i]===1'bx)
           begin
              bQ[i] <= 1'bx;
	       end
	    end
     end // if (!WEBL && !REBL && CLK_same)
end // always @ (posedge AeqBL)
`ifdef UNIT_DELAY
`else
always @(valid_bist)
   begin
    AAL = {M{1'bx}};
    BWEBL = {N{1'b0}};
    bQ = #0.01 {N{1'bx}};
end
always @(valid_aa)
   begin
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
   end

always @(valid_ab)
   begin
      
      bQ = #0.01 {N{1'bx}};
   end

always @(valid_contention)
   begin
    #0.01;
	for (i=0; i<N; i=i+1)
	  begin
	     if(!iBWEB[i] || !BWEBL[i] || (iBWEB[i]===1'bx) || (BWEBL[i]===1'bx))
	       bQ[i] = 1'bx;
         end
   end

always @(valid_ckr)
   begin
      
      bQ = #0.01 {N{1'bx}};
   end
 
always @(valid_ckw)
   begin
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
   end

always @(valid_d0)
   begin
      
      DL[0] = 1'bx;
      BWEBL[0] = 1'b0;
   end

always @(valid_bw0)
   begin
      
      DL[0] = 1'bx;
      BWEBL[0] = 1'b0;
   end

always @(valid_d1)
   begin
      
      DL[1] = 1'bx;
      BWEBL[1] = 1'b0;
   end

always @(valid_bw1)
   begin
      
      DL[1] = 1'bx;
      BWEBL[1] = 1'b0;
   end

always @(valid_d2)
   begin
      
      DL[2] = 1'bx;
      BWEBL[2] = 1'b0;
   end

always @(valid_bw2)
   begin
      
      DL[2] = 1'bx;
      BWEBL[2] = 1'b0;
   end

always @(valid_d3)
   begin
      
      DL[3] = 1'bx;
      BWEBL[3] = 1'b0;
   end

always @(valid_bw3)
   begin
      
      DL[3] = 1'bx;
      BWEBL[3] = 1'b0;
   end

always @(valid_d4)
   begin
      
      DL[4] = 1'bx;
      BWEBL[4] = 1'b0;
   end

always @(valid_bw4)
   begin
      
      DL[4] = 1'bx;
      BWEBL[4] = 1'b0;
   end

always @(valid_d5)
   begin
      
      DL[5] = 1'bx;
      BWEBL[5] = 1'b0;
   end

always @(valid_bw5)
   begin
      
      DL[5] = 1'bx;
      BWEBL[5] = 1'b0;
   end

always @(valid_d6)
   begin
      
      DL[6] = 1'bx;
      BWEBL[6] = 1'b0;
   end

always @(valid_bw6)
   begin
      
      DL[6] = 1'bx;
      BWEBL[6] = 1'b0;
   end

always @(valid_d7)
   begin
      
      DL[7] = 1'bx;
      BWEBL[7] = 1'b0;
   end

always @(valid_bw7)
   begin
      
      DL[7] = 1'bx;
      BWEBL[7] = 1'b0;
   end

 
always @(valid_wea)
   begin
      AAL = {M{1'bx}};
      BWEBL = {N{1'b0}};
   end
 
always @(valid_reb)
   begin
      
      bQ = #0.01 {N{1'bx}};
   end
`endif


always @(valid_pd) begin
  
  AAL <= {M{1'bx}};
  BWEBL <= {N{1'b0}};
  bQ = #0.01 {N{1'bx}};
end

// Task for printing the memory between specified addresses..
task printMemoryFromTo;     
    input [M - 1:0] from;   // memory content are printed, start from this address.
    input [M - 1:0] to;     // memory content are printed, end at this address.
    begin 
        MX.printMemoryFromTo(from, to);
    end 
endtask

// Task for printing entire memory, including normal array and redundancy array.
task printMemory;   
    begin
        MX.printMemory;
    end
endtask

task xMemoryAll;   
    begin
       MX.xMemoryAll;  
    end
endtask

task zeroMemoryAll;   
    begin
       MX.zeroMemoryAll;   
    end
endtask

// Task for Loading a perdefined set of data from an external file.
task preloadData;   
    input [256*8:1] infile;  // Max 256 character File Name
    begin
        MX.preloadData(infile);  
    end
endtask

TS6N28HPCPHVTA64X8M4FWBSO_Int_Array #(1,1,W,N,M,MES_ALL) MX (.D({DL}),.BW({BWEBL}),
         .AW({AAL}),.EN(EN),.RDB(RDB),.AR({ABL}),.Q({QL}));



endmodule

`disable_portfaults
`nosuppress_faults
`endcelldefine

/*
   The module ports are parameterizable vectors.
*/
module TS6N28HPCPHVTA64X8M4FWBSO_Int_Array (D, BW, AW, EN, RDB, AR, Q);
parameter Nread = 2;   // Number of Read Ports
parameter Nwrite = 2;  // Number of Write Ports
parameter Nword = 2;   // Number of Words
parameter Ndata = 1;   // Number of Data Bits / Word
parameter Naddr = 1;   // Number of Address Bits / Word
parameter MES_ALL = "ON";
parameter dly = 0.000;
// Cannot define inputs/outputs as memories
input  [Ndata*Nwrite-1:0] D;  // Data Word(s)
input  [Ndata*Nwrite-1:0] BW; // Negative Bit Write Enable
input  [Naddr*Nwrite-1:0] AW; // Write Address(es)
input  EN;                    // Positive Write Enable
input  RDB;                   // Read Toggle
input  [Naddr*Nread-1:0] AR;  // Read Address(es)
output [Ndata*Nread-1:0] Q;   // Output Data Word(s)
reg    [Ndata*Nread-1:0] Q;
reg [Ndata-1:0] mem [Nword-1:0];
reg [Ndata-1:0] mem_fault [Nword-1:0];
reg chgmem;            // Toggled when write to mem
reg [Nwrite-1:0] wwe;  // Positive Word Write Enable for each Port
reg we;                // Positive Write Enable for all Ports
integer waddr[Nwrite-1:0]; // Write Address for each Enabled Port
integer address;       // Current address
reg [Naddr-1:0] abuf;  // Address of current port
reg [Ndata-1:0] dbuf;  // Data for current port
reg [Ndata-1:0] bwbuf; // Bit Write enable for current port
reg dup;               // Is the address a duplicate?
integer log;           // Log file descriptor
integer ip, ip2, ip_r, ib, ib_r, iw, iw_r, iwb; // Vector indices


initial
   begin
   $timeformat (-9, 2, " ns", 9);
   if (log[0] === 1'bx)
      log = 1;
   chgmem = 1'b0;
   end


always @(D or BW or AW or EN)
   begin: WRITE //{
   if (EN !== 1'b0)
      begin //{ Possible write
      we = 1'b0;
      // Mark any write enabled ports & get write addresses
      for (ip = 0 ; ip < Nwrite ; ip = ip + 1)
         begin //{
         ib = ip * Ndata;
         iw = ib + Ndata;
         while (ib < iw && BW[ib] === 1'b1)
            ib = ib + 1;
         if (ib == iw)
            wwe[ip] = 1'b0;
         else
            begin //{ ip write enabled
            iw = ip * Naddr;
            for (ib = 0 ; ib < Naddr ; ib = ib + 1)
               begin //{
               abuf[ib] = AW[iw+ib];
               if (abuf[ib] !== 1'b0 && abuf[ib] !== 1'b1)
                  ib = Naddr;
               end //}
            if (ib == Naddr)
               begin //{
               if (abuf < Nword)
                  begin //{ Valid address
                  waddr[ip] = abuf;
                  wwe[ip] = 1'b1;
                  if (we == 1'b0)
                     begin
                     chgmem = ~chgmem;
                     we = EN;
                     end
                  end //}
               else
                  begin //{ Out of range address
                  wwe[ip] = 1'b0;
                  if( MES_ALL=="ON" && $realtime != 0)
                       $fdisplay (log,
                             "\nWarning! Int_Array instance, %m:",
                             "\n\t Port %0d", ip,
                             " write address x'%0h'", abuf,
                             " out of range at time %t.", $realtime,
                             "\n\t Port %0d data not written to memory.", ip);
                  end //}
               end //}
            else
               begin //{ unknown write address

               for (ib = 0 ; ib < Ndata ; ib = ib + 1)
                  dbuf[ib] = 1'bx;
               for (iw = 0 ; iw < Nword ; iw = iw + 1)
                  mem[iw] = dbuf;
               chgmem = ~chgmem;
               disable WRITE;
               end //}
            end //} ip write enabled
         end //} for ip
      if (we === 1'b1)
         begin //{ active write enable
         for (ip = 0 ; ip < Nwrite ; ip = ip + 1)
            begin //{
            if (wwe[ip])
               begin //{ write enabled bits of write port ip
               address = waddr[ip];
               dbuf = mem[address];
               iw = ip * Ndata;
               for (ib = 0 ; ib < Ndata ; ib = ib + 1)
                  begin //{
                  iwb = iw + ib;
                  if (BW[iwb] === 1'b0)
                     dbuf[ib] = D[iwb];
                  else if (BW[iwb] !== 1'b1)
                     dbuf[ib] = 1'bx;
                  end //}
               // Check other ports for same address &
               // common write enable bits active
               dup = 0;
               for (ip2 = ip + 1 ; ip2 < Nwrite ; ip2 = ip2 + 1)
                  begin //{
                  if (wwe[ip2] && address == waddr[ip2])
                     begin //{
                     // initialize bwbuf if first dup
                     if (!dup)
                        begin
                        for (ib = 0 ; ib < Ndata ; ib = ib + 1)
                           bwbuf[ib] = BW[iw+ib];
                        dup = 1;
                        end
                     iw = ip2 * Ndata;
                     for (ib = 0 ; ib < Ndata ; ib = ib + 1)
                        begin //{
                        iwb = iw + ib;
                        // New: Always set X if BW X
                        if (BW[iwb] === 1'b0)
                           begin //{
                           if (bwbuf[ib] !== 1'b1)
                              begin
                              if (D[iwb] !== dbuf[ib])
                                 dbuf[ib] = 1'bx;
                              end
                           else
                              begin
                              dbuf[ib] = D[iwb];
                              bwbuf[ib] = 1'b0;
                              end
                           end //}
                        else if (BW[iwb] !== 1'b1)
                           begin
                           dbuf[ib] = 1'bx;
                           bwbuf[ib] = 1'bx;
                           end
                        end //} for each bit
                        wwe[ip2] = 1'b0;
                     end //} Port ip2 address matches port ip
                  end //} for each port beyond ip (ip2=ip+1)
               // Write dbuf to memory
               mem[address] = dbuf;
               end //} wwe[ip] - write port ip enabled
            end //} for each write port ip
         end //} active write enable
      else if (we !== 1'b0)
         begin //{ unknown write enable
         for (ip = 0 ; ip < Nwrite ; ip = ip + 1)
            begin //{
            if (wwe[ip])
               begin //{ write X to enabled bits of write port ip
               address = waddr[ip];
               dbuf = mem[address];
               iw = ip * Ndata;
               for (ib = 0 ; ib < Ndata ; ib = ib + 1)
                  begin //{ 
                 if (BW[iw+ib] !== 1'b1)
                     dbuf[ib] = 1'bx;
                  end //} 
               mem[address] = dbuf;
               if( MES_ALL=="ON" && $realtime != 0)
                    $fdisplay (log,
                          "\nWarning! Int_Array instance, %m:",
                          "\n\t Enable pin unknown at time %t.", $realtime,
                          "\n\t Enabled bits at port %0d", ip,
                          " write address x'%0h' set unknown.", address);
               end //} wwe[ip] - write port ip enabled
            end //} for each write port ip
         end //} unknown write enable
      end //} possible write (EN != 0)
   end //} always @(D or BW or AW or EN)


// Read memory
always @(RDB or AR)
   begin //{
   for (ip_r = 0 ; ip_r < Nread ; ip_r = ip_r + 1)
      begin //{
      iw_r = ip_r * Naddr;
      for (ib_r = 0 ; ib_r < Naddr ; ib_r = ib_r + 1)
         begin
         abuf[ib_r] = AR[iw_r+ib_r];
         if (abuf[ib_r] !== 0 && abuf[ib_r] !== 1)
            ib_r = Naddr;
         end
      iw_r = ip_r * Ndata;
      if (ib_r == Naddr && abuf < Nword)
         begin //{ Read valid address
`ifdef TSMC_INITIALIZE_FAULT
         dbuf = mem[abuf]  ^ mem_fault[abuf];
`else
         dbuf = mem[abuf];
`endif
         for (ib_r = 0 ; ib_r < Ndata ; ib_r = ib_r + 1)
            begin
            if (Q[iw_r+ib_r] == dbuf[ib_r])
                Q[iw_r+ib_r] <= #(dly) dbuf[ib_r];
            else
                begin
                Q[iw_r+ib_r] <= #(dly) dbuf[ib_r];
//                Q[iw_r+ib_r] <= dbuf[ib_r];
                end // else
            end // for
         end //} valid address
      else
         begin //{ Invalid address
         if( MES_ALL=="ON" && $realtime != 0)
               $fwrite (log, "\nWarning! Int_Array instance, %m:",
                       "\n\t Port %0d read address", ip_r);
         if (ib_r > Naddr)
         begin
         if( MES_ALL=="ON" && $realtime != 0)
            $fwrite (log, " unknown");
         end
         else
         begin
         if( MES_ALL=="ON" && $realtime != 0)
            $fwrite (log, " x'%0h' out of range", abuf);
         end
         if( MES_ALL=="ON" && $realtime != 0)
            $fdisplay (log,
                    " at time %t.", $realtime,
                    "\n\t Port %0d outputs set to unknown.", ip_r);
         for (ib_r = 0 ; ib_r < Ndata ; ib_r = ib_r + 1)
            Q[iw_r+ib_r] <= #(dly) 1'bx;
         end //} invalid address
      end //} for each read port ip_r
   end //} always @(chgmem or AR)

// Task for printing the memory between specified addresses..
task printMemoryFromTo;     
    input [Naddr - 1:0] from;   // memory content are printed, start from this address.
    input [Naddr - 1:0] to;     // memory content are printed, end at this address.
    integer i;
    begin 
        $display ("Dumping register file...");
        $display("@    Address, content-----");
        for (i = from; i <= to; i = i + 1) begin
            $display("@%d, %b", i, mem[i]);
        end 
    end
endtask

// Task for printing entire memory, including normal array and redundancy array.
task printMemory;   
    integer i;
    begin
        $display ("Dumping register file...");
        $display("@    Address, content-----");
        for (i = 0; i < Nword; i = i + 1) begin
            $display("@%d, %b", i, mem[i]);
        end 
    end
endtask

task xMemoryAll;   
    begin
       for (ib = 0 ; ib < Ndata ; ib = ib + 1)
          dbuf[ib] = 1'bx;
       for (iw = 0 ; iw < Nword ; iw = iw + 1)
          mem[iw] = dbuf; 
    end
endtask

task zeroMemoryAll;   
    begin
       for (ib = 0 ; ib < Ndata ; ib = ib + 1)
          dbuf[ib] = 1'b0;
       for (iw = 0 ; iw < Nword ; iw = iw + 1)
          mem[iw] = dbuf; 
    end
endtask

// Task for Loading a perdefined set of data from an external file.
task preloadData;   
    input [256*8:1] infile;  // Max 256 character File Name
    begin
        $display ("%m: Reading file, %0s, into the register file", infile);
`ifdef TSMC_INITIALIZE_FORMAT_BINARY
        $readmemb (infile, mem, 0, Nword-1);
`else
        $readmemh (infile, mem, 0, Nword-1);
`endif
    end
endtask

endmodule




