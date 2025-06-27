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
    rtl/top_with_io.sv
}

######### Elaborate and save #########
elaborate top
set_top_module top_io
start_gui
save_block -as top_io_elaborate

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

current_scenario FUNC_Fast 
source  synthesis/top_io.sdc
current_scenario FUNC_Slow 
source  synthesis/top_io.sdc


open_block top_io_elaborate

# Top side
create_cell vdd_io_top    tphn28hpcpgv18_9lm/PVDD2DGZ_H_G
create_cell vss_io_top    tphn28hpcpgv18_9lm/PVSS2DGZ_H_G
create_cell vdd_core_top  tphn28hpcpgv18_9lm/PVDD1DGZ_H_G
create_cell vss_core_top  tphn28hpcpgv18_9lm/PVSS1DGZ_H_G
create_cell poc_pad       tphn28hpcpgv18_9lm/PVDD2POC_H_G

# Bottom side
create_cell vdd_io_bot    tphn28hpcpgv18_9lm/PVDD2DGZ_H_G
create_cell vss_io_bot    tphn28hpcpgv18_9lm/PVSS2DGZ_H_G
create_cell vdd_core_bot  tphn28hpcpgv18_9lm/PVDD1DGZ_H_G
create_cell vss_core_bot  tphn28hpcpgv18_9lm/PVSS1DGZ_H_G

# Left side
create_cell vdd_io_left   tphn28hpcpgv18_9lm/PVDD2DGZ_V_G
create_cell vss_io_left   tphn28hpcpgv18_9lm/PVSS2DGZ_V_G
create_cell vdd_core_left tphn28hpcpgv18_9lm/PVDD1DGZ_V_G
create_cell vss_core_left tphn28hpcpgv18_9lm/PVSS1DGZ_V_G

# Right side
create_cell vdd_io_right   tphn28hpcpgv18_9lm/PVDD2DGZ_V_G
create_cell vss_io_right   tphn28hpcpgv18_9lm/PVSS2DGZ_V_G
create_cell vdd_core_right tphn28hpcpgv18_9lm/PVDD1DGZ_V_G
create_cell vss_core_right tphn28hpcpgv18_9lm/PVSS1DGZ_V_G

initialize_floorplan -control_type die -boundary {{0 0} {1000.0 0} {1000.0 1000.0} {0 1000.0}} -core_offset {458.52 458.8125} -use_site_row -flip_first_row true
create_io_ring
set io_cells [get_cells -hierarchical *io_*]

set left_pads   {vdd_io_left vss_io_left io_wr_en io_chip_sel vdd_core_left vss_core_left io_output_ready io_output io_bus_0}
set top_pads    {io_clk vdd_io_top vss_io_top poc_pad vdd_core_top vss_core_top io_bus_15 io_bus_14 io_bus_13 io_bus_12}
set right_pads  {io_bus_7 io_bus_8 io_bus_9 io_bus_10 io_bus_11 vdd_io_right vss_io_right vdd_core_right vss_core_right}
set bottom_pads {io_bus_1 io_bus_2 io_bus_3 io_bus_4 io_bus_5 io_bus_6 vdd_io_bot vss_io_bot vdd_core_bot vss_core_bot}

create_cell corner_ul tphn28hpcpgv18_9lm/PCORNER_G
create_cell corner_ur tphn28hpcpgv18_9lm/PCORNER_G
create_cell corner_ll tphn28hpcpgv18_9lm/PCORNER_G
create_cell corner_lr tphn28hpcpgv18_9lm/PCORNER_G

set bottom_pads_with_corners [concat corner_ll $bottom_pads corner_lr]
set top_pads_with_corners    [concat corner_ul $top_pads    corner_ur]

add_to_io_guide _default_io_ring1.left   $left_pads
add_to_io_guide _default_io_ring1.right  $right_pads
add_to_io_guide _default_io_ring1.bottom $bottom_pads_with_corners
add_to_io_guide _default_io_ring1.top    $top_pads_with_corners

place_io
report_io_rings
report_floorplan
save_block -as top_io_placed

