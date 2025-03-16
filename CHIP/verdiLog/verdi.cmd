verdiSetActWin -dock widgetDock_<Decl._Tree>
simSetSimulator "-vcssv" -exec \
           "/project/tsmc28mmwave/users/jp1/ws/neural-engine/Neural-Engine/CHIP/simv" \
           -args
debImport "-dbdir" \
          "/project/tsmc28mmwave/users/jp1/ws/neural-engine/Neural-Engine/CHIP/simv.daidir"
debLoadSimResult \
           /project/tsmc28mmwave/users/jp1/ws/neural-engine/Neural-Engine/CHIP/novas.fsdb
wvCreateWindow
verdiWindowResize -win $_Verdi_1 "318" "94" "900" "700"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "mac_out" -line 54 -pos 1 -win $_nTrace1
srcNextChange -win $_nTrace1 -line 54
srcDeselectAll -win $_nTrace1
srcSelect -signal "mac_out" -line 54 -pos 1 -win $_nTrace1
srcAction -pos 53 3 2 -win $_nTrace1 -name "mac_out" -ctrlKey off
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "acc_register" -line 54 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 45193.582511 -snap {("G1" 2)}
wvSetCursor -win $_nWave2 44616.643159 -snap {("G1" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "acc_register" -line 50 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 20 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
verdiSetActWin -win $_nWave2
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "acc_register" -line 30 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -word -line 159 -pos 2 -win $_nTrace1
srcHBSelect "mac_tb.dut" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
debExit
