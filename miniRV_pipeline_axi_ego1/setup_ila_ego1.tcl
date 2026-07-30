# This file is sourced by rebuild_ego1.tcl while the synthesized design is
# open. It is not intended to be run directly.

set expected_probe_width 200
set marked_nets [get_nets -hier -quiet -filter {MARK_DEBUG == 1}]
set ordered_probe_nets [lrepeat $expected_probe_width ""]
set matched_probe_count 0

foreach marked_net $marked_nets {
    set net_name [get_property NAME $marked_net]
    if {[regexp {ila_probe\[([0-9]+)\]$} $net_name -> bit_index]} {
        if {$bit_index < 0 || $bit_index >= $expected_probe_width} {
            error "ILA probe bit index is out of range: $net_name"
        }
        lset ordered_probe_nets $bit_index $marked_net
        incr matched_probe_count
    }
}

if {$matched_probe_count != $expected_probe_width} {
    puts "MARK_DEBUG nets found:"
    foreach marked_net $marked_nets {
        puts "  [get_property NAME $marked_net]"
    }
    error "Expected $expected_probe_width ila_probe bits, found $matched_probe_count"
}

for {set bit_index 0} {$bit_index < $expected_probe_width} {incr bit_index} {
    if {[lindex $ordered_probe_nets $bit_index] eq ""} {
        error "ila_probe bit $bit_index is missing after synthesis"
    }
}

set ila_clock_nets [get_nets -hier -quiet -regexp {.*ila_clk$}]
if {[llength $ila_clock_nets] != 1} {
    puts "Clock-like nets found:"
    foreach clock_net [get_nets -hier -quiet -regexp {.*(ila_clk|sys_clk|pll_clk1).*}] {
        puts "  [get_property NAME $clock_net]"
    }
    error "Expected exactly one ila_clk net, found [llength $ila_clock_nets]"
}

foreach old_core [get_debug_cores -quiet u_ila_boot] {
    delete_debug_core $old_core
}

create_debug_core u_ila_boot ila
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_boot]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_boot]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_boot]

set ila_clk_port [get_debug_ports -quiet u_ila_boot/clk]
if {![llength $ila_clk_port]} {
    set ila_clk_port [get_debug_ports u_ila_boot/CLK]
}
set ila_probe_port [get_debug_ports -quiet u_ila_boot/probe0]
if {![llength $ila_probe_port]} {
    set ila_probe_port [get_debug_ports u_ila_boot/PROBE0]
}

set_property PORT_WIDTH 1 $ila_clk_port
connect_debug_port $ila_clk_port $ila_clock_nets
set_property PORT_WIDTH $expected_probe_width $ila_probe_port
connect_debug_port $ila_probe_port $ordered_probe_nets

report_debug_core
save_constraints -force
puts "ILA u_ila_boot connected: clock=ila_clk, probe width=$expected_probe_width"
