# ------------------------------------------------------------------------------ #
# --
# --      This source code is provided to you (the Licensee) under license
# --      by BittWare, a Molex Company.  To view or use this source code,
# --      the Licensee must accept a Software License Agreement (viewable
# --      at developer.bittware.com), which is commonly provided as a click-
# --      through license agreement.  The terms of the Software License
# --      Agreement govern all use and distribution of this file unless an
# --      alternative superseding license has been executed with BittWare.
# --      This source code and its derivatives may not be distributed to
# --      third parties in source code form. Software including or derived
# --      from this source code, including derivative works thereof created
# --      by Licensee, may be distributed to third parties with BittWare
# --      hardware only and in executable form only.
# --
# --      The click-through license is available here:
# --        https://developer.bittware.com/software_license.txt
# --
# ------------------------------------------------------------------------------ #
# --      UNCLASSIFIED//FOR OFFICIAL USE ONLY
# ------------------------------------------------------------------------------ #
# -- Title       : IA-860m
# -- Project     : IA-860m
# ------------------------------------------------------------------------------ #
# -- Description : Pinout and constraints for the IA-860m (BBRev4)
# ------------------------------------------------------------------------------ #
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
# Current device being tested.  Future devices could include higher speed-grade part
# plus production silicon (when available).
set_global_assignment -name DEVICE AGMF039R47A2E2VC
set_global_assignment -name FAMILY "Agilex 7"

set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1
set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"
set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-12"

set_global_assignment -name AUTO_RESTART_CONFIGURATION OFF
set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME "AVST X8"
set_global_assignment -name USE_PWRMGT_SCL SDM_IO0
set_global_assignment -name USE_PWRMGT_SDA SDM_IO12
set_global_assignment -name USE_PWRMGT_ALERT SDM_IO9
set_global_assignment -name USE_CONF_DONE SDM_IO16
set_global_assignment -name USE_INIT_DONE SDM_IO5
set_global_assignment -name USE_HPS_COLD_RESET SDM_IO7
set_global_assignment -name DEVICE_INITIALIZATION_CLOCK OSC_CLK_1_125MHZ
set_global_assignment -name VID_OPERATION_MODE "PMBUS SLAVE"
set_global_assignment -name PWRMGT_DEVICE_ADDRESS_IN_PMBUS_SLAVE_MODE 01
set_global_assignment -name GENERATE_PR_RBF_FILE ON

set_global_assignment -name MINIMUM_SEU_INTERVAL 0

set_global_assignment -name OPTIMIZATION_MODE "SUPERIOR PERFORMANCE WITH MAXIMUM PLACEMENT EFFORT"
set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL

set_global_assignment -name PRESERVE_UNUSED_XCVR_CHANNEL ON

##########################################################
# F-Tile 12A
##########################################################
# QSFPDD0 
# Reference Clock
set_location_assignment PIN_DK59 -to QSFP0_REFCLK
#set_location_assignment PIN_DJ60 -to QSFP0_REFCLK(n)
#
# Recovered Clocks
#set_location_assignment PIN_CR60 -to RECV0_CLK
#set_location_assignment PIN_CT59 -to RECV0_CLK(n)
#
# RX Ports
set_location_assignment PIN_CM69 -to QSFP0_RX_P[0]
set_location_assignment PIN_CL68 -to QSFP0_RX_N[0]
set_location_assignment PIN_CT69 -to QSFP0_RX_P[1]
set_location_assignment PIN_CR68 -to QSFP0_RX_N[1]
set_location_assignment PIN_CY69 -to QSFP0_RX_P[2]
set_location_assignment PIN_CW68 -to QSFP0_RX_N[2]
set_location_assignment PIN_DD69 -to QSFP0_RX_P[3]
set_location_assignment PIN_DC68 -to QSFP0_RX_N[3]
set_location_assignment PIN_DH69 -to QSFP0_RX_P[4]
set_location_assignment PIN_DG68 -to QSFP0_RX_N[4]
set_location_assignment PIN_DJ66 -to QSFP0_RX_P[5]
set_location_assignment PIN_DK65 -to QSFP0_RX_N[5]
set_location_assignment PIN_DM69 -to QSFP0_RX_P[6]
set_location_assignment PIN_DL68 -to QSFP0_RX_N[6]
set_location_assignment PIN_DN66 -to QSFP0_RX_P[7]
set_location_assignment PIN_DP65 -to QSFP0_RX_N[7]
#
# TX Ports
set_location_assignment PIN_CM63 -to QSFP0_TX_P[0]	   
set_location_assignment PIN_CL62 -to QSFP0_TX_N[0]
set_location_assignment PIN_CN66 -to QSFP0_TX_P[1]	   
set_location_assignment PIN_CP65 -to QSFP0_TX_N[1]
set_location_assignment PIN_CT63 -to QSFP0_TX_P[2]	   
set_location_assignment PIN_CR62 -to QSFP0_TX_N[2]
set_location_assignment PIN_CU66 -to QSFP0_TX_P[3]	   
set_location_assignment PIN_CV65 -to QSFP0_TX_N[3]
set_location_assignment PIN_CY63 -to QSFP0_TX_P[4]	   
set_location_assignment PIN_CW62 -to QSFP0_TX_N[4]
set_location_assignment PIN_DA66 -to QSFP0_TX_P[5]	   
set_location_assignment PIN_DB65 -to QSFP0_TX_N[5]
set_location_assignment PIN_DD63 -to QSFP0_TX_P[6]	   
set_location_assignment PIN_DC62 -to QSFP0_TX_N[6]
set_location_assignment PIN_DE66 -to QSFP0_TX_P[7]	   
set_location_assignment PIN_DF65 -to QSFP0_TX_N[7]	    
#
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP0_RX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP0_RX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP0_RX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP0_RX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP0_RX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP0_RX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP0_RX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP0_RX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP0_RX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP0_RX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP0_RX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP0_RX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP0_RX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP0_RX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP0_RX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP0_RX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP0_RX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP0_RX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP0_RX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP0_RX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP0_RX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP0_RX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP0_RX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP0_RX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP0_TX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP0_TX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP0_TX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP0_TX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP0_TX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP0_TX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP0_TX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP0_TX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP0_TX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP0_TX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP0_TX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP0_TX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP0_TX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP0_TX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP0_TX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP0_TX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP0_TX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP0_TX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP0_TX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP0_TX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP0_TX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP0_TX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP0_TX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP0_TX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP0_TX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP0_TX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP0_TX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP0_TX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP0_TX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP0_TX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP0_TX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP0_TX_P[7] 

