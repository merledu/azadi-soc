
# XM-Sim Command File
# TOOL:	xmsim(64)	20.09-s010
#
#
# You can restore this configuration with:
#
#      xrun -sv -64bit +lic_queue -licqueue +incdir+/home/sahmad/TSMC/xcelium/azadi-tsmc/verif/../flash_model/N25Q128A13E_VG12 -xmlibdirpath ./build/xcelium -xmlibdirname azadi.build -timescale 1ns/1ps -f ../rtl/flist.azadi -top azadi_top_sim +HEX=/home/sahmad/TSMC/xcelium/azadi-tsmc/verif/tests/basic-test/test.hex -access +rwc -input /home/sahmad/TSMC/xcelium/azadi-tsmc/verif/waves/qspi_waves.tcl
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
probe -create -database waves azadi_top_sim.azadi_soc_top_i.u_qspi.clk_i azadi_top_sim.flash.C azadi_top_sim.flash.S azadi_top_sim.azadi_soc_top_i.u_qspi.u_qspi.addr_i azadi_top_sim.azadi_soc_top_i.brq_core_top_i.tlul_iccm_adapter_i.req_i azadi_top_sim.azadi_soc_top_i.brq_core_top_i.tlul_iccm_adapter_i.gnt_o azadi_top_sim.azadi_soc_top_i.brq_core_top_i.tlul_iccm_adapter_i.rdata_o azadi_top_sim.azadi_soc_top_i.brq_core_top_i.tlul_iccm_adapter_i.valid_o azadi_top_sim.azadi_soc_top_i.brq_core_top_i.tlul_dccm_adapter_i.req_i azadi_top_sim.azadi_soc_top_i.brq_core_top_i.tlul_dccm_adapter_i.gnt_o azadi_top_sim.azadi_soc_top_i.brq_core_top_i.tlul_dccm_adapter_i.addr_i azadi_top_sim.azadi_soc_top_i.brq_core_top_i.tlul_dccm_adapter_i.wdata_i azadi_top_sim.flash.HOLD_DQ3 azadi_top_sim.flash.Vpp_W_DQ2 azadi_top_sim.flash.DQ1 azadi_top_sim.flash.DQ0

simvision -input qspi_waves.tcl.svcf
