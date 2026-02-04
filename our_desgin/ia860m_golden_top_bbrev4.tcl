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
# -- Description : Pinout and constraints for the IA-860m
# ------------------------------------------------------------------------------ #
# -- Known Issues and Omissions:
# -- PWRMGT_DEVICE_ADDRESS_IN_PMBUS_SLAVE_MODE value of 01 subject to change.
# --   Whilst it's the default for the tools and works on hardware it may not be
# --   a 'legal' value going by the PMBus Spec. Needs further checking
# --
# ------------------------------------------------------------------------------ #

set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
# IA-860m devices: AGMF039R47A1E2VC
set_global_assignment -name DEVICE AGMF039R47A1E2VC
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

# ------------------------------------
# Transceiver preservation constraints
# ------------------------------------
#
# See the following Intel doc for details:
# https://www.intel.com/content/www/us/en/docs/programmable/683872/current/preserving-unused-pma-lanes.html
#
# F-tile preservation
# If the F-tile (QSFP-DDs) is not included in the design transceiver preservation needs enabled for the F-tile. Use the following setting (this not required
#   if the global setting below is used):
# F-tile (Bank 12A) QSFP0_RX_P[3] Pin: DD69
# set_instance_assignment -name PRESERVE_UNUSED_XCVR_CHANNEL ON -to DD69
#   Fitter report snippet which confirms preservation:
#     Info(22251): Empty 'F-tile' indicated by pin 'DD69' has been preserved  due to PRESERVE_UNUSED_XCVR_CHANNEL instance assignment
# Alternativly the following global assignment can be used
# set_global_assignment -name PRESERVE_UNUSED_XCVR_CHANNEL ON

# ----------------
# General Clocking
# ----------------

# Prime User Clock 100MHz, Bank 2A
set_location_assignment PIN_FJ58 -to USER_CLK0
set_location_assignment PIN_FH57 -to "USER_CLK0(n)"
set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to USER_CLK0
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to USER_CLK0

# Bittware has found issues when USER_CLK0 is connected to a PLL in a neighbouring bank (despite Quartus believing it is legal).
# We recommend locking the PLL (that USER_CLK0 connects to) to a PLL in the same I/O Bank.
# Valid locations are:
# IOPLL_X65_Y2_N0
# IOPLL_X65_Y2_N84 
# IOPLL_X65_Y2_N91

# Secondary User Clock 100MHz, Bank 3A
# PRUNED_UNUSED_PORT set_location_assignment PIN_W58 -to USER_CLK1
# PRUNED_UNUSED_PORT set_location_assignment PIN_Y59 -to "USER_CLK1(n)"
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to USER_CLK1
# PRUNED_UNUSED_PORT set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to USER_CLK1

# Bittware has found issues when USER_CLK1 is connected to a PLL in a neighbouring bank (despite Quartus believing it is legal).
# We recommend locking the PLL (that USER_CLK1 connects to) to a PLL in the same I/O Bank.
# Valid locations are:
# IOPLL_X13_Y418_N0
# IOPLL_X13_Y418_N84 
# IOPLL_X13_Y418_N91

# 1PPS Clock, Bank 2A
# PRUNED_UNUSED_PORT set_location_assignment PIN_EY61 -to U1PPS
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2V" -to U1PPS

# ClkA/External Clock, Bank 2A
# PRUNED_UNUSED_PORT set_location_assignment PIN_FC52 -to CLKA
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2V" -to CLKA

# ----------------
# PCIe Interface
# ----------------
# PCIe - R-Tile Bank 14C
set_location_assignment PIN_BY59 -to PCIE_REFCLK0
set_location_assignment PIN_CA60 -to "PCIE_REFCLK0(n)"
set_location_assignment PIN_BU60 -to PCIE_REFCLK1
set_location_assignment PIN_BT59 -to "PCIE_REFCLK1(n)"
set_instance_assignment -name IO_STANDARD HCSL -to PCIE_REFCLK0
set_instance_assignment -name IO_STANDARD HCSL -to PCIE_REFCLK1

set_location_assignment PIN_AP53 -to PERST_L
set_instance_assignment -name IO_STANDARD 1.0V -to PERST_L

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

set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_TX_P[*]
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_TX_N[*]
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_RX_P[*]
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_RX_N[*]

# ----------------
# HBM2e & NoC
# ----------------
# HBM2e/NoC Reference Clocks
# Lower HBM2e & NoC
set_location_assignment PIN_EC36 -to HBM_REFCLK0
set_location_assignment PIN_ED35 -to "HBM_REFCLK0(n)"
set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to HBM_REFCLK0
set_location_assignment PIN_EE56 -to NOC_CLK0
set_instance_assignment -name IO_STANDARD 1.8V -to NOC_CLK0
# Upper HBM2e
# PRUNED_UNUSED_PORT set_location_assignment PIN_AR36 -to HBM_REFCLK1
# PRUNED_UNUSED_PORT set_location_assignment PIN_AN36 -to "HBM_REFCLK1(n)"
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to HBM_REFCLK1
# PRUNED_UNUSED_PORT set_location_assignment PIN_AU52 -to NOC_CLK1
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to NOC_CLK1

# HBM2e Fabric Clocks.  Each must be connected to IOPLL(s) to use.
# Lower
set_location_assignment PIN_EH37 -to HBM_FBR_REFCLK0
set_location_assignment PIN_EG38 -to "HBM_FBR_REFCLK0(n)"
set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to HBM_FBR_REFCLK0
# Upper
# PRUNED_UNUSED_PORT set_location_assignment PIN_AP33 -to HBM_FBR_REFCLK1
# PRUNED_UNUSED_PORT set_location_assignment PIN_AR32 -to "HBM_FBR_REFCLK1(n)"
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to HBM_FBR_REFCLK1

