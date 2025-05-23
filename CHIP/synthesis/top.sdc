# remove any constraints that were applied from previous runs:
#remove_sdc -design

# Set the physical library:

#set_current_design TOP

# Create clock object and set uncertainty
create_clock -period 1 [get_ports clk_in]
set_clock_uncertainty -setup 0.15 [get_clocks clk_in]
#set_case_analysis 0 [get_port rst_mem]
#set_case_analysis 0 [get_port mul_mem_en]
#set_case_analysis 0 [get_port ac_mem_en]
# Set constraints on input ports
#suppress_message UID-401
#suppress_message DCT-306

#set_input_delay 0.2 -max -clock clk_in  [all_inputs]
set_input_delay -max 0.2 -clock clk_in [remove_from_collection [all_inputs] [get_ports clk_in]]


#Set constraints on output ports:
set_output_delay 0.2 -max -clock clk_in [all_outputs] 	 

#set_load -max [expr [load_of $lib_name/AND2X1_HVT/A1] * 15] [all_outputs]

set_clock_transition -max 0.2 [get_clocks clk_in]