##########################################################

##########################################################
# F-Tile 13A
##########################################################

# MCIO
# Reference Clocks
set_location_assignment PIN_CT13 -to MCIO_REFCLK
#set_location_assignment PIN_CU14 -to MCIO_REFCLK(n)
#
# PERST
#set_location_assignment PIN_EK19 -to MCIO_PERST_N
#
# RX Ports
#set_location_assignment PIN_CP1 -to MCIO_RX_P[0]
#set_location_assignment PIN_CN2 -to MCIO_RX_N[0]
#set_location_assignment PIN_CR4 -to MCIO_RX_P[1]
#set_location_assignment PIN_CT5 -to MCIO_RX_N[1]
#set_location_assignment PIN_CV1 -to MCIO_RX_P[2]
#set_location_assignment PIN_CU2 -to MCIO_RX_N[2]
#set_location_assignment PIN_CW4 -to MCIO_RX_P[3]
#set_location_assignment PIN_CY5 -to MCIO_RX_N[3]
#set_location_assignment PIN_DB1 -to MCIO_RX_P[4]
#set_location_assignment PIN_DA2 -to MCIO_RX_N[4]
#set_location_assignment PIN_DC4 -to MCIO_RX_P[5]
#set_location_assignment PIN_DD5 -to MCIO_RX_N[5]
#set_location_assignment PIN_DF1 -to MCIO_RX_P[6]
#set_location_assignment PIN_DE2 -to MCIO_RX_N[6]
#set_location_assignment PIN_DG4 -to MCIO_RX_P[7]
#set_location_assignment PIN_DH5 -to MCIO_RX_N[7]
#
# TX Ports
#set_location_assignment PIN_CL10 -to MCIO_TX_P[0]
#set_location_assignment PIN_CM11 -to MCIO_TX_N[0]
#set_location_assignment PIN_CP7  -to MCIO_TX_P[1]
#set_location_assignment PIN_CN8  -to MCIO_TX_N[1]
#set_location_assignment PIN_CR10 -to MCIO_TX_P[2]
#set_location_assignment PIN_CT11 -to MCIO_TX_N[2]
#set_location_assignment PIN_CV7  -to MCIO_TX_P[3]
#set_location_assignment PIN_CU8  -to MCIO_TX_N[3]
#set_location_assignment PIN_CW10 -to MCIO_TX_P[4]
#set_location_assignment PIN_CY11 -to MCIO_TX_N[4]
#set_location_assignment PIN_DB7  -to MCIO_TX_P[5]
#set_location_assignment PIN_DA8  -to MCIO_TX_N[5]
#set_location_assignment PIN_DC10 -to MCIO_TX_P[6]
#set_location_assignment PIN_DD11 -to MCIO_TX_N[6]
#set_location_assignment PIN_DF7  -to MCIO_TX_P[7]
#set_location_assignment PIN_DE8  -to MCIO_TX_N[7]
#
#set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to MCIO_RX_P[0] 
#set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to MCIO_RX_P[0] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to MCIO_TX_P[0] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to MCIO_TX_P[0] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to MCIO_TX_P[0] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to MCIO_TX_P[0] 
#set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to MCIO_RX_P[1] 
#set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to MCIO_RX_P[1] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to MCIO_TX_P[1] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to MCIO_TX_P[1] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to MCIO_TX_P[1] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to MCIO_TX_P[1] 
#set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to MCIO_RX_P[2] 
#set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to MCIO_RX_P[2] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to MCIO_TX_P[2] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to MCIO_TX_P[2] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to MCIO_TX_P[2] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to MCIO_TX_P[2] 
#set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to MCIO_RX_P[3] 
#set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to MCIO_RX_P[3] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to MCIO_TX_P[3] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to MCIO_TX_P[3] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to MCIO_TX_P[3] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to MCIO_TX_P[3] 
#set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to MCIO_RX_P[4] 
#set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to MCIO_RX_P[4] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to MCIO_TX_P[4] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to MCIO_TX_P[4] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to MCIO_TX_P[4] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to MCIO_TX_P[4] 
#set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to MCIO_RX_P[5] 
#set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to MCIO_RX_P[5] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to MCIO_TX_P[5] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to MCIO_TX_P[5] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to MCIO_TX_P[5] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to MCIO_TX_P[5] 
#set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to MCIO_RX_P[6] 
#set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to MCIO_RX_P[6] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to MCIO_TX_P[6] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to MCIO_TX_P[6] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to MCIO_TX_P[6] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to MCIO_TX_P[6] 
#set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to MCIO_RX_P[7] 
#set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to MCIO_RX_P[7] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to MCIO_TX_P[7] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to MCIO_TX_P[7] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to MCIO_TX_P[7] 
#set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to MCIO_TX_P[7] 
#
# QSFPDD1 
# Reference Clock
set_location_assignment PIN_DE14 -to QSFP1_REFCLK
#set_location_assignment PIN_DF13 -to QSFP1_REFCLK(n)
#
# Recovered Clocks
#set_location_assignment PIN_DY13 -to RECV1_CLK
#set_location_assignment PIN_EA14 -to RECV1_CLK(n)
#
# RX Ports
set_location_assignment PIN_EC4  -to QSFP1_RX_P[0]
set_location_assignment PIN_ED5  -to QSFP1_RX_N[0]
set_location_assignment PIN_EB1  -to QSFP1_RX_P[1]
set_location_assignment PIN_EA2  -to QSFP1_RX_N[1]
set_location_assignment PIN_DW4  -to QSFP1_RX_P[2]
set_location_assignment PIN_DY5  -to QSFP1_RX_N[2]
set_location_assignment PIN_DV1  -to QSFP1_RX_P[3]
set_location_assignment PIN_DU2  -to QSFP1_RX_N[3]
set_location_assignment PIN_DR4  -to QSFP1_RX_P[4]
set_location_assignment PIN_DT5  -to QSFP1_RX_N[4]
set_location_assignment PIN_DP1  -to QSFP1_RX_P[5]
set_location_assignment PIN_DN2  -to QSFP1_RX_N[5]
set_location_assignment PIN_DL4  -to QSFP1_RX_P[6]
set_location_assignment PIN_DM5  -to QSFP1_RX_N[6]
set_location_assignment PIN_DK1  -to QSFP1_RX_P[7]
set_location_assignment PIN_DJ2  -to QSFP1_RX_N[7]
#
# TX Ports
set_location_assignment PIN_EB7  -to QSFP1_TX_P[0]
set_location_assignment PIN_EA8  -to QSFP1_TX_N[0]
set_location_assignment PIN_DW10 -to QSFP1_TX_P[1]
set_location_assignment PIN_DY11 -to QSFP1_TX_N[1]
set_location_assignment PIN_DV7  -to QSFP1_TX_P[2]
set_location_assignment PIN_DU8  -to QSFP1_TX_N[2]
set_location_assignment PIN_DR10 -to QSFP1_TX_P[3]
set_location_assignment PIN_DT11 -to QSFP1_TX_N[3]
set_location_assignment PIN_DP7  -to QSFP1_TX_P[4]
set_location_assignment PIN_DN8  -to QSFP1_TX_N[4]
set_location_assignment PIN_DL10 -to QSFP1_TX_P[5]
set_location_assignment PIN_DM11 -to QSFP1_TX_N[5]
set_location_assignment PIN_DK7  -to QSFP1_TX_P[6]
set_location_assignment PIN_DJ8  -to QSFP1_TX_N[6]
set_location_assignment PIN_DG10 -to QSFP1_TX_P[7]
set_location_assignment PIN_DH11 -to QSFP1_TX_N[7]
#
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP1_RX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP1_RX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP1_RX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP1_RX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP1_RX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP1_RX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP1_RX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP1_RX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP1_RX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP1_RX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP1_RX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP1_RX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP1_RX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP1_RX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP1_RX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP1_RX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP1_RX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP1_RX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP1_RX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP1_RX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP1_RX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP1_RX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP1_RX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP1_RX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP1_TX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP1_TX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP1_TX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP1_TX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP1_TX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP1_TX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP1_TX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP1_TX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP1_TX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP1_TX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP1_TX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP1_TX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP1_TX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP1_TX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP1_TX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP1_TX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP1_TX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP1_TX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP1_TX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP1_TX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP1_TX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP1_TX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP1_TX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP1_TX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP1_TX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP1_TX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP1_TX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP1_TX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP1_TX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP1_TX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP1_TX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP1_TX_P[7] 