# ---------------------
# F-Tile 12A, QSFPDD0
# ---------------------
# Reference Clock
# Refclk #5 - PIN_DK59
# PRUNED_UNUSED_PORT set_location_assignment PIN_DK59 -to QSFP0_REFCLK
# PRUNED_UNUSED_PORT set_location_assignment PIN_DJ60 -to "QSFP0_REFCLK(n)"

# QSFPDD0 Recovered Clock from the FPGA
# Refclk #9 - PIN_CR60
# PRUNED_UNUSED_PORT set_location_assignment PIN_CR60 -to RECV0_CLK
# PRUNED_UNUSED_PORT set_location_assignment PIN_CT59 -to "RECV0_CLK(n)"

# F-Tile 12A, Quad3 Lanes 0-3
# F-Tile 12A, Quad2 Lanes 4-7
# PRUNED_UNUSED_PORT set_location_assignment PIN_CM69 -to QSFP0_RX_P[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CL68 -to QSFP0_RX_N[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CT69 -to QSFP0_RX_P[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CR68 -to QSFP0_RX_N[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CY69 -to QSFP0_RX_P[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CW68 -to QSFP0_RX_N[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DD69 -to QSFP0_RX_P[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DC68 -to QSFP0_RX_N[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DH69 -to QSFP0_RX_P[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DG68 -to QSFP0_RX_N[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DJ66 -to QSFP0_RX_P[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DK65 -to QSFP0_RX_N[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DM69 -to QSFP0_RX_P[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DL68 -to QSFP0_RX_N[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DN66 -to QSFP0_RX_P[7]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DP65 -to QSFP0_RX_N[7]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CM63 -to QSFP0_TX_P[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CL62 -to QSFP0_TX_N[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CN66 -to QSFP0_TX_P[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CP65 -to QSFP0_TX_N[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CT63 -to QSFP0_TX_P[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CR62 -to QSFP0_TX_N[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CU66 -to QSFP0_TX_P[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CV65 -to QSFP0_TX_N[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CY63 -to QSFP0_TX_P[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CW62 -to QSFP0_TX_N[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DA66 -to QSFP0_TX_P[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DB65 -to QSFP0_TX_N[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DD63 -to QSFP0_TX_P[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DC62 -to QSFP0_TX_N[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DE66 -to QSFP0_TX_P[7]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DF65 -to QSFP0_TX_N[7]

# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP0_RX_P[0]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP0_RX_P[1]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP0_RX_P[2]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP0_RX_P[3]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP0_RX_P[4]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP0_RX_P[5]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP0_RX_P[6]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP0_RX_P[7]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP0_RX_P[0]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP0_RX_P[1]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP0_RX_P[2]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP0_RX_P[3]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP0_RX_P[4]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP0_RX_P[5]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP0_RX_P[6]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP0_RX_P[7]
# vsr_mode should be set to VSR_MODE_HIGH_LOSS for NRZ > 23Gbps and all PAM4 line rates.
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP0_RX_P[0] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP0_RX_P[1] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP0_RX_P[2] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP0_RX_P[3] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP0_RX_P[4] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP0_RX_P[5] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP0_RX_P[6] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP0_RX_P[7] 
# QSFPDD0 Tx HSSI assigments are in the qsf

# ---------------------
# F-Tile 13A, QSFPDD1
# ---------------------
# Reference Clock
# Refclk #5 - PIN_DE14
# PRUNED_UNUSED_PORT set_location_assignment PIN_DE14 -to QSFP1_REFCLK
# PRUNED_UNUSED_PORT set_location_assignment PIN_DF13 -to "QSFP1_REFCLK(n)"

# QSFPDD1 Recovered Clock from the FPGA
# Refclk #9 - PIN_DY13
# PRUNED_UNUSED_PORT set_location_assignment PIN_DY13 -to RECV1_CLK
# PRUNED_UNUSED_PORT set_location_assignment PIN_EA14 -to RECV1_CLK(n)

# F-Tile 13A, Quad3 Lanes 0-3
# F-Tile 13A, Quad2 Lanes 4-7
# PRUNED_UNUSED_PORT set_location_assignment PIN_EC4  -to QSFP1_RX_P[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_ED5  -to QSFP1_RX_N[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_EB1  -to QSFP1_RX_P[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_EA2  -to QSFP1_RX_N[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DW4  -to QSFP1_RX_P[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DY5  -to QSFP1_RX_N[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DV1  -to QSFP1_RX_P[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DU2  -to QSFP1_RX_N[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DR4  -to QSFP1_RX_P[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DT5  -to QSFP1_RX_N[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DP1  -to QSFP1_RX_P[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DN2  -to QSFP1_RX_N[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DL4  -to QSFP1_RX_P[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DM5  -to QSFP1_RX_N[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DK1  -to QSFP1_RX_P[7]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DJ2  -to QSFP1_RX_N[7]
# PRUNED_UNUSED_PORT set_location_assignment PIN_EB7  -to QSFP1_TX_P[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_EA8  -to QSFP1_TX_N[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DW10 -to QSFP1_TX_P[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DY11 -to QSFP1_TX_N[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DV7  -to QSFP1_TX_P[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DU8  -to QSFP1_TX_N[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DR10 -to QSFP1_TX_P[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DT11 -to QSFP1_TX_N[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DP7  -to QSFP1_TX_P[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DN8  -to QSFP1_TX_N[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DL10 -to QSFP1_TX_P[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DM11 -to QSFP1_TX_N[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DK7  -to QSFP1_TX_P[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DJ8  -to QSFP1_TX_N[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DG10 -to QSFP1_TX_P[7]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DH11 -to QSFP1_TX_N[7]

# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP1_RX_P[0]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP1_RX_P[1]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP1_RX_P[2]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP1_RX_P[3]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP1_RX_P[4]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP1_RX_P[5]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP1_RX_P[6]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP1_RX_P[7]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP1_RX_P[0]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP1_RX_P[1]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP1_RX_P[2]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP1_RX_P[3]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP1_RX_P[4]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP1_RX_P[5]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP1_RX_P[6]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP1_RX_P[7]
# vsr_mode should be set to VSR_MODE_HIGH_LOSS for NRZ > 23Gbps and all PAM4 line rates.
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP1_RX_P[0] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP1_RX_P[1] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP1_RX_P[2] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP1_RX_P[3] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP1_RX_P[4] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP1_RX_P[5] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP1_RX_P[6] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP1_RX_P[7] 
# QSFPDD1 Tx HSSI assigments are in the qsf

