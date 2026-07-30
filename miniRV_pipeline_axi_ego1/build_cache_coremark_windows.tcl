# Windows batch entry point for the Cache-enabled CoreMark EGO1 build.
set script_dir [file dirname [file normalize [info script]]]
set project_file [file join $script_dir miniRV.xpr]
set rebuild_script [file join $script_dir rebuild_ego1.tcl]

if {![file exists $project_file]} {
    error "Vivado project was not found: $project_file"
}
if {![file exists $rebuild_script]} {
    error "Rebuild script was not found: $rebuild_script"
}

open_project $project_file
source $rebuild_script
close_project
exit
