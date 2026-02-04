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
# Title       : IA-860m Post IP inclusion Timing Constraints
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
# Set Clock Groups
#**************************************************************
# Debug/SignalTap Asynchronous Groups
set_clock_groups -asynchronous -group {altera_reserved_tck} -group {u001_user_clk0_pll|iopll_0_sysclk} 
set_clock_groups -asynchronous -group {altera_reserved_tck} -group {u001_user_clk0_pll|iopll_0_dram_usr_clk}
set_clock_groups -asynchronous -group {altera_reserved_tck} -group {u001_user_clk0_pll|iopll_0_spi_clk}
set_clock_groups -asynchronous -group {altera_reserved_tck} -group {u008_hbm_fbr_clk_pll_bottom|iopll_0_hbm_test_clk}
set_clock_groups -asynchronous -group {altera_reserved_tck} -group {u009_hbm_fbr_clk_pll_top|iopll_0_hbm_test_clk}
set_clock_groups -asynchronous -group {altera_reserved_tck} -group {u0|pcie_sub_0|pcie_sub_rtile_avst|pcie_sub_rtile_avst_pld_clkout_slow}

# Main Asynchronous Groups
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u001_user_clk0_pll|iopll_0_dram_usr_clk}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u001_user_clk0_pll|iopll_0_spi_clk}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u001_user_clk0_pll|iopll_0_powerburner_clk}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u0|pcie_sub_0|pcie_sub_rtile_avst|pcie_sub_rtile_avst_pld_clkout}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_mem_usr_clk} -group {u0|pcie_sub_0|pcie_sub_rtile_avst|pcie_sub_rtile_avst_pld_clkout}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u008_hbm_fbr_clk_pll_bottom|iopll_0_hbm_test_clk}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u009_hbm_fbr_clk_pll_top|iopll_0_hbm_test_clk}
set_clock_groups -asynchronous -group {u008_hbm_fbr_clk_pll_bottom|iopll_0_hbm_initiator_clk} -group {u008_hbm_fbr_clk_pll_bottom|iopll_0_hbm_test_clk}
set_clock_groups -asynchronous -group {u009_hbm_fbr_clk_pll_top|iopll_0_hbm_initiator_clk} -group {u009_hbm_fbr_clk_pll_top|iopll_0_hbm_test_clk}

set_clock_groups -asynchronous -group {u0|pcie_sub_0|pcie_sub_rtile_avst|pcie_sub_rtile_avst_pld_clkout} -group {u008_hbm_fbr_clk_pll_bottom|iopll_0_hbm_test_clk}
set_clock_groups -asynchronous -group {u0|pcie_sub_0|pcie_sub_rtile_avst|pcie_sub_rtile_avst_pld_clkout} -group {u009_hbm_fbr_clk_pll_top|iopll_0_hbm_test_clk}

set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|tx_clkout|ch23}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|tx_clkout2|ch23}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|rx_clkout|ch23}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|rx_clkout2|ch23}

set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|tx_clkout|ch23}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|tx_clkout2|ch23}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|rx_clkout|ch23}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|rx_clkout2|ch23}

set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|tx_clkout|ch23}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|tx_clkout2|ch23}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|rx_clkout|ch23}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|rx_clkout2|ch23}

# GPIO Test
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {EXT_SE_CLK}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {EXT_GPIO_IN0}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {EXT_GPIO_IN1}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u13_lvds_gpio|lvds_tst_pll|iopll_0_outclk0}

set_false_path -from u13_lvds_gpio|lvds_tst_pll|iopll_0|tennm_ph2_iopll~pll_ctrl_reg

set_false_path -from {u13_lvds_gpio|gen_counters[*].clk_counter|count_?[*]} -to {u13_lvds_gpio|rdata_i[*]}
set_false_path                                                              -to {u13_lvds_gpio|gen_counters[*].retime_*|shift_reg[0]}

# Clocks Test
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {U1PPS}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {CLKA}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {u020_user_clk1_pll|iopll_0_user_clk}
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_sysclk} -group {USR_CLK1}

set_false_path -from {u2_0_clocks|u0_clks_test|gen_counters[*].clk_counter|count_?[*]} -to {u2_0_clocks|u0_clks_test|rdata_i[*]}
set_false_path                                                                         -to {u2_0_clocks|u0_clks_test|gen_counters[*].retime_*|shift_reg[0]}

# HBM Clocks
set_false_path -from u008_hbm_fbr_clk_pll_bottom|iopll_0|tennm_ph2_iopll~pll_ctrl_reg
set_false_path -from u009_hbm_fbr_clk_pll_top|iopll_0|tennm_ph2_iopll~pll_ctrl_reg

# XCVR_BIST
set_false_path -from {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|err_inj_field_tmp[*]}
set_false_path -from {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|retime_rx_core_rst_n|q_i[1][0]} -to {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|inst_phy_adapter|o_rx_mii_d_hi_match_d[*]}
set_false_path -from {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|retime_tx_core_rst_n|q_i[1][0]} -to {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|inst_tx_mac|tx_soft_bond_inst|tx_core_rst_sys_clkout_sync_inst|u|din_s1}
set_false_path -from {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|retime_rx_core_rst_n|q_i[1][0]} -to {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|inst_phy_adapter|rx_core_rst_sys_clkout_sync_inst|u|din_s1}

