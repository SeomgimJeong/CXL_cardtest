#*******************************************************************************
#
#      This source code is provided to you (the Licensee) under license
#      by BittWare, a Molex Company.  To view or use this source code,
#      the Licensee must accept a Software License Agreement (viewable
#      at developer.bittware.com), which is commonly provided as a click-
#      through license agreement.  The terms of the Software License
#      Agreement govern all use and distribution of this file unless an
#      alternative superseding license has been executed with BittWare.
#      This source code and its derivatives may not be distributed to
#      third parties in source code form. Software including or derived
#      from this source code, including derivative works thereof created
#      by Licensee, may be distributed to third parties with BittWare
#      hardware only and in executable form only.
#
#      The click-through license is available here:
#        https://developer.bittware.com/software_license.txt
#
#*******************************************************************************
#      UNCLASSIFIED//FOR OFFICIAL USE ONLY
#*******************************************************************************
# Title       : IA-860m Pre Synthesis Timing Constraints
# Project     : IA-860m
#*******************************************************************************
# Description : Timing constraints - clock declarations
#*******************************************************************************
# Known Issues and Omissions:
#
#*******************************************************************************

#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3


#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {USR_CLK0}             -period  10.000 [get_ports USR_CLK0]
create_clock -name {USR_CLK1}             -period  10.000 [get_ports USR_CLK1]
create_clock -name {U1PPS}                -period 100.000 [get_ports U1PPS]
create_clock -name {CLKA}                 -period 100.000 [get_ports CLKA]
create_clock -name {PCIE_REFCLK0}         -period  10.000 [get_ports PCIE_REFCLK0]
create_clock -name {PCIE_REFCLK1}         -period  10.000 [get_ports PCIE_REFCLK1]
create_clock -name {QSFP0_REFCLK}         -period   6.400 [get_ports QSFP0_REFCLK]
create_clock -name {MCIO_REFCLK}          -period  10.000 [get_ports MCIO_REFCLK]
create_clock -name {QSFP1_REFCLK}         -period   6.400 [get_ports QSFP1_REFCLK]
create_clock -name {M2_REFCLK}	          -period  10.000 [get_ports M2_REFCLK]
create_clock -name {QSFP2_REFCLK}         -period   6.400 [get_ports QSFP2_REFCLK]
create_clock -name {EXT_SE_CLK}           -period   8.000 [get_ports EXT_SE_CLK]
create_clock -name {EXT_GPIO_IN0}         -period  16.000 [get_ports EXT_GPIO_IN[0]]
create_clock -name {EXT_GPIO_IN1}         -period  16.000 [get_ports EXT_GPIO_IN[1]]
create_clock -name {HBM_REFCLK0}          -period  10.000 [get_ports HBM_REFCLK0]
create_clock -name {HBM_FBR_REFCLK0}	  -period  10.000 [get_ports HBM_FBR_REFCLK0]
create_clock -name {HBM_REFCLK1}	      -period  10.000 [get_ports HBM_REFCLK1]
create_clock -name {HBM_FBR_REFCLK1}	  -period  10.000 [get_ports HBM_FBR_REFCLK1]
create_clock -name {NOC_CLK0}		      -period  10.000 [get_ports NOC_CLK0]
create_clock -name {NOC_CLK1}		      -period  10.000 [get_ports NOC_CLK1]
create_clock -name {HPS_DDR4_REFCLK}      -period   7.500 [get_ports HPS_DDR4_REFCLK]
create_clock -name {FPGA_IG_SPI_SCK}      -period  40.000 [get_ports FPGA_IG_SPI_SCK]
#create_clock -name {HPS_CLK}		       -period  40.000 [get_ports HPS_CLK]

# 24MHz
create_clock -name {altera_reserved_tck} -period 24MHz {altera_reserved_tck}

#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty

