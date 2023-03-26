onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /Testbench/DUT/Vcc
add wave -noupdate /Testbench/DUT/S
add wave -noupdate /Testbench/DUT/C
add wave -noupdate /Testbench/DUT/HOLD_DQ3
add wave -noupdate /Testbench/DUT/Vpp_W_DQ2
add wave -noupdate /Testbench/DUT/DQ1
add wave -noupdate /Testbench/DUT/DQ0
add wave -noupdate /Testbench/DUT/XIP
add wave -noupdate /Testbench/DUT/HOLD
add wave -noupdate /Testbench/DUT/intHOLD
add wave -noupdate /Testbench/DUT/int_reset
add wave -noupdate /Testbench/DUT/logicOn
add wave -noupdate /Testbench/DUT/seqRecognized
add wave -noupdate /Testbench/DUT/checkProtocol
add wave -noupdate /Testbench/clock_active
add wave -noupdate -radix hexadecimal /Testbench/DUT/cmd
add wave -noupdate -radix ascii /Testbench/DUT/cmdRecName
add wave -noupdate /Testbench/DUT/sendToBus
add wave -noupdate -radix ascii /Testbench/DUT/protocol
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {616134000 ps} 0}
configure wave -namecolwidth 253
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {592616348 ps} {669702785 ps}
