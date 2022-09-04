
# XM-Sim Command File
# TOOL:	xmsim(64)	20.09-s010
#
#
# You can restore this configuration with:
#
#      xrun -sv -64bit +lic_queue -licqueue +incdir+/home/zrafique/projects/azadi-tsmc/verif/../flash_model/N25Q128A13E_VG12 -xmlibdirpath ./build/xcelium -xmlibdirname azadi.build -timescale 1ns/1ps -f ../rtl/flist.azadi -top azadi_top_sim +HEX=/home/zrafique/projects/azadi-tsmc/verif/tests/basic-test/test.hex +ROM_BIN=/home/zrafique/projects/azadi-tsmc/verif/../arm/post-rom/post_rom_verilog.rcf -access +rwc -s -input /home/zrafique/projects/azadi-tsmc/verif/waves/rom.tcl
#

set tcl_prompt1 {puts -nonewline "xcelium> "}
set tcl_prompt2 {puts -nonewline "> "}
set vlog_format %h
set vhdl_format %v
set real_precision 6
set display_unit auto
set time_unit module
set heap_garbage_size -200
set heap_garbage_time 0
set assert_report_level note
set assert_stop_level error
set autoscope yes
set assert_1164_warnings yes
set pack_assert_off {}
set severity_pack_assert_off {note warning}
set assert_output_stop_level failed
set tcl_debug_level 0
set relax_path_name 1
set vhdl_vcdmap XX01ZX01X
set intovf_severity_level ERROR
set probe_screen_format 0
set rangecnst_severity_level ERROR
set textio_severity_level ERROR
set vital_timing_checks_on 1
set vlog_code_show_force 0
set assert_count_attempts 1
set tcl_all64 false
set tcl_runerror_exit false
set assert_report_incompletes 0
set show_force 1
set force_reset_by_reinvoke 0
set tcl_relaxed_literal 0
set probe_exclude_patterns {}
set probe_packed_limit 4k
set probe_unpacked_limit 16k
set assert_internal_msg no
set svseed 1
set assert_reporting_mode 0
set vcd_compact_mode 0
alias . run
alias quit exit
database -open -shm -into waves.shm waves -default
probe -create -database waves azadi_top_sim.clk_i azadi_top_sim.rst_ni azadi_top_sim.w_byte azadi_top_sim.tx_en azadi_top_sim.tx_ready azadi_top_sim.sck_tb azadi_top_sim.sdi_tb azadi_top_sim.sdo_tb
probe -create -database waves azadi_top_sim.u_azadi_soc_top.boot_addr azadi_top_sim.u_azadi_soc_top.boot_sel_i
probe -create -database waves azadi_top_sim.u_azadi_soc_top.por_ni azadi_top_sim.u_azadi_soc_top.pll_lock_i
probe -create -database waves azadi_top_sim.u_azadi_soc_top.u_brq_core_top.brq_core_i.rst_ni azadi_top_sim.u_azadi_soc_top.u_brq_core_top.brq_core_i.id_stage_i.instr_rdata_i

simvision -input rom.tcl.svcf