# ---------------------
# F-Tile 13A, MCIO
# ---------------------
# Reference Clock
# Refclk #2 - PIN_CT13
# PRUNED_UNUSED_PORT set_location_assignment PIN_CT13 -to MCIO_REFCLK
# PRUNED_UNUSED_PORT set_location_assignment PIN_CU14 -to "MCIO_REFCLK(n)"

# PCIe Reset
# PRUNED_UNUSED_PORT set_location_assignment PIN_EK19 -to MCIO_PERST_N

# F-Tile 13A, Quad1 Lanes 4-7
# F-Tile 13A, Quad0 Lanes 0-3
# PRUNED_UNUSED_PORT set_location_assignment PIN_CP1  -to MCIO_RX_P[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CN2  -to MCIO_RX_N[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CR4  -to MCIO_RX_P[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CT5  -to MCIO_RX_N[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CV1  -to MCIO_RX_P[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CU2  -to MCIO_RX_N[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CW4  -to MCIO_RX_P[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CY5  -to MCIO_RX_N[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DB1  -to MCIO_RX_P[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DA2  -to MCIO_RX_N[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DC4  -to MCIO_RX_P[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DD5  -to MCIO_RX_N[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DF1  -to MCIO_RX_P[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DE2  -to MCIO_RX_N[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DG4  -to MCIO_RX_P[7]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DH5  -to MCIO_RX_N[7]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CL10 -to MCIO_TX_P[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CM11 -to MCIO_TX_N[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CP7  -to MCIO_TX_P[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CN8  -to MCIO_TX_N[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CR10 -to MCIO_TX_P[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CT11 -to MCIO_TX_N[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CV7  -to MCIO_TX_P[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CU8  -to MCIO_TX_N[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CW10 -to MCIO_TX_P[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_CY11 -to MCIO_TX_N[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DB7  -to MCIO_TX_P[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DA8  -to MCIO_TX_N[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DC10 -to MCIO_TX_P[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DD11 -to MCIO_TX_N[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DF7  -to MCIO_TX_P[7]
# PRUNED_UNUSED_PORT set_location_assignment PIN_DE8  -to MCIO_TX_N[7]

# MCIO Sideband Signals (Bank 2A)
# PRUNED_UNUSED_PORT set_location_assignment PIN_FL52 -to MCIO_CWAKEA
# PRUNED_UNUSED_PORT set_location_assignment PIN_FM51 -to MCIO_BP_TYPEA
# PRUNED_UNUSED_PORT set_location_assignment PIN_FR52 -to MCIO_CPRSNTA
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2 V" -to MCIO_CWAKEA
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2 V" -to MCIO_BP_TYPEA
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2 V" -to MCIO_CPRSNTA

# PRUNED_UNUSED_PORT set_location_assignment PIN_FU58 -to MCIO_CWAKEB
# PRUNED_UNUSED_PORT set_location_assignment PIN_FV57 -to MCIO_BP_TYPEB
# PRUNED_UNUSED_PORT set_location_assignment PIN_GA58 -to MCIO_CPRSNTB
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2 V" -to MCIO_CWAKEB
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2 V" -to MCIO_BP_TYPEB
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2 V" -to MCIO_CPRSNTB

# PRUNED_UNUSED_PORT set_location_assignment PIN_FC56 -to MCIO_I2C0_SCL
# PRUNED_UNUSED_PORT set_location_assignment PIN_FB55 -to MCIO_I2C0_SDA
# PRUNED_UNUSED_PORT set_location_assignment PIN_FV55 -to MCIO_I2C1_SCL
# PRUNED_UNUSED_PORT set_location_assignment PIN_FU56 -to MCIO_I2C1_SDA
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2 V" -to MCIO_I2C0_SCL
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2 V" -to MCIO_I2C0_SDA
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2 V" -to MCIO_I2C1_SCL
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2 V" -to MCIO_I2C1_SDA
# PRUNED_UNUSED_PORT set_instance_assignment -name WEAK_PULL_UP_RESISTOR OFF -to MCIO_I2C0_SCL
# PRUNED_UNUSED_PORT set_instance_assignment -name WEAK_PULL_UP_RESISTOR OFF -to MCIO_I2C0_SDA
# PRUNED_UNUSED_PORT set_instance_assignment -name WEAK_PULL_UP_RESISTOR OFF -to MCIO_I2C1_SCL
# PRUNED_UNUSED_PORT set_instance_assignment -name WEAK_PULL_UP_RESISTOR OFF -to MCIO_I2C1_SDA
# PRUNED_UNUSED_PORT set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to MCIO_I2C0_SCL
# PRUNED_UNUSED_PORT set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to MCIO_I2C0_SDA
# PRUNED_UNUSED_PORT set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to MCIO_I2C1_SCL
# PRUNED_UNUSED_PORT set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to MCIO_I2C1_SDA
# PRUNED_UNUSED_PORT set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to MCIO_I2C0_SCL
# PRUNED_UNUSED_PORT set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to MCIO_I2C0_SDA
# PRUNED_UNUSED_PORT set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to MCIO_I2C1_SCL
# PRUNED_UNUSED_PORT set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to MCIO_I2C1_SDA

# ---------------------
# F-Tile 13C, QSFPDD2
# ---------------------
# Reference Clock
# Refclk #5 - PIN_BW14
# PRUNED_UNUSED_PORT set_location_assignment PIN_BW14 -to QSFP2_REFCLK
# PRUNED_UNUSED_PORT set_location_assignment PIN_BY13 -to "QSFP2_REFCLK(n)"

