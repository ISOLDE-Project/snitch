################################################################
# configure board
set board_suffix zcu104
source ../../../board/xilinix_${board_suffix}.cfg
################################################################
################################################################
# configure bd_design
set block_design_name design_1
################################################################


source $project-$block_design_name-bd.tcl

set proj_dir [get_property directory [current_project]]
# Set IP repository paths
set obj [get_filesets sources_1]
if { $obj != {} } {
   set_property "ip_repo_paths" "[file normalize "$proj_dir/../../ip"]" $obj

   # Rebuild user ip_repo's index before adding any source files
   update_ip_catalog -rebuild
}


cr_bd_$::block_design_name ""


set proj_dir          [ get_property DIRECTORY [current_project] ]
set proj_name         [ get_property NAME [current_project] ]
set orig_proj_dir     "[file normalize "$proj_dir"]"
set bd_dir            $proj_dir/$proj_name.srcs/sources_1/bd/$block_design_name
set bd_filename       $bd_dir/$block_design_name.bd 


open_bd_design   $bd_filename
make_wrapper -files [get_files $bd_filename ] -top
add_files -norecurse          $bd_dir/hdl/${block_design_name}_wrapper.v

set_property top ${block_design_name}_wrapper [current_fileset]
update_compile_order -fileset sources_1

#launch_runs synth_1
#launch_runs impl_1 
launch_runs impl_1 -to_step write_bitstream 
wait_on_runs impl_1