create_io_filler_cells -reference_cells {PFILLER0005_G PFILLER05_G PFILLER10_G PFILLER1_G PFILLER20_G PFILLER5_G}

save_block -as top_io_placed


######### Power #########
####remove all old defination
remove_pg_via_master_rules -all
remove_pg_patterns -all
remove_pg_strategies -all
remove_pg_strategy_via_rules -all
remove_routes -ring -stripe -lib_cell_pin_connect

# === Create PG Nets ===
create_net VDD_CORE
create_net VDD_IO
create_net VSS_CORE
create_net VSS_IO

# === Tag PG Nets as Power/Ground ===
set_attribute -objects [get_nets VDD_CORE] -name net_type -value power
set_attribute -objects [get_nets VSS_CORE] -name net_type -value ground
set_attribute -objects [get_nets VDD_IO] -name net_type -value power
set_attribute -objects [get_nets VSS_IO] -name net_type -value ground

connect_net -net VDD_CORE [get_pins {
    vdd_core_left/VDD     vdd_core_left/VDDPST
    vdd_core_top/VDD      vdd_core_top/VDDPST
    vdd_core_right/VDD    vdd_core_right/VDDPST
    vdd_core_bot/VDD      vdd_core_bot/VDDPST
}]
connect_net -net VDD_CORE [get_pins {
    vdd_core_left/VDD     vdd_core_left/VDDPST
    vdd_core_top/VDD      vdd_core_top/VDDPST
    vdd_core_right/VDD    vdd_core_right/VDDPST
    vdd_core_bot/VDD      vdd_core_bot/VDDPST
}]

connect_net -net VSS_CORE [get_pins {
    vss_core_left/VSS     vss_core_left/VSSPST
    vss_core_top/VSS      vss_core_top/VSSPST
    vss_core_right/VSS    vss_core_right/VSSPST
    vss_core_bot/VSS      vss_core_bot/VSSPST
}]

# === Create Core PG Ring Pattern ===
create_pg_ring_pattern core_ring \
  -horizontal_layer M6 -horizontal_width 2.0 -horizontal_spacing 0.5 \
  -vertical_layer   M5 -vertical_width   2.0 -vertical_spacing   0.5

# === Define Core Ring Strategy ===
set_pg_strategy core_ring_strategy -core \
  -pattern {{name: core_ring} {nets: {VDD_CORE VSS_CORE}}} \
  -extension {{stop: core_boundary}}

# === Apply Core Ring Strategy ===
compile_pg -strategies {core_ring_strategy}

# === same for io facing ring===
create_pg_ring_pattern io_facing_ring \
  -horizontal_layer M6 -horizontal_width 2.0 -horizontal_spacing 0.5 \
  -vertical_layer   M5 -vertical_width   2.0 -vertical_spacing   0.5

set_pg_strategy io_facing_ring_strategy -design_boundary \
  -pattern {{name: io_facing_ring} {nets: {VDD_CORE VSS_CORE}} {offset: {-30 -30}}} \
  -extension {{stop: core_boundary}}

compile_pg -strategies {io_facing_ring_strategy}

# === Create PG Straps from IO to Core ===
create_pg_strap -net VDD_CORE -direction horizontal -layer M7 -width 2.0 -spacing 0.4 -pitch 20.0
create_pg_strap -net VSS_CORE -direction horizontal -layer M7 -width 2.0 -spacing 0.4 -pitch 20.0
create_pg_strap -net VDD_CORE -direction vertical   -layer M8 -width 2.0 -spacing 0.4 -pitch 20.0
create_pg_strap -net VSS_CORE -direction vertical   -layer M8 -width 2.0 -spacing 0.4 -pitch 20.0

# === Create VIAs for Connectivity ===
create_pg_vias -nets {VDD_CORE VSS_CORE} -from_layers metal5 -to_layers metal6
create_pg_vias -nets {VDD_CORE VSS_CORE} -from_layers metal6 -to_layers metal7
create_pg_vias -nets {VDD_CORE VSS_CORE} -from_layers metal7 -to_layers metal8

# === Final Check ===
check_pg_connectivity
report_pg_nets