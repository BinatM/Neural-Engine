#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
#create_clock -period "10.0 MHz" [get_ports ADC_CLK_10]
create_clock -period "50.0 MHz" [get_ports MAX10_CLK1_50]
#create_clock -period "50.0 MHz" [get_ports MAX10_CLK2_50]
# -------------------------------------------------
#  Generated clocks
# -------------------------------------------------
# 50 MHz SDRAM clock is just the base clock copied out
create_clock -name sdram_clk -period 20.000 [get_ports DRAM_CLK]
#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************

# Data coming **into** the FPGA one half-cycle after the clock
set_input_delay  -clock [get_clocks sdram_clk] 7.0 \
                 [get_ports {DRAM_DQ[*]}]


#**************************************************************
# Set Output Delay
#**************************************************************
# Data/addr/cmd **leaving** the FPGA one quarter-cycle before the clock edge
set_output_delay -clock [get_clocks sdram_clk] 3.0 \
                 [get_ports {DRAM_DQ[*]          \
                              DRAM_ADDR[*]      \
                              DRAM_BA[*]        \
                              DRAM_CAS_N        \
                              DRAM_RAS_N        \
                              DRAM_WE_N         \
                              DRAM_CS_N         \
                              DRAM_CKE}]


set_output_delay -clock [get_clocks sys_clk] 18.0 \
                 [get_ports {LEDR[*]}]
set_output_delay -clock sdram_clk -max 3.0  [get_ports {DRAM_DQ[*]}]
set_output_delay -clock sdram_clk -min -1.0 [get_ports {DRAM_DQ[*]}]

#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from [get_ports KEY_0]
set_false_path -from [get_ports KEY_1]
set_false_path -from [get_ports MAX10_CLK1_50]
set_false_path -from [get_ports {altera_reserved_*}]
set_false_path -to [get_ports {LEDR[1]}]
set_false_path -to [get_ports {LEDR[2]}]
set_false_path -to [get_ports {LEDR[9]}]
set_false_path -to [get_ports {altera_reserved_tdo}]
set_false_path -to [get_ports {GPIO_[0]}]
set_false_path -to [get_ports {GPIO_[1]}]
set_false_path -to [get_ports {GPIO_[2]}]
set_false_path -to [get_ports {GPIO_[3]}]
set_false_path -to [get_ports {GPIO_[4]}]
set_false_path -to [get_ports {GPIO_[5]}]
set_false_path -to [get_ports {GPIO_[6]}]
set_false_path -to [get_ports {GPIO_[7]}]
set_false_path -to [get_ports {GPIO_[8]}]
set_false_path -to [get_ports {HEX0[0]}]
set_false_path -to [get_ports {HEX0[1]}]
set_false_path -to [get_ports {HEX0[2]}]
set_false_path -to [get_ports {HEX0[3]}]
set_false_path -to [get_ports {HEX0[4]}]
set_false_path -to [get_ports {HEX0[5]}]
set_false_path -to [get_ports {HEX0[6]}]
set_false_path -to [get_ports {HEX1[0]}]
set_false_path -to [get_ports {HEX1[1]}]
set_false_path -to [get_ports {HEX1[2]}]
set_false_path -to [get_ports {HEX1[3]}]
set_false_path -to [get_ports {HEX1[4]}]
set_false_path -to [get_ports {HEX1[5]}]
set_false_path -to [get_ports {HEX1[6]}]
set_false_path -to [get_ports {HEX2[0]}]
set_false_path -to [get_ports {HEX2[1]}]
set_false_path -to [get_ports {HEX2[2]}]
set_false_path -to [get_ports {HEX2[3]}]
set_false_path -to [get_ports {HEX2[4]}]
set_false_path -to [get_ports {HEX2[5]}]
set_false_path -to [get_ports {HEX2[6]}]
set_false_path -to [get_ports {HEX3[0]}]
set_false_path -to [get_ports {HEX3[1]}]
set_false_path -to [get_ports {HEX3[2]}]
set_false_path -to [get_ports {HEX3[3]}]
set_false_path -to [get_ports {HEX3[4]}]
set_false_path -to [get_ports {HEX3[5]}]
set_false_path -to [get_ports {HEX3[6]}]
set_false_path -to [get_ports {HEX4[0]}]
set_false_path -to [get_ports {HEX4[1]}]
set_false_path -to [get_ports {HEX4[2]}]
set_false_path -to [get_ports {HEX4[3]}]
set_false_path -to [get_ports {HEX4[4]}]
set_false_path -to [get_ports {HEX4[5]}]
set_false_path -to [get_ports {HEX4[6]}]
set_false_path -to [get_ports {HEX5[0]}]
set_false_path -to [get_ports {HEX5[1]}]
set_false_path -to [get_ports {HEX5[2]}]
set_false_path -to [get_ports {HEX5[3]}]
set_false_path -to [get_ports {HEX5[4]}]
set_false_path -to [get_ports {HEX5[5]}]
set_false_path -to [get_ports {HEX5[6]}]

#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************