##########################################################

##########################################################
# F-Tile 13C
##########################################################

# M.2 SSD 
# Reference Clock
set_location_assignment PIN_AU14 -to M2_REFCLK
#set_location_assignment PIN_AW14 -to M2_REFCLK(n)
#
# PERST
#set_location_assignment PIN_AY17 -to M2_PERST_N
#
# RX Ports
#set_location_assignment PIN_AB7 -to M2SSD_RX_P[0]
#set_location_assignment PIN_AC8 -to M2SSD_RX_N[0]
#set_location_assignment PIN_AF7 -to M2SSD_RX_P[1]
#set_location_assignment PIN_AG8 -to M2SSD_RX_N[1]
#set_location_assignment PIN_AE4 -to M2SSD_RX_P[2]
#set_location_assignment PIN_AD5 -to M2SSD_RX_N[2]
#set_location_assignment PIN_AJ4 -to M2SSD_RX_P[3]
#set_location_assignment PIN_AH5 -to M2SSD_RX_N[3]
#
# TX Ports
#set_location_assignment PIN_AB13 -to M2SSD_TX_P[0]
#set_location_assignment PIN_AC14 -to M2SSD_TX_N[0]
#set_location_assignment PIN_AF13 -to M2SSD_TX_P[1]
#set_location_assignment PIN_AG14 -to M2SSD_TX_N[1]
#set_location_assignment PIN_AE10 -to M2SSD_TX_P[2]
#set_location_assignment PIN_AD11 -to M2SSD_TX_N[2]
#set_location_assignment PIN_AJ10 -to M2SSD_TX_P[3]
#set_location_assignment PIN_AH11 -to M2SSD_TX_N[3]
#
# QSFPDD2
# Reference Clocks
set_location_assignment PIN_BW14 -to QSFP2_REFCLK
#set_location_assignment PIN_BY13 -to QSFP2_REFCLK(n)
#
# Recovered Clocks
#set_location_assignment PIN_BT11 -to RECV2_CLK
#set_location_assignment PIN_BU10 -to RECV2_CLK(n)
#
# RX Ports
set_location_assignment PIN_BK1 -to QSFP2_RX_P[0]
set_location_assignment PIN_BL2 -to QSFP2_RX_N[0]
set_location_assignment PIN_BF1 -to QSFP2_RX_P[1]
set_location_assignment PIN_BG2 -to QSFP2_RX_N[1]
set_location_assignment PIN_BJ4 -to QSFP2_RX_P[2]
set_location_assignment PIN_BH5 -to QSFP2_RX_N[2]
set_location_assignment PIN_BB1 -to QSFP2_RX_P[3]
set_location_assignment PIN_BC2 -to QSFP2_RX_N[3]
set_location_assignment PIN_BE4 -to QSFP2_RX_P[4]
set_location_assignment PIN_BD5 -to QSFP2_RX_N[4]
set_location_assignment PIN_AV1 -to QSFP2_RX_P[5]
set_location_assignment PIN_AW2 -to QSFP2_RX_N[5]
set_location_assignment PIN_BA4 -to QSFP2_RX_P[6]
set_location_assignment PIN_AY5 -to QSFP2_RX_N[6]
set_location_assignment PIN_AP1 -to QSFP2_RX_P[7]
set_location_assignment PIN_AR2 -to QSFP2_RX_N[7]
#
# TX Ports
set_location_assignment PIN_BP7  -to QSFP2_TX_P[0]
set_location_assignment PIN_BR8  -to QSFP2_TX_N[0]
set_location_assignment PIN_BK7  -to QSFP2_TX_P[1]
set_location_assignment PIN_BL8  -to QSFP2_TX_N[1]
set_location_assignment PIN_BJ10 -to QSFP2_TX_P[2]
set_location_assignment PIN_BH11 -to QSFP2_TX_N[2]
set_location_assignment PIN_BF7  -to QSFP2_TX_P[3]
set_location_assignment PIN_BG8  -to QSFP2_TX_N[3]
set_location_assignment PIN_BE10 -to QSFP2_TX_P[4]
set_location_assignment PIN_BD11 -to QSFP2_TX_N[4]
set_location_assignment PIN_BB7  -to QSFP2_TX_P[5]
set_location_assignment PIN_BC8  -to QSFP2_TX_N[5]
set_location_assignment PIN_BA10 -to QSFP2_TX_P[6]
set_location_assignment PIN_AY11 -to QSFP2_TX_N[6]
set_location_assignment PIN_AV7  -to QSFP2_TX_P[7]
set_location_assignment PIN_AW8  -to QSFP2_TX_N[7]
#
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP2_RX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP2_RX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP2_RX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP2_RX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP2_RX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP2_RX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP2_RX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP2_RX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP2_RX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP2_RX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP2_RX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP2_RX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP2_RX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP2_RX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP2_RX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP2_RX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP2_RX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP2_RX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP2_RX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP2_RX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP2_RX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP2_RX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP2_RX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP2_RX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP2_TX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP2_TX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP2_TX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP2_TX_P[0] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP2_TX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP2_TX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP2_TX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP2_TX_P[1] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP2_TX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP2_TX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP2_TX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP2_TX_P[2] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP2_TX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP2_TX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP2_TX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP2_TX_P[3] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP2_TX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP2_TX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP2_TX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP2_TX_P[4] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP2_TX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP2_TX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP2_TX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP2_TX_P[5] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP2_TX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP2_TX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP2_TX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP2_TX_P[6] 
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to QSFP2_TX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to QSFP2_TX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to QSFP2_TX_P[7] 
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to QSFP2_TX_P[7] 

