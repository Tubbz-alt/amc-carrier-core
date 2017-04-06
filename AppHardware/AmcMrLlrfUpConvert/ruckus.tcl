# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and constraints
loadSource -dir "$::DIR_PATH/core/"

# Load AMC BAY[0] constraints files
set rootName [file rootname [file tail $::DIR_PATH]]
if { $::env(AMC_TYPE_BAY0) == ${rootName} } {
   puts "\n\n AmcMrLlrfUpConvert is not supported in AMC BAY\[0\].\n\n"   
   exit -1
#   # Check the AMC card version
#   if { $::env(AMC_INTF_BAY0) == "Version1" } {
#      loadSource      -path "$::DIR_PATH/v1/AmcMrLlrfUpConvertMapping.vhd"
#      loadConstraints -path "$::DIR_PATH/v1/AmcMrLlrfUpConvertBay0Pinout.xdc"
#   } elseif { $::env(AMC_INTF_BAY0)  == "Version2" } {
#      loadSource      -path "$::DIR_PATH/v2/AmcMrLlrfUpConvertMapping.vhd"
#      loadConstraints -path "$::DIR_PATH/v2/AmcMrLlrfUpConvertBay0Pinout.xdc"
#   } else {
#      puts "\n\n $::env(AMC_INTF_BAY0) is an invalid AMC_INTF_BAY0 name. AMC_INTF_BAY0 can be \[Version1,Version2\]. Please fixed your target/makefile's.\n\n"   
#      exit -1
#   }
}

# Load AMC BAY[1] constraints files
if { $::env(AMC_TYPE_BAY1) == ${rootName} } {
   # Check the AMC card version
   if { $::env(AMC_INTF_BAY1) == "Version1" } {
      loadSource      -path "$::DIR_PATH/v1/AmcMrLlrfUpConvertMapping.vhd"
      loadConstraints -path "$::DIR_PATH/v1/AmcMrLlrfUpConvertBay1Pinout.xdc"
   } elseif { $::env(AMC_INTF_BAY1)  == "Version2" } {
      loadSource      -path "$::DIR_PATH/v2/AmcMrLlrfUpConvertMapping.vhd"
      loadConstraints -path "$::DIR_PATH/v2/AmcMrLlrfUpConvertBay1Pinout.xdc"
   } else {
      puts "\n\n $::env(AMC_INTF_BAY1) is an invalid AMC_INTF_BAY1 name. AMC_INTF_BAY1 can be \[Version1,Version2\]. Please fixed your target/makefile's.\n\n"   
      exit -1
   } 
}