# QSFPDD2 Recovered Clock from the FPGA
# Refclk #9 - PIN_BT11
# PRUNED_UNUSED_PORT set_location_assignment PIN_BT11 -to RECV2_CLK
# PRUNED_UNUSED_PORT set_location_assignment PIN_BU10 -to "RECV2_CLK(n)"

# F-Tile 13C, Quad3 Lanes 0-3
# F-Tile 13C, Quad2 Lanes 4-7
# PRUNED_UNUSED_PORT set_location_assignment PIN_BK1 -to QSFP2_RX_P[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BL2 -to QSFP2_RX_N[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BF1 -to QSFP2_RX_P[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BG2 -to QSFP2_RX_N[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BJ4 -to QSFP2_RX_P[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BH5 -to QSFP2_RX_N[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BB1 -to QSFP2_RX_P[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BC2 -to QSFP2_RX_N[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BE4 -to QSFP2_RX_P[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BD5 -to QSFP2_RX_N[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AV1 -to QSFP2_RX_P[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AW2 -to QSFP2_RX_N[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BA4 -to QSFP2_RX_P[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AY5 -to QSFP2_RX_N[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AP1 -to QSFP2_RX_P[7]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AR2 -to QSFP2_RX_N[7]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BP7  -to QSFP2_TX_P[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BR8  -to QSFP2_TX_N[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BK7  -to QSFP2_TX_P[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BL8  -to QSFP2_TX_N[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BJ10 -to QSFP2_TX_P[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BH11 -to QSFP2_TX_N[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BF7  -to QSFP2_TX_P[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BG8  -to QSFP2_TX_N[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BE10 -to QSFP2_TX_P[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BD11 -to QSFP2_TX_N[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BB7  -to QSFP2_TX_P[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BC8  -to QSFP2_TX_N[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_BA10 -to QSFP2_TX_P[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AY11 -to QSFP2_TX_N[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AV7  -to QSFP2_TX_P[7]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AW8  -to QSFP2_TX_N[7]
#
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP2_RX_P[0]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP2_RX_P[1]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP2_RX_P[2]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP2_RX_P[3]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP2_RX_P[4]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP2_RX_P[5]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP2_RX_P[6]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to QSFP2_RX_P[7]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP2_RX_P[0]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP2_RX_P[1]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP2_RX_P[2]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP2_RX_P[3]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP2_RX_P[4]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP2_RX_P[5]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP2_RX_P[6]
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to QSFP2_RX_P[7]
# vsr_mode should be set to VSR_MODE_HIGH_LOSS for NRZ > 23Gbps and all PAM4 line rates.
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP2_RX_P[0] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP2_RX_P[1] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP2_RX_P[2] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP2_RX_P[3] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP2_RX_P[4] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP2_RX_P[5] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP2_RX_P[6] 
# PRUNED_UNUSED_PORT set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_HIGH_LOSS" -to QSFP2_RX_P[7] 
# QSFPDD2 Tx HSSI assigments are in the qsf

# ---------------------
# F-Tile 13C, M.2 SSD
# ---------------------
# Reference Clock
# Refclk #2 - PIN_CT13
# PRUNED_UNUSED_PORT set_location_assignment PIN_AU14 -to M2_REFCLK
# PRUNED_UNUSED_PORT set_location_assignment PIN_AW14 -to "M2_REFCLK(n)"

# PCIe Reset
# PRUNED_UNUSED_PORT set_location_assignment PIN_AY17 -to M2_PERST_N

# F-Tile 13C, Quad0 Lanes 0-3
# PRUNED_UNUSED_PORT set_location_assignment PIN_AB7  -to M2SSD_RX_P[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AC8  -to M2SSD_RX_N[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AF7  -to M2SSD_RX_P[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AG8  -to M2SSD_RX_N[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AE4  -to M2SSD_RX_P[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AD5  -to M2SSD_RX_N[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AJ4  -to M2SSD_RX_P[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AH5  -to M2SSD_RX_N[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AB13 -to M2SSD_TX_P[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AC14 -to M2SSD_TX_N[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AF13 -to M2SSD_TX_P[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AG14 -to M2SSD_TX_N[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AE10 -to M2SSD_TX_P[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AD11 -to M2SSD_TX_N[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AJ10 -to M2SSD_TX_P[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AH11 -to M2SSD_TX_N[3]

# -------------------------------------------
# Board Management Controller (BMC) Interface
# -------------------------------------------
# BMC interface FPGA Egress SPI and IRQ
# PRUNED_UNUSED_PORT set_location_assignment PIN_FR58 -to FPGA_EG_SPI_SCK
# PRUNED_UNUSED_PORT set_location_assignment PIN_FF61 -to FPGA_EG_SPI_PCS0
# PRUNED_UNUSED_PORT set_location_assignment PIN_FE62 -to FPGA_EG_SPI_MOSI
# PRUNED_UNUSED_PORT set_location_assignment PIN_FP57 -to FPGA_EG_SPI_MISO
# PRUNED_UNUSED_PORT set_location_assignment PIN_FF57 -to BMC_TO_FPGA_IRQ

# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_EG_SPI_SCK
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_EG_SPI_PCS0
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_EG_SPI_MOSI
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_EG_SPI_MISO
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.2V -to BMC_TO_FPGA_IRQ

# BMC interface FPGA Ingress SPI and IRQ
# PRUNED_UNUSED_PORT set_location_assignment PIN_FJ62 -to FPGA_IG_SPI_SCK
# PRUNED_UNUSED_PORT set_location_assignment PIN_FE60 -to FPGA_IG_SPI_PCS0
# PRUNED_UNUSED_PORT set_location_assignment PIN_FF59 -to FPGA_IG_SPI_MOSI
# PRUNED_UNUSED_PORT set_location_assignment PIN_FH61 -to FPGA_IG_SPI_MISO
# PRUNED_UNUSED_PORT set_location_assignment PIN_FM57 -to FPGA_TO_BMC_IRQ

# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_IG_SPI_SCK
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_IG_SPI_PCS0
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_IG_SPI_MOSI
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_IG_SPI_MISO
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.2V -to FPGA_TO_BMC_IRQ

# BMC interface present in FPGA design
set_location_assignment PIN_FM59 -to BMC_IF_PRESENT_L
set_instance_assignment -name IO_STANDARD 1.2V -to BMC_IF_PRESENT_L

# ---------------------------------------
# Board Management Controller (BMC) reset
# ---------------------------------------
# Reset from the BMC - independant from the BMC interface
set_location_assignment PIN_FV63 -to BMC_FPGA_RST_L
set_instance_assignment -name IO_STANDARD 1.2V -to BMC_FPGA_RST_L

# ---------------
# Other - Bank 2A
# ---------------
# LEDs
# PRUNED_UNUSED_PORT set_location_assignment PIN_FC62 -to FPGA_LED_G_L
# PRUNED_UNUSED_PORT set_location_assignment PIN_FB61 -to FPGA_LED_R_L
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2 V" -to FPGA_LED_G_L
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2 V" -to FPGA_LED_R_L

# External GPIO + Clock (LVDS at connector, but single-ended at FPGA)
# External LVDS Clock
# PRUNED_UNUSED_PORT set_location_assignment PIN_FF55 -to EXT_SE_CLK
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2V" -to EXT_SE_CLK

# If connecting to a PLL, we recommend locking the PLL (that EXT_SE_CLK connects to) to a PLL in the same I/O Bank.
# Valid locations are:
# IOPLL_X64_Y2_N293
# IOPLL_X64_Y2_N384 
# IOPLL_X64_Y2_N377
# Ensure you don't lock to the same PLL used for USER_CLK0.

# Input Only (to FPGA)
# PRUNED_UNUSED_PORT set_location_assignment PIN_FL56 -to EXT_GPIO_IN[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_FP55 -to EXT_GPIO_IN[1]
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2 V" -to EXT_GPIO_IN[0]
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2 V" -to EXT_GPIO_IN[1]
# Output Only (from FPGA)
# PRUNED_UNUSED_PORT set_location_assignment PIN_FL54 -to EXT_GPIO_OUT
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2 V" -to EXT_GPIO_OUT

# DDR4 Test Enable
# Included only for completeness. Should never be asserted. Deliberatly commented out.
#set_location_assignment PIN_EY57 -to DDR4_TEN
# set_instance_assignment -name IO_STANDARD "1.2 V" -to DDR4_TEN

# Startup Signals
# These signals should be in every design and should always be driven LOW
# This is especially important if the MCIO or External GPIO are being
# used in the design.
set_location_assignment PIN_FU60 -to MCIO_GPIO_EN_L
set_location_assignment PIN_FY59 -to MCIO_I2C_EN
set_location_assignment PIN_GA60 -to EXT_GPIO_EN_L

set_instance_assignment -name IO_STANDARD 1.2V -to MCIO_GPIO_EN_L
set_instance_assignment -name IO_STANDARD 1.2V -to EXT_GPIO_EN_L
set_instance_assignment -name IO_STANDARD 1.2V -to MCIO_I2C_EN

# -------------
# Miscellaneous
# -------------
# Included only for completeness. Deliberatly commented out.
# # TEMPDIODE0A - SDM temperature diode
# set_location_assignment PIN_EG52 -to SDM_DX_P
# set_location_assignment PIN_EJ52 -to SDM_DX_N
# # TEMPDIODE4 - F-tile (13A) temperature diode
# set_location_assignment PIN_EM23 -to FTILE_13A_DX_P
# set_location_assignment PIN_EK23 -to FTILE_13A_DX_N
# # TEMPDIODE0C - FPGA fabric temperature diode
# set_location_assignment PIN_BH51 -to FABRIC_DX_P
# set_location_assignment PIN_BF51 -to FABRIC_DX_N


# ------------------
# DDR4 HPS Interface
# ------------------
# DDR4 Bank HPS - Banks 3D Top, Bank 3D Bottom
# PRUNED_UNUSED_PORT set_location_assignment PIN_Y25 -to HPS_DDR4_REFCLK
# PRUNED_UNUSED_PORT set_location_assignment PIN_W24 -to "HPS_DDR4_REFCLK(n)"
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to HPS_DDR4_REFCLK 

# PRUNED_UNUSED_PORT set_location_assignment PIN_N24  -to HPS_DDR4_A[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_P25  -to HPS_DDR4_A[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_T25  -to HPS_DDR4_A[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_U24  -to HPS_DDR4_A[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_N22  -to HPS_DDR4_A[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_P23  -to HPS_DDR4_A[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_U22  -to HPS_DDR4_A[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_T23  -to HPS_DDR4_A[7]
# PRUNED_UNUSED_PORT set_location_assignment PIN_N20  -to 
#_DDR4_A[8]
# PRUNED_UNUSED_PORT set_location_assignment PIN_P21  -to HPS_DDR4_A[9]
# PRUNED_UNUSED_PORT set_location_assignment PIN_T21  -to HPS_DDR4_A[10]
# PRUNED_UNUSED_PORT set_location_assignment PIN_U20  -to HPS_DDR4_A[11]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AC24 -to HPS_DDR4_A[12]
# PRUNED_UNUSED_PORT set_location_assignment PIN_W22  -to HPS_DDR4_A[13]
# PRUNED_UNUSED_PORT set_location_assignment PIN_Y23  -to HPS_DDR4_A[14]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AC22 -to HPS_DDR4_A[15]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AB23 -to HPS_DDR4_A[16]
# PRUNED_UNUSED_PORT set_location_assignment PIN_K25  -to HPS_DDR4_ACT_L
# PRUNED_UNUSED_PORT set_location_assignment PIN_W20  -to HPS_DDR4_ALERT_L
# PRUNED_UNUSED_PORT set_location_assignment PIN_Y21  -to HPS_DDR4_BA[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AB21 -to HPS_DDR4_BA[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_AC20 -to HPS_DDR4_BG
# PRUNED_UNUSED_PORT set_location_assignment PIN_L22  -to HPS_DDR4_CKE
# PRUNED_UNUSED_PORT set_location_assignment PIN_L24  -to HPS_DDR4_CS_L
# PRUNED_UNUSED_PORT set_location_assignment PIN_G20  -to HPS_DDR4_CLK_P
# PRUNED_UNUSED_PORT set_location_assignment PIN_H21  -to HPS_DDR4_CLK_N
# PRUNED_UNUSED_PORT set_location_assignment PIN_G22  -to HPS_DDR4_ODT
# PRUNED_UNUSED_PORT set_location_assignment PIN_L20  -to HPS_DDR4_PARITY
# PRUNED_UNUSED_PORT set_location_assignment PIN_G24  -to HPS_DDR4_RESET_L
#set_location_assignment PIN_AB25 -to HPS_DDR4_RZQ