##########################################################

##########################################################
# R-Tile 14C
##########################################################

# Reference Clocks
set_location_assignment PIN_BY59 -to PCIE_REFCLK0
#set_location_assignment PIN_CA60 -to PCIE_REFCLK0(n)
set_location_assignment PIN_BU60 -to PCIE_REFCLK1
#set_location_assignment PIN_BT59 -to PCIE_REFCLK1(n)
#
# PERST
set_location_assignment PIN_AP53 -to PERST_L
#
# RX Ports
set_location_assignment PIN_CH69 -to PCIE_RX_P[0]
set_location_assignment PIN_CG68 -to PCIE_RX_N[0]
set_location_assignment PIN_CD69 -to PCIE_RX_P[1]
set_location_assignment PIN_CC68 -to PCIE_RX_N[1]
set_location_assignment PIN_BY69 -to PCIE_RX_P[2]
set_location_assignment PIN_BW68 -to PCIE_RX_N[2]
set_location_assignment PIN_BU66 -to PCIE_RX_P[3]
set_location_assignment PIN_BV65 -to PCIE_RX_N[3]
set_location_assignment PIN_BT69 -to PCIE_RX_P[4]
set_location_assignment PIN_BR68 -to PCIE_RX_N[4]
set_location_assignment PIN_BN66 -to PCIE_RX_P[5]
set_location_assignment PIN_BP65 -to PCIE_RX_N[5]
set_location_assignment PIN_BM69 -to PCIE_RX_P[6]
set_location_assignment PIN_BL68 -to PCIE_RX_N[6]
set_location_assignment PIN_BJ66 -to PCIE_RX_P[7]
set_location_assignment PIN_BK65 -to PCIE_RX_N[7]
set_location_assignment PIN_BH69 -to PCIE_RX_P[8]
set_location_assignment PIN_BG68 -to PCIE_RX_N[8]
set_location_assignment PIN_BE66 -to PCIE_RX_P[9]
set_location_assignment PIN_BF65 -to PCIE_RX_N[9]
set_location_assignment PIN_BD69 -to PCIE_RX_P[10]
set_location_assignment PIN_BC68 -to PCIE_RX_N[10]
set_location_assignment PIN_BA66 -to PCIE_RX_P[11]
set_location_assignment PIN_BB65 -to PCIE_RX_N[11]
set_location_assignment PIN_AY69 -to PCIE_RX_P[12]
set_location_assignment PIN_AW68 -to PCIE_RX_N[12]
set_location_assignment PIN_AU66 -to PCIE_RX_P[13]
set_location_assignment PIN_AV65 -to PCIE_RX_N[13]
set_location_assignment PIN_AT69 -to PCIE_RX_P[14]
set_location_assignment PIN_AR68 -to PCIE_RX_N[14]
set_location_assignment PIN_AN66 -to PCIE_RX_P[15]
set_location_assignment PIN_AP65 -to PCIE_RX_N[15]
#
# TX Ports
set_location_assignment PIN_CJ66 -to PCIE_TX_P[0]
set_location_assignment PIN_CK65 -to PCIE_TX_N[0]
set_location_assignment PIN_CH63 -to PCIE_TX_P[1]
set_location_assignment PIN_CG62 -to PCIE_TX_N[1]
set_location_assignment PIN_CE66 -to PCIE_TX_P[2]
set_location_assignment PIN_CF65 -to PCIE_TX_N[2]
set_location_assignment PIN_CD63 -to PCIE_TX_P[3]
set_location_assignment PIN_CC62 -to PCIE_TX_N[3]
set_location_assignment PIN_CA66 -to PCIE_TX_P[4]
set_location_assignment PIN_CB65 -to PCIE_TX_N[4]
set_location_assignment PIN_BY63 -to PCIE_TX_P[5]
set_location_assignment PIN_BW62 -to PCIE_TX_N[5]
set_location_assignment PIN_BT63 -to PCIE_TX_P[6]
set_location_assignment PIN_BR62 -to PCIE_TX_N[6]
set_location_assignment PIN_BM63 -to PCIE_TX_P[7]
set_location_assignment PIN_BL62 -to PCIE_TX_N[7]
set_location_assignment PIN_BH63 -to PCIE_TX_P[8]
set_location_assignment PIN_BG62 -to PCIE_TX_N[8]
set_location_assignment PIN_BE60 -to PCIE_TX_P[9]
set_location_assignment PIN_BF59 -to PCIE_TX_N[9]
set_location_assignment PIN_BD63 -to PCIE_TX_P[10]
set_location_assignment PIN_BC62 -to PCIE_TX_N[10]
set_location_assignment PIN_BA60 -to PCIE_TX_P[11]
set_location_assignment PIN_BB59 -to PCIE_TX_N[11]
set_location_assignment PIN_AY63 -to PCIE_TX_P[12]
set_location_assignment PIN_AW62 -to PCIE_TX_N[12]
set_location_assignment PIN_AU60 -to PCIE_TX_P[13]
set_location_assignment PIN_AV59 -to PCIE_TX_N[13]
set_location_assignment PIN_AT63 -to PCIE_TX_P[14]
set_location_assignment PIN_AR62 -to PCIE_TX_N[14]
set_location_assignment PIN_AN60 -to PCIE_TX_P[15]
set_location_assignment PIN_AP59 -to PCIE_TX_N[15]