set_false_path -from {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|err_inj_field_tmp[*]}
set_false_path -from {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|retime_rx_core_rst_n|q_i[1][0]} -to {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|inst_phy_adapter|o_rx_mii_d_hi_match_d[*]}
set_false_path -from {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|retime_tx_core_rst_n|q_i[1][0]} -to {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|inst_tx_mac|tx_soft_bond_inst|tx_core_rst_sys_clkout_sync_inst|u|din_s1}
set_false_path -from {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|retime_rx_core_rst_n|q_i[1][0]} -to {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|inst_phy_adapter|rx_core_rst_sys_clkout_sync_inst|u|din_s1}

set_false_path -from {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|err_inj_field_tmp[*]}
set_false_path -from {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|retime_rx_core_rst_n|q_i[1][0]} -to {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|inst_phy_adapter|o_rx_mii_d_hi_match_d[*]}
set_false_path -from {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|retime_tx_core_rst_n|q_i[1][0]} -to {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|inst_tx_mac|tx_soft_bond_inst|tx_core_rst_sys_clkout_sync_inst|u|din_s1}
set_false_path -from {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|retime_rx_core_rst_n|q_i[1][0]} -to {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|inst_phy_adapter|rx_core_rst_sys_clkout_sync_inst|u|din_s1}

#********************************************
# false path first stage of all synchronizers
#********************************************
# XCVR_BST
set_false_path -to {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|retime_*|q_i[0][0]}
set_false_path -to {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|ftile_retime[*].retime_*|q_i[0][0]}
set_false_path -to {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|tx_efifo_ccc|rst_sync_tx_rd_clk|resync_chains[0].synchronizer_nocut|dreg[*]}
set_false_path -to {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|tx_efifo_ccc|rst_sync_tx_rd_clk|resync_chains[0].synchronizer_nocut|din_s1}
set_false_path -to {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|inst_tx_mac|tx_soft_bond_inst|tx_core_rst_sys_clkout_sync_inst|u|din_s1}
set_false_path -from {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|general_fifo_debug|write_addr_gray[*]} -to {u9_qsfpdd0_test|xcvr_bist_qsfpdd_?|general_fifo_debug|write_addr_gray_r1[*]}

set_false_path -to {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|retime_*|q_i[0][0]}
set_false_path -to {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|ftile_retime[*].retime_*|q_i[0][0]}
set_false_path -to {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|tx_efifo_ccc|rst_sync_tx_rd_clk|resync_chains[0].synchronizer_nocut|dreg[*]}
set_false_path -to {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|tx_efifo_ccc|rst_sync_tx_rd_clk|resync_chains[0].synchronizer_nocut|din_s1}
set_false_path -to {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|inst_tx_mac|tx_soft_bond_inst|tx_core_rst_sys_clkout_sync_inst|u|din_s1}
set_false_path -from {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|general_fifo_debug|write_addr_gray[*]} -to {u10_qsfpdd1_test|xcvr_bist_qsfpdd_?|general_fifo_debug|write_addr_gray_r1[*]}

set_false_path -to {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|retime_*|q_i[0][0]}
set_false_path -to {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|ftile_retime[*].retime_*|q_i[0][0]}
set_false_path -to {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|tx_efifo_ccc|rst_sync_tx_rd_clk|resync_chains[0].synchronizer_nocut|dreg[*]}
set_false_path -to {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|tx_efifo_ccc|rst_sync_tx_rd_clk|resync_chains[0].synchronizer_nocut|din_s1}
set_false_path -to {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|ftile_??g.serialliteiv_x8|sl4_f_0|sip|inst_tx_mac|tx_soft_bond_inst|tx_core_rst_sys_clkout_sync_inst|u|din_s1}
set_false_path -from {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|general_fifo_debug|write_addr_gray[*]} -to {u11_qsfpdd2_test|xcvr_bist_qsfpdd_?|general_fifo_debug|write_addr_gray_r1[*]}

#*********************************************
# BMC 3 Interface
#*********************************************
set_clock_groups -asynchronous -group {u001_user_clk0_pll|iopll_0_spi_clk} -group {FPGA_IG_SPI_SCK} 

set_output_delay -clock {u001_user_clk0_pll|iopll_0_spi_clk} 3 [get_ports {FPGA_EG_SPI_SCK}]
set_output_delay -clock {u001_user_clk0_pll|iopll_0_spi_clk} 3 [get_ports {FPGA_EG_SPI_PCS0}]
set_output_delay -clock {u001_user_clk0_pll|iopll_0_spi_clk} 3 [get_ports {FPGA_EG_SPI_MOSI}]
set_input_delay -clock {u001_user_clk0_pll|iopll_0_spi_clk} 5 [get_ports {FPGA_EG_SPI_MISO}]

set_input_delay -clock FPGA_IG_SPI_SCK -max 8 -clock_fall [get_ports {FPGA_IG_SPI_MOSI}]
set_input_delay -clock FPGA_IG_SPI_SCK -min 2 -clock_fall [get_ports {FPGA_IG_SPI_MOSI}]

set_output_delay -clock FPGA_IG_SPI_SCK -max 22.5  [get_ports {FPGA_IG_SPI_MISO}]
set_output_delay -clock FPGA_IG_SPI_SCK -min 0     [get_ports {FPGA_IG_SPI_MISO}]

set_input_delay -clock {u001_user_clk0_pll|iopll_0_spi_clk} 2.5 [get_ports {FPGA_IG_SPI_SCK}]
set_input_delay -clock {u001_user_clk0_pll|iopll_0_spi_clk} 2.5 [get_ports {FPGA_IG_SPI_PCS0}]


# From "AV SoC Golden Hardware Reference Design"
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
# set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_ntrst]
set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]

