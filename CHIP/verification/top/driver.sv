// File: verification/driver.sv
`timescale 1ns/1ps
import trans_pkg::*;

module driver (
  tb_if.TB vif,
  output logic [15:0] bus_drv,
  output logic        bus_drv_en
);

  parameter int CLK_PERIOD = 10;

  // Example test vector array (64 image+weight, 2 threshold chunks)
  trans_t tv[0:65];

  initial begin
	// Init control signals
	vif.wr_en      = 0;
	vif.rd_en      = 0;
	vif.chip_sel   = 0;
	bus_drv_en     = 0;
	bus_drv        = '0;

	// Generate example vectors
	foreach (tv[i]) begin
	  if (i < 64) begin
		tv[i].pixel        = $urandom_range(0, 255);
		tv[i].weight       = $urandom_range(0, 255);
		tv[i].is_threshold = 0;
	  end else begin
		tv[i].is_threshold = 1;
		tv[i].threshold    = 22'd1000;
	  end
	end

	// Start stimulus after one clock
	@(posedge vif.clk);
	vif.chip_sel <= 1;
	@(posedge vif.clk);

	// Send pixel-weight pairs and threshold
	for (int i = 0; i < $size(tv); i++) begin
	  vif.wr_en   <= 1;
	  bus_drv_en  <= 1;

	  if (!tv[i].is_threshold) begin
		bus_drv <= {tv[i].weight, tv[i].pixel};
		drv_mbx.put(tv[i]);
		@(posedge vif.clk);
	  end else begin
		// Lower 16 bits first
		bus_drv <= tv[i].threshold[15:0];
		drv_mbx.put(tv[i]);
		@(posedge vif.clk);

		// Upper 6 bits in LSB, zero-padded to 16 bits
		bus_drv <= {10'b0, tv[i].threshold[21:16]};
		@(posedge vif.clk);
	  end

	  // Tri-state off
	  bus_drv_en <= 0;
	  vif.wr_en  <= 0;
	  bus_drv    <= 16'hzzzz;
	  @(posedge vif.clk);
	end

	// Wait for result to be ready
	wait (vif.output_ready);

	// Trigger read of MAC result
	vif.rd_en <= 1;
	@(posedge vif.clk);
	@(posedge vif.clk);
	vif.rd_en <= 0;
  end

endmodule : driver