##########################################################

##########################################################
# Bank 2A
##########################################################

# Clocks
set_location_assignment PIN_FC52 -to CLKA
set_location_assignment PIN_FJ58 -to USR_CLK0
#set_location_assignment PIN_FH57 -to USR_CLK0(n)
set_location_assignment PIN_EY61 -to U1PPS

set_instance_assignment -name IO_STANDARD 1.2V -to CLKA
set_instance_assignment -name IO_STANDARD 1.2V -to U1PPS

#
set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to USR_CLK0 
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to USR_CLK0
#
# Resets
set_location_assignment PIN_FV63 -to FPGA_RST_L
set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_RST_L 
#
# BMC SPI Ingress
set_location_assignment PIN_FJ62 -to FPGA_IG_SPI_SCK
set_location_assignment PIN_FE60 -to FPGA_IG_SPI_PCS0
set_location_assignment PIN_FF59 -to FPGA_IG_SPI_MOSI
set_location_assignment PIN_FH61 -to FPGA_IG_SPI_MISO
set_location_assignment PIN_FM57 -to FPGA_TO_BMC_IRQ

set_instance_assignment -name AUTO_GLOBAL_CLOCK ON -to FPGA_IG_SPI_SCK

set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to FPGA_IG_SPI_MISO
set_instance_assignment -name FAST_INPUT_REGISTER ON -to FPGA_IG_SPI_MOSI

set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_IG_SPI_SCK
set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_IG_SPI_PCS0
set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_IG_SPI_MOSI
set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_IG_SPI_MISO
set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_TO_BMC_IRQ

#
# BMC SPI Egress
set_location_assignment PIN_FR58 -to FPGA_EG_SPI_SCK
set_location_assignment PIN_FF61 -to FPGA_EG_SPI_PCS0
set_location_assignment PIN_FE62 -to FPGA_EG_SPI_MOSI
set_location_assignment PIN_FP57 -to FPGA_EG_SPI_MISO
set_location_assignment PIN_FF57 -to BMC_TO_FPGA_IRQ

set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_EG_SPI_SCK
set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_EG_SPI_PCS0
set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_EG_SPI_MOSI
set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_EG_SPI_MISO
set_instance_assignment -name IO_STANDARD 1.2V -to BMC_TO_FPGA_IRQ

#
# BMC General
set_location_assignment PIN_FM59 -to BMC_IF_PRESENT_L

set_instance_assignment -name IO_STANDARD 1.2V -to BMC_IF_PRESENT_L

#
# GPIO
set_location_assignment PIN_FF55 -to EXT_SE_CLK
set_location_assignment PIN_FL56 -to EXT_GPIO_IN[0]
set_location_assignment PIN_FP55 -to EXT_GPIO_IN[1]
set_location_assignment PIN_FL54 -to EXT_GPIO_OUT

set_instance_assignment -name IO_STANDARD 1.2V -to EXT_SE_CLK
set_instance_assignment -name IO_STANDARD 1.2V -to EXT_GPIO_IN
set_instance_assignment -name IO_STANDARD 1.2V -to EXT_GPIO_OUT