# PRUNED_UNUSED_PORT set_location_assignment PIN_A22 -to HPS_DDR4_DQ[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_B23 -to HPS_DDR4_DQ[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_D23 -to HPS_DDR4_DQ[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_E22 -to HPS_DDR4_DQ[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_A18 -to HPS_DDR4_DQ[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_B19 -to HPS_DDR4_DQ[5]
# PRUNED_UNUSED_PORT set_location_assignment PIN_D19 -to HPS_DDR4_DQ[6]
# PRUNED_UNUSED_PORT set_location_assignment PIN_E18 -to HPS_DDR4_DQ[7]
# PRUNED_UNUSED_PORT set_location_assignment PIN_A20 -to HPS_DDR4_DQS_P[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_B21 -to HPS_DDR4_DQS_N[0]
# PRUNED_UNUSED_PORT set_location_assignment PIN_E20 -to HPS_DDR4_DM[0]

# PRUNED_UNUSED_PORT set_location_assignment PIN_N18 -to HPS_DDR4_DQ[8]
# PRUNED_UNUSED_PORT set_location_assignment PIN_P19 -to HPS_DDR4_DQ[9]
# PRUNED_UNUSED_PORT set_location_assignment PIN_U18 -to HPS_DDR4_DQ[10]
# PRUNED_UNUSED_PORT set_location_assignment PIN_T19 -to HPS_DDR4_DQ[11]
# PRUNED_UNUSED_PORT set_location_assignment PIN_N14 -to HPS_DDR4_DQ[12]
# PRUNED_UNUSED_PORT set_location_assignment PIN_P15 -to HPS_DDR4_DQ[13]
# PRUNED_UNUSED_PORT set_location_assignment PIN_T15 -to HPS_DDR4_DQ[14]
# PRUNED_UNUSED_PORT set_location_assignment PIN_U14 -to HPS_DDR4_DQ[15]
# PRUNED_UNUSED_PORT set_location_assignment PIN_N16 -to HPS_DDR4_DQS_P[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_P17 -to HPS_DDR4_DQS_N[1]
# PRUNED_UNUSED_PORT set_location_assignment PIN_U16 -to HPS_DDR4_DM[1]

# PRUNED_UNUSED_PORT set_location_assignment PIN_G18 -to HPS_DDR4_DQ[16]
# PRUNED_UNUSED_PORT set_location_assignment PIN_H19 -to HPS_DDR4_DQ[17]
# PRUNED_UNUSED_PORT set_location_assignment PIN_L18 -to HPS_DDR4_DQ[18]
# PRUNED_UNUSED_PORT set_location_assignment PIN_K19 -to HPS_DDR4_DQ[19]
# PRUNED_UNUSED_PORT set_location_assignment PIN_G14 -to HPS_DDR4_DQ[20]
# PRUNED_UNUSED_PORT set_location_assignment PIN_H15 -to HPS_DDR4_DQ[21]
# PRUNED_UNUSED_PORT set_location_assignment PIN_L14 -to HPS_DDR4_DQ[22]
# PRUNED_UNUSED_PORT set_location_assignment PIN_K15 -to HPS_DDR4_DQ[23]
# PRUNED_UNUSED_PORT set_location_assignment PIN_G16 -to HPS_DDR4_DQS_P[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_H17 -to HPS_DDR4_DQS_N[2]
# PRUNED_UNUSED_PORT set_location_assignment PIN_L16 -to HPS_DDR4_DM[2]

# PRUNED_UNUSED_PORT set_location_assignment PIN_A16 -to HPS_DDR4_DQ[24]
# PRUNED_UNUSED_PORT set_location_assignment PIN_B17 -to HPS_DDR4_DQ[25]
# PRUNED_UNUSED_PORT set_location_assignment PIN_E16 -to HPS_DDR4_DQ[26]
# PRUNED_UNUSED_PORT set_location_assignment PIN_D17 -to HPS_DDR4_DQ[27]
# PRUNED_UNUSED_PORT set_location_assignment PIN_A12 -to HPS_DDR4_DQ[28]
# PRUNED_UNUSED_PORT set_location_assignment PIN_B13 -to HPS_DDR4_DQ[29]
# PRUNED_UNUSED_PORT set_location_assignment PIN_D13 -to HPS_DDR4_DQ[30]
# PRUNED_UNUSED_PORT set_location_assignment PIN_E12 -to HPS_DDR4_DQ[31]
# PRUNED_UNUSED_PORT set_location_assignment PIN_A14 -to HPS_DDR4_DQS_P[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_B15 -to HPS_DDR4_DQS_N[3]
# PRUNED_UNUSED_PORT set_location_assignment PIN_E14 -to HPS_DDR4_DM[3]

