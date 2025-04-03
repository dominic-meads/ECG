
################################################################
# This is a generated script based on design: ECG_bd
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2024.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source ECG_bd_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# AXIS_FIR_bp, iir_4th_order_bandpass_axis, axis_input_to_dual_output, axis_width_16_to_32, AXIS_square, AXIS_moving_average, axis_input_to_dual_output, axis_differentiator, axis_differentiator, AXIS_left_shift_multiply, AXIS_moving_average_2

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7s25csga324-1
   set_property BOARD_PART digilentinc.com:arty-s7-25:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name ECG_bd

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:axis_data_fifo:2.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
AXIS_FIR_bp\
iir_4th_order_bandpass_axis\
axis_input_to_dual_output\
axis_width_16_to_32\
AXIS_square\
AXIS_moving_average\
axis_input_to_dual_output\
axis_differentiator\
axis_differentiator\
AXIS_left_shift_multiply\
AXIS_moving_average_2\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set M_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {60000000} \
   ] $M_AXIS_0

  set M_AXIS_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_1 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {60000000} \
   ] $M_AXIS_1

  set m_axis_2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_2 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {60000000} \
   ] $m_axis_2

  set s_axis_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {60000000} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {0} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {2} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $s_axis_0


  # Create ports
  set sys_clock [ create_bd_port -dir I -type clk -freq_hz 12000000 sys_clock ]
  set_property -dict [ list \
   CONFIG.PHASE {0.0} \
 ] $sys_clock
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset

  # Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_1 ]
  set_property -dict [list \
    CONFIG.CLKIN1_JITTER_PS {833.33} \
    CONFIG.CLKOUT1_JITTER {501.246} \
    CONFIG.CLKOUT1_PHASE_ERROR {674.235} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {60} \
    CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {63.750} \
    CONFIG.MMCM_CLKIN1_PERIOD {83.333} \
    CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {12.750} \
    CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} \
    CONFIG.RESET_BOARD_INTERFACE {reset} \
    CONFIG.RESET_PORT {resetn} \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $clk_wiz_1


  # Create instance: AXIS_FIR_bp_0, and set properties
  set block_name AXIS_FIR_bp
  set block_cell_name AXIS_FIR_bp_0
  if { [catch {set AXIS_FIR_bp_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $AXIS_FIR_bp_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: iir_4th_order_bandpa_0, and set properties
  set block_name iir_4th_order_bandpass_axis
  set block_cell_name iir_4th_order_bandpa_0
  if { [catch {set iir_4th_order_bandpa_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $iir_4th_order_bandpa_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: axis_input_to_dual_o_0, and set properties
  set block_name axis_input_to_dual_output
  set block_cell_name axis_input_to_dual_o_0
  if { [catch {set axis_input_to_dual_o_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_input_to_dual_o_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  set_property -dict [ list \
   CONFIG.FREQ_HZ {60000000} \
 ] [get_bd_intf_pins /axis_input_to_dual_o_0/m_axis_0]

  set_property -dict [ list \
   CONFIG.FREQ_HZ {60000000} \
 ] [get_bd_intf_pins /axis_input_to_dual_o_0/m_axis_1]

  set_property -dict [ list \
   CONFIG.FREQ_HZ {60000000} \
 ] [get_bd_intf_pins /axis_input_to_dual_o_0/s_axis]

  # Create instance: axis_width_16_to_32_0, and set properties
  set block_name axis_width_16_to_32
  set block_cell_name axis_width_16_to_32_0
  if { [catch {set axis_width_16_to_32_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_width_16_to_32_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  set_property -dict [ list \
   CONFIG.FREQ_HZ {60000000} \
 ] [get_bd_intf_pins /axis_width_16_to_32_0/m_axis]

  set_property -dict [ list \
   CONFIG.FREQ_HZ {60000000} \
 ] [get_bd_intf_pins /axis_width_16_to_32_0/s_axis]

  # Create instance: AXIS_square_0, and set properties
  set block_name AXIS_square
  set block_cell_name AXIS_square_0
  if { [catch {set AXIS_square_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $AXIS_square_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: AXIS_moving_average_0, and set properties
  set block_name AXIS_moving_average
  set block_cell_name AXIS_moving_average_0
  if { [catch {set AXIS_moving_average_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $AXIS_moving_average_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: axis_input_to_dual_o_1, and set properties
  set block_name axis_input_to_dual_output
  set block_cell_name axis_input_to_dual_o_1
  if { [catch {set axis_input_to_dual_o_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_input_to_dual_o_1 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.WIDTH {32} $axis_input_to_dual_o_1


  set_property -dict [ list \
   CONFIG.FREQ_HZ {60000000} \
 ] [get_bd_intf_pins /axis_input_to_dual_o_1/m_axis_0]

  set_property -dict [ list \
   CONFIG.FREQ_HZ {60000000} \
 ] [get_bd_intf_pins /axis_input_to_dual_o_1/m_axis_1]

  set_property -dict [ list \
   CONFIG.FREQ_HZ {60000000} \
 ] [get_bd_intf_pins /axis_input_to_dual_o_1/s_axis]

  # Create instance: axis_differentiator_0, and set properties
  set block_name axis_differentiator
  set block_cell_name axis_differentiator_0
  if { [catch {set axis_differentiator_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_differentiator_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: axis_differentiator_1, and set properties
  set block_name axis_differentiator
  set block_cell_name axis_differentiator_1
  if { [catch {set axis_differentiator_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_differentiator_1 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.WIDTH {32} $axis_differentiator_1


  # Create instance: AXIS_left_shift_mult_0, and set properties
  set block_name AXIS_left_shift_multiply
  set block_cell_name AXIS_left_shift_mult_0
  if { [catch {set AXIS_left_shift_mult_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $AXIS_left_shift_mult_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  set_property -dict [ list \
   CONFIG.FREQ_HZ {60000000} \
 ] [get_bd_intf_pins /AXIS_left_shift_mult_0/m_axis]

  set_property -dict [ list \
   CONFIG.FREQ_HZ {60000000} \
 ] [get_bd_intf_pins /AXIS_left_shift_mult_0/s_axis]

  # Create instance: AXIS_moving_average_2_0, and set properties
  set block_name AXIS_moving_average_2
  set block_cell_name AXIS_moving_average_2_0
  if { [catch {set AXIS_moving_average_2_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $AXIS_moving_average_2_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_0 ]
  set_property -dict [list \
    CONFIG.FIFO_DEPTH {256} \
    CONFIG.TDATA_NUM_BYTES {4} \
  ] $axis_data_fifo_0


  # Create instance: axis_data_fifo_1, and set properties
  set axis_data_fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_1 ]
  set_property -dict [list \
    CONFIG.FIFO_DEPTH {128} \
    CONFIG.TDATA_NUM_BYTES {4} \
  ] $axis_data_fifo_1


  # Create interface connections
  connect_bd_intf_net -intf_net AXIS_FIR_bp_0_m_axis [get_bd_intf_pins AXIS_FIR_bp_0/m_axis] [get_bd_intf_pins axis_input_to_dual_o_0/s_axis]
  connect_bd_intf_net -intf_net AXIS_left_shift_mult_0_m_axis [get_bd_intf_pins AXIS_left_shift_mult_0/m_axis] [get_bd_intf_pins AXIS_moving_average_2_0/s_axis]
  connect_bd_intf_net -intf_net AXIS_moving_average_0_m_axis [get_bd_intf_pins AXIS_moving_average_0/m_axis] [get_bd_intf_pins axis_input_to_dual_o_1/s_axis]
  connect_bd_intf_net -intf_net AXIS_moving_average_2_0_m_axis [get_bd_intf_ports m_axis_2] [get_bd_intf_pins AXIS_moving_average_2_0/m_axis]
  connect_bd_intf_net -intf_net AXIS_square_0_m_axis [get_bd_intf_pins AXIS_square_0/m_axis] [get_bd_intf_pins AXIS_moving_average_0/s_axis]
  connect_bd_intf_net -intf_net axis_data_fifo_0_M_AXIS [get_bd_intf_ports M_AXIS_0] [get_bd_intf_pins axis_data_fifo_0/M_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_1_M_AXIS [get_bd_intf_ports M_AXIS_1] [get_bd_intf_pins axis_data_fifo_1/M_AXIS]
  connect_bd_intf_net -intf_net axis_differentiator_0_m_axis [get_bd_intf_pins axis_differentiator_0/m_axis] [get_bd_intf_pins AXIS_square_0/s_axis]
  connect_bd_intf_net -intf_net axis_differentiator_1_m_axis [get_bd_intf_pins AXIS_left_shift_mult_0/s_axis] [get_bd_intf_pins axis_differentiator_1/m_axis]
  connect_bd_intf_net -intf_net axis_input_to_dual_o_0_m_axis_0 [get_bd_intf_pins axis_input_to_dual_o_0/m_axis_0] [get_bd_intf_pins iir_4th_order_bandpa_0/s_axis]
  connect_bd_intf_net -intf_net axis_input_to_dual_o_0_m_axis_1 [get_bd_intf_pins axis_input_to_dual_o_0/m_axis_1] [get_bd_intf_pins axis_width_16_to_32_0/s_axis]
  connect_bd_intf_net -intf_net axis_input_to_dual_o_1_m_axis_0 [get_bd_intf_pins axis_input_to_dual_o_1/m_axis_0] [get_bd_intf_pins axis_differentiator_1/s_axis]
  connect_bd_intf_net -intf_net axis_input_to_dual_o_1_m_axis_1 [get_bd_intf_pins axis_input_to_dual_o_1/m_axis_1] [get_bd_intf_pins axis_data_fifo_1/S_AXIS]
  connect_bd_intf_net -intf_net axis_width_16_to_32_0_m_axis [get_bd_intf_pins axis_width_16_to_32_0/m_axis] [get_bd_intf_pins axis_data_fifo_0/S_AXIS]
  connect_bd_intf_net -intf_net iir_4th_order_bandpa_0_m_axis [get_bd_intf_pins iir_4th_order_bandpa_0/m_axis] [get_bd_intf_pins axis_differentiator_0/s_axis]
  connect_bd_intf_net -intf_net s_axis_0_1 [get_bd_intf_ports s_axis_0] [get_bd_intf_pins AXIS_FIR_bp_0/s_axis]

  # Create port connections
  connect_bd_net -net microblaze_0_Clk [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins iir_4th_order_bandpa_0/clk] [get_bd_pins AXIS_square_0/clk] [get_bd_pins axis_differentiator_0/clk] [get_bd_pins axis_differentiator_1/clk] [get_bd_pins AXIS_moving_average_0/clk] [get_bd_pins AXIS_moving_average_2_0/clk] [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins axis_data_fifo_1/s_axis_aclk] [get_bd_pins AXIS_FIR_bp_0/clk]
  connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins clk_wiz_1/resetn] [get_bd_pins iir_4th_order_bandpa_0/rst_n] [get_bd_pins AXIS_square_0/rst_n] [get_bd_pins axis_differentiator_0/rst_n] [get_bd_pins axis_differentiator_1/rst_n] [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins axis_data_fifo_1/s_axis_aresetn]
  connect_bd_net -net sys_clock_1 [get_bd_ports sys_clock] [get_bd_pins clk_wiz_1/clk_in1]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


