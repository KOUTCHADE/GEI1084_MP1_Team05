set root [file dirname [file normalize [info script]]]
set project_dir [file join $root "Vivado_Project"]
create_project ARMTop_R14 $project_dir -force
set_property target_language VHDL [current_project]

set design_files {}
foreach f [glob -nocomplain -directory $root *.vhd] {
    if {[file tail $f] ni {"tb_arm_top.vhd" "tb_arm_top_bl.vhd" "tb_condcheck.vhd" "tb_condlogic.vhd" "tb_flag_registers.vhd"}} {
        lappend design_files $f
    }
}
add_files -fileset sources_1 $design_files
set_property top arm_top [get_filesets sources_1]

add_files -fileset sim_1 [file join $root "tb_arm_top_bl.vhd"]
set_property top tb_arm_top_bl [get_filesets sim_1]
set_property xsim.simulate.runtime 110ns [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
save_project -name ARMTop_R14
puts "Projet ARMTop_R14 cree dans $project_dir"
