# Run this script from Vivado Tcl Console after opening miniRV.xpr:
#   source rebuild_ego1.tcl
#
# It repairs generated files after the project directory has been copied to
# another computer, then launches synthesis/implementation through bitstream.

set script_dir [file dirname [file normalize [info script]]]
set board_bram_src [file join $script_dir src rtl board_bram.v]
set axi_board_soc_src [file join $script_dir src rtl axi_board_soc.v]
if {![file exists $board_bram_src]} {
    error "board_bram.v was not found at $board_bram_src"
}
if {![file exists $axi_board_soc_src]} {
    error "axi_board_soc.v was not found at $axi_board_soc_src"
}

# Refuse to rebuild if only the old inferred-array source was copied.
set board_bram_file [open $board_bram_src r]
set board_bram_text [read $board_bram_file]
close $board_bram_file
if {[string first "IROM U_program_memory" $board_bram_text] < 0 ||
    [string first "DRAM U_data_memory" $board_bram_text] < 0} {
    error "Old board_bram.v detected. Restore src/rtl/board_bram.v from the final project."
}

# Force the project to use the files beside this script. This avoids retaining
# a board_bram.v reference from an older extraction or another source tree.
foreach source_spec [list \
    [list board_bram.v $board_bram_src] \
    [list axi_board_soc.v $axi_board_soc_src]] {
    set source_name [lindex $source_spec 0]
    set source_path [lindex $source_spec 1]
    set old_sources [get_files -quiet */$source_name]
    if {[llength $old_sources]} {
        remove_files $old_sources
    }
    add_files -fileset sources_1 -norecurse $source_path
}
set_property top miniRV_SoC [get_filesets sources_1]
update_compile_order -fileset sources_1
puts "EGO1 rebuild board memory source: [file normalize $board_bram_src]"

# The IROM/DRAM DCP contains the initialized program image. Reusing a cache
# entry produced for an older COE file can create a valid bitstream that boots
# the wrong contents, so this board-image rebuild must synthesize IP afresh.
config_ip_cache -disable_cache
puts "IP synthesis cache disabled for the board-image rebuild."

set main_mem_src [file join $script_dir src coe main.mem]
set irom_coe [file join $script_dir src coe board_irom.coe]
set dram_coe [file join $script_dir src coe board_dram.coe]
if {![file exists $main_mem_src]} {
    error "main.mem was not found at $main_mem_src"
}

# Split the linked image at the linker-script boundary:
#   IROM: first 12,800 words (50 KiB)
#   DRAM: remaining 25,600 words (100 KiB)
# They are loaded into explicit Block Memory Generator IPs. This is deliberate:
# a Verilog array of this size was mapped to RAMD64E LUT RAM on the EGO1 device.
set input_file [open $main_mem_src r]
set memory_words {}
while {[gets $input_file line] >= 0} {
    set word [string trim $line]
    if {$word ne ""} {
        lappend memory_words $word
    }
}
close $input_file
set word_count [llength $memory_words]
if {$word_count != 38400} {
    error "Expected 38400 words in main.mem, found $word_count"
}

proc write_coe {path words} {
    set output_file [open $path w]
    puts $output_file "memory_initialization_radix=16;"
    puts $output_file "memory_initialization_vector="
    set last_index [expr {[llength $words] - 1}]
    for {set index 0} {$index <= $last_index} {incr index} {
        if {$index == $last_index} {
            puts $output_file "[lindex $words $index];"
        } else {
            puts $output_file "[lindex $words $index],"
        }
    }
    close $output_file
}

write_coe $irom_coe [lrange $memory_words 0 12799]
write_coe $dram_coe [lrange $memory_words 12800 38399]

set irom_xci [get_files -quiet */IROM.xci]
set dram_xci [get_files -quiet */DRAM.xci]
set clk_xci [get_files -quiet */clk_wiz_0.xci]
set irom_ip [get_ips -quiet IROM]
set dram_ip [get_ips -quiet DRAM]
set clk_ip [get_ips -quiet clk_wiz_0]
if {[llength $irom_xci] != 1} {
    error "Expected exactly one IROM.xci, found [llength $irom_xci]"
}
if {[llength $dram_xci] != 1} {
    error "Expected exactly one DRAM.xci, found [llength $dram_xci]"
}
if {[llength $clk_xci] != 1} {
    error "Expected exactly one clk_wiz_0.xci, found [llength $clk_xci]"
}
if {[llength $irom_ip] != 1} {
    error "Expected exactly one IROM IP object, found [llength $irom_ip]"
}
if {[llength $dram_ip] != 1} {
    error "Expected exactly one DRAM IP object, found [llength $dram_ip]"
}
if {[llength $clk_ip] != 1} {
    error "Expected exactly one clk_wiz_0 IP object, found [llength $clk_ip]"
}

# CONFIG.* properties belong to IP objects returned by get_ips, not to the
# XCI file objects returned by get_files.
set_property -dict [list CONFIG.Load_Init_File true CONFIG.Coe_File $irom_coe] $irom_ip
set_property -dict [list CONFIG.Load_Init_File true CONFIG.Coe_File $dram_coe] $dram_ip
update_compile_order -fileset sources_1

foreach ip_object [list $irom_ip $dram_ip $clk_ip] {
    reset_target all $ip_object
    generate_target all $ip_object
    export_ip_user_files -of_objects $ip_object -no_script -sync -force -quiet
}

foreach ip_run [list IROM_synth_1 DRAM_synth_1 clk_wiz_0_synth_1] {
    if {![llength [get_runs -quiet $ip_run]]} {
        error "IP synthesis run $ip_run was not found"
    }
    reset_run $ip_run
    launch_runs $ip_run -jobs 8
    wait_on_run $ip_run
    set ip_status [get_property STATUS [get_runs $ip_run]]
    if {[string match "*cached IP results*" $ip_status]} {
        error "$ip_run unexpectedly used an IP cache during the board-image rebuild"
    }
    if {![string match "*Complete*" $ip_status]} {
        error "$ip_run failed: $ip_status"
    }
    puts "$ip_run ready: $ip_status"
}

# Run synthesis separately and reject the old distributed-memory netlist
# before spending time on implementation.
catch {close_design}
reset_run synth_1
launch_runs synth_1 -jobs 8
wait_on_run synth_1
set synth_status [get_property STATUS [get_runs synth_1]]
if {![string match "*Complete*" $synth_status]} {
    error "synth_1 failed: $synth_status"
}

open_run synth_1
report_utilization -file post_synth_utilization.rpt
set ramd64e_count [llength [get_cells -hier -quiet -filter {REF_NAME == RAMD64E}]]
set ramb18_count [llength [get_cells -hier -quiet -filter {REF_NAME == RAMB18E1}]]
set ramb36_count [llength [get_cells -hier -quiet -filter {REF_NAME == RAMB36E1}]]
puts "Post-synthesis memory primitives: RAMD64E=$ramd64e_count RAMB18E1=$ramb18_count RAMB36E1=$ramb36_count"
if {$ramd64e_count > 1000} {
    error "Old distributed-memory netlist detected after synthesis; implementation was not launched."
}
close_design

reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

set impl_status [get_property STATUS [get_runs impl_1]]
if {![string match "*Complete*" $impl_status]} {
    error "impl_1 failed: $impl_status"
}

open_run impl_1
report_timing_summary -file timing_summary.rpt
report_utilization -file utilization.rpt
report_power -file power.rpt

puts "EGO1 build finished."
puts "Timing report: [file normalize timing_summary.rpt]"
puts "Utilization report: [file normalize utilization.rpt]"
puts "Power report: [file normalize power.rpt]"