# PRUNED_UNUSED_PORT set_location_assignment PIN_A10  -to HPS_DDR4_DQ[32]
# PRUNED_UNUSED_PORT set_location_assignment PIN_B11  -to HPS_DDR4_DQ[33]
# PRUNED_UNUSED_PORT set_location_assignment PIN_E10  -to HPS_DDR4_DQ[34]
# PRUNED_UNUSED_PORT set_location_assignment PIN_D11  -to HPS_DDR4_DQ[35]
# PRUNED_UNUSED_PORT set_location_assignment PIN_C6   -to HPS_DDR4_DQ[36]
# PRUNED_UNUSED_PORT set_location_assignment PIN_B7   -to HPS_DDR4_DQ[37]
# PRUNED_UNUSED_PORT set_location_assignment PIN_D5   -to HPS_DDR4_DQ[38]
# PRUNED_UNUSED_PORT set_location_assignment PIN_E4   -to HPS_DDR4_DQ[39]
# PRUNED_UNUSED_PORT set_location_assignment PIN_D9   -to HPS_DDR4_DQS_P[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_B9   -to HPS_DDR4_DQS_N[4]
# PRUNED_UNUSED_PORT set_location_assignment PIN_D7   -to HPS_DDR4_DM[4]

# --------
# HPS Bank
# --------


# HPS_IOA_1  - PIN_U10
set_location_assignment PIN_U10 -to HPS_NAND_D[0]
# HPS_IOA_2  - PIN_U2
set_location_assignment PIN_U2  -to HPS_NAND_D[1]
# HPS_IOA_3  - PIN_T11
set_location_assignment PIN_T11 -to HPS_NAND_WE_L
# HPS_IOA_4  - PIN_T1
set_location_assignment PIN_T1  -to HPS_NAND_RE_L
# HPS_IOA_5  - PIN_T9
set_location_assignment PIN_T9  -to HPS_NAND_WP_L
# HPS_IOA_6  - PIN_T3
set_location_assignment PIN_T3  -to HPS_NAND_D[2]
# HPS_IOA_7  - PIN_P9
set_location_assignment PIN_P9  -to HPS_NAND_D[3]
# HPS_IOA_8  - PIN_P3
set_location_assignment PIN_P3  -to HPS_NAND_CLE
# HPS_IOA_9  - PIN_N8
set_location_assignment PIN_N8  -to HPS_NAND_D[4]
# HPS_IOA_10 - PIN_P1
set_location_assignment PIN_P1  -to HPS_NAND_D[5]
# HPS_IOA_11 - PIN_P11
set_location_assignment PIN_P11 -to HPS_NAND_D[6]
# HPS_IOA_12 - PIN_N2
set_location_assignment PIN_N2  -to HPS_NAND_D[7]
# HPS_IOA_13 - PIN_L8
set_location_assignment PIN_L8  -to HPS_NAND_ALE
# HPS_IOA_14 - PIN_U6
set_location_assignment PIN_U6  -to HPS_NAND_RB_L
# HPS_IOA_15 - PIN_K7
set_location_assignment PIN_K7  -to HPS_NAND_CE_L
# HPS_IOA_19 - PIN_K1
# PRUNED_UNUSED_PORT set_location_assignment PIN_K1 -to EXT_M2_GPIO_EN_L
# HPS_IOA_20 - PIN_L10
# PRUNED_UNUSED_PORT set_location_assignment PIN_L10 -to EXT_MCIO_GPIO_EN_L
# HPS_IOA_21 - PIN_T13
set_location_assignment PIN_T13 -to HPS_CLK
# HPS_IOA_23 - PIN_K9
# PRUNED_UNUSED_PORT set_location_assignment PIN_K9 -to M2_SMB_DAT
# HPS_IOA_24 - PIN_N4
# PRUNED_UNUSED_PORT set_location_assignment PIN_N4 -to M2_SMB_CLK

set_instance_assignment -name IO_STANDARD 1.8V -to HPS_NAND_D
set_instance_assignment -name IO_STANDARD 1.8V -to HPS_NAND_WE_L
set_instance_assignment -name IO_STANDARD 1.8V -to HPS_NAND_RE_L
set_instance_assignment -name IO_STANDARD 1.8V -to HPS_NAND_WP_L
set_instance_assignment -name IO_STANDARD 1.8V -to HPS_NAND_CLE
set_instance_assignment -name IO_STANDARD 1.8V -to HPS_NAND_ALE
set_instance_assignment -name IO_STANDARD 1.8V -to HPS_NAND_RB_L
set_instance_assignment -name IO_STANDARD 1.8V -to HPS_NAND_CE_L

# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to EXT_M2_GPIO_EN_L
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to EXT_MCIO_GPIO_EN_L
set_instance_assignment -name IO_STANDARD 1.8V -to HPS_CLK
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to M2_SMB_DAT
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to M2_SMB_CLK