#
# LEDs
set_location_assignment PIN_FC62 -to FPGA_LED_G_L
set_location_assignment PIN_FB61 -to FPGA_LED_R_L

set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_LED_G_L
set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_LED_R_L
#
# DDR4 Test Enable
set_location_assignment PIN_EY57 -to DDR4_TEN

set_instance_assignment -name IO_STANDARD 1.2V -to DDR4_TEN

#
# MCIO Sideband
#set_location_assignment PIN_FL52 -to MCIO_1V2_CWAKEA
#set_location_assignment PIN_FM51 -to MCIO_1V2_BP_TYPEA
#set_location_assignment PIN_FR52 -to MCIO_1V2_CPRSNTA
#
#set_instance_assignment -name IO_STANDARD 1.2V -to MCIO_1V2_CWAKEA
#set_instance_assignment -name IO_STANDARD 1.2V -to MCIO_1V2_BP_TYPEA
#set_instance_assignment -name IO_STANDARD 1.2V -to MCIO_1V2_CPRSNTA
#
#set_location_assignment PIN_FU58 -to MCIO_1V2_CWAKEB
#set_location_assignment PIN_FV57 -to MCIO_1V2_BP_TYPEB
#set_location_assignment PIN_GA58 -to MCIO_1V2_CPRSNTB
#
#set_instance_assignment -name IO_STANDARD 1.2V -to MCIO_1V2_CWAKEB
#set_instance_assignment -name IO_STANDARD 1.2V -to MCIO_1V2_BP_TYPEB
#set_instance_assignment -name IO_STANDARD 1.2V -to MCIO_1V2_CPRSNTB
#
#set_location_assignment PIN_FC56 -to NCIO_1V2_I2C0_SCL
#set_location_assignment PIN_FB55 -to MCIO_1V2_I2C0_SDA
#set_location_assignment PIN_FV55 -to NCIO_1V2_I2C1_SCL
#set_location_assignment PIN_FU56 -to MCIO_1V2_I2C1_SDA
#
#set_instance_assignment -name IO_STANDARD 1.2V -to NCIO_1V2_I2C0_SCL
#set_instance_assignment -name IO_STANDARD 1.2V -to MCIO_1V2_I2C0_SDA
#set_instance_assignment -name IO_STANDARD 1.2V -to NCIO_1V2_I2C1_SCL
#set_instance_assignment -name IO_STANDARD 1.2V -to MCIO_1V2_I2C1_SDA
#
# Startup Signals
set_location_assignment PIN_FU60 -to MCIO_GPIO_EN_L
set_location_assignment PIN_GA60 -to EXT_GPIO_EN_L
set_location_assignment PIN_FY59 -to MCIO_I2C_EN

set_instance_assignment -name IO_STANDARD 1.2V -to MCIO_GPIO_EN_L
set_instance_assignment -name IO_STANDARD 1.2V -to EXT_GPIO_EN_L
set_instance_assignment -name IO_STANDARD 1.2V -to MCIO_I2C_EN

##########################################################

##########################################################
# Bank 2B
##########################################################

##########################################################

##########################################################
# Bank 2C
##########################################################

##########################################################

##########################################################
# Bank 2D
##########################################################

##########################################################

##########################################################
# Bank 3A
##########################################################

set_location_assignment PIN_W58 -to USR_CLK1
#set_location_assignment PIN_Y59 -to USR_CLK1(n)

set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to USR_CLK1
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to USR_CLK1

##########################################################

##########################################################
# Bank 3B
##########################################################

##########################################################

##########################################################
# Bank 3C
##########################################################

##########################################################

##########################################################
# Bank 3D
##########################################################

#
# HPS DDR4 SDRAM
# Reference Clock
set_location_assignment PIN_Y25 -to HPS_DDR4_REFCLK
set_location_assignment PIN_W24 -to HPS_DDR4_REFCLK(n)
set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to HPS_DDR4_REFCLK 

