--------------------------------------------------------------------------------
--
--      This source code is provided to you (the Licensee) under license
--      by BittWare, a Molex Company. To view or use this source code,
--      the Licensee must accept a Software License Agreement (viewable
--      at developer.bittware.com), which is commonly provided as a click-
--      through license agreement. The terms of the Software License
--      Agreement govern all use and distribution of this file unless an
--      alternative superseding license has been executed with BittWare.
--      This source code and its derivatives may not be distributed to
--      third parties in source code form. Software including or derived
--      from this source code, including derivative works thereof created
--      by Licensee, may be distributed to third parties with BittWare
--      hardware only and in executable form only.
--
--      The click-through license is available here:
--        https://developer.bittware.com/software_license.txt
--
--------------------------------------------------------------------------------
--      UNCLASSIFIED//FOR OFFICIAL USE ONLY
--------------------------------------------------------------------------------
-- Title       : Package for AXI Interfaces
-- Project     : IA-860m
--------------------------------------------------------------------------------
-- Description : This package contains:
--
--            1/ A record for each AXI4-Lite interface
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

package pkg_axi_buses is


  type T_hbm2e_status_axi is record
    hbm2e_status_awaddr                : std_logic_vector(43 downto 0);
    hbm2e_status_awvalid               : std_logic;
    hbm2e_status_awready               : std_logic;
    hbm2e_status_awprot                : std_logic_vector(2 downto 0);
    hbm2e_status_wdata                 : std_logic_vector(31 downto 0);
    hbm2e_status_wstrb                 : std_logic_vector(3 downto 0);
    hbm2e_status_wvalid                : std_logic;
    hbm2e_status_wready                : std_logic;
    hbm2e_status_bresp                 : std_logic_vector(1 downto 0);
    hbm2e_status_bvalid                : std_logic;
    hbm2e_status_bready                : std_logic;
    hbm2e_status_araddr                : std_logic_vector(43 downto 0);
    hbm2e_status_arvalid               : std_logic;
    hbm2e_status_arready               : std_logic;
    hbm2e_status_arprot                : std_logic_vector(2 downto 0);
    hbm2e_status_rdata                 : std_logic_vector(31 downto 0);
    hbm2e_status_rresp                 : std_logic_vector(1 downto 0);
    hbm2e_status_rvalid                : std_logic;
    hbm2e_status_rready                : std_logic;  
  end record;

  type T_hbm2e_test_ctrl_axi is record
    hbm2e_test_ctrl_awaddr             : std_logic_vector(5 downto 0);
    hbm2e_test_ctrl_awvalid            : std_logic;
    hbm2e_test_ctrl_awready            : std_logic;
    hbm2e_test_ctrl_awprot             : std_logic_vector(2 downto 0);
    hbm2e_test_ctrl_wdata              : std_logic_vector(31 downto 0);
    hbm2e_test_ctrl_wstrb              : std_logic_vector(3 downto 0);
    hbm2e_test_ctrl_wvalid             : std_logic;
    hbm2e_test_ctrl_wready             : std_logic;
    hbm2e_test_ctrl_bresp              : std_logic_vector(1 downto 0);
    hbm2e_test_ctrl_bvalid             : std_logic;
    hbm2e_test_ctrl_bready             : std_logic;
    hbm2e_test_ctrl_araddr             : std_logic_vector(5 downto 0);
    hbm2e_test_ctrl_arvalid            : std_logic;
    hbm2e_test_ctrl_arready            : std_logic;
    hbm2e_test_ctrl_arprot             : std_logic_vector(2 downto 0);
    hbm2e_test_ctrl_rdata              : std_logic_vector(31 downto 0);
    hbm2e_test_ctrl_rresp              : std_logic_vector(1 downto 0);
    hbm2e_test_ctrl_rvalid             : std_logic;
    hbm2e_test_ctrl_rready             : std_logic;
  end record;

  type T_hbm2e_error_log_axi is record
    hbm2e_error_log_awaddr             : std_logic_vector(7 downto 0);
    hbm2e_error_log_awvalid            : std_logic;
    hbm2e_error_log_awready            : std_logic;
    hbm2e_error_log_awprot             : std_logic_vector(2 downto 0);
    hbm2e_error_log_wdata              : std_logic_vector(31 downto 0);
    hbm2e_error_log_wstrb              : std_logic_vector(3 downto 0);
    hbm2e_error_log_wvalid             : std_logic;
    hbm2e_error_log_wready             : std_logic;
    hbm2e_error_log_bresp              : std_logic_vector(1 downto 0);
    hbm2e_error_log_bvalid             : std_logic;
    hbm2e_error_log_bready             : std_logic;
    hbm2e_error_log_araddr             : std_logic_vector(7 downto 0);
    hbm2e_error_log_arvalid            : std_logic;
    hbm2e_error_log_arready            : std_logic;
    hbm2e_error_log_arprot             : std_logic_vector(2 downto 0);
    hbm2e_error_log_rdata              : std_logic_vector(31 downto 0);
    hbm2e_error_log_rresp              : std_logic_vector(1 downto 0);
    hbm2e_error_log_rvalid             : std_logic;
    hbm2e_error_log_rready             : std_logic;
  end record;

  type T_clock_test_cap_axi is record
    clock_test_cap_awaddr              : std_logic_vector(12 downto 0);
    clock_test_cap_awvalid             : std_logic;
    clock_test_cap_awready             : std_logic;
    clock_test_cap_awprot              : std_logic_vector(2 downto 0);
    clock_test_cap_wdata               : std_logic_vector(31 downto 0);
    clock_test_cap_wstrb               : std_logic_vector(3 downto 0);
    clock_test_cap_wvalid              : std_logic;
    clock_test_cap_wready              : std_logic;
    clock_test_cap_bresp               : std_logic_vector(1 downto 0);
    clock_test_cap_bvalid              : std_logic;
    clock_test_cap_bready              : std_logic;
    clock_test_cap_araddr              : std_logic_vector(12 downto 0);
    clock_test_cap_arvalid             : std_logic;
    clock_test_cap_arready             : std_logic;
    clock_test_cap_arprot              : std_logic_vector(2 downto 0);
    clock_test_cap_rdata               : std_logic_vector(31 downto 0);
    clock_test_cap_rresp               : std_logic_vector(1 downto 0);
    clock_test_cap_rvalid              : std_logic;
    clock_test_cap_rready              : std_logic;
  end record;

  type T_clock_test_axi is record
    clock_test_awaddr                  : std_logic_vector(7 downto 0);
    clock_test_awvalid                 : std_logic;
    clock_test_awready                 : std_logic;
    clock_test_awprot                  : std_logic_vector(2 downto 0);
    clock_test_wdata                   : std_logic_vector(31 downto 0);
    clock_test_wstrb                   : std_logic_vector(3 downto 0);
    clock_test_wvalid                  : std_logic;
    clock_test_wready                  : std_logic;
    clock_test_bresp                   : std_logic_vector(1 downto 0);
    clock_test_bvalid                  : std_logic;
    clock_test_bready                  : std_logic;
    clock_test_araddr                  : std_logic_vector(7 downto 0);
    clock_test_arvalid                 : std_logic;
    clock_test_arready                 : std_logic;
    clock_test_arprot                  : std_logic_vector(2 downto 0);
    clock_test_rdata                   : std_logic_vector(31 downto 0);
    clock_test_rresp                   : std_logic_vector(1 downto 0);
    clock_test_rvalid                  : std_logic;
    clock_test_rready                  : std_logic;
  end record;

  type T_pwr_burner_axi is record
    pwr_burner_awaddr                  : std_logic_vector(7 downto 0);
    pwr_burner_awvalid                 : std_logic;
    pwr_burner_awready                 : std_logic;
    pwr_burner_awprot                  : std_logic_vector(2 downto 0);
    pwr_burner_wdata                   : std_logic_vector(31 downto 0);
    pwr_burner_wstrb                   : std_logic_vector(3 downto 0);
    pwr_burner_wvalid                  : std_logic;
    pwr_burner_wready                  : std_logic;
    pwr_burner_bresp                   : std_logic_vector(1 downto 0);
    pwr_burner_bvalid                  : std_logic;
    pwr_burner_bready                  : std_logic;
    pwr_burner_araddr                  : std_logic_vector(7 downto 0);
    pwr_burner_arvalid                 : std_logic;
    pwr_burner_arready                 : std_logic;
    pwr_burner_arprot                  : std_logic_vector(2 downto 0);
    pwr_burner_rdata                   : std_logic_vector(31 downto 0);
    pwr_burner_rresp                   : std_logic_vector(1 downto 0);
    pwr_burner_rvalid                  : std_logic;
    pwr_burner_rready                  : std_logic;
  end record;

  type T_qsfpdd_test_axi is record
    qsfpdd_test_awaddr                 : std_logic_vector(7 downto 0);
    qsfpdd_test_awvalid                : std_logic;
    qsfpdd_test_awready                : std_logic;
    qsfpdd_test_awprot                 : std_logic_vector(2 downto 0);
    qsfpdd_test_wdata                  : std_logic_vector(31 downto 0);
    qsfpdd_test_wstrb                  : std_logic_vector(3 downto 0);
    qsfpdd_test_wvalid                 : std_logic;
    qsfpdd_test_wready                 : std_logic;
    qsfpdd_test_bresp                  : std_logic_vector(1 downto 0);
    qsfpdd_test_bvalid                 : std_logic;
    qsfpdd_test_bready                 : std_logic;
    qsfpdd_test_araddr                 : std_logic_vector(7 downto 0);
    qsfpdd_test_arvalid                : std_logic;
    qsfpdd_test_arready                : std_logic;
    qsfpdd_test_arprot                 : std_logic_vector(2 downto 0);
    qsfpdd_test_rdata                  : std_logic_vector(31 downto 0);
    qsfpdd_test_rresp                  : std_logic_vector(1 downto 0);
    qsfpdd_test_rvalid                 : std_logic;
    qsfpdd_test_rready                 : std_logic;
  end record;

  type T_telemetry_test_axi is record
    telemetry_test_awaddr              : std_logic_vector(11 downto 0);
    telemetry_test_awvalid             : std_logic;
    telemetry_test_awready             : std_logic;
    telemetry_test_awprot              : std_logic_vector(2 downto 0);
    telemetry_test_wdata               : std_logic_vector(31 downto 0);
    telemetry_test_wstrb               : std_logic_vector(3 downto 0);
    telemetry_test_wvalid              : std_logic;
    telemetry_test_wready              : std_logic;
    telemetry_test_bresp               : std_logic_vector(1 downto 0);
    telemetry_test_bvalid              : std_logic;
    telemetry_test_bready              : std_logic;
    telemetry_test_araddr              : std_logic_vector(11 downto 0);
    telemetry_test_arvalid             : std_logic;
    telemetry_test_arready             : std_logic;
    telemetry_test_arprot              : std_logic_vector(2 downto 0);
    telemetry_test_rdata               : std_logic_vector(31 downto 0);
    telemetry_test_rresp               : std_logic_vector(1 downto 0);
    telemetry_test_rvalid              : std_logic;
    telemetry_test_rready              : std_logic;
  end record;

  type T_version_axi is record
    version_awaddr                     : std_logic_vector(4 downto 0);
    version_awvalid                    : std_logic;
    version_awready                    : std_logic;
    version_awprot                     : std_logic_vector(2 downto 0);
    version_wdata                      : std_logic_vector(31 downto 0);
    version_wstrb                      : std_logic_vector(3 downto 0);
    version_wvalid                     : std_logic;
    version_wready                     : std_logic;
    version_bresp                      : std_logic_vector(1 downto 0);
    version_bvalid                     : std_logic;
    version_bready                     : std_logic;
    version_araddr                     : std_logic_vector(4 downto 0);
    version_arvalid                    : std_logic;
    version_arready                    : std_logic;
    version_arprot                     : std_logic_vector(2 downto 0);
    version_rdata                      : std_logic_vector(31 downto 0);
    version_rresp                      : std_logic_vector(1 downto 0);
    version_rvalid                     : std_logic;
    version_rready                     : std_logic;
  end record;

  type T_leds_test_axi is record
    leds_test_awaddr                   : std_logic_vector(3 downto 0);
    leds_test_awvalid                  : std_logic;
    leds_test_awready                  : std_logic;
    leds_test_awprot                   : std_logic_vector(2 downto 0);
    leds_test_wdata                    : std_logic_vector(31 downto 0);
    leds_test_wstrb                    : std_logic_vector(3 downto 0);
    leds_test_wvalid                   : std_logic;
    leds_test_wready                   : std_logic;
    leds_test_bresp                    : std_logic_vector(1 downto 0);
    leds_test_bvalid                   : std_logic;
    leds_test_bready                   : std_logic;
    leds_test_araddr                   : std_logic_vector(3 downto 0);
    leds_test_arvalid                  : std_logic;
    leds_test_arready                  : std_logic;
    leds_test_arprot                   : std_logic_vector(2 downto 0);
    leds_test_rdata                    : std_logic_vector(31 downto 0);
    leds_test_rresp                    : std_logic_vector(1 downto 0);
    leds_test_rvalid                   : std_logic;
    leds_test_rready                   : std_logic;
  end record;

  type T_lvds_gpio_test_axi is record
    lvds_gpio_test_awaddr              : std_logic_vector(4 downto 0);
    lvds_gpio_test_awvalid             : std_logic;
    lvds_gpio_test_awready             : std_logic;
    lvds_gpio_test_awprot              : std_logic_vector(2 downto 0);
    lvds_gpio_test_wdata               : std_logic_vector(31 downto 0);
    lvds_gpio_test_wstrb               : std_logic_vector(3 downto 0);
    lvds_gpio_test_wvalid              : std_logic;
    lvds_gpio_test_wready              : std_logic;
    lvds_gpio_test_bresp               : std_logic_vector(1 downto 0);
    lvds_gpio_test_bvalid              : std_logic;
    lvds_gpio_test_bready              : std_logic;
    lvds_gpio_test_araddr              : std_logic_vector(4 downto 0);
    lvds_gpio_test_arvalid             : std_logic;
    lvds_gpio_test_arready             : std_logic;
    lvds_gpio_test_arprot              : std_logic_vector(2 downto 0);
    lvds_gpio_test_rdata               : std_logic_vector(31 downto 0);
    lvds_gpio_test_rresp               : std_logic_vector(1 downto 0);
    lvds_gpio_test_rvalid              : std_logic;
    lvds_gpio_test_rready              : std_logic;
  end record;

  type T_mcio_sb_test_axi is record
    mcio_sb_test_awaddr                : std_logic_vector(3 downto 0);
    mcio_sb_test_awvalid               : std_logic;
    mcio_sb_test_awready               : std_logic;
    mcio_sb_test_awprot                : std_logic_vector(2 downto 0);
    mcio_sb_test_wdata                 : std_logic_vector(31 downto 0);
    mcio_sb_test_wstrb                 : std_logic_vector(3 downto 0);
    mcio_sb_test_wvalid                : std_logic;
    mcio_sb_test_wready                : std_logic;
    mcio_sb_test_bresp                 : std_logic_vector(1 downto 0);
    mcio_sb_test_bvalid                : std_logic;
    mcio_sb_test_bready                : std_logic;
    mcio_sb_test_araddr                : std_logic_vector(3 downto 0);
    mcio_sb_test_arvalid               : std_logic;
    mcio_sb_test_arready               : std_logic;
    mcio_sb_test_arprot                : std_logic_vector(2 downto 0);
    mcio_sb_test_rdata                 : std_logic_vector(31 downto 0);
    mcio_sb_test_rresp                 : std_logic_vector(1 downto 0);
    mcio_sb_test_rvalid                : std_logic;
    mcio_sb_test_rready                : std_logic;
  end record;

  type T_i2c_ctrl_axi is record
    i2c_ctrl_awaddr                    : std_logic_vector(3 downto 0);
    i2c_ctrl_awvalid                   : std_logic;
    i2c_ctrl_awready                   : std_logic;
    i2c_ctrl_awprot                    : std_logic_vector(2 downto 0);
    i2c_ctrl_wdata                     : std_logic_vector(31 downto 0);
    i2c_ctrl_wstrb                     : std_logic_vector(3 downto 0);
    i2c_ctrl_wvalid                    : std_logic;
    i2c_ctrl_wready                    : std_logic;
    i2c_ctrl_bresp                     : std_logic_vector(1 downto 0);
    i2c_ctrl_bvalid                    : std_logic;
    i2c_ctrl_bready                    : std_logic;
    i2c_ctrl_araddr                    : std_logic_vector(3 downto 0);
    i2c_ctrl_arvalid                   : std_logic;
    i2c_ctrl_arready                   : std_logic;
    i2c_ctrl_arprot                    : std_logic_vector(2 downto 0);
    i2c_ctrl_rdata                     : std_logic_vector(31 downto 0);
    i2c_ctrl_rresp                     : std_logic_vector(1 downto 0);
    i2c_ctrl_rvalid                    : std_logic;
    i2c_ctrl_rready                    : std_logic;
  end record;


  type T_timestamp_axi is record
    timestamp_awaddr                   : std_logic_vector(3 downto 0);
    timestamp_awvalid                  : std_logic;
    timestamp_awready                  : std_logic;
    timestamp_awprot                   : std_logic_vector(2 downto 0);
    timestamp_wdata                    : std_logic_vector(31 downto 0);
    timestamp_wstrb                    : std_logic_vector(3 downto 0);
    timestamp_wvalid                   : std_logic;
    timestamp_wready                   : std_logic;
    timestamp_bresp                    : std_logic_vector(1 downto 0);
    timestamp_bvalid                   : std_logic;
    timestamp_bready                   : std_logic;
    timestamp_araddr                   : std_logic_vector(3 downto 0);
    timestamp_arvalid                  : std_logic;
    timestamp_arready                  : std_logic;
    timestamp_arprot                   : std_logic_vector(2 downto 0);
    timestamp_rdata                    : std_logic_vector(31 downto 0);
    timestamp_rresp                    : std_logic_vector(1 downto 0);
    timestamp_rvalid                   : std_logic;
    timestamp_rready                   : std_logic;
  end record;
  
  type T_xcvr_reconfig_avmm is record 
    xcvr_reconfig_waitrequest          : std_logic;
    xcvr_reconfig_readdata             : std_logic_vector(31 downto 0);
    xcvr_reconfig_readdatavalid        : std_logic;
    xcvr_reconfig_burstcount           : std_logic_vector(0 downto 0);
    xcvr_reconfig_writedata            : std_logic_vector(31 downto 0);
    xcvr_reconfig_address              : std_logic_vector(20 downto 0);
    xcvr_reconfig_write                : std_logic;
    xcvr_reconfig_read                 : std_logic;
    xcvr_reconfig_byteenable           : std_logic_vector(3 downto 0);
    xcvr_reconfig_debugaccess          : std_logic;
  end record;

  type T_sl4_reconfig_avmm is record 
    sl4_reconfig_waitrequest           : std_logic;
    sl4_reconfig_readdata              : std_logic_vector(31 downto 0);
    sl4_reconfig_readdatavalid         : std_logic;
    sl4_reconfig_burstcount            : std_logic_vector(0 downto 0);
    sl4_reconfig_writedata             : std_logic_vector(31 downto 0);
    sl4_reconfig_address               : std_logic_vector(16 downto 0);
    sl4_reconfig_write                 : std_logic;
    sl4_reconfig_read                  : std_logic;
    sl4_reconfig_byteenable            : std_logic_vector(3 downto 0);
    sl4_reconfig_debugaccess           : std_logic;
  end record;

end pkg_axi_buses;

package body pkg_axi_buses is
end pkg_axi_buses;
