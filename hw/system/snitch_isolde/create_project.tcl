################################################################
# configure board
set board_suffix zcu104
source ../../../board/xilinix_${board_suffix}.cfg
################################################################
create_project $project  ./vivado/$project  -part $part  -force
source generated/sources.tcl
set_property top snitch_cluster_wrapper [current_fileset]
update_compile_order -fileset sources_1
if {[regexp -nocase {.*board_part.*} [list_property [current_project]]]} {
  set_property board_part $board [current_project]
} else {
  set_property board $board [current_project]
}