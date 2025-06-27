#RUN FROM CHIP FOLDER
lappend search_path scripts design_data 

set_host_options -max_cores 8
set TECH_FILE     "/data/tsmc/28HPCPMMWAVE/synopsys/tsmcn28_9lm6X1Z1URDL.tf"

######### Create Physical library #########
create_lib -technology $TECH_FILE -ref_libs {
    /data/tsmc/28HPCPMMWAVE/synopsys/libs/tcbn28hpcplusbwp30p140.ndm
    /data/tsmc/28HPCPMMWAVE/synopsys/libs/tcbn28hpcplusbwp30p140hvt.ndm
    /data/tsmc/28HPCPMMWAVE/synopsys/libs/tcbn28hpcplusbwp30p140lvt.ndm
} neuron_top_no_sram.dlib
open_lib neuron_top_no_sram.dlib
report_ref_libs

read_parasitic_tech -tlup /data/tsmc/28HPCPMMWAVE/dig_libs/snpsflow/rcbest/crn28hpc+_1p09m+ut-alrdl_6x1z1u_rcbest.tluplus -name rcbest
read_parasitic_tech -tlup /data/tsmc/28HPCPMMWAVE/dig_libs/snpsflow/rcworst/crn28hpc+_1p09m+ut-alrdl_6x1z1u_rcworst.tluplus -name rcworst
save_lib

######### Analyze and save #########
analyze -format sverilog {
    rtl/top.sv
    rtl/mac.sv
    rtl/Control_unit.sv
    rtl/activation_function.sv
    rtl/neuron_io.sv
    rtl/input_memory.sv
}

######### Elaborate and save #########
elaborate top
set_top_module top
start_gui
save_block -as top_elaborate

########## mcmm_setup: #########
# Remove all MCMM related info
remove_corners   -all
remove_modes     -all
remove_scenarios -all

# Create Corners
create_corner Fast
create_corner Slow

## Set parasitics parameters
set_parasitics_parameters -early_spec rcbest -late_spec  rcbest -corners {Fast}
set_parasitics_parameters -early_spec rcworst -late_spec  rcworst -corners {Slow}

## Create Mode
create_mode  FUNC
current_mode FUNC

## Create Scenarios
create_scenario -mode FUNC -corner Fast    -name FUNC_Fast
create_scenario -mode FUNC -corner Slow    -name FUNC_Slow

#sourse ConFiles/riscv.con
current_scenario FUNC_Fast 
source  synthesis/top.sdc
current_scenario FUNC_Slow 
source  synthesis/top.sdc

######### Synthesis #########
set_auto_floorplan_constraints -core_utilization 0.67 -side_ratio {1 1} -core_offset 2
set_lib_cell_purpose [get_lib_cells */CKL*] -include none
set_individual_pin_constraints -nets {bus[2] bus[3] bus[4] bus[5] bus[6] bus[7]} -sides {4}
set_individual_pin_constraints -nets {bus[10] bus[11] chip_sel wr_en output_bit} -sides {3}
set_individual_pin_constraints -nets {clk_in bus[8] bus[9] bus[14] bus[15]} -sides {2}
set_individual_pin_constraints -nets {output_ready bus[0] bus[1] bus[12] bus[13]} -sides {1}

