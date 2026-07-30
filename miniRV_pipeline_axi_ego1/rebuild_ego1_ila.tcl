# Run from the Vivado Tcl Console after opening miniRV.xpr:
#   source rebuild_ego1_ila.tcl
#
# This enables the deterministic 200-bit Cache/UART ILA probe bus and then reuses the
# normal fresh-IP/synthesis/implementation flow.

set ::MINIRV_ENABLE_ILA 1
set wrapper_dir [file dirname [file normalize [info script]]]
source [file join $wrapper_dir rebuild_ego1.tcl]
unset ::MINIRV_ENABLE_ILA
