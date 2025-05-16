// File: verification/env/test.sv
`timescale 1ns/1ps
import trans_pkg::*;

module test;
  initial begin
	// e.g. override data constraint:
	// trans_item::c_data = { data[0]==16'hFF, foreach(data[i]) if (i!=0) data[i]==i };
	$display("TEST: custom constraints can go here");
  end
endmodule : test