# HPS_IOB_1  - PIN_H7
# PRUNED_UNUSED_PORT set_location_assignment PIN_H7 -to M2_PEWAKE_L
# HPS_IOB_2  - PIN_L4
# PRUNED_UNUSED_PORT set_location_assignment PIN_L4 -to M2_CLKREQ_L
# HPS_IOB_3  - PIN_H9
set_location_assignment PIN_H9 -to HPS_UART_TXD
# HPS_IOB_4  - PIN_K3
set_location_assignment PIN_K3 -to HPS_UART_RXD
# HPS_IOB_5  - PIN_G6
# PRUNED_UNUSED_PORT set_location_assignment PIN_G6 -to M2_PERST_OUT_L
# HPS_IOB_6  - PIN_H3
# PRUNED_UNUSED_PORT set_location_assignment PIN_H3  -to MCIO_PERST_OUT_L
# HPS_IOB_7  - PIN_N12
# PRUNED_UNUSED_PORT set_location_assignment PIN_N12 -to ETH_PHY_RESET_L
# HPS_IOB_9  - PIN_P13
# PRUNED_UNUSED_PORT set_location_assignment PIN_P13 -to EMAC_MDIO
# HPS_IOB_10 - PIN_U8
# PRUNED_UNUSED_PORT set_location_assignment PIN_U8  -to EMAC_MDC
# HPS_IOB_11 - PIN_K11
#set_location_assignment PIN_K11 -to MCIO_PERSTA
# HPS_IOB_12 - PIN_T7
#set_location_assignment PIN_T7  -to MCIO_PERSTB
# HPS_IOB_13 - PIN_L12
# PRUNED_UNUSED_PORT set_location_assignment PIN_L12 -to EMAC_TX_CLK
# HPS_IOB_14 - PIN_P7
# PRUNED_UNUSED_PORT set_location_assignment PIN_P7  -to EMAC_TX_CTL
# HPS_IOB_15 - PIN_K13
# PRUNED_UNUSED_PORT set_location_assignment PIN_K13 -to EMAC_RX_CLK
# HPS_IOB_16 - PIN_N6
# PRUNED_UNUSED_PORT set_location_assignment PIN_N6  -to EMAC_RX_CTL
# HPS_IOB_17 - PIN_H11
# PRUNED_UNUSED_PORT set_location_assignment PIN_H11 -to EMAC_TXD[0]
# HPS_IOB_18 - PIN_L6
# PRUNED_UNUSED_PORT set_location_assignment PIN_L6  -to EMAC_TXD[1]
# HPS_IOB_19 - PIN_G10
# PRUNED_UNUSED_PORT set_location_assignment PIN_G10 -to EMAC_RXD[0]
# HPS_IOB_20 - PIN_K5
# PRUNED_UNUSED_PORT set_location_assignment PIN_K5  -to EMAC_RXD[1]
# HPS_IOB_21 - PIN_G12
# PRUNED_UNUSED_PORT set_location_assignment PIN_G12 -to EMAC_TXD[2]
# HPS_IOB_22 - PIN_H5
# PRUNED_UNUSED_PORT set_location_assignment PIN_H5  -to EMAC_TXD[3]
# HPS_IOB_23 - PIN_H13
# PRUNED_UNUSED_PORT set_location_assignment PIN_H13 -to EMAC_RXD[2]
# HPS_IOB_24 - PIN_G4
# PRUNED_UNUSED_PORT set_location_assignment PIN_G4  -to EMAC_RXD[3]

# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to M2_PEWAKE_L
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to M2_CLKREQ_L
set_instance_assignment -name IO_STANDARD 1.8V -to HPS_UART_TXD
set_instance_assignment -name IO_STANDARD 1.8V -to HPS_UART_RXD
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to M2_PERST_OUT_L
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to MCIO_PERST_OUT_L
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to ETH_PHY_RESET_L
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to EMAC_MDIO
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to EMAC_MDC
#set_instance_assignment -name IO_STANDARD 1.8V -to MCIO_PERSTA
#set_instance_assignment -name IO_STANDARD 1.8V -to MCIO_PERSTB
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to EMAC_TX_CLK
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to EMAC_TX_CTL
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to EMAC_RX_CLK
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to EMAC_RX_CTL
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to EMAC_TXD
# PRUNED_UNUSED_PORT set_instance_assignment -name IO_STANDARD 1.8V -to EMAC_RXD

# --------------------------
# SDM Bank - non-fabric pins
# --------------------------
# SDM_IO0   - PIN_FH65
set_location_assignment PIN_FH65 -to PWRMGT_SCL
# SDM_IO1   - PIN_FN64
set_location_assignment PIN_FN64 -to AVST_DATA[2]
# SDM_IO2   - PIN_FC64
set_location_assignment PIN_FC64 -to AVST_DATA[0]
# SDM_IO3   - PIN_FL64
set_location_assignment PIN_FL64 -to AVST_DATA[3]
# SDM_IO4   - PIN_FG66
set_location_assignment PIN_FG66 -to AVST_DATA[1]
# SDM_IO5   - PIN_FV67
set_location_assignment PIN_FV67 -to INIT_DONE_MSEL[0]
# SDM_IO6   - PIN_FM65
set_location_assignment PIN_FM65 -to AVST_DATA[4]
# SDM_IO7   - PIN_EW64
set_location_assignment PIN_EW64 -to HPS_RESET_L_MSEL[1]
# SDM_IO8   - PIN_FA66
set_location_assignment PIN_FA66 -to AVST_READY
# SDM_IO9   - PIN_FB65
set_location_assignment PIN_FB65 -to PWRMGT_ALERT_MSEL[2]
# SDM_IO10  - PIN_FK65
set_location_assignment PIN_FK65 -to AVST_VALID
# SDM_IO11  - PIN_EW66
set_location_assignment PIN_EW66 -to AVST_DATA[7]
# SDM_IO12  - PIN_EY65
set_location_assignment PIN_EY65 -to PWRMGT_SDA
# SDM_IO13  - PIN_EW68
set_location_assignment PIN_EW68 -to AVST_DATA[5]
# SDM_IO14  - PIN_FE64
set_location_assignment PIN_FE64 -to AVST_CLK
# SDM_IO15  - PIN_FB67
set_location_assignment PIN_FB67 -to AVST_DATA[6]
# SDM_IO16  - PIN_FA68
set_location_assignment PIN_FA68 -to CONF_DONE

# TDO       - PIN_FD67
set_location_assignment PIN_FD67 -to SDM_TDO
# nCONFIG   - PIN_FF65
set_location_assignment PIN_FF65 -to SDM_nCONFIG
# OSK_CLK_1 - PIN_FE66
set_location_assignment PIN_FE66 -to SDM_OSC_CLK_1
# nSTATUS   - PIN_FG64
set_location_assignment PIN_FG64 -to SDM_nSTATUS
# TMS       - PIN_FB69
set_location_assignment PIN_FB69 -to SDM_TMS
# TDI       - PIN_EY69
set_location_assignment PIN_EY69 -to SDM_TDI
# TCK       - PIN_EY67
set_location_assignment PIN_EY67 -to SDM_TCK
# RREF_SDM  - PIN_FF69
set_location_assignment PIN_FF69 -to RREF_SDM
