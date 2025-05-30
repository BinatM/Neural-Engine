module control_unit (
    input  wire       clk,       // system clock
    input  wire       reset_n,   // active-low reset
    input  wire       start,     // start pulse from reset_and_start
	 input  wire       val_done,  // idicates one test is done
	 input  wire       stop_tests,
    output reg        start_run  // one-cycle pulse to test_generator
);

    // state encoding
    typedef enum logic [0:0] {
        ST_IDLE  = 1'd0,  // waiting for start
        ST_START = 1'd1  // issue start_run pulse
    } state_t;

    state_t current_state, next_state;

    // state register
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            current_state <= ST_IDLE;
        else
            current_state <= next_state;
    end

    // next-state logic and start_run output
    always_comb begin
        start_run   = 1'b0;
        next_state  = current_state;

        case (current_state)
            ST_IDLE: begin
				  // if initial start or post-validation, trigger start_run
                if (start||val_done)
					     if (!stop_tests)
								next_state = ST_START;
						  else if 
								next_state = ST_IDLE;
						  
            end

            ST_START: begin
                // pulse start_run for one cycle
                start_run  = 1'b1;
                next_state = ST_IDLE;
            end

        endcase
    end


endmodule
