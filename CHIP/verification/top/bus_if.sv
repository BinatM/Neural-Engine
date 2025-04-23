interface bus_if (
	input  logic clk,
	input  logic chip_sel,
	output logic wr_en,
	output logic rd_en,
	inout  logic [15:0] bus
  );
	logic [5:0] wr_ptr, rd_ptr;
	logic       threshold_ready, output_ready;
	logic       output_bit;

	// connect internal DUT signals
	modport DUT    ( input clk, chip_sel, wr_en, rd_en, bus,
					 output wr_ptr, rd_ptr, threshold_ready, output_ready, output_bit );
	modport DRIVER ( input clk, chip_sel, output wr_en, wr_ptr, bus );
	modport MONITOR( input clk, chip_sel, wr_en, wr_ptr, rd_ptr,
					 input threshold_ready, output_ready, output_bit );
  endinterface