#
# Address/Control
set_location_assignment PIN_N24  -to HPS_DDR4_A[0]
set_location_assignment PIN_P25  -to HPS_DDR4_A[1]
set_location_assignment PIN_T25  -to HPS_DDR4_A[2]
set_location_assignment PIN_U24  -to HPS_DDR4_A[3]
set_location_assignment PIN_N22  -to HPS_DDR4_A[4]
set_location_assignment PIN_P23  -to HPS_DDR4_A[5]
set_location_assignment PIN_U22  -to HPS_DDR4_A[6]
set_location_assignment PIN_T23  -to HPS_DDR4_A[7]
set_location_assignment PIN_N20  -to HPS_DDR4_A[8]
set_location_assignment PIN_P21  -to HPS_DDR4_A[9]
set_location_assignment PIN_T21  -to HPS_DDR4_A[10]
set_location_assignment PIN_U20  -to HPS_DDR4_A[11]
set_location_assignment PIN_AC24 -to HPS_DDR4_A[12]
set_location_assignment PIN_W22  -to HPS_DDR4_A[13]
set_location_assignment PIN_Y23  -to HPS_DDR4_A[14]
set_location_assignment PIN_AC22 -to HPS_DDR4_A[15]
set_location_assignment PIN_AB23 -to HPS_DDR4_A[16]
set_location_assignment PIN_K25  -to HPS_DDR4_ACT_L
set_location_assignment PIN_W20  -to HPS_DDR4_ALERT_L
set_location_assignment PIN_Y21  -to HPS_DDR4_BA[0]
set_location_assignment PIN_AB21 -to HPS_DDR4_BA[1]
set_location_assignment PIN_AC20 -to HPS_DDR4_BG
set_location_assignment PIN_L22  -to HPS_DDR4_CKE
set_location_assignment PIN_L24  -to HPS_DDR4_CS_L
set_location_assignment PIN_G20  -to HPS_DDR4_CLK_P
set_location_assignment PIN_H21  -to HPS_DDR4_CLK_N
set_location_assignment PIN_G22  -to HPS_DDR4_ODT
set_location_assignment PIN_L20  -to HPS_DDR4_PARITY
set_location_assignment PIN_G24  -to HPS_DDR4_RESET_L
set_location_assignment PIN_AB25 -to HPS_DDR4_RZQ
#
# Byte0
set_location_assignment PIN_A22 -to HPS_DDR4_DQ[0]
set_location_assignment PIN_B23 -to HPS_DDR4_DQ[1]
set_location_assignment PIN_D23 -to HPS_DDR4_DQ[2]
set_location_assignment PIN_E22 -to HPS_DDR4_DQ[3]
set_location_assignment PIN_A18 -to HPS_DDR4_DQ[4]
set_location_assignment PIN_B19 -to HPS_DDR4_DQ[5]
set_location_assignment PIN_D19 -to HPS_DDR4_DQ[6]
set_location_assignment PIN_E18 -to HPS_DDR4_DQ[7]
set_location_assignment PIN_A20 -to HPS_DDR4_DQS_P[0]
set_location_assignment PIN_B21 -to HPS_DDR4_DQS_N[0]
set_location_assignment PIN_E20 -to HPS_DDR4_DM[0]
#
# Byte1
set_location_assignment PIN_N18 -to HPS_DDR4_DQ[8]
set_location_assignment PIN_P19 -to HPS_DDR4_DQ[9]
set_location_assignment PIN_U18 -to HPS_DDR4_DQ[10]
set_location_assignment PIN_T19 -to HPS_DDR4_DQ[11]
set_location_assignment PIN_N14 -to HPS_DDR4_DQ[12]
set_location_assignment PIN_P15 -to HPS_DDR4_DQ[13]
set_location_assignment PIN_T15 -to HPS_DDR4_DQ[14]
set_location_assignment PIN_U14 -to HPS_DDR4_DQ[15]
set_location_assignment PIN_N16 -to HPS_DDR4_DQS_P[1]
set_location_assignment PIN_P17 -to HPS_DDR4_DQS_N[1]
set_location_assignment PIN_U16 -to HPS_DDR4_DM[1]
#
# Byte2
set_location_assignment PIN_G18 -to HPS_DDR4_DQ[16]
set_location_assignment PIN_H19 -to HPS_DDR4_DQ[17]
set_location_assignment PIN_L18 -to HPS_DDR4_DQ[18]
set_location_assignment PIN_K19 -to HPS_DDR4_DQ[19]
set_location_assignment PIN_G14 -to HPS_DDR4_DQ[20]
set_location_assignment PIN_H15 -to HPS_DDR4_DQ[21]
set_location_assignment PIN_L14 -to HPS_DDR4_DQ[22]
set_location_assignment PIN_K15 -to HPS_DDR4_DQ[23]
set_location_assignment PIN_G16 -to HPS_DDR4_DQS_P[2]
set_location_assignment PIN_H17 -to HPS_DDR4_DQS_N[2]
set_location_assignment PIN_L16 -to HPS_DDR4_DM[2]
#
# Byte3
set_location_assignment PIN_A16 -to HPS_DDR4_DQ[24]
set_location_assignment PIN_B17 -to HPS_DDR4_DQ[25]
set_location_assignment PIN_E16 -to HPS_DDR4_DQ[26]
set_location_assignment PIN_D17 -to HPS_DDR4_DQ[27]
set_location_assignment PIN_A12 -to HPS_DDR4_DQ[28]
set_location_assignment PIN_B13 -to HPS_DDR4_DQ[29]
set_location_assignment PIN_D13 -to HPS_DDR4_DQ[30]
set_location_assignment PIN_E12 -to HPS_DDR4_DQ[31]
set_location_assignment PIN_A14 -to HPS_DDR4_DQS_P[3]
set_location_assignment PIN_B15 -to HPS_DDR4_DQS_N[3]
set_location_assignment PIN_E14 -to HPS_DDR4_DM[3]
#
# Byte4
set_location_assignment PIN_A10  -to HPS_DDR4_DQ[32]
set_location_assignment PIN_B11  -to HPS_DDR4_DQ[33]
set_location_assignment PIN_E10  -to HPS_DDR4_DQ[34]
set_location_assignment PIN_D11  -to HPS_DDR4_DQ[35]
set_location_assignment PIN_C6   -to HPS_DDR4_DQ[36]
set_location_assignment PIN_B7   -to HPS_DDR4_DQ[37]
set_location_assignment PIN_D5   -to HPS_DDR4_DQ[38]
set_location_assignment PIN_E4   -to HPS_DDR4_DQ[39]
set_location_assignment PIN_D9   -to HPS_DDR4_DQS_P[4]
set_location_assignment PIN_B9   -to HPS_DDR4_DQS_N[4]
set_location_assignment PIN_D7   -to HPS_DDR4_DM[4]

##########################################################

##########################################################
# HPS
##########################################################