# === Enable LVT Optimization ===
# Clean up any old group assignments:
remove_attributes [get_lib_cells */*] threshold_voltage_group
# Set LVT group:
set_attribute [get_lib_cells */*LVT*] threshold_voltage_group LVT
set_threshold_voltage_group_type -type low_vt LVT
# Make sure optimizer is allowed to use them:
set_lib_cell_purpose -include optimization [get_lib_cells */*LVT*]
# Allow percentage LVT (here: 100%, but you can reduce to 30, 50, etc.)
set_multi_vth_constraint -low_vt_percentage 50 -cost cell_count

create_clock -period 0.7 [get_ports clk_in]
compile_fusion -to logic_opto
place_pins -self
compile_fusion -from logic_opto -to final_opto
place_pins -self
create_clock -period 1 [get_ports clk_in]


######### Reports Generation #########
report_area > reports_no_sram/area_report.log
report_utilization > reports_no_sram/utilization.log
save_block -as top_final_opto

# Insert Boundary cells
create_boundary_cells \
  -left_boundary_cell  tcbn28hpcplusbwp30p140/BOUNDARY_LEFTBWP30P140 \
  -right_boundary_cell tcbn28hpcplusbwp30p140/BOUNDARY_RIGHTBWP30P140 \
  -prefix BOUND

# Insert TAP cells to ensure well and substrate ties
create_tap_cells \
  -lib_cell tcbn28hpcplusbwp30p140/TAPCELLBWP30P140 \
  -distance 60 \
  -pattern stagger \
  -skip_fixed_cells

#Checking legality of placement
legalize_placement -incremental
check_legality

save_block -as top_placed_with_tap_and_boundary

######### Power #########
####remove all old defination
remove_pg_via_master_rules -all
remove_pg_patterns -all
remove_pg_strategies -all
remove_pg_strategy_via_rules -all
remove_routes -ring -stripe -lib_cell_pin_connect

#### Set PG net attribute
set_attribute -objects [get_nets VDD] -name net_type -value power
set_attribute -objects [get_nets VSS] -name net_type -value ground

#### Create VIA strategy rule VIA_NIL
set_pg_strategy_via_rule VIA_NIL -via_rule { {intersection: undefined} {via_master: NIL} }

#### Create PG Rails for standard cells
create_pg_std_cell_conn_pattern M1_rail -layers {M1} -rail_width {@wtop @wbottom} -parameters {wtop wbottom}

#### Connect all cess to pg nets 
connect_pg_net -automatic

####  set the PG strategy for M1 cells straps
set_pg_strategy M1_rail_strategy_pwr -core -pattern {{name: M1_rail} {nets: VDD} {parameters: {0.150 0.150}}}
set_pg_strategy M1_rail_strategy_gnd -core -pattern {{name: M1_rail} {nets: VSS} {parameters: {0.150 0.150}}}
compile_pg -strategies M1_rail_strategy_pwr -ignore_drc
compile_pg -strategies M1_rail_strategy_gnd -ignore_drc

### Create M5 Veritacl PG Straps
create_pg_mesh_pattern M5_PG         -layers { {vertical_layer: M5}   {width: 1.6} {spacing: interleaving} {pitch: 16} {offset: 4.0} }
set_pg_strategy M5_PG_Strategy         -core         -pattern   { {name: M5_PG} {nets:{VSS VDD}} }         -extension { {stop: core_boundary} }
compile_pg -strategies {M5_PG_Strategy} -via_rule VIA_NIL

#### Create M6 Horizontal PG Straps
create_pg_mesh_pattern M6_PG         -layers { {horizontal_layer: M6}   {width: 1.6} {spacing: interleaving} {pitch: 16} {offset: 4.0} }
set_pg_strategy M6_PG_Strategy         -core         -pattern   { {name: M6_PG} {nets:{VSS VDD}} }         -extension { {stop: design_boundary_and_generate_pin} }
compile_pg -strategies {M6_PG_Strategy} -via_rule VIA_NIL
create_pg_vias -nets VSS -from_layers M1 -to_layers M5
create_pg_vias -nets VDD -from_layers M1 -to_layers M5
create_pg_vias -nets VDD -from_layers M5 -to_layers M6
create_pg_vias -nets VSS -from_layers M5 -to_layers M6
save_block -as neuron_top_no_sram.dlib:top_with_power.design

#report_ideal_network
######### CTS #########
set_lib_cell_purpose -include optimization [get_lib_cells *CKBD*]
set_lib_cell_purpose -include cts [get_lib_cells *CKBD*]
set_clock_tree_options -clocks [get_clocks clk_in] -root_ndr_fanout_limit 36
clock_opt
set_propagated_clock [get_ports clk_in]
report_timing -max_paths 10 -delay_type max
report_timing -max_paths 10 -delay_type min
report_clock_timing -type summary
save_block -as neuron_top_no_sram.dlib:top_with_clk.design

report_timing > reports_no_sram/timing_after_cts.log
report_qor > reports_no_sram/qor_after_cts.log

######### Routing #########
route_opt
save_block -as neuron_top_no_sram.dlib:top_with_clk_routing.design

report_timing > reports_no_sram/timing_after_route.log
report_power  > reports_no_sram/power_after_route.log
report_qor    > reports_no_sram/qor_after_route.log
report_timing -delay_type min > reports_no_sram/hold_violations.log

######### Fillers #########
