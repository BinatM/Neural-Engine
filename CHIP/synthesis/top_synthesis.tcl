#RUN FROM CHIP FOLDER
lappend search_path scripts design_data 
#lappend search_path CHIP/sram

set_host_options -max_cores 8
set TECH_FILE     "/data/tsmc/28HPCPMMWAVE/synopsys/tsmcn28_9lm6X1Z1URDL.tf"

#######################################################################
## Physical Library Settings
#######################################################################
#/project/tsmc28mmwave/users/binatmakhlin/ws/neuron/CHIP/sram/ts6n28hpcphvta64x8m4fwbso_200b_new.ndm
create_lib -technology $TECH_FILE -ref_libs {
    /data/tsmc/28HPCPMMWAVE/synopsys/libs/tcbn28hpcplusbwp30p140.ndm
    /data/tsmc/28HPCPMMWAVE/synopsys/libs/tcbn28hpcplusbwp30p140hvt.ndm
    /data/tsmc/28HPCPMMWAVE/synopsys/libs/tcbn28hpcplusbwp30p140lvt.ndm
} neuron_top_no_sram.dlib
open_lib neuron_top_no_sram.dlib
report_ref_libs
#read_lef CHIP/sram/ts6n28hpcphvta64x8m4fwbso_200b/LEF/ts6n28hpcphvta64x8m4fwbso_200b.lef

read_parasitic_tech -tlup /data/tsmc/28HPCPMMWAVE/dig_libs/snpsflow/rcbest/crn28hpc+_1p09m+ut-alrdl_6x1z1u_rcbest.tluplus -name rcbest
read_parasitic_tech -tlup /data/tsmc/28HPCPMMWAVE/dig_libs/snpsflow/rcworst/crn28hpc+_1p09m+ut-alrdl_6x1z1u_rcworst.tluplus -name rcworst

save_lib
analyze -format sverilog {
    rtl/top.sv
    rtl/mac.sv
    rtl/Control_unit.sv
    rtl/activation_function.sv
    rtl/neuron_io.sv
    rtl/input_memory.sv
}
elaborate top
set_top_module top
start_gui
save_block -as top_elaborate

# mcmm_setup: 
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

set_auto_floorplan_constraints -core_utilization 0.7 -side_ratio {1 1} -core_offset 2
set_lib_cell_purpose [get_lib_cells */CKL*] -include none
compile_fusion -to logic_opto
#create_placement
#legalize_placement

##Power
compile_fusion -to final_opto

## Reports Generation
report_area > reports/area_report.log
report_cells > reports/cell_count.log
#report_lib_cells -objects [get_lib_cells tcbn28hpcplusbwp30p140] > CHIP/reports/lib_cells.log
report_power > reports/power_report.log
report_timing > reports/timing_report.log
report_utilization > reports/utilization.log
report_qor > reports/qor_report.log
save_block -as top_final_opto