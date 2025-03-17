simSetSimulator "-vcssv" -exec \
           "/project/tsmc28mmwave/users/binatmakhlin/ws/neuron/CHIP/simv" \
           -args
debImport "-dbdir" \
          "/project/tsmc28mmwave/users/binatmakhlin/ws/neuron/CHIP/simv.daidir"
debLoadSimResult \
           /project/tsmc28mmwave/users/binatmakhlin/ws/neuron/CHIP/novas.fsdb
wvCreateWindow
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcHBSelect "mac_tb.dut" -win $_nTrace1
srcSetScope "mac_tb.dut" -delim "." -win $_nTrace1
srcHBSelect "mac_tb.dut" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 7 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 7 -pos 1 -win $_nTrace1
srcAction -pos 6 5 1 -win $_nTrace1 -name "clk" -ctrlKey off
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcHBSelect "mac_tb.dut" -win $_nTrace1
srcSetScope "mac_tb.dut" -delim "." -win $_nTrace1
srcHBSelect "mac_tb.dut" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 7 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "mul_mem_en" -line 9 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoom -win $_nWave2 0.000000 5731134059.390625
verdiSetActWin -win $_nWave2
wvZoom -win $_nWave2 0.000000 53729381.806787
wvZoom -win $_nWave2 0.000000 973845.045248
srcDeselectAll -win $_nTrace1
srcSelect -signal "ac_mem_en" -line 10 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "img_in" -line 11 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "weight_in" -line 12 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "mul_register" -line 29 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "acc_register" -line 39 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "acc_register" -line 39 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
verdiSetActWin -win $_nWave2
wvGoToTime -win $_nWave2 25000
srcDeselectAll -win $_nTrace1
srcSelect -signal "mac_out" -line 48 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 106514.301824 -snap {("G2" 0)}
verdiSetActWin -win $_nWave2
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -win $_nWave2
wvGoToTime -win $_nWave2 25000
srcHBSelect "mac_tb.Monitor" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "mac_tb.Monitor" -win $_nTrace1
srcSetScope "mac_tb.Monitor" -delim "." -win $_nTrace1
srcHBSelect "mac_tb.Monitor" -win $_nTrace1
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -signal "intf.ac_mem_en" -line 79 -pos 1
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 78 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
