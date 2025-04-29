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
####  create pg for the cells on the rows
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
###### create vias to connect all pg nets
create_pg_vias -nets VSS -from_layers M1 -to_layers M5
create_pg_vias -nets VDD -from_layers M1 -to_layers M5
create_pg_vias -nets VDD -from_layers M5 -to_layers M6
create_pg_vias -nets VSS -from_layers M5 -to_layers M6