# Reference Clock
#set_location_assignment PIN_T13 -to HPS_CLK
#
# EMAC
# TX
#set_location_assignment PIN_H11 -to EMAC_TXD[0]
#set_location_assignment PIN_L6  -to EMAC_TXD[1]
#set_location_assignment PIN_G12 -to EMAC_TXD[2]
#set_location_assignment PIN_H5  -to EMAC_TXD[3]
#set_location_assignment PIN_P7  -to EMAC_TX_CTL
#set_location_assignment PIN_L12 -to EMAC_TX_CLK
# RX
#set_location_assignment PIN_G10 -to EMAC_RXD[0]
#set_location_assignment PIN_K5  -to EMAC_RXD[1]
#set_location_assignment PIN_H13 -to EMAC_RXD[2]
#set_location_assignment PIN_G4  -to EMAC_RXD[3]
#set_location_assignment PIN_N6  -to EMAC_RX_CTL
#set_location_assignment PIN_K13 -to EMAC_RX_CLK
# MDIO
#set_location_assignment PIN_U8  -to EMAC_MDC
#set_location_assignment PIN_P13 -to EMAC_MDIO
# Reset
#set_location_assignment PIN_N12 -to ETH_PHY_RESET_L
#
# UART
#set_location_assignment PIN_H9 -to HPS_UART_TXD
#set_location_assignment PIN_K3 -to HPS_UART_RXD
#
# NAND Flash
#set_location_assignment PIN_K7  -to HPS_NAND_CE_L
#set_location_assignment PIN_U6  -to HPS_NAND_RB_L
#set_location_assignment PIN_T9  -to HPS_NAND_WP_L
#set_location_assignment PIN_T1  -to HPS_NAND_RE_L
#set_location_assignment PIN_T11 -to HPS_NAND_WE_L
#set_location_assignment PIN_L8  -to HPS_NAND_ALE
#set_location_assignment PIN_P3  -to HPS_NAND_CLE
#set_location_assignment PIN_U10 -to HPS_NAND_D[0]
#set_location_assignment PIN_U2  -to HPS_NAND_D[1]
#set_location_assignment PIN_T3  -to HPS_NAND_D[2]
#set_location_assignment PIN_P9  -to HPS_NAND_D[3]
#set_location_assignment PIN_N8  -to HPS_NAND_D[4]
#set_location_assignment PIN_P1  -to HPS_NAND_D[5]
#set_location_assignment PIN_P11 -to HPS_NAND_D[6]
#set_location_assignment PIN_N2  -to HPS_NAND_D[7]
#
# M.2 Sideband
#set_location_assignment PIN_G6 -to M2_1V8_PERST_L
#set_location_assignment PIN_L4 -to M2_1V8_CLKREQ_L
#set_location_assignment PIN_H7 -to M2_1V8_PEWAKE_L
#set_location_assignment PIN_N4 -to M2_SMB_CLK
#set_location_assignment PIN_K9 -to M2_SMB_DAT
#set_location_assignment PIN_K1 -to EXT_M2_GPIO_EN_L
#
# MCIO Resets
#set_location_assignment PIN_H3  -to FTILE_MCIO_1V8_PERST_OUT_N
#set_location_assignment PIN_K11 -to MCIO_1V8_PERSTA
#set_location_assignment PIN_T7  -to MCIO_1V8_PERSTB
#set_location_assignment PIN_L10 -to EXT_MCIO_GPIO_EN_L

##########################################################

##########################################################
# HBM and NOC
##########################################################

# HBM Clocks
set_location_assignment PIN_EC36 -to HBM_REFCLK0
set_location_assignment PIN_ED35 -to HBM_REFCLK0(n)
set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to HBM_REFCLK0

set_location_assignment PIN_EH37 -to HBM_FBR_REFCLK0
set_location_assignment PIN_EG38 -to HBM_FBR_REFCLK0(n)
set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to HBM_FBR_REFCLK0

set_location_assignment PIN_AR36 -to HBM_REFCLK1
set_location_assignment PIN_AN36 -to HBM_REFCLK1(n)
set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to HBM_REFCLK1

set_location_assignment PIN_AP33 -to HBM_FBR_REFCLK1
set_location_assignment PIN_AR32 -to HBM_FBR_REFCLK1(n)
set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to HBM_FBR_REFCLK1 

# NOC Clocks
set_location_assignment PIN_EE56 -to NOC_CLK0
set_location_assignment PIN_AU52 -to NOC_CLK1

set_instance_assignment -name IO_STANDARD 1.8V -to NOC_CLK0
set_instance_assignment -name IO_STANDARD 1.8V -to NOC_CLK1

##########################################################

##################################################################
# SDM/Configuration - these signals are not required in you design
##################################################################

# AVSTx8
#set_location_assignment PIN_FE64 -to AVST_CLK
#set_location_assignment PIN_FC64 -to AVST_DATA[0]
#set_location_assignment PIN_FG66 -to AVST_DATA[1]
#set_location_assignment PIN_FN64 -to AVST_DATA[2]
#set_location_assignment PIN_FL64 -to AVST_DATA[3]
#set_location_assignment PIN_FM65 -to AVST_DATA[4]
#set_location_assignment PIN_EW68 -to AVST_DATA[5]
#set_location_assignment PIN_FB67 -to AVST_DATA[6]
#set_location_assignment PIN_EW66 -to AVST_DATA[7]
#set_location_assignment PIN_FK65 -to AVST_VALID
#set_location_assignment PIN_FA66 -to AVST_READY
#
# JTAG
#set_location_assignment PIN_EY67 -to SDM_TCK
#set_location_assignment PIN_FB69 -to SDM_TMS
#set_location_assignment PIN_EY69 -to SDM_TDI
#set_location_assignment PIN_FD67 -to SDM_TDO
#
# MSEL
#set_location_assignment PIN_FV67 -to INIT_DONE_MSEL[0]
#set_location_assignment PIN_EW64 -to HPS_RESET_L_MSEL[1]
#set_location_assignment PIN_FB65 -to PWRMGT_ALERT_MSEL[2]
#
# PWRMGT
#set_location_assignment PIN_FH65 -to PWRMGT_SCL   
#set_location_assignment PIN_EY65 -to PWRMGT_SDA    
#
# Misc
#set_location_assignment PIN_FF65 -to SDM_nCONFIG
#set_location_assignment PIN_FG64 -to SDM_nSTATUS
#set_location_assignment PIN_FE66 -to SDM_OSC_CLK_[1]
#set_location_assignment PIN_FA68 -to CONF_DONE

