
#set block_design_name design_1
set block_design_name [ get_property NAME [current_bd_design] ]
set proj_dir  [ get_property DIRECTORY [current_project] ]
set proj_name [ get_property NAME [current_project] ]
set orig_proj_dir "[file normalize "$proj_dir"]"
set out_file_prefix $proj_name-$block_design_name


open_bd_design   $proj_dir/$proj_name.srcs/sources_1/bd/$block_design_name/$block_design_name.bd 
#write_project_tcl -target_proj_dir "$orig_proj_dir" -force $proj_dir-$proj_name-export.tcl
#puts [ format "%s -- done" $proj_dir-$proj_name-export.tcl ]

set filename  $out_file_prefix-bd.tcl
write_bd_tcl -force -no_project_wrapper -include_layout ./$filename
puts [ format "%s -- done" ./$filename ]
#
#set filename  $proj_dir-$proj_name-properties.txt
#set info [report_property -return_string  [current_project] ]
#set fp [open ./$filename "w+"] 
#puts $fp $info
#close $fp
#
set filename  $out_file_prefix-layout.pdf
puts [ format "%s -- done" ./$filename]
write_bd_layout -force -format pdf -orientation landscape ./$filename
set filename  $out_file_prefix-layout.svg
write_bd_layout -force -format svg -orientation landscape ./$filename