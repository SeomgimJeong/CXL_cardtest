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
-- Title       : Cardtest Top
-- Project     : IA-860m
--------------------------------------------------------------------------------
-- Description : Cardtest design for IA-860m.  
--               QSFPDDs operate at 53Gbps
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--  HPS not included
--  MCIO Interface not included
--  M.2 SSD Interface not included
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.pkg_axi_buses.all;
use work.pkg_xcvr_rate.all;
use work.pkg_revision.all;
use work.pkg_clks_cap_rom_config.all;

entity cardtest_top is
port (
  -- Input Clocks
  USR_CLK0           : in     std_logic;
  USR_CLK1           : in     std_logic;
  CLKA               : in     std_logic;
  U1PPS              : in     std_logic;
  -- Host PCIe (R-Tile) 
  PCIE_REFCLK0       : in     std_logic;
  PCIE_REFCLK1       : in     std_logic;
  PERST_L            : in     std_logic;
  PCIE_TX_P          : out    std_logic_vector(15 downto 0);
  PCIE_TX_N          : out    std_logic_vector(15 downto 0);
  PCIE_RX_P          : in     std_logic_vector(15 downto 0);
  PCIE_RX_N          : in     std_logic_vector(15 downto 0);
  -- HBM Lower
  HBM_REFCLK0        : in     std_logic;
  HBM_FBR_REFCLK0    : in     std_logic;
  HBM_CATRIP0        : in     std_logic;
  HBM_TEMP0          : in     std_logic_vector(2 downto 0);
  -- HBM Upper
  HBM_REFCLK1        : in     std_logic;
  HBM_FBR_REFCLK1    : in     std_logic;
  HBM_CATRIP1        : in     std_logic;
  HBM_TEMP1          : in     std_logic_vector(2 downto 0);
  -- NoC Clocks
  NOC_CLK0           : in     std_logic;
  NOC_CLK1           : in     std_logic;
  -- BMC General
  FPGA_RST_L         : in     std_logic;
  BMC_IF_PRESENT_L   : out    std_logic;
  -- BMC SPI Ingress
  FPGA_IG_SPI_SCK    : in     std_logic;
  FPGA_IG_SPI_PCS0   : in     std_logic;
  FPGA_IG_SPI_MOSI   : in     std_logic;
  FPGA_IG_SPI_MISO   : out    std_logic;
  FPGA_TO_BMC_IRQ    : out    std_logic;
  -- BMC SPI Egress
  FPGA_EG_SPI_SCK    : out    std_logic;
  FPGA_EG_SPI_PCS0   : out    std_logic;
  FPGA_EG_SPI_MOSI   : out    std_logic;
  FPGA_EG_SPI_MISO   : in     std_logic;
  BMC_TO_FPGA_IRQ    : in     std_logic;
  -- LEDs
  FPGA_LED_G_L       : out    std_logic;
  FPGA_LED_R_L       : out    std_logic;
  -- GPIO (LVDS prior to FPGA)
  EXT_SE_CLK         : in     std_logic;
  EXT_GPIO_IN        : in     std_logic_vector(1 downto 0);
  EXT_GPIO_OUT       : out    std_logic;
  -- QSFPDD0
  QSFP0_REFCLK       : in     std_logic;
  QSFP0_TX_P         : out    std_logic_vector(7 downto 0);
  QSFP0_TX_N         : out    std_logic_vector(7 downto 0);
  QSFP0_RX_P         : in     std_logic_vector(7 downto 0);
  QSFP0_RX_N         : in     std_logic_vector(7 downto 0);
  --RECV0_CLK          : out    std_logic;
  -- QSFPDD1
  QSFP1_REFCLK       : in     std_logic;
  QSFP1_TX_P         : out    std_logic_vector(7 downto 0);
  QSFP1_TX_N         : out    std_logic_vector(7 downto 0);
  QSFP1_RX_P         : in     std_logic_vector(7 downto 0);
  QSFP1_RX_N         : in     std_logic_vector(7 downto 0);
  --RECV1_CLK          : out    std_logic;
  -- QSFPDD2
  QSFP2_REFCLK       : in     std_logic;
  QSFP2_TX_P         : out    std_logic_vector(7 downto 0);
  QSFP2_TX_N         : out    std_logic_vector(7 downto 0);
  QSFP2_RX_P         : in     std_logic_vector(7 downto 0);
  QSFP2_RX_N         : in     std_logic_vector(7 downto 0);
  --RECV2_CLK          : out    std_logic
  -- MCIO
  MCIO_REFCLK        : in     std_logic;
  --MCIO_PERST_N       : in     std_logic;
  --MCIO_TX_P          : out    std_logic_vector(7 downto 0);
  --MCIO_TX_N          : out    std_logic_vector(7 downto 0);
  --MCIO_RX_P          : in     std_logic_vector(7 downto 0);
  --MCIO_RX_N          : in     std_logic_vector(7 downto 0);
  -- M.2 SSD
  M2_REFCLK          : in     std_logic;
  --M2_PERST_N         : in     std_logic;
  --M2SSD_TX_P         : out    std_logic_vector(3 downto 0);
  --M2SSD_TX_N         : out    std_logic_vector(3 downto 0);
  --M2SSD_RX_P         : in     std_logic_vector(3 downto 0);
  --M2SSD_RX_N         : in     std_logic_vector(3 downto 0);
  -- HPS DDR4 SDRAM
  HPS_DDR4_REFCLK    : in    std_logic;
  HPS_DDR4_A         : out   std_logic_vector(16 downto 0);
  HPS_DDR4_ACT_L     : out   std_logic;
  HPS_DDR4_ALERT_L   : in    std_logic;
  HPS_DDR4_BA        : out   std_logic_vector(1 downto 0);
  HPS_DDR4_BG        : out   std_logic;
  HPS_DDR4_CKE       : out   std_logic;
  HPS_DDR4_CS_L      : out   std_logic;
  HPS_DDR4_CLK_P     : out   std_logic;
  HPS_DDR4_CLK_N     : out   std_logic;
  HPS_DDR4_ODT       : out   std_logic;
  HPS_DDR4_PARITY    : out   std_logic;
  HPS_DDR4_RESET_L   : out   std_logic;
  HPS_DDR4_DQ        : inout std_logic_vector(39 downto 0);
  HPS_DDR4_DQS_P     : inout std_logic_vector(4 downto 0);
  HPS_DDR4_DQS_N     : inout std_logic_vector(4 downto 0);
  HPS_DDR4_DM        : inout std_logic_vector(4 downto 0);
  HPS_DDR4_RZQ       : in    std_logic;
  -- Buffer Enables
  DDR4_TEN           : out    std_logic;
  MCIO_GPIO_EN_L     : out    std_logic;
  EXT_GPIO_EN_L      : out    std_logic;
  MCIO_I2C_EN        : out    std_logic
  );
end entity cardtest_top;

architecture rtl of cardtest_top is

component main
generic (
  skeleton_ia860m_0_bmc3_telemetry_clk_period           : integer := 20;
  skeleton_ia860m_0_bmc3_telemetry_time_between_updates : integer := 100;
  version_id_ip_version                                 : string  := "0.1.0";
  clocks_test_ip_version                                : string  := "0.1.0";
  powerburner_ip_version                                : string  := "0.1.0";
  serialliteiv_ip_version                               : string  := "0.1.0";
  serialliteiv_xcvr_mode                                : string  := "PAM4";
  serialliteiv_lane_count                               : integer := 8;
  qsfpdd_test_ip_version                                : string  := "0.1.0";
  telemetry_test_ip_version                             : string  := "0.1.0";
  led_test_ip_version                                   : string  := "0.1.0";
  hbm2e_ip_version                                      : string  := "0.1.0";
  hbm2e_test_ip_version                                 : string  := "0.1.0";
  lvds_gpio_test_ip_version                             : string  := "0.1.0";
  hps_dram_test_ip_version                              : string  := "0.1.0"
  );
port (
  pcieclk_clk                                  : out std_logic;                                          
  pcieresetn_reset_n                           : out std_logic;                                          
  spi_sysclk_clk                               : in  std_logic                       := '0';             
  spi_sysreset_reset                           : in  std_logic                       := '0';             
  sysclk_clk                                   : in  std_logic                       := '0';             
  sysreset_reset                               : in  std_logic                       := '0';             
  clock_test_cap_axi_m_awaddr                  : out std_logic_vector(12 downto 0);                       
  clock_test_cap_axi_m_awprot                  : out std_logic_vector(2 downto 0);                       
  clock_test_cap_axi_m_awvalid                 : out std_logic;                                          
  clock_test_cap_axi_m_awready                 : in  std_logic                       := '0';             
  clock_test_cap_axi_m_wdata                   : out std_logic_vector(31 downto 0);                      
  clock_test_cap_axi_m_wstrb                   : out std_logic_vector(3 downto 0);                       
  clock_test_cap_axi_m_wvalid                  : out std_logic;                                          
  clock_test_cap_axi_m_wready                  : in  std_logic                       := '0';             
  clock_test_cap_axi_m_bresp                   : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  clock_test_cap_axi_m_bvalid                  : in  std_logic                       := '0';             
  clock_test_cap_axi_m_bready                  : out std_logic;                                          
  clock_test_cap_axi_m_araddr                  : out std_logic_vector(12 downto 0);                       
  clock_test_cap_axi_m_arprot                  : out std_logic_vector(2 downto 0);                       
  clock_test_cap_axi_m_arvalid                 : out std_logic;                                          
  clock_test_cap_axi_m_arready                 : in  std_logic                       := '0';             
  clock_test_cap_axi_m_rdata                   : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  clock_test_cap_axi_m_rresp                   : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  clock_test_cap_axi_m_rvalid                  : in  std_logic                       := '0';             
  clock_test_cap_axi_m_rready                  : out std_logic;                                          
  clocks_test_axi_m_awaddr                     : out std_logic_vector(7 downto 0);                       
  clocks_test_axi_m_awprot                     : out std_logic_vector(2 downto 0);                       
  clocks_test_axi_m_awvalid                    : out std_logic;                                          
  clocks_test_axi_m_awready                    : in  std_logic                       := '0';             
  clocks_test_axi_m_wdata                      : out std_logic_vector(31 downto 0);                      
  clocks_test_axi_m_wstrb                      : out std_logic_vector(3 downto 0);                       
  clocks_test_axi_m_wvalid                     : out std_logic;                                          
  clocks_test_axi_m_wready                     : in  std_logic                       := '0';             
  clocks_test_axi_m_bresp                      : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  clocks_test_axi_m_bvalid                     : in  std_logic                       := '0';             
  clocks_test_axi_m_bready                     : out std_logic;                                          
  clocks_test_axi_m_araddr                     : out std_logic_vector(7 downto 0);                       
  clocks_test_axi_m_arprot                     : out std_logic_vector(2 downto 0);                       
  clocks_test_axi_m_arvalid                    : out std_logic;                                          
  clocks_test_axi_m_arready                    : in  std_logic                       := '0';             
  clocks_test_axi_m_rdata                      : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  clocks_test_axi_m_rresp                      : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  clocks_test_axi_m_rvalid                     : in  std_logic                       := '0';             
  clocks_test_axi_m_rready                     : out std_logic;                                          
  hps_dram_error_logging_axi_m_awaddr          : out std_logic_vector(7 downto 0);                       
  hps_dram_error_logging_axi_m_awprot          : out std_logic_vector(2 downto 0);                       
  hps_dram_error_logging_axi_m_awvalid         : out std_logic;                                          
  hps_dram_error_logging_axi_m_awready         : in  std_logic                       := '0';             
  hps_dram_error_logging_axi_m_wdata           : out std_logic_vector(31 downto 0);                      
  hps_dram_error_logging_axi_m_wstrb           : out std_logic_vector(3 downto 0);                       
  hps_dram_error_logging_axi_m_wvalid          : out std_logic;                                          
  hps_dram_error_logging_axi_m_wready          : in  std_logic                       := '0';             
  hps_dram_error_logging_axi_m_bresp           : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hps_dram_error_logging_axi_m_bvalid          : in  std_logic                       := '0';             
  hps_dram_error_logging_axi_m_bready          : out std_logic;                                          
  hps_dram_error_logging_axi_m_araddr          : out std_logic_vector(7 downto 0);                       
  hps_dram_error_logging_axi_m_arprot          : out std_logic_vector(2 downto 0);                       
  hps_dram_error_logging_axi_m_arvalid         : out std_logic;                                          
  hps_dram_error_logging_axi_m_arready         : in  std_logic                       := '0';             
  hps_dram_error_logging_axi_m_rdata           : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hps_dram_error_logging_axi_m_rresp           : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hps_dram_error_logging_axi_m_rvalid          : in  std_logic                       := '0';             
  hps_dram_error_logging_axi_m_rready          : out std_logic;                                               
  hps_dram_test_axi_m_awaddr                   : out std_logic_vector(5 downto 0);                       
  hps_dram_test_axi_m_awprot                   : out std_logic_vector(2 downto 0);                       
  hps_dram_test_axi_m_awvalid                  : out std_logic;                                          
  hps_dram_test_axi_m_awready                  : in  std_logic                       := '0';             
  hps_dram_test_axi_m_wdata                    : out std_logic_vector(31 downto 0);                      
  hps_dram_test_axi_m_wstrb                    : out std_logic_vector(3 downto 0);                       
  hps_dram_test_axi_m_wvalid                   : out std_logic;                                          
  hps_dram_test_axi_m_wready                   : in  std_logic                       := '0';             
  hps_dram_test_axi_m_bresp                    : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hps_dram_test_axi_m_bvalid                   : in  std_logic                       := '0';             
  hps_dram_test_axi_m_bready                   : out std_logic;                                          
  hps_dram_test_axi_m_araddr                   : out std_logic_vector(5 downto 0);                       
  hps_dram_test_axi_m_arprot                   : out std_logic_vector(2 downto 0);                       
  hps_dram_test_axi_m_arvalid                  : out std_logic;                                          
  hps_dram_test_axi_m_arready                  : in  std_logic                       := '0';             
  hps_dram_test_axi_m_rdata                    : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hps_dram_test_axi_m_rresp                    : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hps_dram_test_axi_m_rvalid                   : in  std_logic                       := '0';             
  hps_dram_test_axi_m_rready                   : out std_logic; 
  leds_test_axi_m_awaddr                       : out std_logic_vector(3 downto 0);                       
  leds_test_axi_m_awprot                       : out std_logic_vector(2 downto 0);                       
  leds_test_axi_m_awvalid                      : out std_logic;                                          
  leds_test_axi_m_awready                      : in  std_logic                       := '0';             
  leds_test_axi_m_wdata                        : out std_logic_vector(31 downto 0);                      
  leds_test_axi_m_wstrb                        : out std_logic_vector(3 downto 0);                       
  leds_test_axi_m_wvalid                       : out std_logic;                                          
  leds_test_axi_m_wready                       : in  std_logic                       := '0';             
  leds_test_axi_m_bresp                        : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  leds_test_axi_m_bvalid                       : in  std_logic                       := '0';             
  leds_test_axi_m_bready                       : out std_logic;                                          
  leds_test_axi_m_araddr                       : out std_logic_vector(3 downto 0);                       
  leds_test_axi_m_arprot                       : out std_logic_vector(2 downto 0);                       
  leds_test_axi_m_arvalid                      : out std_logic;                                          
  leds_test_axi_m_arready                      : in  std_logic                       := '0';             
  leds_test_axi_m_rdata                        : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  leds_test_axi_m_rresp                        : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  leds_test_axi_m_rvalid                       : in  std_logic                       := '0';             
  leds_test_axi_m_rready                       : out std_logic;    
  lvds_gpio_test_axi_m_awaddr                  : out std_logic_vector(4 downto 0);                       
  lvds_gpio_test_axi_m_awprot                  : out std_logic_vector(2 downto 0);                       
  lvds_gpio_test_axi_m_awvalid                 : out std_logic;                                          
  lvds_gpio_test_axi_m_awready                 : in  std_logic                       := '0';             
  lvds_gpio_test_axi_m_wdata                   : out std_logic_vector(31 downto 0);                      
  lvds_gpio_test_axi_m_wstrb                   : out std_logic_vector(3 downto 0);                       
  lvds_gpio_test_axi_m_wvalid                  : out std_logic;                                          
  lvds_gpio_test_axi_m_wready                  : in  std_logic                       := '0';             
  lvds_gpio_test_axi_m_bresp                   : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  lvds_gpio_test_axi_m_bvalid                  : in  std_logic                       := '0';             
  lvds_gpio_test_axi_m_bready                  : out std_logic;                                          
  lvds_gpio_test_axi_m_araddr                  : out std_logic_vector(4 downto 0);                       
  lvds_gpio_test_axi_m_arprot                  : out std_logic_vector(2 downto 0);                       
  lvds_gpio_test_axi_m_arvalid                 : out std_logic;                                          
  lvds_gpio_test_axi_m_arready                 : in  std_logic                       := '0';             
  lvds_gpio_test_axi_m_rdata                   : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  lvds_gpio_test_axi_m_rresp                   : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  lvds_gpio_test_axi_m_rvalid                  : in  std_logic                       := '0';             
  lvds_gpio_test_axi_m_rready                  : out std_logic;                                          
  pwr_burner_axi_m_awaddr                      : out std_logic_vector(7 downto 0);                       
  pwr_burner_axi_m_awprot                      : out std_logic_vector(2 downto 0);                       
  pwr_burner_axi_m_awvalid                     : out std_logic;                                          
  pwr_burner_axi_m_awready                     : in  std_logic                       := '0';             
  pwr_burner_axi_m_wdata                       : out std_logic_vector(31 downto 0);                      
  pwr_burner_axi_m_wstrb                       : out std_logic_vector(3 downto 0);                       
  pwr_burner_axi_m_wvalid                      : out std_logic;                                          
  pwr_burner_axi_m_wready                      : in  std_logic                       := '0';             
  pwr_burner_axi_m_bresp                       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  pwr_burner_axi_m_bvalid                      : in  std_logic                       := '0';             
  pwr_burner_axi_m_bready                      : out std_logic;                                          
  pwr_burner_axi_m_araddr                      : out std_logic_vector(7 downto 0);                       
  pwr_burner_axi_m_arprot                      : out std_logic_vector(2 downto 0);                       
  pwr_burner_axi_m_arvalid                     : out std_logic;                                          
  pwr_burner_axi_m_arready                     : in  std_logic                       := '0';             
  pwr_burner_axi_m_rdata                       : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  pwr_burner_axi_m_rresp                       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  pwr_burner_axi_m_rvalid                      : in  std_logic                       := '0';             
  pwr_burner_axi_m_rready                      : out std_logic;                                          
  qsfpdd0_test_axi_m_awaddr                    : out std_logic_vector(7 downto 0);                       
  qsfpdd0_test_axi_m_awprot                    : out std_logic_vector(2 downto 0);                       
  qsfpdd0_test_axi_m_awvalid                   : out std_logic;                                          
  qsfpdd0_test_axi_m_awready                   : in  std_logic                       := '0';             
  qsfpdd0_test_axi_m_wdata                     : out std_logic_vector(31 downto 0);                      
  qsfpdd0_test_axi_m_wstrb                     : out std_logic_vector(3 downto 0);                       
  qsfpdd0_test_axi_m_wvalid                    : out std_logic;                                          
  qsfpdd0_test_axi_m_wready                    : in  std_logic                       := '0';             
  qsfpdd0_test_axi_m_bresp                     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  qsfpdd0_test_axi_m_bvalid                    : in  std_logic                       := '0';             
  qsfpdd0_test_axi_m_bready                    : out std_logic;                                          
  qsfpdd0_test_axi_m_araddr                    : out std_logic_vector(7 downto 0);                       
  qsfpdd0_test_axi_m_arprot                    : out std_logic_vector(2 downto 0);                       
  qsfpdd0_test_axi_m_arvalid                   : out std_logic;                                          
  qsfpdd0_test_axi_m_arready                   : in  std_logic                       := '0';             
  qsfpdd0_test_axi_m_rdata                     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  qsfpdd0_test_axi_m_rresp                     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  qsfpdd0_test_axi_m_rvalid                    : in  std_logic                       := '0';             
  qsfpdd0_test_axi_m_rready                    : out std_logic;                                          
  qsfpdd1_test_axi_m_awaddr                    : out std_logic_vector(7 downto 0);                       
  qsfpdd1_test_axi_m_awprot                    : out std_logic_vector(2 downto 0);                       
  qsfpdd1_test_axi_m_awvalid                   : out std_logic;                                          
  qsfpdd1_test_axi_m_awready                   : in  std_logic                       := '0';             
  qsfpdd1_test_axi_m_wdata                     : out std_logic_vector(31 downto 0);                      
  qsfpdd1_test_axi_m_wstrb                     : out std_logic_vector(3 downto 0);                       
  qsfpdd1_test_axi_m_wvalid                    : out std_logic;                                          
  qsfpdd1_test_axi_m_wready                    : in  std_logic                       := '0';             
  qsfpdd1_test_axi_m_bresp                     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  qsfpdd1_test_axi_m_bvalid                    : in  std_logic                       := '0';             
  qsfpdd1_test_axi_m_bready                    : out std_logic;                                          
  qsfpdd1_test_axi_m_araddr                    : out std_logic_vector(7 downto 0);                       
  qsfpdd1_test_axi_m_arprot                    : out std_logic_vector(2 downto 0);                       
  qsfpdd1_test_axi_m_arvalid                   : out std_logic;                                          
  qsfpdd1_test_axi_m_arready                   : in  std_logic                       := '0';             
  qsfpdd1_test_axi_m_rdata                     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  qsfpdd1_test_axi_m_rresp                     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  qsfpdd1_test_axi_m_rvalid                    : in  std_logic                       := '0';             
  qsfpdd1_test_axi_m_rready                    : out std_logic;                                          
  qsfpdd2_test_axi_m_awaddr                    : out std_logic_vector(7 downto 0);                       
  qsfpdd2_test_axi_m_awprot                    : out std_logic_vector(2 downto 0);                       
  qsfpdd2_test_axi_m_awvalid                   : out std_logic;                                          
  qsfpdd2_test_axi_m_awready                   : in  std_logic                       := '0';             
  qsfpdd2_test_axi_m_wdata                     : out std_logic_vector(31 downto 0);                      
  qsfpdd2_test_axi_m_wstrb                     : out std_logic_vector(3 downto 0);                       
  qsfpdd2_test_axi_m_wvalid                    : out std_logic;                                          
  qsfpdd2_test_axi_m_wready                    : in  std_logic                       := '0';             
  qsfpdd2_test_axi_m_bresp                     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  qsfpdd2_test_axi_m_bvalid                    : in  std_logic                       := '0';             
  qsfpdd2_test_axi_m_bready                    : out std_logic;                                          
  qsfpdd2_test_axi_m_araddr                    : out std_logic_vector(7 downto 0);                       
  qsfpdd2_test_axi_m_arprot                    : out std_logic_vector(2 downto 0);                       
  qsfpdd2_test_axi_m_arvalid                   : out std_logic;                                          
  qsfpdd2_test_axi_m_arready                   : in  std_logic                       := '0';             
  qsfpdd2_test_axi_m_rdata                     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  qsfpdd2_test_axi_m_rresp                     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  qsfpdd2_test_axi_m_rvalid                    : in  std_logic                       := '0';             
  qsfpdd2_test_axi_m_rready                    : out std_logic;                                          
  telemetry_test_axi_m_awaddr                  : out std_logic_vector(11 downto 0);                      
  telemetry_test_axi_m_awprot                  : out std_logic_vector(2 downto 0);                       
  telemetry_test_axi_m_awvalid                 : out std_logic;                                          
  telemetry_test_axi_m_awready                 : in  std_logic                       := '0';             
  telemetry_test_axi_m_wdata                   : out std_logic_vector(31 downto 0);                      
  telemetry_test_axi_m_wstrb                   : out std_logic_vector(3 downto 0);                       
  telemetry_test_axi_m_wvalid                  : out std_logic;                                          
  telemetry_test_axi_m_wready                  : in  std_logic                       := '0';             
  telemetry_test_axi_m_bresp                   : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  telemetry_test_axi_m_bvalid                  : in  std_logic                       := '0';             
  telemetry_test_axi_m_bready                  : out std_logic;                                          
  telemetry_test_axi_m_araddr                  : out std_logic_vector(11 downto 0);                      
  telemetry_test_axi_m_arprot                  : out std_logic_vector(2 downto 0);                       
  telemetry_test_axi_m_arvalid                 : out std_logic;                                          
  telemetry_test_axi_m_arready                 : in  std_logic                       := '0';             
  telemetry_test_axi_m_rdata                   : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  telemetry_test_axi_m_rresp                   : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  telemetry_test_axi_m_rvalid                  : in  std_logic                       := '0';             
  telemetry_test_axi_m_rready                  : out std_logic;                                          
  versionid_axi_m_awaddr                       : out std_logic_vector(4 downto 0);                       
  versionid_axi_m_awprot                       : out std_logic_vector(2 downto 0);                       
  versionid_axi_m_awvalid                      : out std_logic;                                          
  versionid_axi_m_awready                      : in  std_logic                       := '0';             
  versionid_axi_m_wdata                        : out std_logic_vector(31 downto 0);                      
  versionid_axi_m_wstrb                        : out std_logic_vector(3 downto 0);                       
  versionid_axi_m_wvalid                       : out std_logic;                                          
  versionid_axi_m_wready                       : in  std_logic                       := '0';             
  versionid_axi_m_bresp                        : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  versionid_axi_m_bvalid                       : in  std_logic                       := '0';             
  versionid_axi_m_bready                       : out std_logic;                                          
  versionid_axi_m_araddr                       : out std_logic_vector(4 downto 0);                       
  versionid_axi_m_arprot                       : out std_logic_vector(2 downto 0);                       
  versionid_axi_m_arvalid                      : out std_logic;                                          
  versionid_axi_m_arready                      : in  std_logic                       := '0';             
  versionid_axi_m_rdata                        : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  versionid_axi_m_rresp                        : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  versionid_axi_m_rvalid                       : in  std_logic                       := '0';             
  versionid_axi_m_rready                       : out std_logic;                                          
  hbm2e_status_upper_ch0_ch1_axi_m_awaddr      : out std_logic_vector(11 downto 0);                      
  hbm2e_status_upper_ch0_ch1_axi_m_awprot      : out std_logic_vector(2 downto 0);                       
  hbm2e_status_upper_ch0_ch1_axi_m_awvalid     : out std_logic;                                          
  hbm2e_status_upper_ch0_ch1_axi_m_awready     : in  std_logic                       := '0';             
  hbm2e_status_upper_ch0_ch1_axi_m_wdata       : out std_logic_vector(31 downto 0);                      
  hbm2e_status_upper_ch0_ch1_axi_m_wstrb       : out std_logic_vector(3 downto 0);                       
  hbm2e_status_upper_ch0_ch1_axi_m_wvalid      : out std_logic;                                          
  hbm2e_status_upper_ch0_ch1_axi_m_wready      : in  std_logic                       := '0';             
  hbm2e_status_upper_ch0_ch1_axi_m_bresp       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_status_upper_ch0_ch1_axi_m_bvalid      : in  std_logic                       := '0';             
  hbm2e_status_upper_ch0_ch1_axi_m_bready      : out std_logic;                                          
  hbm2e_status_upper_ch0_ch1_axi_m_araddr      : out std_logic_vector(11 downto 0);                      
  hbm2e_status_upper_ch0_ch1_axi_m_arprot      : out std_logic_vector(2 downto 0);                       
  hbm2e_status_upper_ch0_ch1_axi_m_arvalid     : out std_logic;                                          
  hbm2e_status_upper_ch0_ch1_axi_m_arready     : in  std_logic                       := '0';             
  hbm2e_status_upper_ch0_ch1_axi_m_rdata       : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_status_upper_ch0_ch1_axi_m_rresp       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_status_upper_ch0_ch1_axi_m_rvalid      : in  std_logic                       := '0';             
  hbm2e_status_upper_ch0_ch1_axi_m_rready      : out std_logic;                                          
  hbm2e_status_upper_ch2_ch3_axi_m_awaddr      : out std_logic_vector(11 downto 0);                      
  hbm2e_status_upper_ch2_ch3_axi_m_awprot      : out std_logic_vector(2 downto 0);                       
  hbm2e_status_upper_ch2_ch3_axi_m_awvalid     : out std_logic;                                          
  hbm2e_status_upper_ch2_ch3_axi_m_awready     : in  std_logic                       := '0';             
  hbm2e_status_upper_ch2_ch3_axi_m_wdata       : out std_logic_vector(31 downto 0);                      
  hbm2e_status_upper_ch2_ch3_axi_m_wstrb       : out std_logic_vector(3 downto 0);                       
  hbm2e_status_upper_ch2_ch3_axi_m_wvalid      : out std_logic;                                          
  hbm2e_status_upper_ch2_ch3_axi_m_wready      : in  std_logic                       := '0';             
  hbm2e_status_upper_ch2_ch3_axi_m_bresp       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_status_upper_ch2_ch3_axi_m_bvalid      : in  std_logic                       := '0';             
  hbm2e_status_upper_ch2_ch3_axi_m_bready      : out std_logic;                                          
  hbm2e_status_upper_ch2_ch3_axi_m_araddr      : out std_logic_vector(11 downto 0);                      
  hbm2e_status_upper_ch2_ch3_axi_m_arprot      : out std_logic_vector(2 downto 0);                       
  hbm2e_status_upper_ch2_ch3_axi_m_arvalid     : out std_logic;                                          
  hbm2e_status_upper_ch2_ch3_axi_m_arready     : in  std_logic                       := '0';             
  hbm2e_status_upper_ch2_ch3_axi_m_rdata       : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_status_upper_ch2_ch3_axi_m_rresp       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_status_upper_ch2_ch3_axi_m_rvalid      : in  std_logic                       := '0';             
  hbm2e_status_upper_ch2_ch3_axi_m_rready      : out std_logic;                                          
  hbm2e_status_upper_ch4_ch5_axi_m_awaddr      : out std_logic_vector(11 downto 0);                      
  hbm2e_status_upper_ch4_ch5_axi_m_awprot      : out std_logic_vector(2 downto 0);                       
  hbm2e_status_upper_ch4_ch5_axi_m_awvalid     : out std_logic;                                          
  hbm2e_status_upper_ch4_ch5_axi_m_awready     : in  std_logic                       := '0';             
  hbm2e_status_upper_ch4_ch5_axi_m_wdata       : out std_logic_vector(31 downto 0);                      
  hbm2e_status_upper_ch4_ch5_axi_m_wstrb       : out std_logic_vector(3 downto 0);                       
  hbm2e_status_upper_ch4_ch5_axi_m_wvalid      : out std_logic;                                          
  hbm2e_status_upper_ch4_ch5_axi_m_wready      : in  std_logic                       := '0';             
  hbm2e_status_upper_ch4_ch5_axi_m_bresp       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_status_upper_ch4_ch5_axi_m_bvalid      : in  std_logic                       := '0';             
  hbm2e_status_upper_ch4_ch5_axi_m_bready      : out std_logic;                                          
  hbm2e_status_upper_ch4_ch5_axi_m_araddr      : out std_logic_vector(11 downto 0);                      
  hbm2e_status_upper_ch4_ch5_axi_m_arprot      : out std_logic_vector(2 downto 0);                       
  hbm2e_status_upper_ch4_ch5_axi_m_arvalid     : out std_logic;                                          
  hbm2e_status_upper_ch4_ch5_axi_m_arready     : in  std_logic                       := '0';             
  hbm2e_status_upper_ch4_ch5_axi_m_rdata       : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_status_upper_ch4_ch5_axi_m_rresp       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_status_upper_ch4_ch5_axi_m_rvalid      : in  std_logic                       := '0';             
  hbm2e_status_upper_ch4_ch5_axi_m_rready      : out std_logic;                                          
  hbm2e_status_upper_ch6_ch7_axi_m_awaddr      : out std_logic_vector(11 downto 0);                      
  hbm2e_status_upper_ch6_ch7_axi_m_awprot      : out std_logic_vector(2 downto 0);                       
  hbm2e_status_upper_ch6_ch7_axi_m_awvalid     : out std_logic;                                          
  hbm2e_status_upper_ch6_ch7_axi_m_awready     : in  std_logic                       := '0';             
  hbm2e_status_upper_ch6_ch7_axi_m_wdata       : out std_logic_vector(31 downto 0);                      
  hbm2e_status_upper_ch6_ch7_axi_m_wstrb       : out std_logic_vector(3 downto 0);                       
  hbm2e_status_upper_ch6_ch7_axi_m_wvalid      : out std_logic;                                          
  hbm2e_status_upper_ch6_ch7_axi_m_wready      : in  std_logic                       := '0';             
  hbm2e_status_upper_ch6_ch7_axi_m_bresp       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_status_upper_ch6_ch7_axi_m_bvalid      : in  std_logic                       := '0';             
  hbm2e_status_upper_ch6_ch7_axi_m_bready      : out std_logic;                                          
  hbm2e_status_upper_ch6_ch7_axi_m_araddr      : out std_logic_vector(11 downto 0);                      
  hbm2e_status_upper_ch6_ch7_axi_m_arprot      : out std_logic_vector(2 downto 0);                       
  hbm2e_status_upper_ch6_ch7_axi_m_arvalid     : out std_logic;                                          
  hbm2e_status_upper_ch6_ch7_axi_m_arready     : in  std_logic                       := '0';             
  hbm2e_status_upper_ch6_ch7_axi_m_rdata       : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_status_upper_ch6_ch7_axi_m_rresp       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_status_upper_ch6_ch7_axi_m_rvalid      : in  std_logic                       := '0';             
  hbm2e_status_upper_ch6_ch7_axi_m_rready      : out std_logic;                                          
  hbm2e_status_lower_ch0_ch1_axi_m_awaddr      : out std_logic_vector(11 downto 0);                      
  hbm2e_status_lower_ch0_ch1_axi_m_awprot      : out std_logic_vector(2 downto 0);                       
  hbm2e_status_lower_ch0_ch1_axi_m_awvalid     : out std_logic;                                          
  hbm2e_status_lower_ch0_ch1_axi_m_awready     : in  std_logic                       := '0';             
  hbm2e_status_lower_ch0_ch1_axi_m_wdata       : out std_logic_vector(31 downto 0);                      
  hbm2e_status_lower_ch0_ch1_axi_m_wstrb       : out std_logic_vector(3 downto 0);                       
  hbm2e_status_lower_ch0_ch1_axi_m_wvalid      : out std_logic;                                          
  hbm2e_status_lower_ch0_ch1_axi_m_wready      : in  std_logic                       := '0';             
  hbm2e_status_lower_ch0_ch1_axi_m_bresp       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_status_lower_ch0_ch1_axi_m_bvalid      : in  std_logic                       := '0';             
  hbm2e_status_lower_ch0_ch1_axi_m_bready      : out std_logic;                                          
  hbm2e_status_lower_ch0_ch1_axi_m_araddr      : out std_logic_vector(11 downto 0);                      
  hbm2e_status_lower_ch0_ch1_axi_m_arprot      : out std_logic_vector(2 downto 0);                       
  hbm2e_status_lower_ch0_ch1_axi_m_arvalid     : out std_logic;                                          
  hbm2e_status_lower_ch0_ch1_axi_m_arready     : in  std_logic                       := '0';             
  hbm2e_status_lower_ch0_ch1_axi_m_rdata       : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_status_lower_ch0_ch1_axi_m_rresp       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_status_lower_ch0_ch1_axi_m_rvalid      : in  std_logic                       := '0';             
  hbm2e_status_lower_ch0_ch1_axi_m_rready      : out std_logic;                                          
  hbm2e_status_lower_ch2_ch3_axi_m_awaddr      : out std_logic_vector(11 downto 0);                      
  hbm2e_status_lower_ch2_ch3_axi_m_awprot      : out std_logic_vector(2 downto 0);                       
  hbm2e_status_lower_ch2_ch3_axi_m_awvalid     : out std_logic;                                          
  hbm2e_status_lower_ch2_ch3_axi_m_awready     : in  std_logic                       := '0';             
  hbm2e_status_lower_ch2_ch3_axi_m_wdata       : out std_logic_vector(31 downto 0);                      
  hbm2e_status_lower_ch2_ch3_axi_m_wstrb       : out std_logic_vector(3 downto 0);                       
  hbm2e_status_lower_ch2_ch3_axi_m_wvalid      : out std_logic;                                          
  hbm2e_status_lower_ch2_ch3_axi_m_wready      : in  std_logic                       := '0';             
  hbm2e_status_lower_ch2_ch3_axi_m_bresp       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_status_lower_ch2_ch3_axi_m_bvalid      : in  std_logic                       := '0';             
  hbm2e_status_lower_ch2_ch3_axi_m_bready      : out std_logic;                                          
  hbm2e_status_lower_ch2_ch3_axi_m_araddr      : out std_logic_vector(11 downto 0);                      
  hbm2e_status_lower_ch2_ch3_axi_m_arprot      : out std_logic_vector(2 downto 0);                       
  hbm2e_status_lower_ch2_ch3_axi_m_arvalid     : out std_logic;                                          
  hbm2e_status_lower_ch2_ch3_axi_m_arready     : in  std_logic                       := '0';             
  hbm2e_status_lower_ch2_ch3_axi_m_rdata       : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_status_lower_ch2_ch3_axi_m_rresp       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_status_lower_ch2_ch3_axi_m_rvalid      : in  std_logic                       := '0';             
  hbm2e_status_lower_ch2_ch3_axi_m_rready      : out std_logic;                                          
  hbm2e_status_lower_ch4_ch5_axi_m_awaddr      : out std_logic_vector(11 downto 0);                      
  hbm2e_status_lower_ch4_ch5_axi_m_awprot      : out std_logic_vector(2 downto 0);                       
  hbm2e_status_lower_ch4_ch5_axi_m_awvalid     : out std_logic;                                          
  hbm2e_status_lower_ch4_ch5_axi_m_awready     : in  std_logic                       := '0';             
  hbm2e_status_lower_ch4_ch5_axi_m_wdata       : out std_logic_vector(31 downto 0);                      
  hbm2e_status_lower_ch4_ch5_axi_m_wstrb       : out std_logic_vector(3 downto 0);                       
  hbm2e_status_lower_ch4_ch5_axi_m_wvalid      : out std_logic;                                          
  hbm2e_status_lower_ch4_ch5_axi_m_wready      : in  std_logic                       := '0';             
  hbm2e_status_lower_ch4_ch5_axi_m_bresp       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_status_lower_ch4_ch5_axi_m_bvalid      : in  std_logic                       := '0';             
  hbm2e_status_lower_ch4_ch5_axi_m_bready      : out std_logic;                                          
  hbm2e_status_lower_ch4_ch5_axi_m_araddr      : out std_logic_vector(11 downto 0);                      
  hbm2e_status_lower_ch4_ch5_axi_m_arprot      : out std_logic_vector(2 downto 0);                       
  hbm2e_status_lower_ch4_ch5_axi_m_arvalid     : out std_logic;                                          
  hbm2e_status_lower_ch4_ch5_axi_m_arready     : in  std_logic                       := '0';             
  hbm2e_status_lower_ch4_ch5_axi_m_rdata       : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_status_lower_ch4_ch5_axi_m_rresp       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_status_lower_ch4_ch5_axi_m_rvalid      : in  std_logic                       := '0';             
  hbm2e_status_lower_ch4_ch5_axi_m_rready      : out std_logic;                                          
  hbm2e_status_lower_ch6_ch7_axi_m_awaddr      : out std_logic_vector(11 downto 0);                      
  hbm2e_status_lower_ch6_ch7_axi_m_awprot      : out std_logic_vector(2 downto 0);                       
  hbm2e_status_lower_ch6_ch7_axi_m_awvalid     : out std_logic;                                          
  hbm2e_status_lower_ch6_ch7_axi_m_awready     : in  std_logic                       := '0';             
  hbm2e_status_lower_ch6_ch7_axi_m_wdata       : out std_logic_vector(31 downto 0);                      
  hbm2e_status_lower_ch6_ch7_axi_m_wstrb       : out std_logic_vector(3 downto 0);                       
  hbm2e_status_lower_ch6_ch7_axi_m_wvalid      : out std_logic;                                          
  hbm2e_status_lower_ch6_ch7_axi_m_wready      : in  std_logic                       := '0';             
  hbm2e_status_lower_ch6_ch7_axi_m_bresp       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_status_lower_ch6_ch7_axi_m_bvalid      : in  std_logic                       := '0';             
  hbm2e_status_lower_ch6_ch7_axi_m_bready      : out std_logic;                                          
  hbm2e_status_lower_ch6_ch7_axi_m_araddr      : out std_logic_vector(11 downto 0);                      
  hbm2e_status_lower_ch6_ch7_axi_m_arprot      : out std_logic_vector(2 downto 0);                       
  hbm2e_status_lower_ch6_ch7_axi_m_arvalid     : out std_logic;                                          
  hbm2e_status_lower_ch6_ch7_axi_m_arready     : in  std_logic                       := '0';             
  hbm2e_status_lower_ch6_ch7_axi_m_rdata       : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_status_lower_ch6_ch7_axi_m_rresp       : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_status_lower_ch6_ch7_axi_m_rvalid      : in  std_logic                       := '0';             
  hbm2e_status_lower_ch6_ch7_axi_m_rready      : out std_logic;                                          
  hbm2e_upper_test_ch0_u0_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch0_u0_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch0_u0_axi_m_awvalid        : out std_logic;                                          
  hbm2e_upper_test_ch0_u0_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch0_u0_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_test_ch0_u0_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_test_ch0_u0_axi_m_wvalid         : out std_logic;                                          
  hbm2e_upper_test_ch0_u0_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch0_u0_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch0_u0_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch0_u0_axi_m_bready         : out std_logic;                                          
  hbm2e_upper_test_ch0_u0_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch0_u0_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch0_u0_axi_m_arvalid        : out std_logic;                                          
  hbm2e_upper_test_ch0_u0_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch0_u0_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_test_ch0_u0_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch0_u0_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch0_u0_axi_m_rready         : out std_logic;                                          
  hbm2e_upper_test_ch0_u1_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch0_u1_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch0_u1_axi_m_awvalid        : out std_logic;                                          
  hbm2e_upper_test_ch0_u1_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch0_u1_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_test_ch0_u1_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_test_ch0_u1_axi_m_wvalid         : out std_logic;                                          
  hbm2e_upper_test_ch0_u1_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch0_u1_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch0_u1_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch0_u1_axi_m_bready         : out std_logic;                                          
  hbm2e_upper_test_ch0_u1_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch0_u1_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch0_u1_axi_m_arvalid        : out std_logic;                                          
  hbm2e_upper_test_ch0_u1_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch0_u1_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_test_ch0_u1_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch0_u1_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch0_u1_axi_m_rready         : out std_logic;                                          
  hbm2e_upper_test_ch1_u0_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch1_u0_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch1_u0_axi_m_awvalid        : out std_logic;                                          
  hbm2e_upper_test_ch1_u0_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch1_u0_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_test_ch1_u0_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_test_ch1_u0_axi_m_wvalid         : out std_logic;                                          
  hbm2e_upper_test_ch1_u0_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch1_u0_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch1_u0_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch1_u0_axi_m_bready         : out std_logic;                                          
  hbm2e_upper_test_ch1_u0_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch1_u0_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch1_u0_axi_m_arvalid        : out std_logic;                                          
  hbm2e_upper_test_ch1_u0_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch1_u0_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_test_ch1_u0_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch1_u0_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch1_u0_axi_m_rready         : out std_logic;                                          
  hbm2e_upper_test_ch1_u1_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch1_u1_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch1_u1_axi_m_awvalid        : out std_logic;                                          
  hbm2e_upper_test_ch1_u1_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch1_u1_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_test_ch1_u1_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_test_ch1_u1_axi_m_wvalid         : out std_logic;                                          
  hbm2e_upper_test_ch1_u1_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch1_u1_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch1_u1_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch1_u1_axi_m_bready         : out std_logic;                                          
  hbm2e_upper_test_ch1_u1_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch1_u1_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch1_u1_axi_m_arvalid        : out std_logic;                                          
  hbm2e_upper_test_ch1_u1_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch1_u1_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_test_ch1_u1_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch1_u1_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch1_u1_axi_m_rready         : out std_logic;                                          
  hbm2e_upper_test_ch2_u0_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch2_u0_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch2_u0_axi_m_awvalid        : out std_logic;                                          
  hbm2e_upper_test_ch2_u0_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch2_u0_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_test_ch2_u0_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_test_ch2_u0_axi_m_wvalid         : out std_logic;                                          
  hbm2e_upper_test_ch2_u0_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch2_u0_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch2_u0_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch2_u0_axi_m_bready         : out std_logic;                                          
  hbm2e_upper_test_ch2_u0_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch2_u0_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch2_u0_axi_m_arvalid        : out std_logic;                                          
  hbm2e_upper_test_ch2_u0_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch2_u0_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_test_ch2_u0_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch2_u0_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch2_u0_axi_m_rready         : out std_logic;                                          
  hbm2e_upper_test_ch2_u1_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch2_u1_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch2_u1_axi_m_awvalid        : out std_logic;                                          
  hbm2e_upper_test_ch2_u1_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch2_u1_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_test_ch2_u1_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_test_ch2_u1_axi_m_wvalid         : out std_logic;                                          
  hbm2e_upper_test_ch2_u1_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch2_u1_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch2_u1_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch2_u1_axi_m_bready         : out std_logic;                                          
  hbm2e_upper_test_ch2_u1_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch2_u1_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch2_u1_axi_m_arvalid        : out std_logic;                                          
  hbm2e_upper_test_ch2_u1_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch2_u1_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_test_ch2_u1_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch2_u1_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch2_u1_axi_m_rready         : out std_logic;                                          
  hbm2e_upper_test_ch3_u0_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch3_u0_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch3_u0_axi_m_awvalid        : out std_logic;                                          
  hbm2e_upper_test_ch3_u0_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch3_u0_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_test_ch3_u0_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_test_ch3_u0_axi_m_wvalid         : out std_logic;                                          
  hbm2e_upper_test_ch3_u0_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch3_u0_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch3_u0_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch3_u0_axi_m_bready         : out std_logic;                                          
  hbm2e_upper_test_ch3_u0_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch3_u0_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch3_u0_axi_m_arvalid        : out std_logic;                                          
  hbm2e_upper_test_ch3_u0_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch3_u0_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_test_ch3_u0_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch3_u0_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch3_u0_axi_m_rready         : out std_logic;                                          
  hbm2e_upper_test_ch3_u1_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch3_u1_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch3_u1_axi_m_awvalid        : out std_logic;                                          
  hbm2e_upper_test_ch3_u1_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch3_u1_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_test_ch3_u1_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_test_ch3_u1_axi_m_wvalid         : out std_logic;                                          
  hbm2e_upper_test_ch3_u1_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch3_u1_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch3_u1_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch3_u1_axi_m_bready         : out std_logic;                                          
  hbm2e_upper_test_ch3_u1_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch3_u1_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch3_u1_axi_m_arvalid        : out std_logic;                                          
  hbm2e_upper_test_ch3_u1_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch3_u1_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_test_ch3_u1_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch3_u1_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch3_u1_axi_m_rready         : out std_logic;                                          
  hbm2e_upper_test_ch4_u0_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch4_u0_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch4_u0_axi_m_awvalid        : out std_logic;                                          
  hbm2e_upper_test_ch4_u0_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch4_u0_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_test_ch4_u0_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_test_ch4_u0_axi_m_wvalid         : out std_logic;                                          
  hbm2e_upper_test_ch4_u0_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch4_u0_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch4_u0_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch4_u0_axi_m_bready         : out std_logic;                                          
  hbm2e_upper_test_ch4_u0_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch4_u0_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch4_u0_axi_m_arvalid        : out std_logic;                                          
  hbm2e_upper_test_ch4_u0_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch4_u0_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_test_ch4_u0_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch4_u0_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch4_u0_axi_m_rready         : out std_logic;                                          
  hbm2e_upper_test_ch4_u1_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch4_u1_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch4_u1_axi_m_awvalid        : out std_logic;                                          
  hbm2e_upper_test_ch4_u1_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch4_u1_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_test_ch4_u1_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_test_ch4_u1_axi_m_wvalid         : out std_logic;                                          
  hbm2e_upper_test_ch4_u1_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch4_u1_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch4_u1_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch4_u1_axi_m_bready         : out std_logic;                                          
  hbm2e_upper_test_ch4_u1_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch4_u1_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch4_u1_axi_m_arvalid        : out std_logic;                                          
  hbm2e_upper_test_ch4_u1_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch4_u1_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_test_ch4_u1_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch4_u1_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch4_u1_axi_m_rready         : out std_logic;                                          
  hbm2e_upper_test_ch5_u0_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch5_u0_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch5_u0_axi_m_awvalid        : out std_logic;                                          
  hbm2e_upper_test_ch5_u0_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch5_u0_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_test_ch5_u0_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_test_ch5_u0_axi_m_wvalid         : out std_logic;                                          
  hbm2e_upper_test_ch5_u0_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch5_u0_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch5_u0_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch5_u0_axi_m_bready         : out std_logic;                                          
  hbm2e_upper_test_ch5_u0_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch5_u0_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch5_u0_axi_m_arvalid        : out std_logic;                                          
  hbm2e_upper_test_ch5_u0_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch5_u0_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_test_ch5_u0_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch5_u0_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch5_u0_axi_m_rready         : out std_logic;                                          
  hbm2e_upper_test_ch5_u1_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch5_u1_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch5_u1_axi_m_awvalid        : out std_logic;                                          
  hbm2e_upper_test_ch5_u1_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch5_u1_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_test_ch5_u1_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_test_ch5_u1_axi_m_wvalid         : out std_logic;                                          
  hbm2e_upper_test_ch5_u1_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch5_u1_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch5_u1_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch5_u1_axi_m_bready         : out std_logic;                                          
  hbm2e_upper_test_ch5_u1_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch5_u1_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch5_u1_axi_m_arvalid        : out std_logic;                                          
  hbm2e_upper_test_ch5_u1_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch5_u1_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_test_ch5_u1_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch5_u1_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch5_u1_axi_m_rready         : out std_logic;                                          
  hbm2e_upper_test_ch6_u0_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch6_u0_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch6_u0_axi_m_awvalid        : out std_logic;                                          
  hbm2e_upper_test_ch6_u0_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch6_u0_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_test_ch6_u0_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_test_ch6_u0_axi_m_wvalid         : out std_logic;                                          
  hbm2e_upper_test_ch6_u0_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch6_u0_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch6_u0_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch6_u0_axi_m_bready         : out std_logic;                                          
  hbm2e_upper_test_ch6_u0_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch6_u0_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch6_u0_axi_m_arvalid        : out std_logic;                                          
  hbm2e_upper_test_ch6_u0_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch6_u0_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_test_ch6_u0_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch6_u0_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch6_u0_axi_m_rready         : out std_logic;                                          
  hbm2e_upper_test_ch6_u1_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch6_u1_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch6_u1_axi_m_awvalid        : out std_logic;                                          
  hbm2e_upper_test_ch6_u1_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch6_u1_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_test_ch6_u1_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_test_ch6_u1_axi_m_wvalid         : out std_logic;                                          
  hbm2e_upper_test_ch6_u1_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch6_u1_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch6_u1_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch6_u1_axi_m_bready         : out std_logic;                                          
  hbm2e_upper_test_ch6_u1_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch6_u1_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch6_u1_axi_m_arvalid        : out std_logic;                                          
  hbm2e_upper_test_ch6_u1_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch6_u1_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_test_ch6_u1_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch6_u1_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch6_u1_axi_m_rready         : out std_logic;                                          
  hbm2e_upper_test_ch7_u0_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch7_u0_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch7_u0_axi_m_awvalid        : out std_logic;                                          
  hbm2e_upper_test_ch7_u0_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch7_u0_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_test_ch7_u0_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_test_ch7_u0_axi_m_wvalid         : out std_logic;                                          
  hbm2e_upper_test_ch7_u0_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch7_u0_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch7_u0_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch7_u0_axi_m_bready         : out std_logic;                                          
  hbm2e_upper_test_ch7_u0_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch7_u0_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch7_u0_axi_m_arvalid        : out std_logic;                                          
  hbm2e_upper_test_ch7_u0_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch7_u0_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_test_ch7_u0_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch7_u0_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch7_u0_axi_m_rready         : out std_logic;                                          
  hbm2e_upper_test_ch7_u1_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch7_u1_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch7_u1_axi_m_awvalid        : out std_logic;                                          
  hbm2e_upper_test_ch7_u1_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch7_u1_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_test_ch7_u1_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_test_ch7_u1_axi_m_wvalid         : out std_logic;                                          
  hbm2e_upper_test_ch7_u1_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch7_u1_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch7_u1_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch7_u1_axi_m_bready         : out std_logic;                                          
  hbm2e_upper_test_ch7_u1_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_upper_test_ch7_u1_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_test_ch7_u1_axi_m_arvalid        : out std_logic;                                          
  hbm2e_upper_test_ch7_u1_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_upper_test_ch7_u1_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_test_ch7_u1_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_test_ch7_u1_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_upper_test_ch7_u1_axi_m_rready         : out std_logic;                                          
  hbm2e_upper_error_log_ch0_u0_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch0_u0_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch0_u0_axi_m_awvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch0_u0_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch0_u0_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_error_log_ch0_u0_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_error_log_ch0_u0_axi_m_wvalid    : out std_logic;                                          
  hbm2e_upper_error_log_ch0_u0_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch0_u0_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch0_u0_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch0_u0_axi_m_bready    : out std_logic;                                          
  hbm2e_upper_error_log_ch0_u0_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch0_u0_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch0_u0_axi_m_arvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch0_u0_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch0_u0_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_error_log_ch0_u0_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch0_u0_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch0_u0_axi_m_rready    : out std_logic;                                          
  hbm2e_upper_error_log_ch0_u1_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch0_u1_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch0_u1_axi_m_awvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch0_u1_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch0_u1_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_error_log_ch0_u1_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_error_log_ch0_u1_axi_m_wvalid    : out std_logic;                                          
  hbm2e_upper_error_log_ch0_u1_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch0_u1_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch0_u1_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch0_u1_axi_m_bready    : out std_logic;                                          
  hbm2e_upper_error_log_ch0_u1_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch0_u1_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch0_u1_axi_m_arvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch0_u1_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch0_u1_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_error_log_ch0_u1_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch0_u1_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch0_u1_axi_m_rready    : out std_logic;                                          
  hbm2e_upper_error_log_ch1_u0_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch1_u0_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch1_u0_axi_m_awvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch1_u0_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch1_u0_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_error_log_ch1_u0_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_error_log_ch1_u0_axi_m_wvalid    : out std_logic;                                          
  hbm2e_upper_error_log_ch1_u0_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch1_u0_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch1_u0_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch1_u0_axi_m_bready    : out std_logic;                                          
  hbm2e_upper_error_log_ch1_u0_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch1_u0_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch1_u0_axi_m_arvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch1_u0_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch1_u0_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_error_log_ch1_u0_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch1_u0_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch1_u0_axi_m_rready    : out std_logic;                                          
  hbm2e_upper_error_log_ch1_u1_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch1_u1_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch1_u1_axi_m_awvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch1_u1_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch1_u1_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_error_log_ch1_u1_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_error_log_ch1_u1_axi_m_wvalid    : out std_logic;                                          
  hbm2e_upper_error_log_ch1_u1_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch1_u1_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch1_u1_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch1_u1_axi_m_bready    : out std_logic;                                          
  hbm2e_upper_error_log_ch1_u1_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch1_u1_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch1_u1_axi_m_arvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch1_u1_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch1_u1_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_error_log_ch1_u1_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch1_u1_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch1_u1_axi_m_rready    : out std_logic;                                          
  hbm2e_upper_error_log_ch2_u0_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch2_u0_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch2_u0_axi_m_awvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch2_u0_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch2_u0_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_error_log_ch2_u0_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_error_log_ch2_u0_axi_m_wvalid    : out std_logic;                                          
  hbm2e_upper_error_log_ch2_u0_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch2_u0_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch2_u0_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch2_u0_axi_m_bready    : out std_logic;                                          
  hbm2e_upper_error_log_ch2_u0_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch2_u0_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch2_u0_axi_m_arvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch2_u0_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch2_u0_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_error_log_ch2_u0_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch2_u0_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch2_u0_axi_m_rready    : out std_logic;                                          
  hbm2e_upper_error_log_ch2_u1_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch2_u1_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch2_u1_axi_m_awvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch2_u1_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch2_u1_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_error_log_ch2_u1_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_error_log_ch2_u1_axi_m_wvalid    : out std_logic;                                          
  hbm2e_upper_error_log_ch2_u1_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch2_u1_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch2_u1_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch2_u1_axi_m_bready    : out std_logic;                                          
  hbm2e_upper_error_log_ch2_u1_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch2_u1_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch2_u1_axi_m_arvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch2_u1_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch2_u1_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_error_log_ch2_u1_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch2_u1_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch2_u1_axi_m_rready    : out std_logic;                                          
  hbm2e_upper_error_log_ch3_u0_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch3_u0_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch3_u0_axi_m_awvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch3_u0_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch3_u0_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_error_log_ch3_u0_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_error_log_ch3_u0_axi_m_wvalid    : out std_logic;                                          
  hbm2e_upper_error_log_ch3_u0_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch3_u0_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch3_u0_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch3_u0_axi_m_bready    : out std_logic;                                          
  hbm2e_upper_error_log_ch3_u0_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch3_u0_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch3_u0_axi_m_arvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch3_u0_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch3_u0_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_error_log_ch3_u0_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch3_u0_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch3_u0_axi_m_rready    : out std_logic;                                          
  hbm2e_upper_error_log_ch3_u1_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch3_u1_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch3_u1_axi_m_awvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch3_u1_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch3_u1_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_error_log_ch3_u1_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_error_log_ch3_u1_axi_m_wvalid    : out std_logic;                                          
  hbm2e_upper_error_log_ch3_u1_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch3_u1_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch3_u1_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch3_u1_axi_m_bready    : out std_logic;                                          
  hbm2e_upper_error_log_ch3_u1_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch3_u1_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch3_u1_axi_m_arvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch3_u1_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch3_u1_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_error_log_ch3_u1_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch3_u1_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch3_u1_axi_m_rready    : out std_logic;                                          
  hbm2e_upper_error_log_ch4_u0_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch4_u0_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch4_u0_axi_m_awvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch4_u0_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch4_u0_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_error_log_ch4_u0_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_error_log_ch4_u0_axi_m_wvalid    : out std_logic;                                          
  hbm2e_upper_error_log_ch4_u0_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch4_u0_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch4_u0_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch4_u0_axi_m_bready    : out std_logic;                                          
  hbm2e_upper_error_log_ch4_u0_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch4_u0_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch4_u0_axi_m_arvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch4_u0_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch4_u0_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_error_log_ch4_u0_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch4_u0_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch4_u0_axi_m_rready    : out std_logic;                                          
  hbm2e_upper_error_log_ch4_u1_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch4_u1_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch4_u1_axi_m_awvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch4_u1_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch4_u1_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_error_log_ch4_u1_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_error_log_ch4_u1_axi_m_wvalid    : out std_logic;                                          
  hbm2e_upper_error_log_ch4_u1_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch4_u1_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch4_u1_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch4_u1_axi_m_bready    : out std_logic;                                          
  hbm2e_upper_error_log_ch4_u1_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch4_u1_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch4_u1_axi_m_arvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch4_u1_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch4_u1_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_error_log_ch4_u1_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch4_u1_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch4_u1_axi_m_rready    : out std_logic;                                          
  hbm2e_upper_error_log_ch5_u0_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch5_u0_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch5_u0_axi_m_awvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch5_u0_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch5_u0_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_error_log_ch5_u0_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_error_log_ch5_u0_axi_m_wvalid    : out std_logic;                                          
  hbm2e_upper_error_log_ch5_u0_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch5_u0_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch5_u0_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch5_u0_axi_m_bready    : out std_logic;                                          
  hbm2e_upper_error_log_ch5_u0_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch5_u0_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch5_u0_axi_m_arvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch5_u0_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch5_u0_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_error_log_ch5_u0_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch5_u0_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch5_u0_axi_m_rready    : out std_logic;                                          
  hbm2e_upper_error_log_ch5_u1_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch5_u1_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch5_u1_axi_m_awvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch5_u1_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch5_u1_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_error_log_ch5_u1_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_error_log_ch5_u1_axi_m_wvalid    : out std_logic;                                          
  hbm2e_upper_error_log_ch5_u1_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch5_u1_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch5_u1_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch5_u1_axi_m_bready    : out std_logic;                                          
  hbm2e_upper_error_log_ch5_u1_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch5_u1_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch5_u1_axi_m_arvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch5_u1_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch5_u1_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_error_log_ch5_u1_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch5_u1_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch5_u1_axi_m_rready    : out std_logic;                                          
  hbm2e_upper_error_log_ch6_u0_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch6_u0_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch6_u0_axi_m_awvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch6_u0_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch6_u0_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_error_log_ch6_u0_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_error_log_ch6_u0_axi_m_wvalid    : out std_logic;                                          
  hbm2e_upper_error_log_ch6_u0_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch6_u0_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch6_u0_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch6_u0_axi_m_bready    : out std_logic;                                          
  hbm2e_upper_error_log_ch6_u0_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch6_u0_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch6_u0_axi_m_arvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch6_u0_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch6_u0_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_error_log_ch6_u0_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch6_u0_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch6_u0_axi_m_rready    : out std_logic;                                          
  hbm2e_upper_error_log_ch6_u1_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch6_u1_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch6_u1_axi_m_awvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch6_u1_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch6_u1_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_error_log_ch6_u1_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_error_log_ch6_u1_axi_m_wvalid    : out std_logic;                                          
  hbm2e_upper_error_log_ch6_u1_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch6_u1_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch6_u1_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch6_u1_axi_m_bready    : out std_logic;                                          
  hbm2e_upper_error_log_ch6_u1_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch6_u1_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch6_u1_axi_m_arvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch6_u1_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch6_u1_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_error_log_ch6_u1_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch6_u1_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch6_u1_axi_m_rready    : out std_logic;                                          
  hbm2e_upper_error_log_ch7_u0_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch7_u0_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch7_u0_axi_m_awvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch7_u0_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch7_u0_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_error_log_ch7_u0_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_error_log_ch7_u0_axi_m_wvalid    : out std_logic;                                          
  hbm2e_upper_error_log_ch7_u0_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch7_u0_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch7_u0_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch7_u0_axi_m_bready    : out std_logic;                                          
  hbm2e_upper_error_log_ch7_u0_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch7_u0_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch7_u0_axi_m_arvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch7_u0_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch7_u0_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_error_log_ch7_u0_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch7_u0_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch7_u0_axi_m_rready    : out std_logic;                                          
  hbm2e_upper_error_log_ch7_u1_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch7_u1_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch7_u1_axi_m_awvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch7_u1_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch7_u1_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_upper_error_log_ch7_u1_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_upper_error_log_ch7_u1_axi_m_wvalid    : out std_logic;                                          
  hbm2e_upper_error_log_ch7_u1_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch7_u1_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch7_u1_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch7_u1_axi_m_bready    : out std_logic;                                          
  hbm2e_upper_error_log_ch7_u1_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_upper_error_log_ch7_u1_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_upper_error_log_ch7_u1_axi_m_arvalid   : out std_logic;                                          
  hbm2e_upper_error_log_ch7_u1_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch7_u1_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_upper_error_log_ch7_u1_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_upper_error_log_ch7_u1_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_upper_error_log_ch7_u1_axi_m_rready    : out std_logic;                                          
  hbm2e_lower_test_ch0_u0_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch0_u0_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch0_u0_axi_m_awvalid        : out std_logic;                                          
  hbm2e_lower_test_ch0_u0_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch0_u0_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_test_ch0_u0_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_test_ch0_u0_axi_m_wvalid         : out std_logic;                                          
  hbm2e_lower_test_ch0_u0_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch0_u0_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch0_u0_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch0_u0_axi_m_bready         : out std_logic;                                          
  hbm2e_lower_test_ch0_u0_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch0_u0_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch0_u0_axi_m_arvalid        : out std_logic;                                          
  hbm2e_lower_test_ch0_u0_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch0_u0_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_test_ch0_u0_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch0_u0_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch0_u0_axi_m_rready         : out std_logic;                                          
  hbm2e_lower_test_ch0_u1_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch0_u1_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch0_u1_axi_m_awvalid        : out std_logic;                                          
  hbm2e_lower_test_ch0_u1_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch0_u1_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_test_ch0_u1_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_test_ch0_u1_axi_m_wvalid         : out std_logic;                                          
  hbm2e_lower_test_ch0_u1_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch0_u1_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch0_u1_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch0_u1_axi_m_bready         : out std_logic;                                          
  hbm2e_lower_test_ch0_u1_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch0_u1_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch0_u1_axi_m_arvalid        : out std_logic;                                          
  hbm2e_lower_test_ch0_u1_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch0_u1_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_test_ch0_u1_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch0_u1_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch0_u1_axi_m_rready         : out std_logic;                                          
  hbm2e_lower_test_ch1_u0_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch1_u0_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch1_u0_axi_m_awvalid        : out std_logic;                                          
  hbm2e_lower_test_ch1_u0_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch1_u0_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_test_ch1_u0_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_test_ch1_u0_axi_m_wvalid         : out std_logic;                                          
  hbm2e_lower_test_ch1_u0_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch1_u0_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch1_u0_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch1_u0_axi_m_bready         : out std_logic;                                          
  hbm2e_lower_test_ch1_u0_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch1_u0_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch1_u0_axi_m_arvalid        : out std_logic;                                          
  hbm2e_lower_test_ch1_u0_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch1_u0_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_test_ch1_u0_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch1_u0_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch1_u0_axi_m_rready         : out std_logic;                                          
  hbm2e_lower_test_ch1_u1_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch1_u1_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch1_u1_axi_m_awvalid        : out std_logic;                                          
  hbm2e_lower_test_ch1_u1_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch1_u1_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_test_ch1_u1_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_test_ch1_u1_axi_m_wvalid         : out std_logic;                                          
  hbm2e_lower_test_ch1_u1_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch1_u1_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch1_u1_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch1_u1_axi_m_bready         : out std_logic;                                          
  hbm2e_lower_test_ch1_u1_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch1_u1_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch1_u1_axi_m_arvalid        : out std_logic;                                          
  hbm2e_lower_test_ch1_u1_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch1_u1_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_test_ch1_u1_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch1_u1_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch1_u1_axi_m_rready         : out std_logic;                                          
  hbm2e_lower_test_ch2_u0_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch2_u0_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch2_u0_axi_m_awvalid        : out std_logic;                                          
  hbm2e_lower_test_ch2_u0_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch2_u0_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_test_ch2_u0_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_test_ch2_u0_axi_m_wvalid         : out std_logic;                                          
  hbm2e_lower_test_ch2_u0_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch2_u0_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch2_u0_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch2_u0_axi_m_bready         : out std_logic;                                          
  hbm2e_lower_test_ch2_u0_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch2_u0_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch2_u0_axi_m_arvalid        : out std_logic;                                          
  hbm2e_lower_test_ch2_u0_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch2_u0_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_test_ch2_u0_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch2_u0_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch2_u0_axi_m_rready         : out std_logic;                                          
  hbm2e_lower_test_ch2_u1_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch2_u1_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch2_u1_axi_m_awvalid        : out std_logic;                                          
  hbm2e_lower_test_ch2_u1_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch2_u1_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_test_ch2_u1_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_test_ch2_u1_axi_m_wvalid         : out std_logic;                                          
  hbm2e_lower_test_ch2_u1_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch2_u1_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch2_u1_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch2_u1_axi_m_bready         : out std_logic;                                          
  hbm2e_lower_test_ch2_u1_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch2_u1_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch2_u1_axi_m_arvalid        : out std_logic;                                          
  hbm2e_lower_test_ch2_u1_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch2_u1_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_test_ch2_u1_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch2_u1_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch2_u1_axi_m_rready         : out std_logic;                                          
  hbm2e_lower_test_ch3_u0_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch3_u0_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch3_u0_axi_m_awvalid        : out std_logic;                                          
  hbm2e_lower_test_ch3_u0_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch3_u0_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_test_ch3_u0_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_test_ch3_u0_axi_m_wvalid         : out std_logic;                                          
  hbm2e_lower_test_ch3_u0_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch3_u0_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch3_u0_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch3_u0_axi_m_bready         : out std_logic;                                          
  hbm2e_lower_test_ch3_u0_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch3_u0_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch3_u0_axi_m_arvalid        : out std_logic;                                          
  hbm2e_lower_test_ch3_u0_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch3_u0_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_test_ch3_u0_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch3_u0_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch3_u0_axi_m_rready         : out std_logic;                                          
  hbm2e_lower_test_ch3_u1_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch3_u1_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch3_u1_axi_m_awvalid        : out std_logic;                                          
  hbm2e_lower_test_ch3_u1_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch3_u1_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_test_ch3_u1_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_test_ch3_u1_axi_m_wvalid         : out std_logic;                                          
  hbm2e_lower_test_ch3_u1_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch3_u1_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch3_u1_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch3_u1_axi_m_bready         : out std_logic;                                          
  hbm2e_lower_test_ch3_u1_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch3_u1_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch3_u1_axi_m_arvalid        : out std_logic;                                          
  hbm2e_lower_test_ch3_u1_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch3_u1_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_test_ch3_u1_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch3_u1_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch3_u1_axi_m_rready         : out std_logic;                                          
  hbm2e_lower_test_ch4_u0_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch4_u0_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch4_u0_axi_m_awvalid        : out std_logic;                                          
  hbm2e_lower_test_ch4_u0_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch4_u0_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_test_ch4_u0_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_test_ch4_u0_axi_m_wvalid         : out std_logic;                                          
  hbm2e_lower_test_ch4_u0_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch4_u0_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch4_u0_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch4_u0_axi_m_bready         : out std_logic;                                          
  hbm2e_lower_test_ch4_u0_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch4_u0_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch4_u0_axi_m_arvalid        : out std_logic;                                          
  hbm2e_lower_test_ch4_u0_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch4_u0_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_test_ch4_u0_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch4_u0_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch4_u0_axi_m_rready         : out std_logic;                                          
  hbm2e_lower_test_ch4_u1_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch4_u1_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch4_u1_axi_m_awvalid        : out std_logic;                                          
  hbm2e_lower_test_ch4_u1_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch4_u1_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_test_ch4_u1_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_test_ch4_u1_axi_m_wvalid         : out std_logic;                                          
  hbm2e_lower_test_ch4_u1_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch4_u1_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch4_u1_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch4_u1_axi_m_bready         : out std_logic;                                          
  hbm2e_lower_test_ch4_u1_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch4_u1_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch4_u1_axi_m_arvalid        : out std_logic;                                          
  hbm2e_lower_test_ch4_u1_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch4_u1_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_test_ch4_u1_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch4_u1_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch4_u1_axi_m_rready         : out std_logic;                                          
  hbm2e_lower_test_ch5_u0_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch5_u0_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch5_u0_axi_m_awvalid        : out std_logic;                                          
  hbm2e_lower_test_ch5_u0_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch5_u0_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_test_ch5_u0_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_test_ch5_u0_axi_m_wvalid         : out std_logic;                                          
  hbm2e_lower_test_ch5_u0_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch5_u0_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch5_u0_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch5_u0_axi_m_bready         : out std_logic;                                          
  hbm2e_lower_test_ch5_u0_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch5_u0_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch5_u0_axi_m_arvalid        : out std_logic;                                          
  hbm2e_lower_test_ch5_u0_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch5_u0_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_test_ch5_u0_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch5_u0_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch5_u0_axi_m_rready         : out std_logic;                                          
  hbm2e_lower_test_ch5_u1_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch5_u1_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch5_u1_axi_m_awvalid        : out std_logic;                                          
  hbm2e_lower_test_ch5_u1_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch5_u1_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_test_ch5_u1_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_test_ch5_u1_axi_m_wvalid         : out std_logic;                                          
  hbm2e_lower_test_ch5_u1_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch5_u1_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch5_u1_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch5_u1_axi_m_bready         : out std_logic;                                          
  hbm2e_lower_test_ch5_u1_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch5_u1_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch5_u1_axi_m_arvalid        : out std_logic;                                          
  hbm2e_lower_test_ch5_u1_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch5_u1_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_test_ch5_u1_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch5_u1_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch5_u1_axi_m_rready         : out std_logic;                                          
  hbm2e_lower_test_ch6_u0_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch6_u0_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch6_u0_axi_m_awvalid        : out std_logic;                                          
  hbm2e_lower_test_ch6_u0_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch6_u0_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_test_ch6_u0_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_test_ch6_u0_axi_m_wvalid         : out std_logic;                                          
  hbm2e_lower_test_ch6_u0_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch6_u0_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch6_u0_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch6_u0_axi_m_bready         : out std_logic;                                          
  hbm2e_lower_test_ch6_u0_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch6_u0_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch6_u0_axi_m_arvalid        : out std_logic;                                          
  hbm2e_lower_test_ch6_u0_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch6_u0_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_test_ch6_u0_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch6_u0_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch6_u0_axi_m_rready         : out std_logic;                                          
  hbm2e_lower_test_ch6_u1_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch6_u1_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch6_u1_axi_m_awvalid        : out std_logic;                                          
  hbm2e_lower_test_ch6_u1_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch6_u1_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_test_ch6_u1_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_test_ch6_u1_axi_m_wvalid         : out std_logic;                                          
  hbm2e_lower_test_ch6_u1_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch6_u1_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch6_u1_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch6_u1_axi_m_bready         : out std_logic;                                          
  hbm2e_lower_test_ch6_u1_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch6_u1_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch6_u1_axi_m_arvalid        : out std_logic;                                          
  hbm2e_lower_test_ch6_u1_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch6_u1_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_test_ch6_u1_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch6_u1_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch6_u1_axi_m_rready         : out std_logic;                                          
  hbm2e_lower_test_ch7_u0_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch7_u0_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch7_u0_axi_m_awvalid        : out std_logic;                                          
  hbm2e_lower_test_ch7_u0_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch7_u0_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_test_ch7_u0_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_test_ch7_u0_axi_m_wvalid         : out std_logic;                                          
  hbm2e_lower_test_ch7_u0_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch7_u0_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch7_u0_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch7_u0_axi_m_bready         : out std_logic;                                          
  hbm2e_lower_test_ch7_u0_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch7_u0_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch7_u0_axi_m_arvalid        : out std_logic;                                          
  hbm2e_lower_test_ch7_u0_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch7_u0_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_test_ch7_u0_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch7_u0_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch7_u0_axi_m_rready         : out std_logic;                                          
  hbm2e_lower_test_ch7_u1_axi_m_awaddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch7_u1_axi_m_awprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch7_u1_axi_m_awvalid        : out std_logic;                                          
  hbm2e_lower_test_ch7_u1_axi_m_awready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch7_u1_axi_m_wdata          : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_test_ch7_u1_axi_m_wstrb          : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_test_ch7_u1_axi_m_wvalid         : out std_logic;                                          
  hbm2e_lower_test_ch7_u1_axi_m_wready         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch7_u1_axi_m_bresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch7_u1_axi_m_bvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch7_u1_axi_m_bready         : out std_logic;                                          
  hbm2e_lower_test_ch7_u1_axi_m_araddr         : out std_logic_vector(5 downto 0);                       
  hbm2e_lower_test_ch7_u1_axi_m_arprot         : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_test_ch7_u1_axi_m_arvalid        : out std_logic;                                          
  hbm2e_lower_test_ch7_u1_axi_m_arready        : in  std_logic                       := '0';             
  hbm2e_lower_test_ch7_u1_axi_m_rdata          : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_test_ch7_u1_axi_m_rresp          : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_test_ch7_u1_axi_m_rvalid         : in  std_logic                       := '0';             
  hbm2e_lower_test_ch7_u1_axi_m_rready         : out std_logic;                                          
  hbm2e_lower_error_log_ch0_u0_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch0_u0_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch0_u0_axi_m_awvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch0_u0_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch0_u0_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_error_log_ch0_u0_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_error_log_ch0_u0_axi_m_wvalid    : out std_logic;                                          
  hbm2e_lower_error_log_ch0_u0_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch0_u0_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch0_u0_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch0_u0_axi_m_bready    : out std_logic;                                          
  hbm2e_lower_error_log_ch0_u0_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch0_u0_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch0_u0_axi_m_arvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch0_u0_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch0_u0_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_error_log_ch0_u0_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch0_u0_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch0_u0_axi_m_rready    : out std_logic;                                          
  hbm2e_lower_error_log_ch0_u1_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch0_u1_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch0_u1_axi_m_awvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch0_u1_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch0_u1_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_error_log_ch0_u1_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_error_log_ch0_u1_axi_m_wvalid    : out std_logic;                                          
  hbm2e_lower_error_log_ch0_u1_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch0_u1_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch0_u1_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch0_u1_axi_m_bready    : out std_logic;                                          
  hbm2e_lower_error_log_ch0_u1_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch0_u1_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch0_u1_axi_m_arvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch0_u1_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch0_u1_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_error_log_ch0_u1_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch0_u1_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch0_u1_axi_m_rready    : out std_logic;                                          
  hbm2e_lower_error_log_ch1_u0_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch1_u0_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch1_u0_axi_m_awvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch1_u0_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch1_u0_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_error_log_ch1_u0_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_error_log_ch1_u0_axi_m_wvalid    : out std_logic;                                          
  hbm2e_lower_error_log_ch1_u0_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch1_u0_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch1_u0_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch1_u0_axi_m_bready    : out std_logic;                                          
  hbm2e_lower_error_log_ch1_u0_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch1_u0_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch1_u0_axi_m_arvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch1_u0_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch1_u0_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_error_log_ch1_u0_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch1_u0_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch1_u0_axi_m_rready    : out std_logic;                                          
  hbm2e_lower_error_log_ch1_u1_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch1_u1_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch1_u1_axi_m_awvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch1_u1_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch1_u1_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_error_log_ch1_u1_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_error_log_ch1_u1_axi_m_wvalid    : out std_logic;                                          
  hbm2e_lower_error_log_ch1_u1_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch1_u1_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch1_u1_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch1_u1_axi_m_bready    : out std_logic;                                          
  hbm2e_lower_error_log_ch1_u1_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch1_u1_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch1_u1_axi_m_arvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch1_u1_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch1_u1_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_error_log_ch1_u1_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch1_u1_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch1_u1_axi_m_rready    : out std_logic;                                          
  hbm2e_lower_error_log_ch2_u0_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch2_u0_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch2_u0_axi_m_awvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch2_u0_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch2_u0_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_error_log_ch2_u0_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_error_log_ch2_u0_axi_m_wvalid    : out std_logic;                                          
  hbm2e_lower_error_log_ch2_u0_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch2_u0_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch2_u0_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch2_u0_axi_m_bready    : out std_logic;                                          
  hbm2e_lower_error_log_ch2_u0_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch2_u0_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch2_u0_axi_m_arvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch2_u0_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch2_u0_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_error_log_ch2_u0_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch2_u0_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch2_u0_axi_m_rready    : out std_logic;                                          
  hbm2e_lower_error_log_ch2_u1_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch2_u1_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch2_u1_axi_m_awvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch2_u1_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch2_u1_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_error_log_ch2_u1_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_error_log_ch2_u1_axi_m_wvalid    : out std_logic;                                          
  hbm2e_lower_error_log_ch2_u1_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch2_u1_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch2_u1_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch2_u1_axi_m_bready    : out std_logic;                                          
  hbm2e_lower_error_log_ch2_u1_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch2_u1_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch2_u1_axi_m_arvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch2_u1_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch2_u1_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_error_log_ch2_u1_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch2_u1_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch2_u1_axi_m_rready    : out std_logic;                                          
  hbm2e_lower_error_log_ch3_u0_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch3_u0_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch3_u0_axi_m_awvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch3_u0_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch3_u0_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_error_log_ch3_u0_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_error_log_ch3_u0_axi_m_wvalid    : out std_logic;                                          
  hbm2e_lower_error_log_ch3_u0_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch3_u0_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch3_u0_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch3_u0_axi_m_bready    : out std_logic;                                          
  hbm2e_lower_error_log_ch3_u0_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch3_u0_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch3_u0_axi_m_arvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch3_u0_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch3_u0_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_error_log_ch3_u0_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch3_u0_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch3_u0_axi_m_rready    : out std_logic;                                          
  hbm2e_lower_error_log_ch3_u1_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch3_u1_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch3_u1_axi_m_awvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch3_u1_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch3_u1_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_error_log_ch3_u1_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_error_log_ch3_u1_axi_m_wvalid    : out std_logic;                                          
  hbm2e_lower_error_log_ch3_u1_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch3_u1_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch3_u1_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch3_u1_axi_m_bready    : out std_logic;                                          
  hbm2e_lower_error_log_ch3_u1_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch3_u1_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch3_u1_axi_m_arvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch3_u1_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch3_u1_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_error_log_ch3_u1_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch3_u1_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch3_u1_axi_m_rready    : out std_logic;                                          
  hbm2e_lower_error_log_ch4_u0_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch4_u0_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch4_u0_axi_m_awvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch4_u0_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch4_u0_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_error_log_ch4_u0_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_error_log_ch4_u0_axi_m_wvalid    : out std_logic;                                          
  hbm2e_lower_error_log_ch4_u0_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch4_u0_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch4_u0_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch4_u0_axi_m_bready    : out std_logic;                                          
  hbm2e_lower_error_log_ch4_u0_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch4_u0_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch4_u0_axi_m_arvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch4_u0_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch4_u0_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_error_log_ch4_u0_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch4_u0_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch4_u0_axi_m_rready    : out std_logic;                                          
  hbm2e_lower_error_log_ch4_u1_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch4_u1_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch4_u1_axi_m_awvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch4_u1_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch4_u1_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_error_log_ch4_u1_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_error_log_ch4_u1_axi_m_wvalid    : out std_logic;                                          
  hbm2e_lower_error_log_ch4_u1_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch4_u1_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch4_u1_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch4_u1_axi_m_bready    : out std_logic;                                          
  hbm2e_lower_error_log_ch4_u1_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch4_u1_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch4_u1_axi_m_arvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch4_u1_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch4_u1_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_error_log_ch4_u1_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch4_u1_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch4_u1_axi_m_rready    : out std_logic;                                          
  hbm2e_lower_error_log_ch5_u0_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch5_u0_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch5_u0_axi_m_awvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch5_u0_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch5_u0_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_error_log_ch5_u0_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_error_log_ch5_u0_axi_m_wvalid    : out std_logic;                                          
  hbm2e_lower_error_log_ch5_u0_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch5_u0_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch5_u0_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch5_u0_axi_m_bready    : out std_logic;                                          
  hbm2e_lower_error_log_ch5_u0_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch5_u0_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch5_u0_axi_m_arvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch5_u0_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch5_u0_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_error_log_ch5_u0_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch5_u0_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch5_u0_axi_m_rready    : out std_logic;                                          
  hbm2e_lower_error_log_ch5_u1_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch5_u1_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch5_u1_axi_m_awvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch5_u1_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch5_u1_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_error_log_ch5_u1_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_error_log_ch5_u1_axi_m_wvalid    : out std_logic;                                          
  hbm2e_lower_error_log_ch5_u1_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch5_u1_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch5_u1_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch5_u1_axi_m_bready    : out std_logic;                                          
  hbm2e_lower_error_log_ch5_u1_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch5_u1_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch5_u1_axi_m_arvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch5_u1_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch5_u1_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_error_log_ch5_u1_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch5_u1_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch5_u1_axi_m_rready    : out std_logic;                                          
  hbm2e_lower_error_log_ch6_u0_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch6_u0_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch6_u0_axi_m_awvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch6_u0_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch6_u0_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_error_log_ch6_u0_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_error_log_ch6_u0_axi_m_wvalid    : out std_logic;                                          
  hbm2e_lower_error_log_ch6_u0_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch6_u0_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch6_u0_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch6_u0_axi_m_bready    : out std_logic;                                          
  hbm2e_lower_error_log_ch6_u0_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch6_u0_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch6_u0_axi_m_arvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch6_u0_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch6_u0_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_error_log_ch6_u0_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch6_u0_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch6_u0_axi_m_rready    : out std_logic;                                          
  hbm2e_lower_error_log_ch6_u1_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch6_u1_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch6_u1_axi_m_awvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch6_u1_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch6_u1_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_error_log_ch6_u1_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_error_log_ch6_u1_axi_m_wvalid    : out std_logic;                                          
  hbm2e_lower_error_log_ch6_u1_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch6_u1_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch6_u1_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch6_u1_axi_m_bready    : out std_logic;                                          
  hbm2e_lower_error_log_ch6_u1_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch6_u1_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch6_u1_axi_m_arvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch6_u1_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch6_u1_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_error_log_ch6_u1_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch6_u1_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch6_u1_axi_m_rready    : out std_logic;                                          
  hbm2e_lower_error_log_ch7_u0_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch7_u0_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch7_u0_axi_m_awvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch7_u0_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch7_u0_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_error_log_ch7_u0_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_error_log_ch7_u0_axi_m_wvalid    : out std_logic;                                          
  hbm2e_lower_error_log_ch7_u0_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch7_u0_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch7_u0_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch7_u0_axi_m_bready    : out std_logic;                                          
  hbm2e_lower_error_log_ch7_u0_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch7_u0_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch7_u0_axi_m_arvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch7_u0_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch7_u0_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_error_log_ch7_u0_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch7_u0_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch7_u0_axi_m_rready    : out std_logic;                                          
  hbm2e_lower_error_log_ch7_u1_axi_m_awaddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch7_u1_axi_m_awprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch7_u1_axi_m_awvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch7_u1_axi_m_awready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch7_u1_axi_m_wdata     : out std_logic_vector(31 downto 0);                      
  hbm2e_lower_error_log_ch7_u1_axi_m_wstrb     : out std_logic_vector(3 downto 0);                       
  hbm2e_lower_error_log_ch7_u1_axi_m_wvalid    : out std_logic;                                          
  hbm2e_lower_error_log_ch7_u1_axi_m_wready    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch7_u1_axi_m_bresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch7_u1_axi_m_bvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch7_u1_axi_m_bready    : out std_logic;                                          
  hbm2e_lower_error_log_ch7_u1_axi_m_araddr    : out std_logic_vector(7 downto 0);                       
  hbm2e_lower_error_log_ch7_u1_axi_m_arprot    : out std_logic_vector(2 downto 0);                       
  hbm2e_lower_error_log_ch7_u1_axi_m_arvalid   : out std_logic;                                          
  hbm2e_lower_error_log_ch7_u1_axi_m_arready   : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch7_u1_axi_m_rdata     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  hbm2e_lower_error_log_ch7_u1_axi_m_rresp     : in  std_logic_vector(1 downto 0)    := (others => '0'); 
  hbm2e_lower_error_log_ch7_u1_axi_m_rvalid    : in  std_logic                       := '0';             
  hbm2e_lower_error_log_ch7_u1_axi_m_rready    : out std_logic;                                          
  hip_serial_rx_n_in0                          : in  std_logic                       := '0';             
  hip_serial_rx_n_in1                          : in  std_logic                       := '0';             
  hip_serial_rx_n_in2                          : in  std_logic                       := '0';             
  hip_serial_rx_n_in3                          : in  std_logic                       := '0';             
  hip_serial_rx_n_in4                          : in  std_logic                       := '0';             
  hip_serial_rx_n_in5                          : in  std_logic                       := '0';             
  hip_serial_rx_n_in6                          : in  std_logic                       := '0';             
  hip_serial_rx_n_in7                          : in  std_logic                       := '0';             
  hip_serial_rx_n_in8                          : in  std_logic                       := '0';             
  hip_serial_rx_n_in9                          : in  std_logic                       := '0';             
  hip_serial_rx_n_in10                         : in  std_logic                       := '0';             
  hip_serial_rx_n_in11                         : in  std_logic                       := '0';             
  hip_serial_rx_n_in12                         : in  std_logic                       := '0';             
  hip_serial_rx_n_in13                         : in  std_logic                       := '0';             
  hip_serial_rx_n_in14                         : in  std_logic                       := '0';             
  hip_serial_rx_n_in15                         : in  std_logic                       := '0';             
  hip_serial_rx_p_in0                          : in  std_logic                       := '0';             
  hip_serial_rx_p_in1                          : in  std_logic                       := '0';             
  hip_serial_rx_p_in2                          : in  std_logic                       := '0';             
  hip_serial_rx_p_in3                          : in  std_logic                       := '0';             
  hip_serial_rx_p_in4                          : in  std_logic                       := '0';             
  hip_serial_rx_p_in5                          : in  std_logic                       := '0';             
  hip_serial_rx_p_in6                          : in  std_logic                       := '0';             
  hip_serial_rx_p_in7                          : in  std_logic                       := '0';             
  hip_serial_rx_p_in8                          : in  std_logic                       := '0';             
  hip_serial_rx_p_in9                          : in  std_logic                       := '0';             
  hip_serial_rx_p_in10                         : in  std_logic                       := '0';             
  hip_serial_rx_p_in11                         : in  std_logic                       := '0';             
  hip_serial_rx_p_in12                         : in  std_logic                       := '0';             
  hip_serial_rx_p_in13                         : in  std_logic                       := '0';             
  hip_serial_rx_p_in14                         : in  std_logic                       := '0';             
  hip_serial_rx_p_in15                         : in  std_logic                       := '0';             
  hip_serial_tx_n_out0                         : out std_logic;                                          
  hip_serial_tx_n_out1                         : out std_logic;                                          
  hip_serial_tx_n_out2                         : out std_logic;                                          
  hip_serial_tx_n_out3                         : out std_logic;                                          
  hip_serial_tx_n_out4                         : out std_logic;                                          
  hip_serial_tx_n_out5                         : out std_logic;                                          
  hip_serial_tx_n_out6                         : out std_logic;                                          
  hip_serial_tx_n_out7                         : out std_logic;                                          
  hip_serial_tx_n_out8                         : out std_logic;                                          
  hip_serial_tx_n_out9                         : out std_logic;                                          
  hip_serial_tx_n_out10                        : out std_logic;                                          
  hip_serial_tx_n_out11                        : out std_logic;                                          
  hip_serial_tx_n_out12                        : out std_logic;                                          
  hip_serial_tx_n_out13                        : out std_logic;                                          
  hip_serial_tx_n_out14                        : out std_logic;                                          
  hip_serial_tx_n_out15                        : out std_logic;                                          
  hip_serial_tx_p_out0                         : out std_logic;                                          
  hip_serial_tx_p_out1                         : out std_logic;                                          
  hip_serial_tx_p_out2                         : out std_logic;                                          
  hip_serial_tx_p_out3                         : out std_logic;                                          
  hip_serial_tx_p_out4                         : out std_logic;                                          
  hip_serial_tx_p_out5                         : out std_logic;                                          
  hip_serial_tx_p_out6                         : out std_logic;                                          
  hip_serial_tx_p_out7                         : out std_logic;                                          
  hip_serial_tx_p_out8                         : out std_logic;                                          
  hip_serial_tx_p_out9                         : out std_logic;                                          
  hip_serial_tx_p_out10                        : out std_logic;                                          
  hip_serial_tx_p_out11                        : out std_logic;                                          
  hip_serial_tx_p_out12                        : out std_logic;                                          
  hip_serial_tx_p_out13                        : out std_logic;                                          
  hip_serial_tx_p_out14                        : out std_logic;                                          
  hip_serial_tx_p_out15                        : out std_logic;                                          
  pcie_refclk0_clk                             : in  std_logic                       := '0';             
  pcie_refclk1_clk                             : in  std_logic                       := '0';             
  ninit_done_reset                             : in  std_logic                       := '0';             
  dummy_user_avmm_rst_reset                    : in  std_logic                       := '0';             
  pin_perst_reset_n                            : in  std_logic                       := '0';    
  pin_perst_n_o_reset_n                        : out std_logic;  
  sl4_reconfig0_m_waitrequest                  : in  std_logic                       := '0';             
  sl4_reconfig0_m_readdata                     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  sl4_reconfig0_m_readdatavalid                : in  std_logic                       := '0';             
  sl4_reconfig0_m_burstcount                   : out std_logic_vector(0 downto 0);                       
  sl4_reconfig0_m_writedata                    : out std_logic_vector(31 downto 0);                      
  sl4_reconfig0_m_address                      : out std_logic_vector(16 downto 0);                      
  sl4_reconfig0_m_write                        : out std_logic;                                          
  sl4_reconfig0_m_read                         : out std_logic;                                          
  sl4_reconfig0_m_byteenable                   : out std_logic_vector(3 downto 0);                       
  sl4_reconfig0_m_debugaccess                  : out std_logic;                                          
  xcvr_reconfig0_m_waitrequest                 : in  std_logic                       := '0';             
  xcvr_reconfig0_m_readdata                    : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  xcvr_reconfig0_m_readdatavalid               : in  std_logic                       := '0';             
  xcvr_reconfig0_m_burstcount                  : out std_logic_vector(0 downto 0);                       
  xcvr_reconfig0_m_writedata                   : out std_logic_vector(31 downto 0);                      
  xcvr_reconfig0_m_address                     : out std_logic_vector(20 downto 0);                      
  xcvr_reconfig0_m_write                       : out std_logic;                                          
  xcvr_reconfig0_m_read                        : out std_logic;                                          
  xcvr_reconfig0_m_byteenable                  : out std_logic_vector(3 downto 0);                       
  xcvr_reconfig0_m_debugaccess                 : out std_logic;                                          
  sl4_reconfig1_m_waitrequest                  : in  std_logic                       := '0';             
  sl4_reconfig1_m_readdata                     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  sl4_reconfig1_m_readdatavalid                : in  std_logic                       := '0';             
  sl4_reconfig1_m_burstcount                   : out std_logic_vector(0 downto 0);                       
  sl4_reconfig1_m_writedata                    : out std_logic_vector(31 downto 0);                      
  sl4_reconfig1_m_address                      : out std_logic_vector(16 downto 0);                      
  sl4_reconfig1_m_write                        : out std_logic;                                          
  sl4_reconfig1_m_read                         : out std_logic;                                          
  sl4_reconfig1_m_byteenable                   : out std_logic_vector(3 downto 0);                       
  sl4_reconfig1_m_debugaccess                  : out std_logic;                                          
  xcvr_reconfig1_m_waitrequest                 : in  std_logic                       := '0';             
  xcvr_reconfig1_m_readdata                    : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  xcvr_reconfig1_m_readdatavalid               : in  std_logic                       := '0';             
  xcvr_reconfig1_m_burstcount                  : out std_logic_vector(0 downto 0);                       
  xcvr_reconfig1_m_writedata                   : out std_logic_vector(31 downto 0);                      
  xcvr_reconfig1_m_address                     : out std_logic_vector(20 downto 0);                      
  xcvr_reconfig1_m_write                       : out std_logic;                                          
  xcvr_reconfig1_m_read                        : out std_logic;                                          
  xcvr_reconfig1_m_byteenable                  : out std_logic_vector(3 downto 0);                       
  xcvr_reconfig1_m_debugaccess                 : out std_logic;                                          
  sl4_reconfig2_m_waitrequest                  : in  std_logic                       := '0';             
  sl4_reconfig2_m_readdata                     : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  sl4_reconfig2_m_readdatavalid                : in  std_logic                       := '0';             
  sl4_reconfig2_m_burstcount                   : out std_logic_vector(0 downto 0);                       
  sl4_reconfig2_m_writedata                    : out std_logic_vector(31 downto 0);                      
  sl4_reconfig2_m_address                      : out std_logic_vector(16 downto 0);                      
  sl4_reconfig2_m_write                        : out std_logic;                                          
  sl4_reconfig2_m_read                         : out std_logic;                                          
  sl4_reconfig2_m_byteenable                   : out std_logic_vector(3 downto 0);                       
  sl4_reconfig2_m_debugaccess                  : out std_logic;                                          
  xcvr_reconfig2_m_waitrequest                 : in  std_logic                       := '0';             
  xcvr_reconfig2_m_readdata                    : in  std_logic_vector(31 downto 0)   := (others => '0'); 
  xcvr_reconfig2_m_readdatavalid               : in  std_logic                       := '0';             
  xcvr_reconfig2_m_burstcount                  : out std_logic_vector(0 downto 0);                       
  xcvr_reconfig2_m_writedata                   : out std_logic_vector(31 downto 0);                      
  xcvr_reconfig2_m_address                     : out std_logic_vector(20 downto 0);                      
  xcvr_reconfig2_m_write                       : out std_logic;                                          
  xcvr_reconfig2_m_read                        : out std_logic;                                          
  xcvr_reconfig2_m_byteenable                  : out std_logic_vector(3 downto 0);                       
  xcvr_reconfig2_m_debugaccess                 : out std_logic;                                          
  spi_ig_sclk                                  : in  std_logic                       := '0';             
  spi_ig_ss_n                                  : in  std_logic                       := '0';             
  spi_ig_mosi                                  : in  std_logic                       := '0';             
  spi_ig_miso                                  : out std_logic;                                          
  bmc_if_present_n_bmc_if_ready_n              : out std_logic;                                          
  f2b_irq_n_f2b_irq_n                          : out std_logic;                                          
  spi_eg_sclk                                  : out std_logic;                                          
  spi_eg_ss_n                                  : out std_logic;                                          
  spi_eg_mosi                                  : out std_logic;                                          
  spi_eg_miso                                  : in  std_logic                       := '0';             
  b2f_irq_n_b2f_irq_n                          : in  std_logic                       := '0';             
  bmc3_telemetry_eeprom_data                   : out std_logic_vector(2047 downto 0);                    
  bmc3_telemetry_qspfdd0_ctrl_status_rst_n     : in  std_logic                       := '0';             
  bmc3_telemetry_qspfdd0_ctrl_status_lpmode    : in  std_logic                       := '0';             
  bmc3_telemetry_qspfdd0_ctrl_status_int_n     : out std_logic;                                          
  bmc3_telemetry_qspfdd0_ctrl_status_present_n : out std_logic;                                          
  bmc3_telemetry_qspfdd1_ctrl_status_rst_n     : in  std_logic                       := '0';             
  bmc3_telemetry_qspfdd1_ctrl_status_lpmode    : in  std_logic                       := '0';             
  bmc3_telemetry_qspfdd1_ctrl_status_int_n     : out std_logic;                                          
  bmc3_telemetry_qspfdd1_ctrl_status_present_n : out std_logic;                                          
  bmc3_telemetry_qspfdd2_ctrl_status_rst_n     : in  std_logic                       := '0';             
  bmc3_telemetry_qspfdd2_ctrl_status_lpmode    : in  std_logic                       := '0';             
  bmc3_telemetry_qspfdd2_ctrl_status_int_n     : out std_logic;                                          
  bmc3_telemetry_qspfdd2_ctrl_status_present_n : out std_logic                                           
  );
end component;

component axi4_lite_x4_noc_initiator
port (
  s0_axi4lite_awaddr        : in  std_logic_vector(43 downto 0) := (others => '0'); 
  s0_axi4lite_awvalid       : in  std_logic                     := '0';             
  s0_axi4lite_awready       : out std_logic;                                        
  s0_axi4lite_wdata         : in  std_logic_vector(31 downto 0) := (others => '0'); 
  s0_axi4lite_wstrb         : in  std_logic_vector(3 downto 0)  := (others => '0'); 
  s0_axi4lite_wvalid        : in  std_logic                     := '0';             
  s0_axi4lite_wready        : out std_logic;                                        
  s0_axi4lite_bresp         : out std_logic_vector(1 downto 0);                     
  s0_axi4lite_bvalid        : out std_logic;                                        
  s0_axi4lite_bready        : in  std_logic                     := '0';             
  s0_axi4lite_araddr        : in  std_logic_vector(43 downto 0) := (others => '0'); 
  s0_axi4lite_arvalid       : in  std_logic                     := '0';             
  s0_axi4lite_arready       : out std_logic;                                        
  s0_axi4lite_rdata         : out std_logic_vector(31 downto 0);                    
  s0_axi4lite_rresp         : out std_logic_vector(1 downto 0);                     
  s0_axi4lite_rvalid        : out std_logic;                                        
  s0_axi4lite_rready        : in  std_logic                     := '0';             
  s0_axi4lite_awprot        : in  std_logic_vector(2 downto 0)  := (others => '0'); 
  s0_axi4lite_arprot        : in  std_logic_vector(2 downto 0)  := (others => '0'); 
  s1_axi4lite_awaddr        : in  std_logic_vector(43 downto 0) := (others => '0'); 
  s1_axi4lite_awvalid       : in  std_logic                     := '0';             
  s1_axi4lite_awready       : out std_logic;                                        
  s1_axi4lite_wdata         : in  std_logic_vector(31 downto 0) := (others => '0'); 
  s1_axi4lite_wstrb         : in  std_logic_vector(3 downto 0)  := (others => '0'); 
  s1_axi4lite_wvalid        : in  std_logic                     := '0';             
  s1_axi4lite_wready        : out std_logic;                                        
  s1_axi4lite_bresp         : out std_logic_vector(1 downto 0);                     
  s1_axi4lite_bvalid        : out std_logic;                                        
  s1_axi4lite_bready        : in  std_logic                     := '0';             
  s1_axi4lite_araddr        : in  std_logic_vector(43 downto 0) := (others => '0'); 
  s1_axi4lite_arvalid       : in  std_logic                     := '0';             
  s1_axi4lite_arready       : out std_logic;                                        
  s1_axi4lite_rdata         : out std_logic_vector(31 downto 0);                    
  s1_axi4lite_rresp         : out std_logic_vector(1 downto 0);                     
  s1_axi4lite_rvalid        : out std_logic;                                        
  s1_axi4lite_rready        : in  std_logic                     := '0';             
  s1_axi4lite_awprot        : in  std_logic_vector(2 downto 0)  := (others => '0'); 
  s1_axi4lite_arprot        : in  std_logic_vector(2 downto 0)  := (others => '0'); 
  s2_axi4lite_awaddr        : in  std_logic_vector(43 downto 0) := (others => '0'); 
  s2_axi4lite_awvalid       : in  std_logic                     := '0';             
  s2_axi4lite_awready       : out std_logic;                                        
  s2_axi4lite_wdata         : in  std_logic_vector(31 downto 0) := (others => '0'); 
  s2_axi4lite_wstrb         : in  std_logic_vector(3 downto 0)  := (others => '0'); 
  s2_axi4lite_wvalid        : in  std_logic                     := '0';             
  s2_axi4lite_wready        : out std_logic;                                        
  s2_axi4lite_bresp         : out std_logic_vector(1 downto 0);                     
  s2_axi4lite_bvalid        : out std_logic;                                        
  s2_axi4lite_bready        : in  std_logic                     := '0';             
  s2_axi4lite_araddr        : in  std_logic_vector(43 downto 0) := (others => '0'); 
  s2_axi4lite_arvalid       : in  std_logic                     := '0';             
  s2_axi4lite_arready       : out std_logic;                                        
  s2_axi4lite_rdata         : out std_logic_vector(31 downto 0);                    
  s2_axi4lite_rresp         : out std_logic_vector(1 downto 0);                     
  s2_axi4lite_rvalid        : out std_logic;                                        
  s2_axi4lite_rready        : in  std_logic                     := '0';             
  s2_axi4lite_awprot        : in  std_logic_vector(2 downto 0)  := (others => '0'); 
  s2_axi4lite_arprot        : in  std_logic_vector(2 downto 0)  := (others => '0'); 
  s3_axi4lite_awaddr        : in  std_logic_vector(43 downto 0) := (others => '0'); 
  s3_axi4lite_awvalid       : in  std_logic                     := '0';             
  s3_axi4lite_awready       : out std_logic;                                        
  s3_axi4lite_wdata         : in  std_logic_vector(31 downto 0) := (others => '0'); 
  s3_axi4lite_wstrb         : in  std_logic_vector(3 downto 0)  := (others => '0'); 
  s3_axi4lite_wvalid        : in  std_logic                     := '0';             
  s3_axi4lite_wready        : out std_logic;                                        
  s3_axi4lite_bresp         : out std_logic_vector(1 downto 0);                     
  s3_axi4lite_bvalid        : out std_logic;                                        
  s3_axi4lite_bready        : in  std_logic                     := '0';             
  s3_axi4lite_araddr        : in  std_logic_vector(43 downto 0) := (others => '0'); 
  s3_axi4lite_arvalid       : in  std_logic                     := '0';             
  s3_axi4lite_arready       : out std_logic;                                        
  s3_axi4lite_rdata         : out std_logic_vector(31 downto 0);                    
  s3_axi4lite_rresp         : out std_logic_vector(1 downto 0);                     
  s3_axi4lite_rvalid        : out std_logic;                                        
  s3_axi4lite_rready        : in  std_logic                     := '0';             
  s3_axi4lite_awprot        : in  std_logic_vector(2 downto 0)  := (others => '0'); 
  s3_axi4lite_arprot        : in  std_logic_vector(2 downto 0)  := (others => '0'); 
  s0_axi4lite_aclk          : in  std_logic                     := '0';             
  s0_axi4lite_aresetn       : in  std_logic                     := '0';             
  s1_axi4lite_aclk          : in  std_logic                     := '0';             
  s1_axi4lite_aresetn       : in  std_logic                     := '0';             
  s2_axi4lite_aclk          : in  std_logic                     := '0';             
  s2_axi4lite_aresetn       : in  std_logic                     := '0';             
  s3_axi4lite_aclk          : in  std_logic                     := '0';             
  s3_axi4lite_aresetn       : in  std_logic                     := '0'              
  );
end component;

component version_plus_scratchpad 
port (
  aclk                            : in   std_logic;
  areset                          : in   std_logic;
  awaddr                          : in   std_logic_vector(4 downto 0);
  awvalid                         : in   std_logic;
  awready                         : out  std_logic;
  awprot                          : in   std_logic_vector(2 downto 0);
  wdata                           : in   std_logic_vector(31 downto 0);
  wstrb                           : in   std_logic_vector(3 downto 0);
  wvalid                          : in   std_logic;
  wready                          : out  std_logic;
  bresp                           : out  std_logic_vector(1 downto 0);						
  bvalid                          : out  std_logic;									
  bready                          : in   std_logic;									
  araddr                          : in   std_logic_vector(4 downto 0);						
  arvalid                         : in   std_logic;								
  arready                         : out  std_logic;								
  arprot                          : in   std_logic_vector(2 downto 0);
  rdata                           : out  std_logic_vector(31 downto 0);				
  rresp                           : out  std_logic_vector(1 downto 0);				
  rvalid                          : out  std_logic;							
  rready                          : in   std_logic					  
  );
end component;

component hbm2e_upper_test
generic (
  TEST_CTRL_CLK_PERIOD      :      integer := 10
  );
port (
  -- System Clock (Drives AXI Interface)
  sys_clk                   : in   std_logic;
  sys_reset                 : in   std_logic;
  -- HBM2e Reference Clock
  hbm2e_refclk              : in   std_logic;
  hbm2e_cattrip_in          : in   std_logic;
  hbm2e_temp_in             : in   std_logic_vector(2 downto 0);
  -- HBM2e Initiator Clock 
  initiator_clk             : in   std_logic;
  -- HBM2e User Clock & Reset
  mem_usr_clk               : in   std_logic;
  mem_usr_reset             : in   std_logic_vector(15 downto 0);
  -- Channel 0 Test AXI Control/Status
  test_ctrl0_0_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl0_0_awvalid      : in   std_logic;
  test_ctrl0_0_awready      : out  std_logic;
  test_ctrl0_0_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl0_0_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl0_0_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl0_0_wvalid       : in   std_logic;
  test_ctrl0_0_wready       : out  std_logic;
  test_ctrl0_0_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl0_0_bvalid       : out  std_logic;									
  test_ctrl0_0_bready       : in   std_logic;									
  test_ctrl0_0_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl0_0_arvalid      : in   std_logic;								
  test_ctrl0_0_arready      : out  std_logic;								
  test_ctrl0_0_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl0_0_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl0_0_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl0_0_rvalid       : out  std_logic;							
  test_ctrl0_0_rready       : in   std_logic;  
  error_log0_0_awaddr       : in   std_logic_vector(7 downto 0);
  error_log0_0_awvalid      : in   std_logic;
  error_log0_0_awready      : out  std_logic;
  error_log0_0_awprot       : in   std_logic_vector(2 downto 0);
  error_log0_0_wdata        : in   std_logic_vector(31 downto 0);
  error_log0_0_wstrb        : in   std_logic_vector(3 downto 0);
  error_log0_0_wvalid       : in   std_logic;
  error_log0_0_wready       : out  std_logic;
  error_log0_0_bresp        : out  std_logic_vector(1 downto 0);						
  error_log0_0_bvalid       : out  std_logic;									
  error_log0_0_bready       : in   std_logic;									
  error_log0_0_araddr       : in   std_logic_vector(7 downto 0);						
  error_log0_0_arvalid      : in   std_logic;								
  error_log0_0_arready      : out  std_logic;								
  error_log0_0_arprot       : in   std_logic_vector(2 downto 0);
  error_log0_0_rdata        : out  std_logic_vector(31 downto 0);				
  error_log0_0_rresp        : out  std_logic_vector(1 downto 0);				
  error_log0_0_rvalid       : out  std_logic;							
  error_log0_0_rready       : in   std_logic;
  test_ctrl0_1_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl0_1_awvalid      : in   std_logic;
  test_ctrl0_1_awready      : out  std_logic;
  test_ctrl0_1_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl0_1_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl0_1_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl0_1_wvalid       : in   std_logic;
  test_ctrl0_1_wready       : out  std_logic;
  test_ctrl0_1_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl0_1_bvalid       : out  std_logic;									
  test_ctrl0_1_bready       : in   std_logic;									
  test_ctrl0_1_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl0_1_arvalid      : in   std_logic;								
  test_ctrl0_1_arready      : out  std_logic;								
  test_ctrl0_1_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl0_1_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl0_1_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl0_1_rvalid       : out  std_logic;							
  test_ctrl0_1_rready       : in   std_logic;  
  error_log0_1_awaddr       : in   std_logic_vector(7 downto 0);
  error_log0_1_awvalid      : in   std_logic;
  error_log0_1_awready      : out  std_logic;
  error_log0_1_awprot       : in   std_logic_vector(2 downto 0);
  error_log0_1_wdata        : in   std_logic_vector(31 downto 0);
  error_log0_1_wstrb        : in   std_logic_vector(3 downto 0);
  error_log0_1_wvalid       : in   std_logic;
  error_log0_1_wready       : out  std_logic;
  error_log0_1_bresp        : out  std_logic_vector(1 downto 0);						
  error_log0_1_bvalid       : out  std_logic;									
  error_log0_1_bready       : in   std_logic;									
  error_log0_1_araddr       : in   std_logic_vector(7 downto 0);						
  error_log0_1_arvalid      : in   std_logic;								
  error_log0_1_arready      : out  std_logic;								
  error_log0_1_arprot       : in   std_logic_vector(2 downto 0);
  error_log0_1_rdata        : out  std_logic_vector(31 downto 0);				
  error_log0_1_rresp        : out  std_logic_vector(1 downto 0);				
  error_log0_1_rvalid       : out  std_logic;							
  error_log0_1_rready       : in   std_logic;
  -- Channel 1 Test AXI Control/Status
  test_ctrl1_0_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl1_0_awvalid      : in   std_logic;
  test_ctrl1_0_awready      : out  std_logic;
  test_ctrl1_0_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl1_0_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl1_0_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl1_0_wvalid       : in   std_logic;
  test_ctrl1_0_wready       : out  std_logic;
  test_ctrl1_0_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl1_0_bvalid       : out  std_logic;									
  test_ctrl1_0_bready       : in   std_logic;									
  test_ctrl1_0_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl1_0_arvalid      : in   std_logic;								
  test_ctrl1_0_arready      : out  std_logic;								
  test_ctrl1_0_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl1_0_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl1_0_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl1_0_rvalid       : out  std_logic;							
  test_ctrl1_0_rready       : in   std_logic;  
  error_log1_0_awaddr       : in   std_logic_vector(7 downto 0);
  error_log1_0_awvalid      : in   std_logic;
  error_log1_0_awready      : out  std_logic;
  error_log1_0_awprot       : in   std_logic_vector(2 downto 0);
  error_log1_0_wdata        : in   std_logic_vector(31 downto 0);
  error_log1_0_wstrb        : in   std_logic_vector(3 downto 0);
  error_log1_0_wvalid       : in   std_logic;
  error_log1_0_wready       : out  std_logic;
  error_log1_0_bresp        : out  std_logic_vector(1 downto 0);						
  error_log1_0_bvalid       : out  std_logic;									
  error_log1_0_bready       : in   std_logic;									
  error_log1_0_araddr       : in   std_logic_vector(7 downto 0);						
  error_log1_0_arvalid      : in   std_logic;								
  error_log1_0_arready      : out  std_logic;								
  error_log1_0_arprot       : in   std_logic_vector(2 downto 0);
  error_log1_0_rdata        : out  std_logic_vector(31 downto 0);				
  error_log1_0_rresp        : out  std_logic_vector(1 downto 0);				
  error_log1_0_rvalid       : out  std_logic;							
  error_log1_0_rready       : in   std_logic;
  test_ctrl1_1_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl1_1_awvalid      : in   std_logic;
  test_ctrl1_1_awready      : out  std_logic;
  test_ctrl1_1_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl1_1_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl1_1_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl1_1_wvalid       : in   std_logic;
  test_ctrl1_1_wready       : out  std_logic;
  test_ctrl1_1_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl1_1_bvalid       : out  std_logic;									
  test_ctrl1_1_bready       : in   std_logic;									
  test_ctrl1_1_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl1_1_arvalid      : in   std_logic;								
  test_ctrl1_1_arready      : out  std_logic;								
  test_ctrl1_1_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl1_1_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl1_1_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl1_1_rvalid       : out  std_logic;							
  test_ctrl1_1_rready       : in   std_logic;  
  error_log1_1_awaddr       : in   std_logic_vector(7 downto 0);
  error_log1_1_awvalid      : in   std_logic;
  error_log1_1_awready      : out  std_logic;
  error_log1_1_awprot       : in   std_logic_vector(2 downto 0);
  error_log1_1_wdata        : in   std_logic_vector(31 downto 0);
  error_log1_1_wstrb        : in   std_logic_vector(3 downto 0);
  error_log1_1_wvalid       : in   std_logic;
  error_log1_1_wready       : out  std_logic;
  error_log1_1_bresp        : out  std_logic_vector(1 downto 0);						
  error_log1_1_bvalid       : out  std_logic;									
  error_log1_1_bready       : in   std_logic;									
  error_log1_1_araddr       : in   std_logic_vector(7 downto 0);						
  error_log1_1_arvalid      : in   std_logic;								
  error_log1_1_arready      : out  std_logic;								
  error_log1_1_arprot       : in   std_logic_vector(2 downto 0);
  error_log1_1_rdata        : out  std_logic_vector(31 downto 0);				
  error_log1_1_rresp        : out  std_logic_vector(1 downto 0);				
  error_log1_1_rvalid       : out  std_logic;							
  error_log1_1_rready       : in   std_logic;
  -- Channel 2 Test AXI Control/Status
  test_ctrl2_0_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl2_0_awvalid      : in   std_logic;
  test_ctrl2_0_awready      : out  std_logic;
  test_ctrl2_0_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl2_0_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl2_0_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl2_0_wvalid       : in   std_logic;
  test_ctrl2_0_wready       : out  std_logic;
  test_ctrl2_0_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl2_0_bvalid       : out  std_logic;									
  test_ctrl2_0_bready       : in   std_logic;									
  test_ctrl2_0_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl2_0_arvalid      : in   std_logic;								
  test_ctrl2_0_arready      : out  std_logic;								
  test_ctrl2_0_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl2_0_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl2_0_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl2_0_rvalid       : out  std_logic;							
  test_ctrl2_0_rready       : in   std_logic;  
  error_log2_0_awaddr       : in   std_logic_vector(7 downto 0);
  error_log2_0_awvalid      : in   std_logic;
  error_log2_0_awready      : out  std_logic;
  error_log2_0_awprot       : in   std_logic_vector(2 downto 0);
  error_log2_0_wdata        : in   std_logic_vector(31 downto 0);
  error_log2_0_wstrb        : in   std_logic_vector(3 downto 0);
  error_log2_0_wvalid       : in   std_logic;
  error_log2_0_wready       : out  std_logic;
  error_log2_0_bresp        : out  std_logic_vector(1 downto 0);						
  error_log2_0_bvalid       : out  std_logic;									
  error_log2_0_bready       : in   std_logic;									
  error_log2_0_araddr       : in   std_logic_vector(7 downto 0);						
  error_log2_0_arvalid      : in   std_logic;								
  error_log2_0_arready      : out  std_logic;								
  error_log2_0_arprot       : in   std_logic_vector(2 downto 0);
  error_log2_0_rdata        : out  std_logic_vector(31 downto 0);				
  error_log2_0_rresp        : out  std_logic_vector(1 downto 0);				
  error_log2_0_rvalid       : out  std_logic;							
  error_log2_0_rready       : in   std_logic;
  test_ctrl2_1_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl2_1_awvalid      : in   std_logic;
  test_ctrl2_1_awready      : out  std_logic;
  test_ctrl2_1_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl2_1_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl2_1_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl2_1_wvalid       : in   std_logic;
  test_ctrl2_1_wready       : out  std_logic;
  test_ctrl2_1_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl2_1_bvalid       : out  std_logic;									
  test_ctrl2_1_bready       : in   std_logic;									
  test_ctrl2_1_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl2_1_arvalid      : in   std_logic;								
  test_ctrl2_1_arready      : out  std_logic;								
  test_ctrl2_1_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl2_1_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl2_1_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl2_1_rvalid       : out  std_logic;							
  test_ctrl2_1_rready       : in   std_logic;  
  error_log2_1_awaddr       : in   std_logic_vector(7 downto 0);
  error_log2_1_awvalid      : in   std_logic;
  error_log2_1_awready      : out  std_logic;
  error_log2_1_awprot       : in   std_logic_vector(2 downto 0);
  error_log2_1_wdata        : in   std_logic_vector(31 downto 0);
  error_log2_1_wstrb        : in   std_logic_vector(3 downto 0);
  error_log2_1_wvalid       : in   std_logic;
  error_log2_1_wready       : out  std_logic;
  error_log2_1_bresp        : out  std_logic_vector(1 downto 0);						
  error_log2_1_bvalid       : out  std_logic;									
  error_log2_1_bready       : in   std_logic;									
  error_log2_1_araddr       : in   std_logic_vector(7 downto 0);						
  error_log2_1_arvalid      : in   std_logic;								
  error_log2_1_arready      : out  std_logic;								
  error_log2_1_arprot       : in   std_logic_vector(2 downto 0);
  error_log2_1_rdata        : out  std_logic_vector(31 downto 0);				
  error_log2_1_rresp        : out  std_logic_vector(1 downto 0);				
  error_log2_1_rvalid       : out  std_logic;							
  error_log2_1_rready       : in   std_logic;
  -- Channel 3 Test AXI Control/Status
  test_ctrl3_0_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl3_0_awvalid      : in   std_logic;
  test_ctrl3_0_awready      : out  std_logic;
  test_ctrl3_0_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl3_0_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl3_0_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl3_0_wvalid       : in   std_logic;
  test_ctrl3_0_wready       : out  std_logic;
  test_ctrl3_0_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl3_0_bvalid       : out  std_logic;									
  test_ctrl3_0_bready       : in   std_logic;									
  test_ctrl3_0_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl3_0_arvalid      : in   std_logic;								
  test_ctrl3_0_arready      : out  std_logic;								
  test_ctrl3_0_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl3_0_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl3_0_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl3_0_rvalid       : out  std_logic;							
  test_ctrl3_0_rready       : in   std_logic;  
  error_log3_0_awaddr       : in   std_logic_vector(7 downto 0);
  error_log3_0_awvalid      : in   std_logic;
  error_log3_0_awready      : out  std_logic;
  error_log3_0_awprot       : in   std_logic_vector(2 downto 0);
  error_log3_0_wdata        : in   std_logic_vector(31 downto 0);
  error_log3_0_wstrb        : in   std_logic_vector(3 downto 0);
  error_log3_0_wvalid       : in   std_logic;
  error_log3_0_wready       : out  std_logic;
  error_log3_0_bresp        : out  std_logic_vector(1 downto 0);						
  error_log3_0_bvalid       : out  std_logic;									
  error_log3_0_bready       : in   std_logic;									
  error_log3_0_araddr       : in   std_logic_vector(7 downto 0);						
  error_log3_0_arvalid      : in   std_logic;								
  error_log3_0_arready      : out  std_logic;								
  error_log3_0_arprot       : in   std_logic_vector(2 downto 0);
  error_log3_0_rdata        : out  std_logic_vector(31 downto 0);				
  error_log3_0_rresp        : out  std_logic_vector(1 downto 0);				
  error_log3_0_rvalid       : out  std_logic;							
  error_log3_0_rready       : in   std_logic;
  test_ctrl3_1_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl3_1_awvalid      : in   std_logic;
  test_ctrl3_1_awready      : out  std_logic;
  test_ctrl3_1_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl3_1_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl3_1_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl3_1_wvalid       : in   std_logic;
  test_ctrl3_1_wready       : out  std_logic;
  test_ctrl3_1_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl3_1_bvalid       : out  std_logic;									
  test_ctrl3_1_bready       : in   std_logic;									
  test_ctrl3_1_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl3_1_arvalid      : in   std_logic;								
  test_ctrl3_1_arready      : out  std_logic;								
  test_ctrl3_1_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl3_1_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl3_1_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl3_1_rvalid       : out  std_logic;							
  test_ctrl3_1_rready       : in   std_logic;  
  error_log3_1_awaddr       : in   std_logic_vector(7 downto 0);
  error_log3_1_awvalid      : in   std_logic;
  error_log3_1_awready      : out  std_logic;
  error_log3_1_awprot       : in   std_logic_vector(2 downto 0);
  error_log3_1_wdata        : in   std_logic_vector(31 downto 0);
  error_log3_1_wstrb        : in   std_logic_vector(3 downto 0);
  error_log3_1_wvalid       : in   std_logic;
  error_log3_1_wready       : out  std_logic;
  error_log3_1_bresp        : out  std_logic_vector(1 downto 0);						
  error_log3_1_bvalid       : out  std_logic;									
  error_log3_1_bready       : in   std_logic;									
  error_log3_1_araddr       : in   std_logic_vector(7 downto 0);						
  error_log3_1_arvalid      : in   std_logic;								
  error_log3_1_arready      : out  std_logic;								
  error_log3_1_arprot       : in   std_logic_vector(2 downto 0);
  error_log3_1_rdata        : out  std_logic_vector(31 downto 0);				
  error_log3_1_rresp        : out  std_logic_vector(1 downto 0);				
  error_log3_1_rvalid       : out  std_logic;							
  error_log3_1_rready       : in   std_logic;
  -- Channel 4 Test AXI Control/Status
  test_ctrl4_0_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl4_0_awvalid      : in   std_logic;
  test_ctrl4_0_awready      : out  std_logic;
  test_ctrl4_0_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl4_0_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl4_0_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl4_0_wvalid       : in   std_logic;
  test_ctrl4_0_wready       : out  std_logic;
  test_ctrl4_0_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl4_0_bvalid       : out  std_logic;									
  test_ctrl4_0_bready       : in   std_logic;									
  test_ctrl4_0_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl4_0_arvalid      : in   std_logic;								
  test_ctrl4_0_arready      : out  std_logic;								
  test_ctrl4_0_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl4_0_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl4_0_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl4_0_rvalid       : out  std_logic;							
  test_ctrl4_0_rready       : in   std_logic;  
  error_log4_0_awaddr       : in   std_logic_vector(7 downto 0);
  error_log4_0_awvalid      : in   std_logic;
  error_log4_0_awready      : out  std_logic;
  error_log4_0_awprot       : in   std_logic_vector(2 downto 0);
  error_log4_0_wdata        : in   std_logic_vector(31 downto 0);
  error_log4_0_wstrb        : in   std_logic_vector(3 downto 0);
  error_log4_0_wvalid       : in   std_logic;
  error_log4_0_wready       : out  std_logic;
  error_log4_0_bresp        : out  std_logic_vector(1 downto 0);						
  error_log4_0_bvalid       : out  std_logic;									
  error_log4_0_bready       : in   std_logic;									
  error_log4_0_araddr       : in   std_logic_vector(7 downto 0);						
  error_log4_0_arvalid      : in   std_logic;								
  error_log4_0_arready      : out  std_logic;								
  error_log4_0_arprot       : in   std_logic_vector(2 downto 0);
  error_log4_0_rdata        : out  std_logic_vector(31 downto 0);				
  error_log4_0_rresp        : out  std_logic_vector(1 downto 0);				
  error_log4_0_rvalid       : out  std_logic;							
  error_log4_0_rready       : in   std_logic;
  test_ctrl4_1_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl4_1_awvalid      : in   std_logic;
  test_ctrl4_1_awready      : out  std_logic;
  test_ctrl4_1_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl4_1_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl4_1_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl4_1_wvalid       : in   std_logic;
  test_ctrl4_1_wready       : out  std_logic;
  test_ctrl4_1_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl4_1_bvalid       : out  std_logic;									
  test_ctrl4_1_bready       : in   std_logic;									
  test_ctrl4_1_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl4_1_arvalid      : in   std_logic;								
  test_ctrl4_1_arready      : out  std_logic;								
  test_ctrl4_1_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl4_1_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl4_1_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl4_1_rvalid       : out  std_logic;							
  test_ctrl4_1_rready       : in   std_logic;  
  error_log4_1_awaddr       : in   std_logic_vector(7 downto 0);
  error_log4_1_awvalid      : in   std_logic;
  error_log4_1_awready      : out  std_logic;
  error_log4_1_awprot       : in   std_logic_vector(2 downto 0);
  error_log4_1_wdata        : in   std_logic_vector(31 downto 0);
  error_log4_1_wstrb        : in   std_logic_vector(3 downto 0);
  error_log4_1_wvalid       : in   std_logic;
  error_log4_1_wready       : out  std_logic;
  error_log4_1_bresp        : out  std_logic_vector(1 downto 0);						
  error_log4_1_bvalid       : out  std_logic;									
  error_log4_1_bready       : in   std_logic;									
  error_log4_1_araddr       : in   std_logic_vector(7 downto 0);						
  error_log4_1_arvalid      : in   std_logic;								
  error_log4_1_arready      : out  std_logic;								
  error_log4_1_arprot       : in   std_logic_vector(2 downto 0);
  error_log4_1_rdata        : out  std_logic_vector(31 downto 0);				
  error_log4_1_rresp        : out  std_logic_vector(1 downto 0);				
  error_log4_1_rvalid       : out  std_logic;							
  error_log4_1_rready       : in   std_logic;
  -- Channel 5 Test AXI Control/Status
  test_ctrl5_0_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl5_0_awvalid      : in   std_logic;
  test_ctrl5_0_awready      : out  std_logic;
  test_ctrl5_0_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl5_0_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl5_0_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl5_0_wvalid       : in   std_logic;
  test_ctrl5_0_wready       : out  std_logic;
  test_ctrl5_0_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl5_0_bvalid       : out  std_logic;									
  test_ctrl5_0_bready       : in   std_logic;									
  test_ctrl5_0_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl5_0_arvalid      : in   std_logic;								
  test_ctrl5_0_arready      : out  std_logic;								
  test_ctrl5_0_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl5_0_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl5_0_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl5_0_rvalid       : out  std_logic;							
  test_ctrl5_0_rready       : in   std_logic;  
  error_log5_0_awaddr       : in   std_logic_vector(7 downto 0);
  error_log5_0_awvalid      : in   std_logic;
  error_log5_0_awready      : out  std_logic;
  error_log5_0_awprot       : in   std_logic_vector(2 downto 0);
  error_log5_0_wdata        : in   std_logic_vector(31 downto 0);
  error_log5_0_wstrb        : in   std_logic_vector(3 downto 0);
  error_log5_0_wvalid       : in   std_logic;
  error_log5_0_wready       : out  std_logic;
  error_log5_0_bresp        : out  std_logic_vector(1 downto 0);						
  error_log5_0_bvalid       : out  std_logic;									
  error_log5_0_bready       : in   std_logic;									
  error_log5_0_araddr       : in   std_logic_vector(7 downto 0);						
  error_log5_0_arvalid      : in   std_logic;								
  error_log5_0_arready      : out  std_logic;								
  error_log5_0_arprot       : in   std_logic_vector(2 downto 0);
  error_log5_0_rdata        : out  std_logic_vector(31 downto 0);				
  error_log5_0_rresp        : out  std_logic_vector(1 downto 0);				
  error_log5_0_rvalid       : out  std_logic;							
  error_log5_0_rready       : in   std_logic;
  test_ctrl5_1_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl5_1_awvalid      : in   std_logic;
  test_ctrl5_1_awready      : out  std_logic;
  test_ctrl5_1_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl5_1_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl5_1_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl5_1_wvalid       : in   std_logic;
  test_ctrl5_1_wready       : out  std_logic;
  test_ctrl5_1_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl5_1_bvalid       : out  std_logic;									
  test_ctrl5_1_bready       : in   std_logic;									
  test_ctrl5_1_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl5_1_arvalid      : in   std_logic;								
  test_ctrl5_1_arready      : out  std_logic;								
  test_ctrl5_1_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl5_1_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl5_1_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl5_1_rvalid       : out  std_logic;							
  test_ctrl5_1_rready       : in   std_logic;  
  error_log5_1_awaddr       : in   std_logic_vector(7 downto 0);
  error_log5_1_awvalid      : in   std_logic;
  error_log5_1_awready      : out  std_logic;
  error_log5_1_awprot       : in   std_logic_vector(2 downto 0);
  error_log5_1_wdata        : in   std_logic_vector(31 downto 0);
  error_log5_1_wstrb        : in   std_logic_vector(3 downto 0);
  error_log5_1_wvalid       : in   std_logic;
  error_log5_1_wready       : out  std_logic;
  error_log5_1_bresp        : out  std_logic_vector(1 downto 0);						
  error_log5_1_bvalid       : out  std_logic;									
  error_log5_1_bready       : in   std_logic;									
  error_log5_1_araddr       : in   std_logic_vector(7 downto 0);						
  error_log5_1_arvalid      : in   std_logic;								
  error_log5_1_arready      : out  std_logic;								
  error_log5_1_arprot       : in   std_logic_vector(2 downto 0);
  error_log5_1_rdata        : out  std_logic_vector(31 downto 0);				
  error_log5_1_rresp        : out  std_logic_vector(1 downto 0);				
  error_log5_1_rvalid       : out  std_logic;							
  error_log5_1_rready       : in   std_logic;
  -- Channel 6 Test AXI Control/Status
  test_ctrl6_0_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl6_0_awvalid      : in   std_logic;
  test_ctrl6_0_awready      : out  std_logic;
  test_ctrl6_0_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl6_0_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl6_0_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl6_0_wvalid       : in   std_logic;
  test_ctrl6_0_wready       : out  std_logic;
  test_ctrl6_0_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl6_0_bvalid       : out  std_logic;									
  test_ctrl6_0_bready       : in   std_logic;									
  test_ctrl6_0_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl6_0_arvalid      : in   std_logic;								
  test_ctrl6_0_arready      : out  std_logic;								
  test_ctrl6_0_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl6_0_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl6_0_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl6_0_rvalid       : out  std_logic;							
  test_ctrl6_0_rready       : in   std_logic;  
  error_log6_0_awaddr       : in   std_logic_vector(7 downto 0);
  error_log6_0_awvalid      : in   std_logic;
  error_log6_0_awready      : out  std_logic;
  error_log6_0_awprot       : in   std_logic_vector(2 downto 0);
  error_log6_0_wdata        : in   std_logic_vector(31 downto 0);
  error_log6_0_wstrb        : in   std_logic_vector(3 downto 0);
  error_log6_0_wvalid       : in   std_logic;
  error_log6_0_wready       : out  std_logic;
  error_log6_0_bresp        : out  std_logic_vector(1 downto 0);						
  error_log6_0_bvalid       : out  std_logic;									
  error_log6_0_bready       : in   std_logic;									
  error_log6_0_araddr       : in   std_logic_vector(7 downto 0);						
  error_log6_0_arvalid      : in   std_logic;								
  error_log6_0_arready      : out  std_logic;								
  error_log6_0_arprot       : in   std_logic_vector(2 downto 0);
  error_log6_0_rdata        : out  std_logic_vector(31 downto 0);				
  error_log6_0_rresp        : out  std_logic_vector(1 downto 0);				
  error_log6_0_rvalid       : out  std_logic;							
  error_log6_0_rready       : in   std_logic;
  test_ctrl6_1_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl6_1_awvalid      : in   std_logic;
  test_ctrl6_1_awready      : out  std_logic;
  test_ctrl6_1_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl6_1_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl6_1_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl6_1_wvalid       : in   std_logic;
  test_ctrl6_1_wready       : out  std_logic;
  test_ctrl6_1_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl6_1_bvalid       : out  std_logic;									
  test_ctrl6_1_bready       : in   std_logic;									
  test_ctrl6_1_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl6_1_arvalid      : in   std_logic;								
  test_ctrl6_1_arready      : out  std_logic;								
  test_ctrl6_1_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl6_1_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl6_1_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl6_1_rvalid       : out  std_logic;							
  test_ctrl6_1_rready       : in   std_logic;  
  error_log6_1_awaddr       : in   std_logic_vector(7 downto 0);
  error_log6_1_awvalid      : in   std_logic;
  error_log6_1_awready      : out  std_logic;
  error_log6_1_awprot       : in   std_logic_vector(2 downto 0);
  error_log6_1_wdata        : in   std_logic_vector(31 downto 0);
  error_log6_1_wstrb        : in   std_logic_vector(3 downto 0);
  error_log6_1_wvalid       : in   std_logic;
  error_log6_1_wready       : out  std_logic;
  error_log6_1_bresp        : out  std_logic_vector(1 downto 0);						
  error_log6_1_bvalid       : out  std_logic;									
  error_log6_1_bready       : in   std_logic;									
  error_log6_1_araddr       : in   std_logic_vector(7 downto 0);						
  error_log6_1_arvalid      : in   std_logic;								
  error_log6_1_arready      : out  std_logic;								
  error_log6_1_arprot       : in   std_logic_vector(2 downto 0);
  error_log6_1_rdata        : out  std_logic_vector(31 downto 0);				
  error_log6_1_rresp        : out  std_logic_vector(1 downto 0);				
  error_log6_1_rvalid       : out  std_logic;							
  error_log6_1_rready       : in   std_logic;
  -- Channel 7 Test AXI Control/Status
  test_ctrl7_0_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl7_0_awvalid      : in   std_logic;
  test_ctrl7_0_awready      : out  std_logic;
  test_ctrl7_0_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl7_0_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl7_0_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl7_0_wvalid       : in   std_logic;
  test_ctrl7_0_wready       : out  std_logic;
  test_ctrl7_0_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl7_0_bvalid       : out  std_logic;									
  test_ctrl7_0_bready       : in   std_logic;									
  test_ctrl7_0_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl7_0_arvalid      : in   std_logic;								
  test_ctrl7_0_arready      : out  std_logic;								
  test_ctrl7_0_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl7_0_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl7_0_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl7_0_rvalid       : out  std_logic;							
  test_ctrl7_0_rready       : in   std_logic;  
  error_log7_0_awaddr       : in   std_logic_vector(7 downto 0);
  error_log7_0_awvalid      : in   std_logic;
  error_log7_0_awready      : out  std_logic;
  error_log7_0_awprot       : in   std_logic_vector(2 downto 0);
  error_log7_0_wdata        : in   std_logic_vector(31 downto 0);
  error_log7_0_wstrb        : in   std_logic_vector(3 downto 0);
  error_log7_0_wvalid       : in   std_logic;
  error_log7_0_wready       : out  std_logic;
  error_log7_0_bresp        : out  std_logic_vector(1 downto 0);						
  error_log7_0_bvalid       : out  std_logic;									
  error_log7_0_bready       : in   std_logic;									
  error_log7_0_araddr       : in   std_logic_vector(7 downto 0);						
  error_log7_0_arvalid      : in   std_logic;								
  error_log7_0_arready      : out  std_logic;								
  error_log7_0_arprot       : in   std_logic_vector(2 downto 0);
  error_log7_0_rdata        : out  std_logic_vector(31 downto 0);				
  error_log7_0_rresp        : out  std_logic_vector(1 downto 0);				
  error_log7_0_rvalid       : out  std_logic;							
  error_log7_0_rready       : in   std_logic;
  test_ctrl7_1_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl7_1_awvalid      : in   std_logic;
  test_ctrl7_1_awready      : out  std_logic;
  test_ctrl7_1_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl7_1_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl7_1_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl7_1_wvalid       : in   std_logic;
  test_ctrl7_1_wready       : out  std_logic;
  test_ctrl7_1_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl7_1_bvalid       : out  std_logic;									
  test_ctrl7_1_bready       : in   std_logic;									
  test_ctrl7_1_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl7_1_arvalid      : in   std_logic;								
  test_ctrl7_1_arready      : out  std_logic;								
  test_ctrl7_1_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl7_1_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl7_1_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl7_1_rvalid       : out  std_logic;							
  test_ctrl7_1_rready       : in   std_logic;  
  error_log7_1_awaddr       : in   std_logic_vector(7 downto 0);
  error_log7_1_awvalid      : in   std_logic;
  error_log7_1_awready      : out  std_logic;
  error_log7_1_awprot       : in   std_logic_vector(2 downto 0);
  error_log7_1_wdata        : in   std_logic_vector(31 downto 0);
  error_log7_1_wstrb        : in   std_logic_vector(3 downto 0);
  error_log7_1_wvalid       : in   std_logic;
  error_log7_1_wready       : out  std_logic;
  error_log7_1_bresp        : out  std_logic_vector(1 downto 0);						
  error_log7_1_bvalid       : out  std_logic;									
  error_log7_1_bready       : in   std_logic;									
  error_log7_1_araddr       : in   std_logic_vector(7 downto 0);						
  error_log7_1_arvalid      : in   std_logic;								
  error_log7_1_arready      : out  std_logic;								
  error_log7_1_arprot       : in   std_logic_vector(2 downto 0);
  error_log7_1_rdata        : out  std_logic_vector(31 downto 0);				
  error_log7_1_rresp        : out  std_logic_vector(1 downto 0);				
  error_log7_1_rvalid       : out  std_logic;							
  error_log7_1_rready       : in   std_logic
  );
end component;

component hbm2e_lower_test
generic (
  TEST_CTRL_CLK_PERIOD      :      integer := 10
  );
port (
  -- System Clock (Drives AXI Interface)
  sys_clk                   : in   std_logic;
  sys_reset                 : in   std_logic;
  -- HBM2e Reference Clock
  hbm2e_refclk              : in   std_logic;
  hbm2e_cattrip_in          : in   std_logic;
  hbm2e_temp_in             : in   std_logic_vector(2 downto 0);
  -- HBM2e Initiator Clock 
  initiator_clk             : in   std_logic;
  -- HBM2e User Clock & Reset
  mem_usr_clk               : in   std_logic;
  mem_usr_reset             : in   std_logic_vector(15 downto 0);
  -- Channel 0 Test AXI Control/Status
  test_ctrl0_0_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl0_0_awvalid      : in   std_logic;
  test_ctrl0_0_awready      : out  std_logic;
  test_ctrl0_0_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl0_0_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl0_0_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl0_0_wvalid       : in   std_logic;
  test_ctrl0_0_wready       : out  std_logic;
  test_ctrl0_0_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl0_0_bvalid       : out  std_logic;									
  test_ctrl0_0_bready       : in   std_logic;									
  test_ctrl0_0_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl0_0_arvalid      : in   std_logic;								
  test_ctrl0_0_arready      : out  std_logic;								
  test_ctrl0_0_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl0_0_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl0_0_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl0_0_rvalid       : out  std_logic;							
  test_ctrl0_0_rready       : in   std_logic;  
  error_log0_0_awaddr       : in   std_logic_vector(7 downto 0);
  error_log0_0_awvalid      : in   std_logic;
  error_log0_0_awready      : out  std_logic;
  error_log0_0_awprot       : in   std_logic_vector(2 downto 0);
  error_log0_0_wdata        : in   std_logic_vector(31 downto 0);
  error_log0_0_wstrb        : in   std_logic_vector(3 downto 0);
  error_log0_0_wvalid       : in   std_logic;
  error_log0_0_wready       : out  std_logic;
  error_log0_0_bresp        : out  std_logic_vector(1 downto 0);						
  error_log0_0_bvalid       : out  std_logic;									
  error_log0_0_bready       : in   std_logic;									
  error_log0_0_araddr       : in   std_logic_vector(7 downto 0);						
  error_log0_0_arvalid      : in   std_logic;								
  error_log0_0_arready      : out  std_logic;								
  error_log0_0_arprot       : in   std_logic_vector(2 downto 0);
  error_log0_0_rdata        : out  std_logic_vector(31 downto 0);				
  error_log0_0_rresp        : out  std_logic_vector(1 downto 0);				
  error_log0_0_rvalid       : out  std_logic;							
  error_log0_0_rready       : in   std_logic;
  test_ctrl0_1_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl0_1_awvalid      : in   std_logic;
  test_ctrl0_1_awready      : out  std_logic;
  test_ctrl0_1_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl0_1_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl0_1_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl0_1_wvalid       : in   std_logic;
  test_ctrl0_1_wready       : out  std_logic;
  test_ctrl0_1_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl0_1_bvalid       : out  std_logic;									
  test_ctrl0_1_bready       : in   std_logic;									
  test_ctrl0_1_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl0_1_arvalid      : in   std_logic;								
  test_ctrl0_1_arready      : out  std_logic;								
  test_ctrl0_1_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl0_1_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl0_1_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl0_1_rvalid       : out  std_logic;							
  test_ctrl0_1_rready       : in   std_logic;  
  error_log0_1_awaddr       : in   std_logic_vector(7 downto 0);
  error_log0_1_awvalid      : in   std_logic;
  error_log0_1_awready      : out  std_logic;
  error_log0_1_awprot       : in   std_logic_vector(2 downto 0);
  error_log0_1_wdata        : in   std_logic_vector(31 downto 0);
  error_log0_1_wstrb        : in   std_logic_vector(3 downto 0);
  error_log0_1_wvalid       : in   std_logic;
  error_log0_1_wready       : out  std_logic;
  error_log0_1_bresp        : out  std_logic_vector(1 downto 0);						
  error_log0_1_bvalid       : out  std_logic;									
  error_log0_1_bready       : in   std_logic;									
  error_log0_1_araddr       : in   std_logic_vector(7 downto 0);						
  error_log0_1_arvalid      : in   std_logic;								
  error_log0_1_arready      : out  std_logic;								
  error_log0_1_arprot       : in   std_logic_vector(2 downto 0);
  error_log0_1_rdata        : out  std_logic_vector(31 downto 0);				
  error_log0_1_rresp        : out  std_logic_vector(1 downto 0);				
  error_log0_1_rvalid       : out  std_logic;							
  error_log0_1_rready       : in   std_logic;
  -- Channel 1 Test AXI Control/Status
  test_ctrl1_0_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl1_0_awvalid      : in   std_logic;
  test_ctrl1_0_awready      : out  std_logic;
  test_ctrl1_0_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl1_0_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl1_0_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl1_0_wvalid       : in   std_logic;
  test_ctrl1_0_wready       : out  std_logic;
  test_ctrl1_0_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl1_0_bvalid       : out  std_logic;									
  test_ctrl1_0_bready       : in   std_logic;									
  test_ctrl1_0_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl1_0_arvalid      : in   std_logic;								
  test_ctrl1_0_arready      : out  std_logic;								
  test_ctrl1_0_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl1_0_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl1_0_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl1_0_rvalid       : out  std_logic;							
  test_ctrl1_0_rready       : in   std_logic;  
  error_log1_0_awaddr       : in   std_logic_vector(7 downto 0);
  error_log1_0_awvalid      : in   std_logic;
  error_log1_0_awready      : out  std_logic;
  error_log1_0_awprot       : in   std_logic_vector(2 downto 0);
  error_log1_0_wdata        : in   std_logic_vector(31 downto 0);
  error_log1_0_wstrb        : in   std_logic_vector(3 downto 0);
  error_log1_0_wvalid       : in   std_logic;
  error_log1_0_wready       : out  std_logic;
  error_log1_0_bresp        : out  std_logic_vector(1 downto 0);						
  error_log1_0_bvalid       : out  std_logic;									
  error_log1_0_bready       : in   std_logic;									
  error_log1_0_araddr       : in   std_logic_vector(7 downto 0);						
  error_log1_0_arvalid      : in   std_logic;								
  error_log1_0_arready      : out  std_logic;								
  error_log1_0_arprot       : in   std_logic_vector(2 downto 0);
  error_log1_0_rdata        : out  std_logic_vector(31 downto 0);				
  error_log1_0_rresp        : out  std_logic_vector(1 downto 0);				
  error_log1_0_rvalid       : out  std_logic;							
  error_log1_0_rready       : in   std_logic;
  test_ctrl1_1_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl1_1_awvalid      : in   std_logic;
  test_ctrl1_1_awready      : out  std_logic;
  test_ctrl1_1_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl1_1_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl1_1_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl1_1_wvalid       : in   std_logic;
  test_ctrl1_1_wready       : out  std_logic;
  test_ctrl1_1_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl1_1_bvalid       : out  std_logic;									
  test_ctrl1_1_bready       : in   std_logic;									
  test_ctrl1_1_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl1_1_arvalid      : in   std_logic;								
  test_ctrl1_1_arready      : out  std_logic;								
  test_ctrl1_1_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl1_1_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl1_1_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl1_1_rvalid       : out  std_logic;							
  test_ctrl1_1_rready       : in   std_logic;  
  error_log1_1_awaddr       : in   std_logic_vector(7 downto 0);
  error_log1_1_awvalid      : in   std_logic;
  error_log1_1_awready      : out  std_logic;
  error_log1_1_awprot       : in   std_logic_vector(2 downto 0);
  error_log1_1_wdata        : in   std_logic_vector(31 downto 0);
  error_log1_1_wstrb        : in   std_logic_vector(3 downto 0);
  error_log1_1_wvalid       : in   std_logic;
  error_log1_1_wready       : out  std_logic;
  error_log1_1_bresp        : out  std_logic_vector(1 downto 0);						
  error_log1_1_bvalid       : out  std_logic;									
  error_log1_1_bready       : in   std_logic;									
  error_log1_1_araddr       : in   std_logic_vector(7 downto 0);						
  error_log1_1_arvalid      : in   std_logic;								
  error_log1_1_arready      : out  std_logic;								
  error_log1_1_arprot       : in   std_logic_vector(2 downto 0);
  error_log1_1_rdata        : out  std_logic_vector(31 downto 0);				
  error_log1_1_rresp        : out  std_logic_vector(1 downto 0);				
  error_log1_1_rvalid       : out  std_logic;							
  error_log1_1_rready       : in   std_logic;
  -- Channel 2 Test AXI Control/Status
  test_ctrl2_0_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl2_0_awvalid      : in   std_logic;
  test_ctrl2_0_awready      : out  std_logic;
  test_ctrl2_0_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl2_0_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl2_0_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl2_0_wvalid       : in   std_logic;
  test_ctrl2_0_wready       : out  std_logic;
  test_ctrl2_0_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl2_0_bvalid       : out  std_logic;									
  test_ctrl2_0_bready       : in   std_logic;									
  test_ctrl2_0_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl2_0_arvalid      : in   std_logic;								
  test_ctrl2_0_arready      : out  std_logic;								
  test_ctrl2_0_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl2_0_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl2_0_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl2_0_rvalid       : out  std_logic;							
  test_ctrl2_0_rready       : in   std_logic;  
  error_log2_0_awaddr       : in   std_logic_vector(7 downto 0);
  error_log2_0_awvalid      : in   std_logic;
  error_log2_0_awready      : out  std_logic;
  error_log2_0_awprot       : in   std_logic_vector(2 downto 0);
  error_log2_0_wdata        : in   std_logic_vector(31 downto 0);
  error_log2_0_wstrb        : in   std_logic_vector(3 downto 0);
  error_log2_0_wvalid       : in   std_logic;
  error_log2_0_wready       : out  std_logic;
  error_log2_0_bresp        : out  std_logic_vector(1 downto 0);						
  error_log2_0_bvalid       : out  std_logic;									
  error_log2_0_bready       : in   std_logic;									
  error_log2_0_araddr       : in   std_logic_vector(7 downto 0);						
  error_log2_0_arvalid      : in   std_logic;								
  error_log2_0_arready      : out  std_logic;								
  error_log2_0_arprot       : in   std_logic_vector(2 downto 0);
  error_log2_0_rdata        : out  std_logic_vector(31 downto 0);				
  error_log2_0_rresp        : out  std_logic_vector(1 downto 0);				
  error_log2_0_rvalid       : out  std_logic;							
  error_log2_0_rready       : in   std_logic;
  test_ctrl2_1_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl2_1_awvalid      : in   std_logic;
  test_ctrl2_1_awready      : out  std_logic;
  test_ctrl2_1_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl2_1_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl2_1_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl2_1_wvalid       : in   std_logic;
  test_ctrl2_1_wready       : out  std_logic;
  test_ctrl2_1_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl2_1_bvalid       : out  std_logic;									
  test_ctrl2_1_bready       : in   std_logic;									
  test_ctrl2_1_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl2_1_arvalid      : in   std_logic;								
  test_ctrl2_1_arready      : out  std_logic;								
  test_ctrl2_1_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl2_1_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl2_1_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl2_1_rvalid       : out  std_logic;							
  test_ctrl2_1_rready       : in   std_logic;  
  error_log2_1_awaddr       : in   std_logic_vector(7 downto 0);
  error_log2_1_awvalid      : in   std_logic;
  error_log2_1_awready      : out  std_logic;
  error_log2_1_awprot       : in   std_logic_vector(2 downto 0);
  error_log2_1_wdata        : in   std_logic_vector(31 downto 0);
  error_log2_1_wstrb        : in   std_logic_vector(3 downto 0);
  error_log2_1_wvalid       : in   std_logic;
  error_log2_1_wready       : out  std_logic;
  error_log2_1_bresp        : out  std_logic_vector(1 downto 0);						
  error_log2_1_bvalid       : out  std_logic;									
  error_log2_1_bready       : in   std_logic;									
  error_log2_1_araddr       : in   std_logic_vector(7 downto 0);						
  error_log2_1_arvalid      : in   std_logic;								
  error_log2_1_arready      : out  std_logic;								
  error_log2_1_arprot       : in   std_logic_vector(2 downto 0);
  error_log2_1_rdata        : out  std_logic_vector(31 downto 0);				
  error_log2_1_rresp        : out  std_logic_vector(1 downto 0);				
  error_log2_1_rvalid       : out  std_logic;							
  error_log2_1_rready       : in   std_logic;
  -- Channel 3 Test AXI Control/Status
  test_ctrl3_0_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl3_0_awvalid      : in   std_logic;
  test_ctrl3_0_awready      : out  std_logic;
  test_ctrl3_0_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl3_0_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl3_0_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl3_0_wvalid       : in   std_logic;
  test_ctrl3_0_wready       : out  std_logic;
  test_ctrl3_0_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl3_0_bvalid       : out  std_logic;									
  test_ctrl3_0_bready       : in   std_logic;									
  test_ctrl3_0_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl3_0_arvalid      : in   std_logic;								
  test_ctrl3_0_arready      : out  std_logic;								
  test_ctrl3_0_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl3_0_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl3_0_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl3_0_rvalid       : out  std_logic;							
  test_ctrl3_0_rready       : in   std_logic;  
  error_log3_0_awaddr       : in   std_logic_vector(7 downto 0);
  error_log3_0_awvalid      : in   std_logic;
  error_log3_0_awready      : out  std_logic;
  error_log3_0_awprot       : in   std_logic_vector(2 downto 0);
  error_log3_0_wdata        : in   std_logic_vector(31 downto 0);
  error_log3_0_wstrb        : in   std_logic_vector(3 downto 0);
  error_log3_0_wvalid       : in   std_logic;
  error_log3_0_wready       : out  std_logic;
  error_log3_0_bresp        : out  std_logic_vector(1 downto 0);						
  error_log3_0_bvalid       : out  std_logic;									
  error_log3_0_bready       : in   std_logic;									
  error_log3_0_araddr       : in   std_logic_vector(7 downto 0);						
  error_log3_0_arvalid      : in   std_logic;								
  error_log3_0_arready      : out  std_logic;								
  error_log3_0_arprot       : in   std_logic_vector(2 downto 0);
  error_log3_0_rdata        : out  std_logic_vector(31 downto 0);				
  error_log3_0_rresp        : out  std_logic_vector(1 downto 0);				
  error_log3_0_rvalid       : out  std_logic;							
  error_log3_0_rready       : in   std_logic;
  test_ctrl3_1_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl3_1_awvalid      : in   std_logic;
  test_ctrl3_1_awready      : out  std_logic;
  test_ctrl3_1_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl3_1_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl3_1_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl3_1_wvalid       : in   std_logic;
  test_ctrl3_1_wready       : out  std_logic;
  test_ctrl3_1_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl3_1_bvalid       : out  std_logic;									
  test_ctrl3_1_bready       : in   std_logic;									
  test_ctrl3_1_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl3_1_arvalid      : in   std_logic;								
  test_ctrl3_1_arready      : out  std_logic;								
  test_ctrl3_1_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl3_1_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl3_1_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl3_1_rvalid       : out  std_logic;							
  test_ctrl3_1_rready       : in   std_logic;  
  error_log3_1_awaddr       : in   std_logic_vector(7 downto 0);
  error_log3_1_awvalid      : in   std_logic;
  error_log3_1_awready      : out  std_logic;
  error_log3_1_awprot       : in   std_logic_vector(2 downto 0);
  error_log3_1_wdata        : in   std_logic_vector(31 downto 0);
  error_log3_1_wstrb        : in   std_logic_vector(3 downto 0);
  error_log3_1_wvalid       : in   std_logic;
  error_log3_1_wready       : out  std_logic;
  error_log3_1_bresp        : out  std_logic_vector(1 downto 0);						
  error_log3_1_bvalid       : out  std_logic;									
  error_log3_1_bready       : in   std_logic;									
  error_log3_1_araddr       : in   std_logic_vector(7 downto 0);						
  error_log3_1_arvalid      : in   std_logic;								
  error_log3_1_arready      : out  std_logic;								
  error_log3_1_arprot       : in   std_logic_vector(2 downto 0);
  error_log3_1_rdata        : out  std_logic_vector(31 downto 0);				
  error_log3_1_rresp        : out  std_logic_vector(1 downto 0);				
  error_log3_1_rvalid       : out  std_logic;							
  error_log3_1_rready       : in   std_logic;
  -- Channel 4 Test AXI Control/Status
  test_ctrl4_0_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl4_0_awvalid      : in   std_logic;
  test_ctrl4_0_awready      : out  std_logic;
  test_ctrl4_0_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl4_0_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl4_0_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl4_0_wvalid       : in   std_logic;
  test_ctrl4_0_wready       : out  std_logic;
  test_ctrl4_0_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl4_0_bvalid       : out  std_logic;									
  test_ctrl4_0_bready       : in   std_logic;									
  test_ctrl4_0_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl4_0_arvalid      : in   std_logic;								
  test_ctrl4_0_arready      : out  std_logic;								
  test_ctrl4_0_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl4_0_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl4_0_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl4_0_rvalid       : out  std_logic;							
  test_ctrl4_0_rready       : in   std_logic;  
  error_log4_0_awaddr       : in   std_logic_vector(7 downto 0);
  error_log4_0_awvalid      : in   std_logic;
  error_log4_0_awready      : out  std_logic;
  error_log4_0_awprot       : in   std_logic_vector(2 downto 0);
  error_log4_0_wdata        : in   std_logic_vector(31 downto 0);
  error_log4_0_wstrb        : in   std_logic_vector(3 downto 0);
  error_log4_0_wvalid       : in   std_logic;
  error_log4_0_wready       : out  std_logic;
  error_log4_0_bresp        : out  std_logic_vector(1 downto 0);						
  error_log4_0_bvalid       : out  std_logic;									
  error_log4_0_bready       : in   std_logic;									
  error_log4_0_araddr       : in   std_logic_vector(7 downto 0);						
  error_log4_0_arvalid      : in   std_logic;								
  error_log4_0_arready      : out  std_logic;								
  error_log4_0_arprot       : in   std_logic_vector(2 downto 0);
  error_log4_0_rdata        : out  std_logic_vector(31 downto 0);				
  error_log4_0_rresp        : out  std_logic_vector(1 downto 0);				
  error_log4_0_rvalid       : out  std_logic;							
  error_log4_0_rready       : in   std_logic;
  test_ctrl4_1_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl4_1_awvalid      : in   std_logic;
  test_ctrl4_1_awready      : out  std_logic;
  test_ctrl4_1_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl4_1_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl4_1_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl4_1_wvalid       : in   std_logic;
  test_ctrl4_1_wready       : out  std_logic;
  test_ctrl4_1_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl4_1_bvalid       : out  std_logic;									
  test_ctrl4_1_bready       : in   std_logic;									
  test_ctrl4_1_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl4_1_arvalid      : in   std_logic;								
  test_ctrl4_1_arready      : out  std_logic;								
  test_ctrl4_1_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl4_1_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl4_1_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl4_1_rvalid       : out  std_logic;							
  test_ctrl4_1_rready       : in   std_logic;  
  error_log4_1_awaddr       : in   std_logic_vector(7 downto 0);
  error_log4_1_awvalid      : in   std_logic;
  error_log4_1_awready      : out  std_logic;
  error_log4_1_awprot       : in   std_logic_vector(2 downto 0);
  error_log4_1_wdata        : in   std_logic_vector(31 downto 0);
  error_log4_1_wstrb        : in   std_logic_vector(3 downto 0);
  error_log4_1_wvalid       : in   std_logic;
  error_log4_1_wready       : out  std_logic;
  error_log4_1_bresp        : out  std_logic_vector(1 downto 0);						
  error_log4_1_bvalid       : out  std_logic;									
  error_log4_1_bready       : in   std_logic;									
  error_log4_1_araddr       : in   std_logic_vector(7 downto 0);						
  error_log4_1_arvalid      : in   std_logic;								
  error_log4_1_arready      : out  std_logic;								
  error_log4_1_arprot       : in   std_logic_vector(2 downto 0);
  error_log4_1_rdata        : out  std_logic_vector(31 downto 0);				
  error_log4_1_rresp        : out  std_logic_vector(1 downto 0);				
  error_log4_1_rvalid       : out  std_logic;							
  error_log4_1_rready       : in   std_logic;
  -- Channel 5 Test AXI Control/Status
  test_ctrl5_0_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl5_0_awvalid      : in   std_logic;
  test_ctrl5_0_awready      : out  std_logic;
  test_ctrl5_0_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl5_0_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl5_0_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl5_0_wvalid       : in   std_logic;
  test_ctrl5_0_wready       : out  std_logic;
  test_ctrl5_0_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl5_0_bvalid       : out  std_logic;									
  test_ctrl5_0_bready       : in   std_logic;									
  test_ctrl5_0_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl5_0_arvalid      : in   std_logic;								
  test_ctrl5_0_arready      : out  std_logic;								
  test_ctrl5_0_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl5_0_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl5_0_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl5_0_rvalid       : out  std_logic;							
  test_ctrl5_0_rready       : in   std_logic;  
  error_log5_0_awaddr       : in   std_logic_vector(7 downto 0);
  error_log5_0_awvalid      : in   std_logic;
  error_log5_0_awready      : out  std_logic;
  error_log5_0_awprot       : in   std_logic_vector(2 downto 0);
  error_log5_0_wdata        : in   std_logic_vector(31 downto 0);
  error_log5_0_wstrb        : in   std_logic_vector(3 downto 0);
  error_log5_0_wvalid       : in   std_logic;
  error_log5_0_wready       : out  std_logic;
  error_log5_0_bresp        : out  std_logic_vector(1 downto 0);						
  error_log5_0_bvalid       : out  std_logic;									
  error_log5_0_bready       : in   std_logic;									
  error_log5_0_araddr       : in   std_logic_vector(7 downto 0);						
  error_log5_0_arvalid      : in   std_logic;								
  error_log5_0_arready      : out  std_logic;								
  error_log5_0_arprot       : in   std_logic_vector(2 downto 0);
  error_log5_0_rdata        : out  std_logic_vector(31 downto 0);				
  error_log5_0_rresp        : out  std_logic_vector(1 downto 0);				
  error_log5_0_rvalid       : out  std_logic;							
  error_log5_0_rready       : in   std_logic;
  test_ctrl5_1_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl5_1_awvalid      : in   std_logic;
  test_ctrl5_1_awready      : out  std_logic;
  test_ctrl5_1_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl5_1_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl5_1_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl5_1_wvalid       : in   std_logic;
  test_ctrl5_1_wready       : out  std_logic;
  test_ctrl5_1_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl5_1_bvalid       : out  std_logic;									
  test_ctrl5_1_bready       : in   std_logic;									
  test_ctrl5_1_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl5_1_arvalid      : in   std_logic;								
  test_ctrl5_1_arready      : out  std_logic;								
  test_ctrl5_1_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl5_1_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl5_1_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl5_1_rvalid       : out  std_logic;							
  test_ctrl5_1_rready       : in   std_logic;  
  error_log5_1_awaddr       : in   std_logic_vector(7 downto 0);
  error_log5_1_awvalid      : in   std_logic;
  error_log5_1_awready      : out  std_logic;
  error_log5_1_awprot       : in   std_logic_vector(2 downto 0);
  error_log5_1_wdata        : in   std_logic_vector(31 downto 0);
  error_log5_1_wstrb        : in   std_logic_vector(3 downto 0);
  error_log5_1_wvalid       : in   std_logic;
  error_log5_1_wready       : out  std_logic;
  error_log5_1_bresp        : out  std_logic_vector(1 downto 0);						
  error_log5_1_bvalid       : out  std_logic;									
  error_log5_1_bready       : in   std_logic;									
  error_log5_1_araddr       : in   std_logic_vector(7 downto 0);						
  error_log5_1_arvalid      : in   std_logic;								
  error_log5_1_arready      : out  std_logic;								
  error_log5_1_arprot       : in   std_logic_vector(2 downto 0);
  error_log5_1_rdata        : out  std_logic_vector(31 downto 0);				
  error_log5_1_rresp        : out  std_logic_vector(1 downto 0);				
  error_log5_1_rvalid       : out  std_logic;							
  error_log5_1_rready       : in   std_logic;
  -- Channel 6 Test AXI Control/Status
  test_ctrl6_0_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl6_0_awvalid      : in   std_logic;
  test_ctrl6_0_awready      : out  std_logic;
  test_ctrl6_0_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl6_0_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl6_0_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl6_0_wvalid       : in   std_logic;
  test_ctrl6_0_wready       : out  std_logic;
  test_ctrl6_0_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl6_0_bvalid       : out  std_logic;									
  test_ctrl6_0_bready       : in   std_logic;									
  test_ctrl6_0_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl6_0_arvalid      : in   std_logic;								
  test_ctrl6_0_arready      : out  std_logic;								
  test_ctrl6_0_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl6_0_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl6_0_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl6_0_rvalid       : out  std_logic;							
  test_ctrl6_0_rready       : in   std_logic;  
  error_log6_0_awaddr       : in   std_logic_vector(7 downto 0);
  error_log6_0_awvalid      : in   std_logic;
  error_log6_0_awready      : out  std_logic;
  error_log6_0_awprot       : in   std_logic_vector(2 downto 0);
  error_log6_0_wdata        : in   std_logic_vector(31 downto 0);
  error_log6_0_wstrb        : in   std_logic_vector(3 downto 0);
  error_log6_0_wvalid       : in   std_logic;
  error_log6_0_wready       : out  std_logic;
  error_log6_0_bresp        : out  std_logic_vector(1 downto 0);						
  error_log6_0_bvalid       : out  std_logic;									
  error_log6_0_bready       : in   std_logic;									
  error_log6_0_araddr       : in   std_logic_vector(7 downto 0);						
  error_log6_0_arvalid      : in   std_logic;								
  error_log6_0_arready      : out  std_logic;								
  error_log6_0_arprot       : in   std_logic_vector(2 downto 0);
  error_log6_0_rdata        : out  std_logic_vector(31 downto 0);				
  error_log6_0_rresp        : out  std_logic_vector(1 downto 0);				
  error_log6_0_rvalid       : out  std_logic;							
  error_log6_0_rready       : in   std_logic;
  test_ctrl6_1_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl6_1_awvalid      : in   std_logic;
  test_ctrl6_1_awready      : out  std_logic;
  test_ctrl6_1_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl6_1_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl6_1_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl6_1_wvalid       : in   std_logic;
  test_ctrl6_1_wready       : out  std_logic;
  test_ctrl6_1_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl6_1_bvalid       : out  std_logic;									
  test_ctrl6_1_bready       : in   std_logic;									
  test_ctrl6_1_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl6_1_arvalid      : in   std_logic;								
  test_ctrl6_1_arready      : out  std_logic;								
  test_ctrl6_1_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl6_1_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl6_1_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl6_1_rvalid       : out  std_logic;							
  test_ctrl6_1_rready       : in   std_logic;  
  error_log6_1_awaddr       : in   std_logic_vector(7 downto 0);
  error_log6_1_awvalid      : in   std_logic;
  error_log6_1_awready      : out  std_logic;
  error_log6_1_awprot       : in   std_logic_vector(2 downto 0);
  error_log6_1_wdata        : in   std_logic_vector(31 downto 0);
  error_log6_1_wstrb        : in   std_logic_vector(3 downto 0);
  error_log6_1_wvalid       : in   std_logic;
  error_log6_1_wready       : out  std_logic;
  error_log6_1_bresp        : out  std_logic_vector(1 downto 0);						
  error_log6_1_bvalid       : out  std_logic;									
  error_log6_1_bready       : in   std_logic;									
  error_log6_1_araddr       : in   std_logic_vector(7 downto 0);						
  error_log6_1_arvalid      : in   std_logic;								
  error_log6_1_arready      : out  std_logic;								
  error_log6_1_arprot       : in   std_logic_vector(2 downto 0);
  error_log6_1_rdata        : out  std_logic_vector(31 downto 0);				
  error_log6_1_rresp        : out  std_logic_vector(1 downto 0);				
  error_log6_1_rvalid       : out  std_logic;							
  error_log6_1_rready       : in   std_logic;
  -- Channel 7 Test AXI Control/Status
  test_ctrl7_0_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl7_0_awvalid      : in   std_logic;
  test_ctrl7_0_awready      : out  std_logic;
  test_ctrl7_0_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl7_0_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl7_0_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl7_0_wvalid       : in   std_logic;
  test_ctrl7_0_wready       : out  std_logic;
  test_ctrl7_0_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl7_0_bvalid       : out  std_logic;									
  test_ctrl7_0_bready       : in   std_logic;									
  test_ctrl7_0_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl7_0_arvalid      : in   std_logic;								
  test_ctrl7_0_arready      : out  std_logic;								
  test_ctrl7_0_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl7_0_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl7_0_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl7_0_rvalid       : out  std_logic;							
  test_ctrl7_0_rready       : in   std_logic;  
  error_log7_0_awaddr       : in   std_logic_vector(7 downto 0);
  error_log7_0_awvalid      : in   std_logic;
  error_log7_0_awready      : out  std_logic;
  error_log7_0_awprot       : in   std_logic_vector(2 downto 0);
  error_log7_0_wdata        : in   std_logic_vector(31 downto 0);
  error_log7_0_wstrb        : in   std_logic_vector(3 downto 0);
  error_log7_0_wvalid       : in   std_logic;
  error_log7_0_wready       : out  std_logic;
  error_log7_0_bresp        : out  std_logic_vector(1 downto 0);						
  error_log7_0_bvalid       : out  std_logic;									
  error_log7_0_bready       : in   std_logic;									
  error_log7_0_araddr       : in   std_logic_vector(7 downto 0);						
  error_log7_0_arvalid      : in   std_logic;								
  error_log7_0_arready      : out  std_logic;								
  error_log7_0_arprot       : in   std_logic_vector(2 downto 0);
  error_log7_0_rdata        : out  std_logic_vector(31 downto 0);				
  error_log7_0_rresp        : out  std_logic_vector(1 downto 0);				
  error_log7_0_rvalid       : out  std_logic;							
  error_log7_0_rready       : in   std_logic;
  test_ctrl7_1_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl7_1_awvalid      : in   std_logic;
  test_ctrl7_1_awready      : out  std_logic;
  test_ctrl7_1_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl7_1_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl7_1_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl7_1_wvalid       : in   std_logic;
  test_ctrl7_1_wready       : out  std_logic;
  test_ctrl7_1_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl7_1_bvalid       : out  std_logic;									
  test_ctrl7_1_bready       : in   std_logic;									
  test_ctrl7_1_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl7_1_arvalid      : in   std_logic;								
  test_ctrl7_1_arready      : out  std_logic;								
  test_ctrl7_1_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl7_1_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl7_1_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl7_1_rvalid       : out  std_logic;							
  test_ctrl7_1_rready       : in   std_logic;  
  error_log7_1_awaddr       : in   std_logic_vector(7 downto 0);
  error_log7_1_awvalid      : in   std_logic;
  error_log7_1_awready      : out  std_logic;
  error_log7_1_awprot       : in   std_logic_vector(2 downto 0);
  error_log7_1_wdata        : in   std_logic_vector(31 downto 0);
  error_log7_1_wstrb        : in   std_logic_vector(3 downto 0);
  error_log7_1_wvalid       : in   std_logic;
  error_log7_1_wready       : out  std_logic;
  error_log7_1_bresp        : out  std_logic_vector(1 downto 0);						
  error_log7_1_bvalid       : out  std_logic;									
  error_log7_1_bready       : in   std_logic;									
  error_log7_1_araddr       : in   std_logic_vector(7 downto 0);						
  error_log7_1_arvalid      : in   std_logic;								
  error_log7_1_arready      : out  std_logic;								
  error_log7_1_arprot       : in   std_logic_vector(2 downto 0);
  error_log7_1_rdata        : out  std_logic_vector(31 downto 0);				
  error_log7_1_rresp        : out  std_logic_vector(1 downto 0);				
  error_log7_1_rvalid       : out  std_logic;							
  error_log7_1_rready       : in   std_logic
  );
end component;

component hps_dram_test
generic (
  TEST_CTRL_CLK_PERIOD      :      integer := 10
  );
port (
  ref_clk                   : in    std_logic;                                
  mem_ck_t                  : out   std_logic;                                        
  mem_ck_c                  : out   std_logic;                                        
  mem_cke                   : out   std_logic;                                        
  mem_odt                   : out   std_logic;                                        
  mem_cs_n                  : out   std_logic;                                        
  mem_a                     : out   std_logic_vector(16 downto 0);                    
  mem_ba                    : out   std_logic_vector(1 downto 0);                     
  mem_bg                    : out   std_logic;                                        
  mem_act_n                 : out   std_logic;                                        
  mem_par                   : out   std_logic;                                        
  mem_alert_n               : in    std_logic;                                 
  mem_reset_n               : out   std_logic;                                        
  mem_dq                    : inout std_logic_vector(39 downto 0); 
  mem_dqs_t                 : inout std_logic_vector(4 downto 0); 
  mem_dqs_c                 : inout std_logic_vector(4 downto 0); 
  mem_dbi_n                 : inout std_logic_vector(4 downto 0); 
  oct_rzqin                 : in    std_logic;                     
  sys_clk                   : in   std_logic;
  sys_reset                 : in   std_logic;
  initiator_clk             : in   std_logic;
  mem_usr_clk               : in   std_logic;
  mem_usr_reset             : in   std_logic;
  test_ctrl_awaddr          : in   std_logic_vector(5 downto 0);
  test_ctrl_awvalid         : in   std_logic;
  test_ctrl_awready         : out  std_logic;
  test_ctrl_awprot          : in   std_logic_vector(2 downto 0);
  test_ctrl_wdata           : in   std_logic_vector(31 downto 0);
  test_ctrl_wstrb           : in   std_logic_vector(3 downto 0);
  test_ctrl_wvalid          : in   std_logic;
  test_ctrl_wready          : out  std_logic;
  test_ctrl_bresp           : out  std_logic_vector(1 downto 0);						
  test_ctrl_bvalid          : out  std_logic;									
  test_ctrl_bready          : in   std_logic;									
  test_ctrl_araddr          : in   std_logic_vector(5 downto 0);						
  test_ctrl_arvalid         : in   std_logic;								
  test_ctrl_arready         : out  std_logic;								
  test_ctrl_arprot          : in   std_logic_vector(2 downto 0);
  test_ctrl_rdata           : out  std_logic_vector(31 downto 0);				
  test_ctrl_rresp           : out  std_logic_vector(1 downto 0);				
  test_ctrl_rvalid          : out  std_logic;							
  test_ctrl_rready          : in   std_logic;  
  error_log_awaddr          : in   std_logic_vector(7 downto 0);
  error_log_awvalid         : in   std_logic;
  error_log_awready         : out  std_logic;
  error_log_awprot          : in   std_logic_vector(2 downto 0);
  error_log_wdata           : in   std_logic_vector(31 downto 0);
  error_log_wstrb           : in   std_logic_vector(3 downto 0);
  error_log_wvalid          : in   std_logic;
  error_log_wready          : out  std_logic;
  error_log_bresp           : out  std_logic_vector(1 downto 0);						
  error_log_bvalid          : out  std_logic;									
  error_log_bready          : in   std_logic;									
  error_log_araddr          : in   std_logic_vector(7 downto 0);						
  error_log_arvalid         : in   std_logic;								
  error_log_arready         : out  std_logic;								
  error_log_arprot          : in   std_logic_vector(2 downto 0);
  error_log_rdata           : out  std_logic_vector(31 downto 0);				
  error_log_rresp           : out  std_logic_vector(1 downto 0);				
  error_log_rvalid          : out  std_logic;							
  error_log_rready          : in   std_logic
  );
end component;

component telemetry_test
generic (
  QSFPDD_NUM                      :      integer range 1 to 3 := 1
  );
port (
  aclk                            : in   std_logic;
  areset                          : in   std_logic;
  awaddr                          : in   std_logic_vector(11 downto 0);
  awvalid                         : in   std_logic;
  awready                         : out  std_logic;
  awprot                          : in   std_logic_vector(2 downto 0);
  wdata                           : in   std_logic_vector(31 downto 0);
  wstrb                           : in   std_logic_vector(3 downto 0);
  wvalid                          : in   std_logic;
  wready                          : out  std_logic;
  bresp                           : out  std_logic_vector(1 downto 0);						
  bvalid                          : out  std_logic;									
  bready                          : in   std_logic;									
  araddr                          : in   std_logic_vector(11 downto 0);						
  arvalid                         : in   std_logic;								
  arready                         : out  std_logic;								
  arprot                          : in   std_logic_vector(2 downto 0);
  rdata                           : out  std_logic_vector(31 downto 0);				
  rresp                           : out  std_logic_vector(1 downto 0);				
  rvalid                          : out  std_logic;							
  rready                          : in   std_logic;							
  qsfpdd0_rst_n                   : out  std_logic;
  qsfpdd0_lpmode                  : out  std_logic;
  qsfpdd0_int_n                   : in   std_logic;
  qsfpdd0_present_n               : in   std_logic;
  qsfpdd1_rst_n                   : out  std_logic;
  qsfpdd1_lpmode                  : out  std_logic;
  qsfpdd1_int_n                   : in   std_logic;
  qsfpdd1_present_n               : in   std_logic;
  qsfpdd2_rst_n                   : out  std_logic;
  qsfpdd2_lpmode                  : out  std_logic;
  qsfpdd2_int_n                   : in   std_logic;
  qsfpdd2_present_n               : in   std_logic;  
  eeprom_data                     : in   std_logic_vector(2047 downto 0)  
  );
end component;

component clock_test
generic (
  VERSION_MINOR                               : integer          := 1;
  VERSION_MAJOR                               : integer          := 0;
  CLOCK0_TYPE                                 : integer          := 1;
  CLOCK0_EN                                   : boolean          := false;
  CLOCK0_FREQ                                 : integer          := 0;
  CLOCK0_NAME                                 : string           := "";
  CLOCK1_TYPE                                 : integer          := 1;
  CLOCK1_EN                                   : boolean          := false;
  CLOCK1_FREQ                                 : integer          := 0;
  CLOCK1_NAME                                 : string           := "";
  CLOCK2_TYPE                                 : integer          := 1;
  CLOCK2_EN                                   : boolean          := false;
  CLOCK2_FREQ                                 : integer          := 0;
  CLOCK2_NAME                                 : string           := "";
  CLOCK3_TYPE                                 : integer          := 1;
  CLOCK3_EN                                   : boolean          := false;
  CLOCK3_FREQ                                 : integer          := 0;
  CLOCK3_NAME                                 : string           := "";
  CLOCK4_TYPE                                 : integer          := 1;
  CLOCK4_EN                                   : boolean          := false;
  CLOCK4_FREQ                                 : integer          := 0;
  CLOCK4_NAME                                 : string           := "";
  CLOCK5_TYPE                                 : integer          := 1;
  CLOCK5_EN                                   : boolean          := false;
  CLOCK5_FREQ                                 : integer          := 0;
  CLOCK5_NAME                                 : string           := "";
  CLOCK6_TYPE                                 : integer          := 1;
  CLOCK6_EN                                   : boolean          := false;
  CLOCK6_FREQ                                 : integer          := 0;
  CLOCK6_NAME                                 : string           := "";
  CLOCK7_TYPE                                 : integer          := 1;
  CLOCK7_EN                                   : boolean          := false;
  CLOCK7_FREQ                                 : integer          := 0;
  CLOCK7_NAME                                 : string           := "";
  CLOCK8_TYPE                                 : integer          := 1;
  CLOCK8_EN                                   : boolean          := false;
  CLOCK8_FREQ                                 : integer          := 0;
  CLOCK8_NAME                                 : string           := "";
  CLOCK9_TYPE                                 : integer          := 1;
  CLOCK9_EN                                   : boolean          := false;
  CLOCK9_FREQ                                 : integer          := 0;
  CLOCK9_NAME                                 : string           := "";
  CLOCK10_TYPE                                : integer          := 1;
  CLOCK10_EN                                  : boolean          := false;
  CLOCK10_FREQ                                : integer          := 0;
  CLOCK10_NAME                                : string           := "";
  CLOCK11_TYPE                                : integer          := 1;
  CLOCK11_EN                                  : boolean          := false;
  CLOCK11_FREQ                                : integer          := 0;
  CLOCK11_NAME                                : string           := "";
  CLOCK12_TYPE                                : integer          := 1;
  CLOCK12_EN                                  : boolean          := false;
  CLOCK12_FREQ                                : integer          := 0;
  CLOCK12_NAME                                : string           := "";
  CLOCK13_TYPE                                : integer          := 1;
  CLOCK13_EN                                  : boolean          := false;
  CLOCK13_FREQ                                : integer          := 0;
  CLOCK13_NAME                                : string           := "";
  CLOCK14_TYPE                                : integer          := 1;
  CLOCK14_EN                                  : boolean          := false;
  CLOCK14_FREQ                                : integer          := 0;
  CLOCK14_NAME                                : string           := "";
  CLOCK15_TYPE                                : integer          := 1;
  CLOCK15_EN                                  : boolean          := false;
  CLOCK15_FREQ                                : integer          := 0;
  CLOCK15_NAME                                : string           := "";
  CLOCK16_TYPE                                : integer          := 1;
  CLOCK16_EN                                  : boolean          := false;
  CLOCK16_FREQ                                : integer          := 0;
  CLOCK16_NAME                                : string           := "";
  CLOCK17_TYPE                                : integer          := 1;
  CLOCK17_EN                                  : boolean          := false;
  CLOCK17_FREQ                                : integer          := 0;
  CLOCK17_NAME                                : string           := "";
  CLOCK18_TYPE                                : integer          := 1;
  CLOCK18_EN                                  : boolean          := false;
  CLOCK18_FREQ                                : integer          := 0;
  CLOCK18_NAME                                : string           := "";
  CLOCK19_TYPE                                : integer          := 1;
  CLOCK19_EN                                  : boolean          := false;
  CLOCK19_FREQ                                : integer          := 0;
  CLOCK19_NAME                                : string           := ""
  );  
port (
  clocks_test_aclk      					  : in  std_logic;
  clocks_test_areset    					  : in  std_logic;
  clocks_test_awaddr						  : in  std_logic_vector(7 downto 0); 
  clocks_test_awvalid 					  	  : in  std_logic;
  clocks_test_awready 					  	  : out std_logic; 					
  clocks_test_awprot						  : in  std_logic_vector(2 downto 0);
  clocks_test_wdata						  	  : in  std_logic_vector(31 downto 0); 
  clocks_test_wstrb							  : in  std_logic_vector(3 downto 0);  
  clocks_test_wvalid						  : in  std_logic;
  clocks_test_wready						  : out std_logic;
  clocks_test_bresp                           : out  std_logic_vector(1 downto 0);						
  clocks_test_bvalid                          : out  std_logic;									
  clocks_test_bready                          : in   std_logic;									
  clocks_test_araddr                          : in   std_logic_vector(7 downto 0);						
  clocks_test_arvalid                         : in   std_logic;								
  clocks_test_arready                         : out  std_logic;								
  clocks_test_arprot                          : in   std_logic_vector(2 downto 0);
  clocks_test_rdata                           : out  std_logic_vector(31 downto 0);				
  clocks_test_rresp                           : out  std_logic_vector(1 downto 0);				
  clocks_test_rvalid                          : out  std_logic;							
  clocks_test_rready                          : in   std_logic;				
  clocks_test_test_clock                      : in   std_logic_vector(19 downto 0);
  clocks_test_test_clock_stat                 : in   std_logic_vector(19 downto 0);
  clocks_cap_aclk                             : in   std_logic;
  clocks_cap_areset                           : in   std_logic;
  clocks_cap_awaddr                           : in   std_logic_vector(12 downto 0);
  clocks_cap_awvalid                          : in   std_logic;
  clocks_cap_awready                          : out  std_logic;
  clocks_cap_awprot                           : in   std_logic_vector(2 downto 0);
  clocks_cap_wdata                            : in   std_logic_vector(31 downto 0);
  clocks_cap_wstrb                            : in   std_logic_vector(3 downto 0);
  clocks_cap_wvalid                           : in   std_logic;
  clocks_cap_wready                           : out  std_logic;
  clocks_cap_bresp                            : out  std_logic_vector(1 downto 0);						
  clocks_cap_bvalid                           : out  std_logic;									
  clocks_cap_bready                           : in   std_logic;									
  clocks_cap_araddr                           : in   std_logic_vector(12 downto 0);						
  clocks_cap_arvalid                          : in   std_logic;								
  clocks_cap_arready                          : out  std_logic;								
  clocks_cap_arprot                           : in   std_logic_vector(2 downto 0);
  clocks_cap_rdata                            : out  std_logic_vector(31 downto 0);				
  clocks_cap_rresp                            : out  std_logic_vector(1 downto 0);				
  clocks_cap_rvalid                           : out  std_logic;							
  clocks_cap_rready                           : in   std_logic   
  );
end component;

component led_control
generic (
  LED_NUMBER                      :      integer range 1 to 5
  );
port (
  aclk                            : in   std_logic;
  areset                          : in   std_logic;
  awaddr                          : in   std_logic_vector(3 downto 0);
  awvalid                         : in   std_logic;
  awready                         : out  std_logic;
  awprot                          : in   std_logic_vector(2 downto 0);
  wdata                           : in   std_logic_vector(31 downto 0);
  wstrb                           : in   std_logic_vector(3 downto 0);
  wvalid                          : in   std_logic;
  wready                          : out  std_logic;
  bresp                           : out  std_logic_vector(1 downto 0);						
  bvalid                          : out  std_logic;									
  bready                          : in   std_logic;									
  araddr                          : in   std_logic_vector(3 downto 0);						
  arvalid                         : in   std_logic;								
  arready                         : out  std_logic;								
  arprot                          : in   std_logic_vector(2 downto 0);
  rdata                           : out  std_logic_vector(31 downto 0);				
  rresp                           : out  std_logic_vector(1 downto 0);				
  rvalid                          : out  std_logic;							
  rready                          : in   std_logic;							
  led_r                           : out  std_logic_vector(LED_NUMBER-1 downto 0);
  led_g                           : out  std_logic_vector(LED_NUMBER-1 downto 0)  
  );
end component;

component xcvr_if
generic (
  RATE0                         :     integer range 0 to 2 := 0; -- 0=10G, 1=25G, 2=53G           
  CONFIGCLK_PERIOD              :     integer              := 10
  );
port (
  refclk_fgt_2                  : in  std_logic;       
  refclk_fgt_5                  : in  std_logic;       
  coreclk_fgt_2                 : out std_logic;       
  coreclk_fgt_5                 : out std_logic;       
  systempll_synthlock_322       : out std_logic;       
  systempll_synthlock_805       : out std_logic;       
  systempll_synthlock_830       : out std_logic;       
  tx_serial_data_0              : out std_logic_vector(7 downto 0);
  tx_serial_data_0_n            : out std_logic_vector(7 downto 0);
  rx_serial_data_0              : in  std_logic_vector(7 downto 0);
  rx_serial_data_0_n            : in  std_logic_vector(7 downto 0);
  reconfig_0_write              : in  std_logic;       
  reconfig_0_read               : in  std_logic;       
  reconfig_0_address            : in  std_logic_vector(20 downto 0); 
  reconfig_0_byteenable         : in  std_logic_vector(3 downto 0); 
  reconfig_0_writedata          : in  std_logic_vector(31 downto 0); 
  reconfig_0_readdata           : out std_logic_vector(31 downto 0); 
  reconfig_0_waitrequest        : out std_logic;       
  reconfig_0_readdatavalid      : out std_logic;       
  reconfig_sl_0_write           : in  std_logic;       
  reconfig_sl_0_read            : in  std_logic;       
  reconfig_sl_0_address         : in  std_logic_vector(16 downto 0);
  reconfig_sl_0_byteenable      : in  std_logic_vector(3 downto 0); 
  reconfig_sl_0_writedata       : in  std_logic_vector(31 downto 0);
  reconfig_sl_0_readdata        : out std_logic_vector(31 downto 0);
  reconfig_sl_0_waitrequest     : out std_logic;       
  reconfig_sl_0_readdatavalid   : out std_logic;       
  config_clk                    : in  std_logic;       
  config_rstn                   : in  std_logic;       
  awaddr                        : in  std_logic_vector(7 downto 0); 
  awvalid                       : in  std_logic;       
  awready                       : out std_logic;       
  wdata                         : in  std_logic_vector(31 downto 0);
  wstrb                         : in  std_logic_vector(3 downto 0); 
  wvalid                        : in  std_logic;       
  wready                        : out std_logic;       
  bresp                         : out std_logic_vector(1 downto 0); 
  bvalid                        : out std_logic;       
  bready                        : in  std_logic;       
  araddr                        : in  std_logic_vector(7 downto 0); 
  arvalid                       : in  std_logic;       
  arready                       : out std_logic;        
  rdata                         : out std_logic_vector(31 downto 0);
  rresp                         : out std_logic_vector(1 downto 0); 
  rvalid                        : out std_logic;       
  rready                        : in  std_logic       
  ); 
end component;

component powerburner_controller
generic (
  CORE_CLK_FREQUENCY              :      natural   := 100000000;      --Frequency in Hz
  POWERBURNER_INSTANCES           :      natural range 1 to 32 := 1;  --Max 32
  BRAM_HW_TARGET                  :      natural   := 32;             --Target Hardware utilisation for device after compilation, min (16*instances)
  SREG_HW_TARGET                  :      natural   := 12;             --Target Hardware utilisation for device after compilation, min (64*instances)
  DSP_HW_TARGET                   :      natural   := 32              --Target Hardware utilisation for device after compilation, min (4*instances)
  );
port (
  aclk                            : in   std_logic;
  areset                          : in   std_logic;
  awaddr                          : in   std_logic_vector(7 downto 0);
  awvalid                         : in   std_logic;
  awready                         : out  std_logic;
  awprot                          : in   std_logic_vector(2 downto 0);
  wdata                           : in   std_logic_vector(31 downto 0);
  wstrb                           : in   std_logic_vector(3 downto 0);
  wvalid                          : in   std_logic;
  wready                          : out  std_logic;
  bresp                           : out  std_logic_vector(1 downto 0);
  bvalid                          : out  std_logic;
  bready                          : in   std_logic;
  araddr                          : in   std_logic_vector(7 downto 0);
  arvalid                         : in   std_logic;
  arready                         : out  std_logic;
  arprot                          : in   std_logic_vector(2 downto 0);
  rdata                           : out  std_logic_vector(31 downto 0);
  rresp                           : out  std_logic_vector(1 downto 0);
  rvalid                          : out  std_logic;
  rready                          : in   std_logic;
  pb_clk                          : in   std_logic
  );
end component;

component lvds_gpio_test 
port (
  aclk                            : in   std_logic;
  areset                          : in   std_logic;
  awaddr                          : in   std_logic_vector(4 downto 0);
  awvalid                         : in   std_logic;
  awready                         : out  std_logic;
  awprot                          : in   std_logic_vector(2 downto 0);
  wdata                           : in   std_logic_vector(31 downto 0);
  wstrb                           : in   std_logic_vector(3 downto 0);
  wvalid                          : in   std_logic;
  wready                          : out  std_logic;
  bresp                           : out  std_logic_vector(1 downto 0);						
  bvalid                          : out  std_logic;									
  bready                          : in   std_logic;									
  araddr                          : in   std_logic_vector(4 downto 0);						
  arvalid                         : in   std_logic;								
  arready                         : out  std_logic;								
  arprot                          : in   std_logic_vector(2 downto 0);
  rdata                           : out  std_logic_vector(31 downto 0);				
  rresp                           : out  std_logic_vector(1 downto 0);				
  rvalid                          : out  std_logic;							
  rready                          : in   std_logic;				
  lvds_clock                      : in   std_logic;
  lvds_out                        : out  std_logic;
  lvds_in                         : in   std_logic_vector(1 downto 0)
  );
end component;

component user_clk0_pll
port (
  refclk   : in  std_logic; 
  locked   : out std_logic;        
  rst      : in  std_logic; 
  outclk_0 : out std_logic;        
  outclk_1 : out std_logic;        
  outclk_2 : out std_logic;        
  outclk_3 : out std_logic         
  );
end component;

component user_clk1_pll
port (
  refclk   : in  std_logic;
  locked   : out std_logic;
  rst      : in  std_logic;
  outclk_0 : out std_logic
  );
end component;

component hbm_fbr_clk_pll
port (
  refclk   : in  std_logic := '0'; 
  locked   : out std_logic;        
  rst      : in  std_logic := '0'; 
  outclk_0 : out std_logic;
  outclk_1 : out std_logic  
  );
end component;

component noc_upper_clk_ctrl
port (
  refclk     : in  std_logic := '0'; 
  pll_lock_o : out std_logic         
  );
end component;

component noc_lower_clk_ctrl
port (
  refclk     : in  std_logic := '0'; 
  pll_lock_o : out std_logic         
  );
end component;

component reset_release
port (
  ninit_done : out std_logic   
  );
end component;

component reset_top
generic (
  NUM_SYS_CLK_CYCLES  : std_logic_vector(31 downto 0)         := x"00000100";
  RST_FAN_OUT         : integer := 16
  );
port (
  sys_clk             : in  std_logic;
  pll_locked          : in  std_logic;
  ninit_done          : in  std_logic;
  bmc_reset           : in  std_logic;
  pcie_reset          : in  std_logic;
  sys_reset           : out std_logic_vector(RST_FAN_OUT-1 downto 0);
  sys_reset_n         : out std_logic_vector(RST_FAN_OUT-1 downto 0)
  );
end component;

component reset_synchroniser
generic (
  depth               :     integer := 2
  );
port (
  clock               : in  std_logic;
  async_reset         : in  std_logic;
  sync_reset          : out std_logic
  );
end component;

signal bmc_reset                        : std_logic;
signal bmc_reset_sys                    : std_logic;

signal ninit_done                       : std_logic;
signal sys_init_done                    : std_logic;
signal sys_init_done_n                  : std_logic;

signal sys_rstn_init                    : std_logic_vector(31 downto 0);
signal sys_rst_init                     : std_logic_vector(31 downto 0);
				        					
signal sys_clk                          : std_logic;
signal sys_reset                        : std_logic_vector(31 downto 0);
signal sys_resetn                       : std_logic_vector(31 downto 0);

signal hbm_fbr_clk0_locked              : std_logic;
signal hbm_fbr_clk1_locked              : std_logic;
			
signal hbm_initiator_clk0               : std_logic;            
signal hbm_tst_clk0                     : std_logic;
signal hbml_init_done                   : std_logic;
signal hbml_init_done_n                 : std_logic;
signal hbml_rstn_init                   : std_logic_vector(15 downto 0);
signal hbml_rst_init                    : std_logic_vector(15 downto 0);
signal pcie_usr_reset_hbml              : std_logic;		                
signal bmc_reset_hbml                   : std_logic;
signal hbml_user_reset                  : std_logic_vector(15 downto 0);
signal hbml_user_reset_d1               : std_logic_vector(15 downto 0);
signal hbml_user_reset_d2               : std_logic_vector(15 downto 0);
signal hbml_user_reset_d3               : std_logic_vector(15 downto 0);
signal hbml_user_reset_d4               : std_logic_vector(15 downto 0);

signal hbm_initiator_clk1               : std_logic;            
signal hbm_tst_clk1                     : std_logic;
signal hbmu_init_done                   : std_logic;
signal hbmu_init_done_n                 : std_logic;
signal hbmu_rstn_init                   : std_logic_vector(15 downto 0);
signal hbmu_rst_init                    : std_logic_vector(15 downto 0);
signal pcie_usr_reset_hbmu              : std_logic;
signal bmc_reset_hbmu                   : std_logic;
signal hbmu_user_reset                  : std_logic_vector(15 downto 0);
signal hbmu_user_reset_d1               : std_logic_vector(15 downto 0);
signal hbmu_user_reset_d2               : std_logic_vector(15 downto 0);
signal hbmu_user_reset_d3               : std_logic_vector(15 downto 0);
signal hbmu_user_reset_d4               : std_logic_vector(15 downto 0);

signal dram_usr_clk                     : std_logic;
signal dram_usr_reset                   : std_logic;

signal spi_sysclk                       : std_logic;
signal spi_sysreset                     : std_logic;

signal powerburner_clk                  : std_logic;
signal powerburner_reset                : std_logic;

signal pcie_usr_clk                     : std_logic;
signal pcie_usr_resetn                  : std_logic;
signal pcie_usr_reset                   : std_logic;	
signal pcie_usr_reset_sys               : std_logic;

signal pci_perst_n                      : std_logic;
signal pci_perst                        : std_logic;

signal usr_clk1_clk100                  : std_logic;

signal pll_locked0                      : std_logic;
signal pll_locked1                      : std_logic;
signal noc_upper_locked                 : std_logic;
signal noc_lower_locked                 : std_logic;
				        
-- Test AXI and Avalon buses	        
signal clock_test_capability_axi        : T_clock_test_cap_axi;
signal clock_test_axi                   : T_clock_test_axi;
signal pwr_burner_axi                   : T_pwr_burner_axi;
signal qsfpdd0_test_axi                 : T_qsfpdd_test_axi;
signal qsfpdd1_test_axi                 : T_qsfpdd_test_axi;
signal qsfpdd2_test_axi                 : T_qsfpdd_test_axi;
signal telemetry_test_axi               : T_telemetry_test_axi;
signal versionid_axi                    : T_version_axi;
signal leds_test_axi                    : T_leds_test_axi;
signal lvds_gpio_test_axi               : T_lvds_gpio_test_axi;
signal hbm2e_upper_test_ch0_u0_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_upper_test_ch0_u1_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_upper_test_ch1_u0_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_upper_test_ch1_u1_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_upper_test_ch2_u0_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_upper_test_ch2_u1_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_upper_test_ch3_u0_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_upper_test_ch3_u1_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_upper_test_ch4_u0_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_upper_test_ch4_u1_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_upper_test_ch5_u0_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_upper_test_ch5_u1_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_upper_test_ch6_u0_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_upper_test_ch6_u1_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_upper_test_ch7_u0_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_upper_test_ch7_u1_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_upper_error_log_ch0_u0_axi : T_hbm2e_error_log_axi;
signal hbm2e_upper_error_log_ch0_u1_axi : T_hbm2e_error_log_axi;
signal hbm2e_upper_error_log_ch1_u0_axi : T_hbm2e_error_log_axi;
signal hbm2e_upper_error_log_ch1_u1_axi : T_hbm2e_error_log_axi;
signal hbm2e_upper_error_log_ch2_u0_axi : T_hbm2e_error_log_axi;
signal hbm2e_upper_error_log_ch2_u1_axi : T_hbm2e_error_log_axi;
signal hbm2e_upper_error_log_ch3_u0_axi : T_hbm2e_error_log_axi;
signal hbm2e_upper_error_log_ch3_u1_axi : T_hbm2e_error_log_axi;
signal hbm2e_upper_error_log_ch4_u0_axi : T_hbm2e_error_log_axi;
signal hbm2e_upper_error_log_ch4_u1_axi : T_hbm2e_error_log_axi;
signal hbm2e_upper_error_log_ch5_u0_axi : T_hbm2e_error_log_axi;
signal hbm2e_upper_error_log_ch5_u1_axi : T_hbm2e_error_log_axi;
signal hbm2e_upper_error_log_ch6_u0_axi : T_hbm2e_error_log_axi;
signal hbm2e_upper_error_log_ch6_u1_axi : T_hbm2e_error_log_axi;
signal hbm2e_upper_error_log_ch7_u0_axi : T_hbm2e_error_log_axi;
signal hbm2e_upper_error_log_ch7_u1_axi : T_hbm2e_error_log_axi;
signal hbm2e_lower_test_ch0_u0_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_lower_test_ch0_u1_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_lower_test_ch1_u0_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_lower_test_ch1_u1_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_lower_test_ch2_u0_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_lower_test_ch2_u1_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_lower_test_ch3_u0_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_lower_test_ch3_u1_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_lower_test_ch4_u0_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_lower_test_ch4_u1_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_lower_test_ch5_u0_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_lower_test_ch5_u1_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_lower_test_ch6_u0_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_lower_test_ch6_u1_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_lower_test_ch7_u0_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_lower_test_ch7_u1_axi      : T_hbm2e_test_ctrl_axi;
signal hbm2e_lower_error_log_ch0_u0_axi : T_hbm2e_error_log_axi;
signal hbm2e_lower_error_log_ch0_u1_axi : T_hbm2e_error_log_axi;
signal hbm2e_lower_error_log_ch1_u0_axi : T_hbm2e_error_log_axi;
signal hbm2e_lower_error_log_ch1_u1_axi : T_hbm2e_error_log_axi;
signal hbm2e_lower_error_log_ch2_u0_axi : T_hbm2e_error_log_axi;
signal hbm2e_lower_error_log_ch2_u1_axi : T_hbm2e_error_log_axi;
signal hbm2e_lower_error_log_ch3_u0_axi : T_hbm2e_error_log_axi;
signal hbm2e_lower_error_log_ch3_u1_axi : T_hbm2e_error_log_axi;
signal hbm2e_lower_error_log_ch4_u0_axi : T_hbm2e_error_log_axi;
signal hbm2e_lower_error_log_ch4_u1_axi : T_hbm2e_error_log_axi;
signal hbm2e_lower_error_log_ch5_u0_axi : T_hbm2e_error_log_axi;
signal hbm2e_lower_error_log_ch5_u1_axi : T_hbm2e_error_log_axi;
signal hbm2e_lower_error_log_ch6_u0_axi : T_hbm2e_error_log_axi;
signal hbm2e_lower_error_log_ch6_u1_axi : T_hbm2e_error_log_axi;
signal hbm2e_lower_error_log_ch7_u0_axi : T_hbm2e_error_log_axi;
signal hbm2e_lower_error_log_ch7_u1_axi : T_hbm2e_error_log_axi;
signal dram_test_ctrl_axi               : T_hbm2e_test_ctrl_axi;
signal dram_error_log_axi               : T_hbm2e_error_log_axi;
signal qsfpdd0_xcvr_reconfig_avmm       : T_xcvr_reconfig_avmm;
signal qsfpdd0_sl4_reconfig_avmm        : T_sl4_reconfig_avmm;
signal qsfpdd1_xcvr_reconfig_avmm       : T_xcvr_reconfig_avmm;
signal qsfpdd1_sl4_reconfig_avmm        : T_sl4_reconfig_avmm;
signal qsfpdd2_xcvr_reconfig_avmm       : T_xcvr_reconfig_avmm;
signal qsfpdd2_sl4_reconfig_avmm        : T_sl4_reconfig_avmm;
signal hbm2e_upper_ch0_ch1_status_axi   : T_hbm2e_status_axi;
signal hbm2e_upper_ch2_ch3_status_axi   : T_hbm2e_status_axi;
signal hbm2e_upper_ch4_ch5_status_axi   : T_hbm2e_status_axi;
signal hbm2e_upper_ch6_ch7_status_axi   : T_hbm2e_status_axi;
signal hbm2e_lower_ch0_ch1_status_axi   : T_hbm2e_status_axi;
signal hbm2e_lower_ch2_ch3_status_axi   : T_hbm2e_status_axi;
signal hbm2e_lower_ch4_ch5_status_axi   : T_hbm2e_status_axi;
signal hbm2e_lower_ch6_ch7_status_axi   : T_hbm2e_status_axi;

signal qsfpdd0_rst_n                    : std_logic;    
signal qsfpdd0_lpmode                   : std_logic;    
signal qsfpdd0_int_n                    : std_logic;     
signal qsfpdd0_present_n                : std_logic; 
signal qsfpdd1_rst_n                    : std_logic;     
signal qsfpdd1_lpmode                   : std_logic;    
signal qsfpdd1_int_n                    : std_logic;     
signal qsfpdd1_present_n                : std_logic;
signal qsfpdd2_rst_n                    : std_logic;     
signal qsfpdd2_lpmode                   : std_logic;    
signal qsfpdd2_int_n                    : std_logic;     
signal qsfpdd2_present_n                : std_logic; 
signal eeprom_data                      : std_logic_vector(2047 downto 0);       

signal qsfpdd0_refclk_pll               : std_logic;
signal qsfpdd0_refclk_lock322           : std_logic;
signal qsfpdd0_refclk_lock805           : std_logic;
signal qsfpdd0_refclk_lock830           : std_logic;
signal qsfpdd0_refclk_lock              : std_logic;
signal mcio_refclk_pll                  : std_logic;
signal qsfpdd1_refclk_pll               : std_logic;
signal qsfpdd1_refclk_lock322           : std_logic;
signal qsfpdd1_refclk_lock805           : std_logic;
signal qsfpdd1_refclk_lock830           : std_logic;
signal qsfpdd1_refclk_lock              : std_logic;
signal m2_refclk_pll                    : std_logic;
signal qsfpdd2_refclk_pll               : std_logic;
signal qsfpdd2_refclk_lock322           : std_logic;
signal qsfpdd2_refclk_lock805           : std_logic;
signal qsfpdd2_refclk_lock830           : std_logic; 
signal qsfpdd2_refclk_lock              : std_logic;
                                        
signal test_clocks                      : std_logic_vector(19 downto 0);
signal test_clocks_status               : std_logic_vector(19 downto 0);

attribute preserve : boolean;
attribute preserve of sys_rstn_init     : signal is true;
attribute preserve of sys_rst_init      : signal is true;
attribute preserve of hbmu_rstn_init    : signal is true;
attribute preserve of hbmu_rst_init     : signal is true;
attribute preserve of hbml_rstn_init    : signal is true;
attribute preserve of hbml_rst_init     : signal is true;
attribute preserve of sys_reset         : signal is true;
attribute preserve of hbmu_user_reset   : signal is true;
attribute preserve of hbmu_user_reset_d1: signal is true;
attribute preserve of hbmu_user_reset_d2: signal is true;
attribute preserve of hbmu_user_reset_d3: signal is true;
attribute preserve of hbmu_user_reset_d4: signal is true;
attribute preserve of hbml_user_reset   : signal is true;
attribute preserve of hbml_user_reset_d1: signal is true;
attribute preserve of hbml_user_reset_d2: signal is true;
attribute preserve of hbml_user_reset_d3: signal is true;
attribute preserve of hbml_user_reset_d4: signal is true;


begin

MCIO_GPIO_EN_L <= '0';
EXT_GPIO_EN_L  <= '0'; 
MCIO_I2C_EN    <= '1';
DDR4_TEN       <= '0'; 

pcie_usr_reset <= not(pcie_usr_resetn);
bmc_reset      <= not(FPGA_RST_L);
pci_perst      <= not(pci_perst_n);

u000_init_done : reset_release
port map (
  ninit_done => ninit_done
  );

u001_user_clk0_pll : user_clk0_pll
port map (
  refclk   => USR_CLK0,
  locked   => pll_locked0,
  rst      => ninit_done,
  outclk_0 => sys_clk,
  outclk_1 => dram_usr_clk,
  outclk_2 => spi_sysclk,
  outclk_3 => powerburner_clk
  );

u002_sys_reset : reset_top
generic map (
  NUM_SYS_CLK_CYCLES  => x"00000100",
  RST_FAN_OUT         => 32
  )
port map (
  sys_clk             => sys_clk,
  pll_locked          => pll_locked0,
  ninit_done          => ninit_done,
  bmc_reset           => bmc_reset,
  pcie_reset          => pci_perst,
  sys_reset           => sys_reset,
  sys_reset_n         => sys_resetn
  );
  
u003 : reset_synchroniser
generic map (
  depth               => 3 
  )
port map (
  clock               => spi_sysclk,
  async_reset         => sys_reset(0),
  sync_reset          => spi_sysreset
  );  

u004 : reset_synchroniser
generic map (
  depth               => 3
  )
port map (
  clock               => powerburner_clk,
  async_reset         => sys_reset(1),
  sync_reset          => powerburner_reset
  );  

u005 : reset_synchroniser
generic map (
  depth               => 3 
  )
port map (
  clock               => dram_usr_clk,
  async_reset         => sys_reset(23),
  sync_reset          => dram_usr_reset
  );  

u006_upper_noc_clk_ctrl : noc_upper_clk_ctrl
port map (
  refclk     => NOC_CLK1,
  pll_lock_o => noc_upper_locked
  );

u007_lower_noc_clk_ctrl : noc_lower_clk_ctrl
port map (
  refclk     => NOC_CLK0,
  pll_lock_o => noc_lower_locked
  );

u008_hbm_fbr_clk_pll_bottom : hbm_fbr_clk_pll
port map (
  refclk   => HBM_FBR_REFCLK0,
  locked   => hbm_fbr_clk0_locked,
  rst      => ninit_done,
  outclk_0 => hbm_initiator_clk0,
  outclk_1 => hbm_tst_clk0
  );

u009_hbm_fbr_clk_pll_top : hbm_fbr_clk_pll
port map (
  refclk   => HBM_FBR_REFCLK1,
  locked   => hbm_fbr_clk1_locked,
  rst      => ninit_done,
  outclk_0 => hbm_initiator_clk1,
  outclk_1 => hbm_tst_clk1
  );

u010_hbml_user_reset : reset_top
generic map (
  NUM_SYS_CLK_CYCLES  => x"00000100",
  RST_FAN_OUT         => 16
  )
port map (
  sys_clk             => hbm_tst_clk0,
  pll_locked          => hbm_fbr_clk0_locked,
  ninit_done          => ninit_done,
  bmc_reset           => bmc_reset,
  pcie_reset          => pci_perst,
  sys_reset           => hbml_user_reset,
  sys_reset_n         => open
  );

process (hbm_tst_clk0)
begin
  if rising_edge(hbm_tst_clk0) then
    hbml_user_reset_d1 <= hbml_user_reset;
	hbml_user_reset_d2 <= hbml_user_reset_d1;
	hbml_user_reset_d3 <= hbml_user_reset_d2;
	hbml_user_reset_d4 <= hbml_user_reset_d3;
  end if;
end process;

u011_hbmu_user_reset : reset_top
generic map (
  NUM_SYS_CLK_CYCLES  => x"00000100",
  RST_FAN_OUT         => 16
  )
port map (
  sys_clk             => hbm_tst_clk1,
  pll_locked          => hbm_fbr_clk1_locked,
  ninit_done          => ninit_done,
  bmc_reset           => bmc_reset,
  pcie_reset          => pci_perst,
  sys_reset           => hbmu_user_reset,
  sys_reset_n         => open
  );

process (hbm_tst_clk1)
begin
  if rising_edge(hbm_tst_clk1) then
    hbmu_user_reset_d1 <= hbmu_user_reset;
	hbmu_user_reset_d2 <= hbmu_user_reset_d1;
	hbmu_user_reset_d3 <= hbmu_user_reset_d2;
	hbmu_user_reset_d4 <= hbmu_user_reset_d3;
  end if;
end process;

u012_user_clk1_pll : user_clk1_pll
port map (
  refclk   => USR_CLK1,
  locked   => pll_locked1,
  rst      => ninit_done,
  outclk_0 => usr_clk1_clk100
  );
   
u0 : main
generic map (
  skeleton_ia860m_0_bmc3_telemetry_clk_period             => 20,
  skeleton_ia860m_0_bmc3_telemetry_time_between_updates   => 100,
  version_id_ip_version                                   => "2.0.0",
  clocks_test_ip_version                                  => "2.0.0",
  powerburner_ip_version                                  => "0.1.0",
  serialliteiv_ip_version                                 => "9.2.0",
  serialliteiv_xcvr_mode                                  => XCVR_MODE,
  serialliteiv_lane_count                                 => 8,
  qsfpdd_test_ip_version                                  => "1.0.0",
  telemetry_test_ip_version                               => "0.1.0",
  led_test_ip_version                                     => "1.0.0",
  hbm2e_ip_version                                        => "3.0.0",
  hbm2e_test_ip_version                                   => "1.0.0",
  lvds_gpio_test_ip_version                               => "1.0.0",
  hps_dram_test_ip_version                                => "1.0.0"
  )
port map (
  pcieclk_clk                                             => pcie_usr_clk,
  pcieresetn_reset_n                                      => pcie_usr_resetn,
  spi_sysclk_clk                                          => spi_sysclk,
  spi_sysreset_reset                                      => spi_sysreset,
  sysclk_clk                                              => sys_clk,
  sysreset_reset                                          => sys_reset(2),
  clock_test_cap_axi_m_awaddr                             => clock_test_capability_axi.clock_test_cap_awaddr,
  clock_test_cap_axi_m_awprot                             => clock_test_capability_axi.clock_test_cap_awprot,
  clock_test_cap_axi_m_awvalid                            => clock_test_capability_axi.clock_test_cap_awvalid,
  clock_test_cap_axi_m_awready                            => clock_test_capability_axi.clock_test_cap_awready,
  clock_test_cap_axi_m_wdata                              => clock_test_capability_axi.clock_test_cap_wdata,
  clock_test_cap_axi_m_wstrb                              => clock_test_capability_axi.clock_test_cap_wstrb,
  clock_test_cap_axi_m_wvalid                             => clock_test_capability_axi.clock_test_cap_wvalid,
  clock_test_cap_axi_m_wready                             => clock_test_capability_axi.clock_test_cap_wready,
  clock_test_cap_axi_m_bresp                              => clock_test_capability_axi.clock_test_cap_bresp,
  clock_test_cap_axi_m_bvalid                             => clock_test_capability_axi.clock_test_cap_bvalid,
  clock_test_cap_axi_m_bready                             => clock_test_capability_axi.clock_test_cap_bready,
  clock_test_cap_axi_m_araddr                             => clock_test_capability_axi.clock_test_cap_araddr,
  clock_test_cap_axi_m_arprot                             => clock_test_capability_axi.clock_test_cap_arprot,
  clock_test_cap_axi_m_arvalid                            => clock_test_capability_axi.clock_test_cap_arvalid,
  clock_test_cap_axi_m_arready                            => clock_test_capability_axi.clock_test_cap_arready,
  clock_test_cap_axi_m_rdata                              => clock_test_capability_axi.clock_test_cap_rdata,
  clock_test_cap_axi_m_rresp                              => clock_test_capability_axi.clock_test_cap_rresp,
  clock_test_cap_axi_m_rvalid                             => clock_test_capability_axi.clock_test_cap_rvalid,
  clock_test_cap_axi_m_rready                             => clock_test_capability_axi.clock_test_cap_rready,
  clocks_test_axi_m_awaddr                                => clock_test_axi.clock_test_awaddr,
  clocks_test_axi_m_awprot                                => clock_test_axi.clock_test_awprot,
  clocks_test_axi_m_awvalid                               => clock_test_axi.clock_test_awvalid,
  clocks_test_axi_m_awready                               => clock_test_axi.clock_test_awready,
  clocks_test_axi_m_wdata                                 => clock_test_axi.clock_test_wdata,
  clocks_test_axi_m_wstrb                                 => clock_test_axi.clock_test_wstrb,
  clocks_test_axi_m_wvalid                                => clock_test_axi.clock_test_wvalid,
  clocks_test_axi_m_wready                                => clock_test_axi.clock_test_wready,
  clocks_test_axi_m_bresp                                 => clock_test_axi.clock_test_bresp,
  clocks_test_axi_m_bvalid                                => clock_test_axi.clock_test_bvalid,
  clocks_test_axi_m_bready                                => clock_test_axi.clock_test_bready,
  clocks_test_axi_m_araddr                                => clock_test_axi.clock_test_araddr,
  clocks_test_axi_m_arprot                                => clock_test_axi.clock_test_arprot,
  clocks_test_axi_m_arvalid                               => clock_test_axi.clock_test_arvalid,
  clocks_test_axi_m_arready                               => clock_test_axi.clock_test_arready,
  clocks_test_axi_m_rdata                                 => clock_test_axi.clock_test_rdata,
  clocks_test_axi_m_rresp                                 => clock_test_axi.clock_test_rresp,
  clocks_test_axi_m_rvalid                                => clock_test_axi.clock_test_rvalid,
  clocks_test_axi_m_rready                                => clock_test_axi.clock_test_rready,
  hps_dram_error_logging_axi_m_awaddr                     => dram_error_log_axi.hbm2e_error_log_awaddr,   
  hps_dram_error_logging_axi_m_awprot                     => dram_error_log_axi.hbm2e_error_log_awprot,   
  hps_dram_error_logging_axi_m_awvalid                    => dram_error_log_axi.hbm2e_error_log_awvalid,  
  hps_dram_error_logging_axi_m_awready                    => dram_error_log_axi.hbm2e_error_log_awready,  
  hps_dram_error_logging_axi_m_wdata                      => dram_error_log_axi.hbm2e_error_log_wdata,    
  hps_dram_error_logging_axi_m_wstrb                      => dram_error_log_axi.hbm2e_error_log_wstrb,    
  hps_dram_error_logging_axi_m_wvalid                     => dram_error_log_axi.hbm2e_error_log_wvalid,   
  hps_dram_error_logging_axi_m_wready                     => dram_error_log_axi.hbm2e_error_log_wready,   
  hps_dram_error_logging_axi_m_bresp                      => dram_error_log_axi.hbm2e_error_log_bresp,    
  hps_dram_error_logging_axi_m_bvalid                     => dram_error_log_axi.hbm2e_error_log_bvalid,   
  hps_dram_error_logging_axi_m_bready                     => dram_error_log_axi.hbm2e_error_log_bready,   
  hps_dram_error_logging_axi_m_araddr                     => dram_error_log_axi.hbm2e_error_log_araddr,   
  hps_dram_error_logging_axi_m_arprot                     => dram_error_log_axi.hbm2e_error_log_arprot,   
  hps_dram_error_logging_axi_m_arvalid                    => dram_error_log_axi.hbm2e_error_log_arvalid,  
  hps_dram_error_logging_axi_m_arready                    => dram_error_log_axi.hbm2e_error_log_arready,  
  hps_dram_error_logging_axi_m_rdata                      => dram_error_log_axi.hbm2e_error_log_rdata,    
  hps_dram_error_logging_axi_m_rresp                      => dram_error_log_axi.hbm2e_error_log_rresp,    
  hps_dram_error_logging_axi_m_rvalid                     => dram_error_log_axi.hbm2e_error_log_rvalid,   
  hps_dram_error_logging_axi_m_rready                     => dram_error_log_axi.hbm2e_error_log_rready,   
  hps_dram_test_axi_m_awaddr                              => dram_test_ctrl_axi.hbm2e_test_ctrl_awaddr,                  
  hps_dram_test_axi_m_awprot                              => dram_test_ctrl_axi.hbm2e_test_ctrl_awprot,                 
  hps_dram_test_axi_m_awvalid                             => dram_test_ctrl_axi.hbm2e_test_ctrl_awvalid,                 
  hps_dram_test_axi_m_awready                             => dram_test_ctrl_axi.hbm2e_test_ctrl_awready,                  
  hps_dram_test_axi_m_wdata                               => dram_test_ctrl_axi.hbm2e_test_ctrl_wdata,                   
  hps_dram_test_axi_m_wstrb                               => dram_test_ctrl_axi.hbm2e_test_ctrl_wstrb,                   
  hps_dram_test_axi_m_wvalid                              => dram_test_ctrl_axi.hbm2e_test_ctrl_wvalid,                  
  hps_dram_test_axi_m_wready                              => dram_test_ctrl_axi.hbm2e_test_ctrl_wready,                  
  hps_dram_test_axi_m_bresp                               => dram_test_ctrl_axi.hbm2e_test_ctrl_bresp,   	                
  hps_dram_test_axi_m_bvalid                              => dram_test_ctrl_axi.hbm2e_test_ctrl_bvalid,  	                
  hps_dram_test_axi_m_bready                              => dram_test_ctrl_axi.hbm2e_test_ctrl_bready,  	                
  hps_dram_test_axi_m_araddr                              => dram_test_ctrl_axi.hbm2e_test_ctrl_araddr,  	                
  hps_dram_test_axi_m_arprot                              => dram_test_ctrl_axi.hbm2e_test_ctrl_arprot,                 
  hps_dram_test_axi_m_arvalid                             => dram_test_ctrl_axi.hbm2e_test_ctrl_arvalid,                 
  hps_dram_test_axi_m_arready                             => dram_test_ctrl_axi.hbm2e_test_ctrl_arready,                  
  hps_dram_test_axi_m_rdata                               => dram_test_ctrl_axi.hbm2e_test_ctrl_rdata,   	                
  hps_dram_test_axi_m_rresp                               => dram_test_ctrl_axi.hbm2e_test_ctrl_rresp,   	                
  hps_dram_test_axi_m_rvalid                              => dram_test_ctrl_axi.hbm2e_test_ctrl_rvalid,                  
  hps_dram_test_axi_m_rready                              => dram_test_ctrl_axi.hbm2e_test_ctrl_rready,                  
  leds_test_axi_m_awaddr                                  => leds_test_axi.leds_test_awaddr,               
  leds_test_axi_m_awprot                                  => leds_test_axi.leds_test_awprot,               
  leds_test_axi_m_awvalid                                 => leds_test_axi.leds_test_awvalid,              
  leds_test_axi_m_awready                                 => leds_test_axi.leds_test_awready,              
  leds_test_axi_m_wdata                                   => leds_test_axi.leds_test_wdata,                
  leds_test_axi_m_wstrb                                   => leds_test_axi.leds_test_wstrb,                
  leds_test_axi_m_wvalid                                  => leds_test_axi.leds_test_wvalid,               
  leds_test_axi_m_wready                                  => leds_test_axi.leds_test_wready,               
  leds_test_axi_m_bresp                                   => leds_test_axi.leds_test_bresp,                
  leds_test_axi_m_bvalid                                  => leds_test_axi.leds_test_bvalid,               
  leds_test_axi_m_bready                                  => leds_test_axi.leds_test_bready,               
  leds_test_axi_m_araddr                                  => leds_test_axi.leds_test_araddr,               
  leds_test_axi_m_arprot                                  => leds_test_axi.leds_test_arprot,               
  leds_test_axi_m_arvalid                                 => leds_test_axi.leds_test_arvalid,              
  leds_test_axi_m_arready                                 => leds_test_axi.leds_test_arready,               
  leds_test_axi_m_rdata                                   => leds_test_axi.leds_test_rdata,                
  leds_test_axi_m_rresp                                   => leds_test_axi.leds_test_rresp,                
  leds_test_axi_m_rvalid                                  => leds_test_axi.leds_test_rvalid,               
  leds_test_axi_m_rready                                  => leds_test_axi.leds_test_rready,               
  lvds_gpio_test_axi_m_awaddr                             => lvds_gpio_test_axi.lvds_gpio_test_awaddr,
  lvds_gpio_test_axi_m_awprot                             => lvds_gpio_test_axi.lvds_gpio_test_awprot,
  lvds_gpio_test_axi_m_awvalid                            => lvds_gpio_test_axi.lvds_gpio_test_awvalid,
  lvds_gpio_test_axi_m_awready                            => lvds_gpio_test_axi.lvds_gpio_test_awready,
  lvds_gpio_test_axi_m_wdata                              => lvds_gpio_test_axi.lvds_gpio_test_wdata,
  lvds_gpio_test_axi_m_wstrb                              => lvds_gpio_test_axi.lvds_gpio_test_wstrb,
  lvds_gpio_test_axi_m_wvalid                             => lvds_gpio_test_axi.lvds_gpio_test_wvalid,
  lvds_gpio_test_axi_m_wready                             => lvds_gpio_test_axi.lvds_gpio_test_wready,
  lvds_gpio_test_axi_m_bresp                              => lvds_gpio_test_axi.lvds_gpio_test_bresp,	
  lvds_gpio_test_axi_m_bvalid                             => lvds_gpio_test_axi.lvds_gpio_test_bvalid,
  lvds_gpio_test_axi_m_bready                             => lvds_gpio_test_axi.lvds_gpio_test_bready,
  lvds_gpio_test_axi_m_araddr                             => lvds_gpio_test_axi.lvds_gpio_test_araddr,
  lvds_gpio_test_axi_m_arprot                             => lvds_gpio_test_axi.lvds_gpio_test_arprot,
  lvds_gpio_test_axi_m_arvalid                            => lvds_gpio_test_axi.lvds_gpio_test_arvalid,
  lvds_gpio_test_axi_m_arready                            => lvds_gpio_test_axi.lvds_gpio_test_arready,
  lvds_gpio_test_axi_m_rdata                              => lvds_gpio_test_axi.lvds_gpio_test_rdata,	
  lvds_gpio_test_axi_m_rresp                              => lvds_gpio_test_axi.lvds_gpio_test_rresp,	
  lvds_gpio_test_axi_m_rvalid                             => lvds_gpio_test_axi.lvds_gpio_test_rvalid,
  lvds_gpio_test_axi_m_rready                             => lvds_gpio_test_axi.lvds_gpio_test_rready,
  pwr_burner_axi_m_awaddr                                 => pwr_burner_axi.pwr_burner_awaddr,
  pwr_burner_axi_m_awprot                                 => pwr_burner_axi.pwr_burner_awprot,
  pwr_burner_axi_m_awvalid                                => pwr_burner_axi.pwr_burner_awvalid,
  pwr_burner_axi_m_awready                                => pwr_burner_axi.pwr_burner_awready,
  pwr_burner_axi_m_wdata                                  => pwr_burner_axi.pwr_burner_wdata,
  pwr_burner_axi_m_wstrb                                  => pwr_burner_axi.pwr_burner_wstrb,
  pwr_burner_axi_m_wvalid                                 => pwr_burner_axi.pwr_burner_wvalid,
  pwr_burner_axi_m_wready                                 => pwr_burner_axi.pwr_burner_wready,
  pwr_burner_axi_m_bresp                                  => pwr_burner_axi.pwr_burner_bresp,
  pwr_burner_axi_m_bvalid                                 => pwr_burner_axi.pwr_burner_bvalid,
  pwr_burner_axi_m_bready                                 => pwr_burner_axi.pwr_burner_bready,
  pwr_burner_axi_m_araddr                                 => pwr_burner_axi.pwr_burner_araddr,
  pwr_burner_axi_m_arprot                                 => pwr_burner_axi.pwr_burner_arprot,
  pwr_burner_axi_m_arvalid                                => pwr_burner_axi.pwr_burner_arvalid,
  pwr_burner_axi_m_arready                                => pwr_burner_axi.pwr_burner_arready,
  pwr_burner_axi_m_rdata                                  => pwr_burner_axi.pwr_burner_rdata,
  pwr_burner_axi_m_rresp                                  => pwr_burner_axi.pwr_burner_rresp,
  pwr_burner_axi_m_rvalid                                 => pwr_burner_axi.pwr_burner_rvalid,
  pwr_burner_axi_m_rready                                 => pwr_burner_axi.pwr_burner_rready,
  qsfpdd0_test_axi_m_awaddr                               => qsfpdd0_test_axi.qsfpdd_test_awaddr,
  qsfpdd0_test_axi_m_awprot                               => qsfpdd0_test_axi.qsfpdd_test_awprot,
  qsfpdd0_test_axi_m_awvalid                              => qsfpdd0_test_axi.qsfpdd_test_awvalid,
  qsfpdd0_test_axi_m_awready                              => qsfpdd0_test_axi.qsfpdd_test_awready,
  qsfpdd0_test_axi_m_wdata                                => qsfpdd0_test_axi.qsfpdd_test_wdata,
  qsfpdd0_test_axi_m_wstrb                                => qsfpdd0_test_axi.qsfpdd_test_wstrb,
  qsfpdd0_test_axi_m_wvalid                               => qsfpdd0_test_axi.qsfpdd_test_wvalid,
  qsfpdd0_test_axi_m_wready                               => qsfpdd0_test_axi.qsfpdd_test_wready,
  qsfpdd0_test_axi_m_bresp                                => qsfpdd0_test_axi.qsfpdd_test_bresp,
  qsfpdd0_test_axi_m_bvalid                               => qsfpdd0_test_axi.qsfpdd_test_bvalid,
  qsfpdd0_test_axi_m_bready                               => qsfpdd0_test_axi.qsfpdd_test_bready,
  qsfpdd0_test_axi_m_araddr                               => qsfpdd0_test_axi.qsfpdd_test_araddr,
  qsfpdd0_test_axi_m_arprot                               => qsfpdd0_test_axi.qsfpdd_test_arprot,
  qsfpdd0_test_axi_m_arvalid                              => qsfpdd0_test_axi.qsfpdd_test_arvalid,
  qsfpdd0_test_axi_m_arready                              => qsfpdd0_test_axi.qsfpdd_test_arready,
  qsfpdd0_test_axi_m_rdata                                => qsfpdd0_test_axi.qsfpdd_test_rdata,
  qsfpdd0_test_axi_m_rresp                                => qsfpdd0_test_axi.qsfpdd_test_rresp,
  qsfpdd0_test_axi_m_rvalid                               => qsfpdd0_test_axi.qsfpdd_test_rvalid,
  qsfpdd0_test_axi_m_rready                               => qsfpdd0_test_axi.qsfpdd_test_rready,
  qsfpdd1_test_axi_m_awaddr                               => qsfpdd1_test_axi.qsfpdd_test_awaddr,
  qsfpdd1_test_axi_m_awprot                               => qsfpdd1_test_axi.qsfpdd_test_awprot,
  qsfpdd1_test_axi_m_awvalid                              => qsfpdd1_test_axi.qsfpdd_test_awvalid,
  qsfpdd1_test_axi_m_awready                              => qsfpdd1_test_axi.qsfpdd_test_awready,
  qsfpdd1_test_axi_m_wdata                                => qsfpdd1_test_axi.qsfpdd_test_wdata,
  qsfpdd1_test_axi_m_wstrb                                => qsfpdd1_test_axi.qsfpdd_test_wstrb,
  qsfpdd1_test_axi_m_wvalid                               => qsfpdd1_test_axi.qsfpdd_test_wvalid,
  qsfpdd1_test_axi_m_wready                               => qsfpdd1_test_axi.qsfpdd_test_wready,
  qsfpdd1_test_axi_m_bresp                                => qsfpdd1_test_axi.qsfpdd_test_bresp,
  qsfpdd1_test_axi_m_bvalid                               => qsfpdd1_test_axi.qsfpdd_test_bvalid,
  qsfpdd1_test_axi_m_bready                               => qsfpdd1_test_axi.qsfpdd_test_bready,
  qsfpdd1_test_axi_m_araddr                               => qsfpdd1_test_axi.qsfpdd_test_araddr,
  qsfpdd1_test_axi_m_arprot                               => qsfpdd1_test_axi.qsfpdd_test_arprot,
  qsfpdd1_test_axi_m_arvalid                              => qsfpdd1_test_axi.qsfpdd_test_arvalid,
  qsfpdd1_test_axi_m_arready                              => qsfpdd1_test_axi.qsfpdd_test_arready,
  qsfpdd1_test_axi_m_rdata                                => qsfpdd1_test_axi.qsfpdd_test_rdata,
  qsfpdd1_test_axi_m_rresp                                => qsfpdd1_test_axi.qsfpdd_test_rresp,
  qsfpdd1_test_axi_m_rvalid                               => qsfpdd1_test_axi.qsfpdd_test_rvalid,
  qsfpdd1_test_axi_m_rready                               => qsfpdd1_test_axi.qsfpdd_test_rready,
  qsfpdd2_test_axi_m_awaddr                               => qsfpdd2_test_axi.qsfpdd_test_awaddr,
  qsfpdd2_test_axi_m_awprot                               => qsfpdd2_test_axi.qsfpdd_test_awprot,
  qsfpdd2_test_axi_m_awvalid                              => qsfpdd2_test_axi.qsfpdd_test_awvalid,
  qsfpdd2_test_axi_m_awready                              => qsfpdd2_test_axi.qsfpdd_test_awready,
  qsfpdd2_test_axi_m_wdata                                => qsfpdd2_test_axi.qsfpdd_test_wdata,
  qsfpdd2_test_axi_m_wstrb                                => qsfpdd2_test_axi.qsfpdd_test_wstrb,
  qsfpdd2_test_axi_m_wvalid                               => qsfpdd2_test_axi.qsfpdd_test_wvalid,
  qsfpdd2_test_axi_m_wready                               => qsfpdd2_test_axi.qsfpdd_test_wready,
  qsfpdd2_test_axi_m_bresp                                => qsfpdd2_test_axi.qsfpdd_test_bresp,
  qsfpdd2_test_axi_m_bvalid                               => qsfpdd2_test_axi.qsfpdd_test_bvalid,
  qsfpdd2_test_axi_m_bready                               => qsfpdd2_test_axi.qsfpdd_test_bready,
  qsfpdd2_test_axi_m_araddr                               => qsfpdd2_test_axi.qsfpdd_test_araddr,
  qsfpdd2_test_axi_m_arprot                               => qsfpdd2_test_axi.qsfpdd_test_arprot,
  qsfpdd2_test_axi_m_arvalid                              => qsfpdd2_test_axi.qsfpdd_test_arvalid,
  qsfpdd2_test_axi_m_arready                              => qsfpdd2_test_axi.qsfpdd_test_arready,
  qsfpdd2_test_axi_m_rdata                                => qsfpdd2_test_axi.qsfpdd_test_rdata,
  qsfpdd2_test_axi_m_rresp                                => qsfpdd2_test_axi.qsfpdd_test_rresp,
  qsfpdd2_test_axi_m_rvalid                               => qsfpdd2_test_axi.qsfpdd_test_rvalid,
  qsfpdd2_test_axi_m_rready                               => qsfpdd2_test_axi.qsfpdd_test_rready,
  telemetry_test_axi_m_awaddr                             => telemetry_test_axi.telemetry_test_awaddr,
  telemetry_test_axi_m_awprot                             => telemetry_test_axi.telemetry_test_awprot,
  telemetry_test_axi_m_awvalid                            => telemetry_test_axi.telemetry_test_awvalid,
  telemetry_test_axi_m_awready                            => telemetry_test_axi.telemetry_test_awready,
  telemetry_test_axi_m_wdata                              => telemetry_test_axi.telemetry_test_wdata,
  telemetry_test_axi_m_wstrb                              => telemetry_test_axi.telemetry_test_wstrb,
  telemetry_test_axi_m_wvalid                             => telemetry_test_axi.telemetry_test_wvalid,
  telemetry_test_axi_m_wready                             => telemetry_test_axi.telemetry_test_wready,
  telemetry_test_axi_m_bresp                              => telemetry_test_axi.telemetry_test_bresp,
  telemetry_test_axi_m_bvalid                             => telemetry_test_axi.telemetry_test_bvalid,
  telemetry_test_axi_m_bready                             => telemetry_test_axi.telemetry_test_bready,
  telemetry_test_axi_m_araddr                             => telemetry_test_axi.telemetry_test_araddr,
  telemetry_test_axi_m_arprot                             => telemetry_test_axi.telemetry_test_arprot,
  telemetry_test_axi_m_arvalid                            => telemetry_test_axi.telemetry_test_arvalid,
  telemetry_test_axi_m_arready                            => telemetry_test_axi.telemetry_test_arready,
  telemetry_test_axi_m_rdata                              => telemetry_test_axi.telemetry_test_rdata,
  telemetry_test_axi_m_rresp                              => telemetry_test_axi.telemetry_test_rresp,
  telemetry_test_axi_m_rvalid                             => telemetry_test_axi.telemetry_test_rvalid,
  telemetry_test_axi_m_rready                             => telemetry_test_axi.telemetry_test_rready,
  versionid_axi_m_awaddr                                  => versionid_axi.version_awaddr,
  versionid_axi_m_awprot                                  => versionid_axi.version_awprot,
  versionid_axi_m_awvalid                                 => versionid_axi.version_awvalid,
  versionid_axi_m_awready                                 => versionid_axi.version_awready,
  versionid_axi_m_wdata                                   => versionid_axi.version_wdata,
  versionid_axi_m_wstrb                                   => versionid_axi.version_wstrb,
  versionid_axi_m_wvalid                                  => versionid_axi.version_wvalid,
  versionid_axi_m_wready                                  => versionid_axi.version_wready,
  versionid_axi_m_bresp                                   => versionid_axi.version_bresp,
  versionid_axi_m_bvalid                                  => versionid_axi.version_bvalid,
  versionid_axi_m_bready                                  => versionid_axi.version_bready,
  versionid_axi_m_araddr                                  => versionid_axi.version_araddr,
  versionid_axi_m_arprot                                  => versionid_axi.version_arprot,
  versionid_axi_m_arvalid                                 => versionid_axi.version_arvalid,
  versionid_axi_m_arready                                 => versionid_axi.version_arready,
  versionid_axi_m_rdata                                   => versionid_axi.version_rdata,
  versionid_axi_m_rresp                                   => versionid_axi.version_rresp,
  versionid_axi_m_rvalid                                  => versionid_axi.version_rvalid,
  versionid_axi_m_rready                                  => versionid_axi.version_rready,
  hbm2e_status_upper_ch0_ch1_axi_m_awaddr                 => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_awaddr(11 downto 0),
  hbm2e_status_upper_ch0_ch1_axi_m_awprot                 => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_awprot,
  hbm2e_status_upper_ch0_ch1_axi_m_awvalid                => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_awvalid,
  hbm2e_status_upper_ch0_ch1_axi_m_awready                => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_awready,
  hbm2e_status_upper_ch0_ch1_axi_m_wdata                  => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_wdata,
  hbm2e_status_upper_ch0_ch1_axi_m_wstrb                  => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_wstrb,
  hbm2e_status_upper_ch0_ch1_axi_m_wvalid                 => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_wvalid,
  hbm2e_status_upper_ch0_ch1_axi_m_wready                 => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_wready,
  hbm2e_status_upper_ch0_ch1_axi_m_bresp                  => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_bresp,
  hbm2e_status_upper_ch0_ch1_axi_m_bvalid                 => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_bvalid,
  hbm2e_status_upper_ch0_ch1_axi_m_bready                 => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_bready,
  hbm2e_status_upper_ch0_ch1_axi_m_araddr                 => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_araddr(11 downto 0),
  hbm2e_status_upper_ch0_ch1_axi_m_arprot                 => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_arprot,
  hbm2e_status_upper_ch0_ch1_axi_m_arvalid                => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_arvalid,
  hbm2e_status_upper_ch0_ch1_axi_m_arready                => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_arready,
  hbm2e_status_upper_ch0_ch1_axi_m_rdata                  => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_rdata,
  hbm2e_status_upper_ch0_ch1_axi_m_rresp                  => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_rresp,
  hbm2e_status_upper_ch0_ch1_axi_m_rvalid                 => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_rvalid,
  hbm2e_status_upper_ch0_ch1_axi_m_rready                 => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_rready,
  hbm2e_status_upper_ch2_ch3_axi_m_awaddr                 => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_awaddr(11 downto 0),
  hbm2e_status_upper_ch2_ch3_axi_m_awprot                 => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_awprot,
  hbm2e_status_upper_ch2_ch3_axi_m_awvalid                => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_awvalid,
  hbm2e_status_upper_ch2_ch3_axi_m_awready                => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_awready,
  hbm2e_status_upper_ch2_ch3_axi_m_wdata                  => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_wdata,
  hbm2e_status_upper_ch2_ch3_axi_m_wstrb                  => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_wstrb,
  hbm2e_status_upper_ch2_ch3_axi_m_wvalid                 => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_wvalid,
  hbm2e_status_upper_ch2_ch3_axi_m_wready                 => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_wready,
  hbm2e_status_upper_ch2_ch3_axi_m_bresp                  => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_bresp,
  hbm2e_status_upper_ch2_ch3_axi_m_bvalid                 => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_bvalid,
  hbm2e_status_upper_ch2_ch3_axi_m_bready                 => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_bready,
  hbm2e_status_upper_ch2_ch3_axi_m_araddr                 => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_araddr(11 downto 0),
  hbm2e_status_upper_ch2_ch3_axi_m_arprot                 => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_arprot,
  hbm2e_status_upper_ch2_ch3_axi_m_arvalid                => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_arvalid,
  hbm2e_status_upper_ch2_ch3_axi_m_arready                => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_arready,
  hbm2e_status_upper_ch2_ch3_axi_m_rdata                  => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_rdata,
  hbm2e_status_upper_ch2_ch3_axi_m_rresp                  => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_rresp,
  hbm2e_status_upper_ch2_ch3_axi_m_rvalid                 => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_rvalid,
  hbm2e_status_upper_ch2_ch3_axi_m_rready                 => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_rready,
  hbm2e_status_upper_ch4_ch5_axi_m_awaddr                 => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_awaddr(11 downto 0),
  hbm2e_status_upper_ch4_ch5_axi_m_awprot                 => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_awprot,
  hbm2e_status_upper_ch4_ch5_axi_m_awvalid                => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_awvalid,
  hbm2e_status_upper_ch4_ch5_axi_m_awready                => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_awready,
  hbm2e_status_upper_ch4_ch5_axi_m_wdata                  => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_wdata,
  hbm2e_status_upper_ch4_ch5_axi_m_wstrb                  => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_wstrb,
  hbm2e_status_upper_ch4_ch5_axi_m_wvalid                 => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_wvalid,
  hbm2e_status_upper_ch4_ch5_axi_m_wready                 => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_wready,
  hbm2e_status_upper_ch4_ch5_axi_m_bresp                  => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_bresp,
  hbm2e_status_upper_ch4_ch5_axi_m_bvalid                 => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_bvalid,
  hbm2e_status_upper_ch4_ch5_axi_m_bready                 => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_bready,
  hbm2e_status_upper_ch4_ch5_axi_m_araddr                 => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_araddr(11 downto 0),
  hbm2e_status_upper_ch4_ch5_axi_m_arprot                 => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_arprot,
  hbm2e_status_upper_ch4_ch5_axi_m_arvalid                => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_arvalid,
  hbm2e_status_upper_ch4_ch5_axi_m_arready                => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_arready,
  hbm2e_status_upper_ch4_ch5_axi_m_rdata                  => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_rdata,
  hbm2e_status_upper_ch4_ch5_axi_m_rresp                  => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_rresp,
  hbm2e_status_upper_ch4_ch5_axi_m_rvalid                 => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_rvalid,
  hbm2e_status_upper_ch4_ch5_axi_m_rready                 => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_rready,
  hbm2e_status_upper_ch6_ch7_axi_m_awaddr                 => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_awaddr(11 downto 0),
  hbm2e_status_upper_ch6_ch7_axi_m_awprot                 => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_awprot,
  hbm2e_status_upper_ch6_ch7_axi_m_awvalid                => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_awvalid,
  hbm2e_status_upper_ch6_ch7_axi_m_awready                => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_awready,
  hbm2e_status_upper_ch6_ch7_axi_m_wdata                  => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_wdata,
  hbm2e_status_upper_ch6_ch7_axi_m_wstrb                  => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_wstrb,
  hbm2e_status_upper_ch6_ch7_axi_m_wvalid                 => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_wvalid,
  hbm2e_status_upper_ch6_ch7_axi_m_wready                 => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_wready,
  hbm2e_status_upper_ch6_ch7_axi_m_bresp                  => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_bresp,
  hbm2e_status_upper_ch6_ch7_axi_m_bvalid                 => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_bvalid,
  hbm2e_status_upper_ch6_ch7_axi_m_bready                 => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_bready,
  hbm2e_status_upper_ch6_ch7_axi_m_araddr                 => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_araddr(11 downto 0),
  hbm2e_status_upper_ch6_ch7_axi_m_arprot                 => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_arprot,
  hbm2e_status_upper_ch6_ch7_axi_m_arvalid                => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_arvalid,
  hbm2e_status_upper_ch6_ch7_axi_m_arready                => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_arready,
  hbm2e_status_upper_ch6_ch7_axi_m_rdata                  => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_rdata,
  hbm2e_status_upper_ch6_ch7_axi_m_rresp                  => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_rresp,
  hbm2e_status_upper_ch6_ch7_axi_m_rvalid                 => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_rvalid,
  hbm2e_status_upper_ch6_ch7_axi_m_rready                 => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_rready,
  hbm2e_status_lower_ch0_ch1_axi_m_awaddr                 => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_awaddr(11 downto 0),
  hbm2e_status_lower_ch0_ch1_axi_m_awprot                 => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_awprot,
  hbm2e_status_lower_ch0_ch1_axi_m_awvalid                => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_awvalid,
  hbm2e_status_lower_ch0_ch1_axi_m_awready                => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_awready,
  hbm2e_status_lower_ch0_ch1_axi_m_wdata                  => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_wdata,
  hbm2e_status_lower_ch0_ch1_axi_m_wstrb                  => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_wstrb,
  hbm2e_status_lower_ch0_ch1_axi_m_wvalid                 => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_wvalid,
  hbm2e_status_lower_ch0_ch1_axi_m_wready                 => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_wready,
  hbm2e_status_lower_ch0_ch1_axi_m_bresp                  => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_bresp,
  hbm2e_status_lower_ch0_ch1_axi_m_bvalid                 => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_bvalid,
  hbm2e_status_lower_ch0_ch1_axi_m_bready                 => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_bready,
  hbm2e_status_lower_ch0_ch1_axi_m_araddr                 => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_araddr(11 downto 0),
  hbm2e_status_lower_ch0_ch1_axi_m_arprot                 => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_arprot,
  hbm2e_status_lower_ch0_ch1_axi_m_arvalid                => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_arvalid,
  hbm2e_status_lower_ch0_ch1_axi_m_arready                => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_arready,
  hbm2e_status_lower_ch0_ch1_axi_m_rdata                  => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_rdata,
  hbm2e_status_lower_ch0_ch1_axi_m_rresp                  => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_rresp,
  hbm2e_status_lower_ch0_ch1_axi_m_rvalid                 => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_rvalid,
  hbm2e_status_lower_ch0_ch1_axi_m_rready                 => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_rready,
  hbm2e_status_lower_ch2_ch3_axi_m_awaddr                 => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_awaddr(11 downto 0),
  hbm2e_status_lower_ch2_ch3_axi_m_awprot                 => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_awprot,
  hbm2e_status_lower_ch2_ch3_axi_m_awvalid                => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_awvalid,
  hbm2e_status_lower_ch2_ch3_axi_m_awready                => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_awready,
  hbm2e_status_lower_ch2_ch3_axi_m_wdata                  => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_wdata,
  hbm2e_status_lower_ch2_ch3_axi_m_wstrb                  => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_wstrb,
  hbm2e_status_lower_ch2_ch3_axi_m_wvalid                 => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_wvalid,
  hbm2e_status_lower_ch2_ch3_axi_m_wready                 => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_wready,
  hbm2e_status_lower_ch2_ch3_axi_m_bresp                  => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_bresp,
  hbm2e_status_lower_ch2_ch3_axi_m_bvalid                 => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_bvalid,
  hbm2e_status_lower_ch2_ch3_axi_m_bready                 => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_bready,
  hbm2e_status_lower_ch2_ch3_axi_m_araddr                 => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_araddr(11 downto 0),
  hbm2e_status_lower_ch2_ch3_axi_m_arprot                 => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_arprot,
  hbm2e_status_lower_ch2_ch3_axi_m_arvalid                => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_arvalid,
  hbm2e_status_lower_ch2_ch3_axi_m_arready                => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_arready,
  hbm2e_status_lower_ch2_ch3_axi_m_rdata                  => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_rdata,
  hbm2e_status_lower_ch2_ch3_axi_m_rresp                  => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_rresp,
  hbm2e_status_lower_ch2_ch3_axi_m_rvalid                 => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_rvalid,
  hbm2e_status_lower_ch2_ch3_axi_m_rready                 => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_rready,
  hbm2e_status_lower_ch4_ch5_axi_m_awaddr                 => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_awaddr(11 downto 0),
  hbm2e_status_lower_ch4_ch5_axi_m_awprot                 => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_awprot,
  hbm2e_status_lower_ch4_ch5_axi_m_awvalid                => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_awvalid,
  hbm2e_status_lower_ch4_ch5_axi_m_awready                => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_awready,
  hbm2e_status_lower_ch4_ch5_axi_m_wdata                  => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_wdata,
  hbm2e_status_lower_ch4_ch5_axi_m_wstrb                  => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_wstrb,
  hbm2e_status_lower_ch4_ch5_axi_m_wvalid                 => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_wvalid,
  hbm2e_status_lower_ch4_ch5_axi_m_wready                 => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_wready,
  hbm2e_status_lower_ch4_ch5_axi_m_bresp                  => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_bresp,
  hbm2e_status_lower_ch4_ch5_axi_m_bvalid                 => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_bvalid,
  hbm2e_status_lower_ch4_ch5_axi_m_bready                 => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_bready,
  hbm2e_status_lower_ch4_ch5_axi_m_araddr                 => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_araddr(11 downto 0),
  hbm2e_status_lower_ch4_ch5_axi_m_arprot                 => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_arprot,
  hbm2e_status_lower_ch4_ch5_axi_m_arvalid                => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_arvalid,
  hbm2e_status_lower_ch4_ch5_axi_m_arready                => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_arready,
  hbm2e_status_lower_ch4_ch5_axi_m_rdata                  => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_rdata,
  hbm2e_status_lower_ch4_ch5_axi_m_rresp                  => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_rresp,
  hbm2e_status_lower_ch4_ch5_axi_m_rvalid                 => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_rvalid,
  hbm2e_status_lower_ch4_ch5_axi_m_rready                 => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_rready,
  hbm2e_status_lower_ch6_ch7_axi_m_awaddr                 => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_awaddr(11 downto 0),
  hbm2e_status_lower_ch6_ch7_axi_m_awprot                 => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_awprot,
  hbm2e_status_lower_ch6_ch7_axi_m_awvalid                => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_awvalid,
  hbm2e_status_lower_ch6_ch7_axi_m_awready                => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_awready,
  hbm2e_status_lower_ch6_ch7_axi_m_wdata                  => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_wdata,
  hbm2e_status_lower_ch6_ch7_axi_m_wstrb                  => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_wstrb,
  hbm2e_status_lower_ch6_ch7_axi_m_wvalid                 => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_wvalid,
  hbm2e_status_lower_ch6_ch7_axi_m_wready                 => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_wready,
  hbm2e_status_lower_ch6_ch7_axi_m_bresp                  => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_bresp,
  hbm2e_status_lower_ch6_ch7_axi_m_bvalid                 => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_bvalid,
  hbm2e_status_lower_ch6_ch7_axi_m_bready                 => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_bready,
  hbm2e_status_lower_ch6_ch7_axi_m_araddr                 => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_araddr(11 downto 0),
  hbm2e_status_lower_ch6_ch7_axi_m_arprot                 => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_arprot,
  hbm2e_status_lower_ch6_ch7_axi_m_arvalid                => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_arvalid,
  hbm2e_status_lower_ch6_ch7_axi_m_arready                => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_arready,
  hbm2e_status_lower_ch6_ch7_axi_m_rdata                  => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_rdata,
  hbm2e_status_lower_ch6_ch7_axi_m_rresp                  => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_rresp,
  hbm2e_status_lower_ch6_ch7_axi_m_rvalid                 => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_rvalid,
  hbm2e_status_lower_ch6_ch7_axi_m_rready                 => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_rready,
  hbm2e_upper_test_ch0_u0_axi_m_awaddr                    => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_upper_test_ch0_u0_axi_m_awprot                    => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_awprot,
  hbm2e_upper_test_ch0_u0_axi_m_awvalid                   => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_upper_test_ch0_u0_axi_m_awready                   => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_awready,
  hbm2e_upper_test_ch0_u0_axi_m_wdata                     => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_wdata,
  hbm2e_upper_test_ch0_u0_axi_m_wstrb                     => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_upper_test_ch0_u0_axi_m_wvalid                    => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_upper_test_ch0_u0_axi_m_wready                    => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_wready,
  hbm2e_upper_test_ch0_u0_axi_m_bresp                     => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_bresp,
  hbm2e_upper_test_ch0_u0_axi_m_bvalid                    => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_upper_test_ch0_u0_axi_m_bready                    => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_bready,
  hbm2e_upper_test_ch0_u0_axi_m_araddr                    => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_araddr,
  hbm2e_upper_test_ch0_u0_axi_m_arprot                    => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_arprot,
  hbm2e_upper_test_ch0_u0_axi_m_arvalid                   => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_upper_test_ch0_u0_axi_m_arready                   => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_arready,
  hbm2e_upper_test_ch0_u0_axi_m_rdata                     => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_rdata,
  hbm2e_upper_test_ch0_u0_axi_m_rresp                     => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_rresp,
  hbm2e_upper_test_ch0_u0_axi_m_rvalid                    => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_upper_test_ch0_u0_axi_m_rready                    => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_rready,
  hbm2e_upper_test_ch0_u1_axi_m_awaddr                    => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_upper_test_ch0_u1_axi_m_awprot                    => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_awprot,
  hbm2e_upper_test_ch0_u1_axi_m_awvalid                   => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_upper_test_ch0_u1_axi_m_awready                   => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_awready,
  hbm2e_upper_test_ch0_u1_axi_m_wdata                     => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_wdata,
  hbm2e_upper_test_ch0_u1_axi_m_wstrb                     => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_upper_test_ch0_u1_axi_m_wvalid                    => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_upper_test_ch0_u1_axi_m_wready                    => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_wready,
  hbm2e_upper_test_ch0_u1_axi_m_bresp                     => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_bresp,
  hbm2e_upper_test_ch0_u1_axi_m_bvalid                    => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_upper_test_ch0_u1_axi_m_bready                    => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_bready,
  hbm2e_upper_test_ch0_u1_axi_m_araddr                    => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_araddr,
  hbm2e_upper_test_ch0_u1_axi_m_arprot                    => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_arprot,
  hbm2e_upper_test_ch0_u1_axi_m_arvalid                   => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_upper_test_ch0_u1_axi_m_arready                   => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_arready,
  hbm2e_upper_test_ch0_u1_axi_m_rdata                     => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_rdata,
  hbm2e_upper_test_ch0_u1_axi_m_rresp                     => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_rresp,
  hbm2e_upper_test_ch0_u1_axi_m_rvalid                    => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_upper_test_ch0_u1_axi_m_rready                    => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_rready,
  hbm2e_upper_test_ch1_u0_axi_m_awaddr                    => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_upper_test_ch1_u0_axi_m_awprot                    => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_awprot,
  hbm2e_upper_test_ch1_u0_axi_m_awvalid                   => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_upper_test_ch1_u0_axi_m_awready                   => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_awready,
  hbm2e_upper_test_ch1_u0_axi_m_wdata                     => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_wdata,
  hbm2e_upper_test_ch1_u0_axi_m_wstrb                     => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_upper_test_ch1_u0_axi_m_wvalid                    => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_upper_test_ch1_u0_axi_m_wready                    => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_wready,
  hbm2e_upper_test_ch1_u0_axi_m_bresp                     => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_bresp,
  hbm2e_upper_test_ch1_u0_axi_m_bvalid                    => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_upper_test_ch1_u0_axi_m_bready                    => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_bready,
  hbm2e_upper_test_ch1_u0_axi_m_araddr                    => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_araddr,
  hbm2e_upper_test_ch1_u0_axi_m_arprot                    => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_arprot,
  hbm2e_upper_test_ch1_u0_axi_m_arvalid                   => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_upper_test_ch1_u0_axi_m_arready                   => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_arready,
  hbm2e_upper_test_ch1_u0_axi_m_rdata                     => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_rdata,
  hbm2e_upper_test_ch1_u0_axi_m_rresp                     => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_rresp,
  hbm2e_upper_test_ch1_u0_axi_m_rvalid                    => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_upper_test_ch1_u0_axi_m_rready                    => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_rready,
  hbm2e_upper_test_ch1_u1_axi_m_awaddr                    => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_upper_test_ch1_u1_axi_m_awprot                    => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_awprot,
  hbm2e_upper_test_ch1_u1_axi_m_awvalid                   => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_upper_test_ch1_u1_axi_m_awready                   => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_awready,
  hbm2e_upper_test_ch1_u1_axi_m_wdata                     => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_wdata,
  hbm2e_upper_test_ch1_u1_axi_m_wstrb                     => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_upper_test_ch1_u1_axi_m_wvalid                    => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_upper_test_ch1_u1_axi_m_wready                    => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_wready,
  hbm2e_upper_test_ch1_u1_axi_m_bresp                     => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_bresp,
  hbm2e_upper_test_ch1_u1_axi_m_bvalid                    => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_upper_test_ch1_u1_axi_m_bready                    => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_bready,
  hbm2e_upper_test_ch1_u1_axi_m_araddr                    => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_araddr,
  hbm2e_upper_test_ch1_u1_axi_m_arprot                    => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_arprot,
  hbm2e_upper_test_ch1_u1_axi_m_arvalid                   => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_upper_test_ch1_u1_axi_m_arready                   => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_arready,
  hbm2e_upper_test_ch1_u1_axi_m_rdata                     => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_rdata,
  hbm2e_upper_test_ch1_u1_axi_m_rresp                     => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_rresp,
  hbm2e_upper_test_ch1_u1_axi_m_rvalid                    => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_upper_test_ch1_u1_axi_m_rready                    => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_rready,
  hbm2e_upper_test_ch2_u0_axi_m_awaddr                    => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_upper_test_ch2_u0_axi_m_awprot                    => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_awprot,
  hbm2e_upper_test_ch2_u0_axi_m_awvalid                   => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_upper_test_ch2_u0_axi_m_awready                   => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_awready,
  hbm2e_upper_test_ch2_u0_axi_m_wdata                     => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_wdata,
  hbm2e_upper_test_ch2_u0_axi_m_wstrb                     => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_upper_test_ch2_u0_axi_m_wvalid                    => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_upper_test_ch2_u0_axi_m_wready                    => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_wready,
  hbm2e_upper_test_ch2_u0_axi_m_bresp                     => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_bresp,
  hbm2e_upper_test_ch2_u0_axi_m_bvalid                    => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_upper_test_ch2_u0_axi_m_bready                    => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_bready,
  hbm2e_upper_test_ch2_u0_axi_m_araddr                    => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_araddr,
  hbm2e_upper_test_ch2_u0_axi_m_arprot                    => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_arprot,
  hbm2e_upper_test_ch2_u0_axi_m_arvalid                   => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_upper_test_ch2_u0_axi_m_arready                   => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_arready,
  hbm2e_upper_test_ch2_u0_axi_m_rdata                     => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_rdata,
  hbm2e_upper_test_ch2_u0_axi_m_rresp                     => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_rresp,
  hbm2e_upper_test_ch2_u0_axi_m_rvalid                    => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_upper_test_ch2_u0_axi_m_rready                    => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_rready,
  hbm2e_upper_test_ch2_u1_axi_m_awaddr                    => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_upper_test_ch2_u1_axi_m_awprot                    => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_awprot,
  hbm2e_upper_test_ch2_u1_axi_m_awvalid                   => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_upper_test_ch2_u1_axi_m_awready                   => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_awready,
  hbm2e_upper_test_ch2_u1_axi_m_wdata                     => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_wdata,
  hbm2e_upper_test_ch2_u1_axi_m_wstrb                     => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_upper_test_ch2_u1_axi_m_wvalid                    => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_upper_test_ch2_u1_axi_m_wready                    => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_wready,
  hbm2e_upper_test_ch2_u1_axi_m_bresp                     => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_bresp,
  hbm2e_upper_test_ch2_u1_axi_m_bvalid                    => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_upper_test_ch2_u1_axi_m_bready                    => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_bready,
  hbm2e_upper_test_ch2_u1_axi_m_araddr                    => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_araddr,
  hbm2e_upper_test_ch2_u1_axi_m_arprot                    => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_arprot,
  hbm2e_upper_test_ch2_u1_axi_m_arvalid                   => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_upper_test_ch2_u1_axi_m_arready                   => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_arready,
  hbm2e_upper_test_ch2_u1_axi_m_rdata                     => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_rdata,
  hbm2e_upper_test_ch2_u1_axi_m_rresp                     => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_rresp,
  hbm2e_upper_test_ch2_u1_axi_m_rvalid                    => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_upper_test_ch2_u1_axi_m_rready                    => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_rready,
  hbm2e_upper_test_ch3_u0_axi_m_awaddr                    => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_upper_test_ch3_u0_axi_m_awprot                    => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_awprot,
  hbm2e_upper_test_ch3_u0_axi_m_awvalid                   => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_upper_test_ch3_u0_axi_m_awready                   => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_awready,
  hbm2e_upper_test_ch3_u0_axi_m_wdata                     => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_wdata,
  hbm2e_upper_test_ch3_u0_axi_m_wstrb                     => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_upper_test_ch3_u0_axi_m_wvalid                    => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_upper_test_ch3_u0_axi_m_wready                    => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_wready,
  hbm2e_upper_test_ch3_u0_axi_m_bresp                     => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_bresp,
  hbm2e_upper_test_ch3_u0_axi_m_bvalid                    => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_upper_test_ch3_u0_axi_m_bready                    => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_bready,
  hbm2e_upper_test_ch3_u0_axi_m_araddr                    => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_araddr,
  hbm2e_upper_test_ch3_u0_axi_m_arprot                    => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_arprot,
  hbm2e_upper_test_ch3_u0_axi_m_arvalid                   => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_upper_test_ch3_u0_axi_m_arready                   => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_arready,
  hbm2e_upper_test_ch3_u0_axi_m_rdata                     => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_rdata,
  hbm2e_upper_test_ch3_u0_axi_m_rresp                     => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_rresp,
  hbm2e_upper_test_ch3_u0_axi_m_rvalid                    => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_upper_test_ch3_u0_axi_m_rready                    => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_rready,
  hbm2e_upper_test_ch3_u1_axi_m_awaddr                    => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_upper_test_ch3_u1_axi_m_awprot                    => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_awprot,
  hbm2e_upper_test_ch3_u1_axi_m_awvalid                   => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_upper_test_ch3_u1_axi_m_awready                   => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_awready,
  hbm2e_upper_test_ch3_u1_axi_m_wdata                     => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_wdata,
  hbm2e_upper_test_ch3_u1_axi_m_wstrb                     => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_upper_test_ch3_u1_axi_m_wvalid                    => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_upper_test_ch3_u1_axi_m_wready                    => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_wready,
  hbm2e_upper_test_ch3_u1_axi_m_bresp                     => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_bresp,
  hbm2e_upper_test_ch3_u1_axi_m_bvalid                    => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_upper_test_ch3_u1_axi_m_bready                    => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_bready,
  hbm2e_upper_test_ch3_u1_axi_m_araddr                    => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_araddr,
  hbm2e_upper_test_ch3_u1_axi_m_arprot                    => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_arprot,
  hbm2e_upper_test_ch3_u1_axi_m_arvalid                   => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_upper_test_ch3_u1_axi_m_arready                   => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_arready,
  hbm2e_upper_test_ch3_u1_axi_m_rdata                     => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_rdata,
  hbm2e_upper_test_ch3_u1_axi_m_rresp                     => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_rresp,
  hbm2e_upper_test_ch3_u1_axi_m_rvalid                    => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_upper_test_ch3_u1_axi_m_rready                    => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_rready,
  hbm2e_upper_test_ch4_u0_axi_m_awaddr                    => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_upper_test_ch4_u0_axi_m_awprot                    => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_awprot,
  hbm2e_upper_test_ch4_u0_axi_m_awvalid                   => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_upper_test_ch4_u0_axi_m_awready                   => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_awready,
  hbm2e_upper_test_ch4_u0_axi_m_wdata                     => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_wdata,
  hbm2e_upper_test_ch4_u0_axi_m_wstrb                     => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_upper_test_ch4_u0_axi_m_wvalid                    => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_upper_test_ch4_u0_axi_m_wready                    => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_wready,
  hbm2e_upper_test_ch4_u0_axi_m_bresp                     => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_bresp,
  hbm2e_upper_test_ch4_u0_axi_m_bvalid                    => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_upper_test_ch4_u0_axi_m_bready                    => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_bready,
  hbm2e_upper_test_ch4_u0_axi_m_araddr                    => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_araddr,
  hbm2e_upper_test_ch4_u0_axi_m_arprot                    => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_arprot,
  hbm2e_upper_test_ch4_u0_axi_m_arvalid                   => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_upper_test_ch4_u0_axi_m_arready                   => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_arready,
  hbm2e_upper_test_ch4_u0_axi_m_rdata                     => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_rdata,
  hbm2e_upper_test_ch4_u0_axi_m_rresp                     => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_rresp,
  hbm2e_upper_test_ch4_u0_axi_m_rvalid                    => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_upper_test_ch4_u0_axi_m_rready                    => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_rready,
  hbm2e_upper_test_ch4_u1_axi_m_awaddr                    => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_upper_test_ch4_u1_axi_m_awprot                    => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_awprot,
  hbm2e_upper_test_ch4_u1_axi_m_awvalid                   => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_upper_test_ch4_u1_axi_m_awready                   => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_awready,
  hbm2e_upper_test_ch4_u1_axi_m_wdata                     => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_wdata,
  hbm2e_upper_test_ch4_u1_axi_m_wstrb                     => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_upper_test_ch4_u1_axi_m_wvalid                    => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_upper_test_ch4_u1_axi_m_wready                    => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_wready,
  hbm2e_upper_test_ch4_u1_axi_m_bresp                     => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_bresp,
  hbm2e_upper_test_ch4_u1_axi_m_bvalid                    => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_upper_test_ch4_u1_axi_m_bready                    => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_bready,
  hbm2e_upper_test_ch4_u1_axi_m_araddr                    => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_araddr,
  hbm2e_upper_test_ch4_u1_axi_m_arprot                    => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_arprot,
  hbm2e_upper_test_ch4_u1_axi_m_arvalid                   => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_upper_test_ch4_u1_axi_m_arready                   => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_arready,
  hbm2e_upper_test_ch4_u1_axi_m_rdata                     => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_rdata,
  hbm2e_upper_test_ch4_u1_axi_m_rresp                     => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_rresp,
  hbm2e_upper_test_ch4_u1_axi_m_rvalid                    => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_upper_test_ch4_u1_axi_m_rready                    => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_rready,
  hbm2e_upper_test_ch5_u0_axi_m_awaddr                    => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_upper_test_ch5_u0_axi_m_awprot                    => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_awprot,
  hbm2e_upper_test_ch5_u0_axi_m_awvalid                   => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_upper_test_ch5_u0_axi_m_awready                   => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_awready,
  hbm2e_upper_test_ch5_u0_axi_m_wdata                     => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_wdata,
  hbm2e_upper_test_ch5_u0_axi_m_wstrb                     => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_upper_test_ch5_u0_axi_m_wvalid                    => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_upper_test_ch5_u0_axi_m_wready                    => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_wready,
  hbm2e_upper_test_ch5_u0_axi_m_bresp                     => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_bresp,
  hbm2e_upper_test_ch5_u0_axi_m_bvalid                    => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_upper_test_ch5_u0_axi_m_bready                    => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_bready,
  hbm2e_upper_test_ch5_u0_axi_m_araddr                    => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_araddr,
  hbm2e_upper_test_ch5_u0_axi_m_arprot                    => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_arprot,
  hbm2e_upper_test_ch5_u0_axi_m_arvalid                   => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_upper_test_ch5_u0_axi_m_arready                   => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_arready,
  hbm2e_upper_test_ch5_u0_axi_m_rdata                     => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_rdata,
  hbm2e_upper_test_ch5_u0_axi_m_rresp                     => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_rresp,
  hbm2e_upper_test_ch5_u0_axi_m_rvalid                    => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_upper_test_ch5_u0_axi_m_rready                    => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_rready,
  hbm2e_upper_test_ch5_u1_axi_m_awaddr                    => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_upper_test_ch5_u1_axi_m_awprot                    => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_awprot,
  hbm2e_upper_test_ch5_u1_axi_m_awvalid                   => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_upper_test_ch5_u1_axi_m_awready                   => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_awready,
  hbm2e_upper_test_ch5_u1_axi_m_wdata                     => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_wdata,
  hbm2e_upper_test_ch5_u1_axi_m_wstrb                     => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_upper_test_ch5_u1_axi_m_wvalid                    => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_upper_test_ch5_u1_axi_m_wready                    => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_wready,
  hbm2e_upper_test_ch5_u1_axi_m_bresp                     => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_bresp,
  hbm2e_upper_test_ch5_u1_axi_m_bvalid                    => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_upper_test_ch5_u1_axi_m_bready                    => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_bready,
  hbm2e_upper_test_ch5_u1_axi_m_araddr                    => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_araddr,
  hbm2e_upper_test_ch5_u1_axi_m_arprot                    => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_arprot,
  hbm2e_upper_test_ch5_u1_axi_m_arvalid                   => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_upper_test_ch5_u1_axi_m_arready                   => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_arready,
  hbm2e_upper_test_ch5_u1_axi_m_rdata                     => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_rdata,
  hbm2e_upper_test_ch5_u1_axi_m_rresp                     => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_rresp,
  hbm2e_upper_test_ch5_u1_axi_m_rvalid                    => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_upper_test_ch5_u1_axi_m_rready                    => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_rready,
  hbm2e_upper_test_ch6_u0_axi_m_awaddr                    => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_upper_test_ch6_u0_axi_m_awprot                    => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_awprot,
  hbm2e_upper_test_ch6_u0_axi_m_awvalid                   => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_upper_test_ch6_u0_axi_m_awready                   => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_awready,
  hbm2e_upper_test_ch6_u0_axi_m_wdata                     => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_wdata,
  hbm2e_upper_test_ch6_u0_axi_m_wstrb                     => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_upper_test_ch6_u0_axi_m_wvalid                    => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_upper_test_ch6_u0_axi_m_wready                    => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_wready,
  hbm2e_upper_test_ch6_u0_axi_m_bresp                     => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_bresp,
  hbm2e_upper_test_ch6_u0_axi_m_bvalid                    => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_upper_test_ch6_u0_axi_m_bready                    => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_bready,
  hbm2e_upper_test_ch6_u0_axi_m_araddr                    => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_araddr,
  hbm2e_upper_test_ch6_u0_axi_m_arprot                    => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_arprot,
  hbm2e_upper_test_ch6_u0_axi_m_arvalid                   => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_upper_test_ch6_u0_axi_m_arready                   => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_arready,
  hbm2e_upper_test_ch6_u0_axi_m_rdata                     => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_rdata,
  hbm2e_upper_test_ch6_u0_axi_m_rresp                     => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_rresp,
  hbm2e_upper_test_ch6_u0_axi_m_rvalid                    => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_upper_test_ch6_u0_axi_m_rready                    => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_rready,
  hbm2e_upper_test_ch6_u1_axi_m_awaddr                    => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_upper_test_ch6_u1_axi_m_awprot                    => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_awprot,
  hbm2e_upper_test_ch6_u1_axi_m_awvalid                   => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_upper_test_ch6_u1_axi_m_awready                   => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_awready,
  hbm2e_upper_test_ch6_u1_axi_m_wdata                     => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_wdata,
  hbm2e_upper_test_ch6_u1_axi_m_wstrb                     => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_upper_test_ch6_u1_axi_m_wvalid                    => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_upper_test_ch6_u1_axi_m_wready                    => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_wready,
  hbm2e_upper_test_ch6_u1_axi_m_bresp                     => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_bresp,
  hbm2e_upper_test_ch6_u1_axi_m_bvalid                    => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_upper_test_ch6_u1_axi_m_bready                    => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_bready,
  hbm2e_upper_test_ch6_u1_axi_m_araddr                    => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_araddr,
  hbm2e_upper_test_ch6_u1_axi_m_arprot                    => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_arprot,
  hbm2e_upper_test_ch6_u1_axi_m_arvalid                   => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_upper_test_ch6_u1_axi_m_arready                   => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_arready,
  hbm2e_upper_test_ch6_u1_axi_m_rdata                     => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_rdata,
  hbm2e_upper_test_ch6_u1_axi_m_rresp                     => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_rresp,
  hbm2e_upper_test_ch6_u1_axi_m_rvalid                    => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_upper_test_ch6_u1_axi_m_rready                    => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_rready,
  hbm2e_upper_test_ch7_u0_axi_m_awaddr                    => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_upper_test_ch7_u0_axi_m_awprot                    => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_awprot,
  hbm2e_upper_test_ch7_u0_axi_m_awvalid                   => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_upper_test_ch7_u0_axi_m_awready                   => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_awready,
  hbm2e_upper_test_ch7_u0_axi_m_wdata                     => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_wdata,
  hbm2e_upper_test_ch7_u0_axi_m_wstrb                     => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_upper_test_ch7_u0_axi_m_wvalid                    => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_upper_test_ch7_u0_axi_m_wready                    => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_wready,
  hbm2e_upper_test_ch7_u0_axi_m_bresp                     => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_bresp,
  hbm2e_upper_test_ch7_u0_axi_m_bvalid                    => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_upper_test_ch7_u0_axi_m_bready                    => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_bready,
  hbm2e_upper_test_ch7_u0_axi_m_araddr                    => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_araddr,
  hbm2e_upper_test_ch7_u0_axi_m_arprot                    => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_arprot,
  hbm2e_upper_test_ch7_u0_axi_m_arvalid                   => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_upper_test_ch7_u0_axi_m_arready                   => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_arready,
  hbm2e_upper_test_ch7_u0_axi_m_rdata                     => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_rdata,
  hbm2e_upper_test_ch7_u0_axi_m_rresp                     => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_rresp,
  hbm2e_upper_test_ch7_u0_axi_m_rvalid                    => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_upper_test_ch7_u0_axi_m_rready                    => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_rready,
  hbm2e_upper_test_ch7_u1_axi_m_awaddr                    => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_upper_test_ch7_u1_axi_m_awprot                    => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_awprot,
  hbm2e_upper_test_ch7_u1_axi_m_awvalid                   => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_upper_test_ch7_u1_axi_m_awready                   => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_awready,
  hbm2e_upper_test_ch7_u1_axi_m_wdata                     => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_wdata,
  hbm2e_upper_test_ch7_u1_axi_m_wstrb                     => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_upper_test_ch7_u1_axi_m_wvalid                    => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_upper_test_ch7_u1_axi_m_wready                    => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_wready,
  hbm2e_upper_test_ch7_u1_axi_m_bresp                     => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_bresp,
  hbm2e_upper_test_ch7_u1_axi_m_bvalid                    => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_upper_test_ch7_u1_axi_m_bready                    => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_bready,
  hbm2e_upper_test_ch7_u1_axi_m_araddr                    => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_araddr,
  hbm2e_upper_test_ch7_u1_axi_m_arprot                    => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_arprot,
  hbm2e_upper_test_ch7_u1_axi_m_arvalid                   => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_upper_test_ch7_u1_axi_m_arready                   => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_arready,
  hbm2e_upper_test_ch7_u1_axi_m_rdata                     => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_rdata,
  hbm2e_upper_test_ch7_u1_axi_m_rresp                     => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_rresp,
  hbm2e_upper_test_ch7_u1_axi_m_rvalid                    => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_upper_test_ch7_u1_axi_m_rready                    => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_rready,
  hbm2e_upper_error_log_ch0_u0_axi_m_awaddr               => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_awaddr, 
  hbm2e_upper_error_log_ch0_u0_axi_m_awprot               => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_awprot,
  hbm2e_upper_error_log_ch0_u0_axi_m_awvalid              => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_awvalid,
  hbm2e_upper_error_log_ch0_u0_axi_m_awready              => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_awready, 
  hbm2e_upper_error_log_ch0_u0_axi_m_wdata                => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_wdata,  
  hbm2e_upper_error_log_ch0_u0_axi_m_wstrb                => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_wstrb,  
  hbm2e_upper_error_log_ch0_u0_axi_m_wvalid               => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_wvalid,
  hbm2e_upper_error_log_ch0_u0_axi_m_wready               => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_wready,
  hbm2e_upper_error_log_ch0_u0_axi_m_bresp                => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_bresp,	
  hbm2e_upper_error_log_ch0_u0_axi_m_bvalid               => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_bvalid,	
  hbm2e_upper_error_log_ch0_u0_axi_m_bready               => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_bready,	
  hbm2e_upper_error_log_ch0_u0_axi_m_araddr               => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_araddr, 	
  hbm2e_upper_error_log_ch0_u0_axi_m_arprot               => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_arprot,	
  hbm2e_upper_error_log_ch0_u0_axi_m_arvalid              => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_arvalid,	
  hbm2e_upper_error_log_ch0_u0_axi_m_arready              => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_arready, 
  hbm2e_upper_error_log_ch0_u0_axi_m_rdata                => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_rdata,	
  hbm2e_upper_error_log_ch0_u0_axi_m_rresp                => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_rresp,	
  hbm2e_upper_error_log_ch0_u0_axi_m_rvalid               => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_rvalid,	
  hbm2e_upper_error_log_ch0_u0_axi_m_rready               => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_rready, 
  hbm2e_upper_error_log_ch0_u1_axi_m_awaddr               => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_awaddr, 
  hbm2e_upper_error_log_ch0_u1_axi_m_awprot               => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_awprot,
  hbm2e_upper_error_log_ch0_u1_axi_m_awvalid              => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_awvalid,
  hbm2e_upper_error_log_ch0_u1_axi_m_awready              => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_awready, 
  hbm2e_upper_error_log_ch0_u1_axi_m_wdata                => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_wdata,  
  hbm2e_upper_error_log_ch0_u1_axi_m_wstrb                => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_wstrb,  
  hbm2e_upper_error_log_ch0_u1_axi_m_wvalid               => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_wvalid,
  hbm2e_upper_error_log_ch0_u1_axi_m_wready               => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_wready,
  hbm2e_upper_error_log_ch0_u1_axi_m_bresp                => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_bresp,	
  hbm2e_upper_error_log_ch0_u1_axi_m_bvalid               => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_bvalid,	
  hbm2e_upper_error_log_ch0_u1_axi_m_bready               => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_bready,	
  hbm2e_upper_error_log_ch0_u1_axi_m_araddr               => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_araddr, 	
  hbm2e_upper_error_log_ch0_u1_axi_m_arprot               => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_arprot,	
  hbm2e_upper_error_log_ch0_u1_axi_m_arvalid              => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_arvalid,	
  hbm2e_upper_error_log_ch0_u1_axi_m_arready              => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_arready, 
  hbm2e_upper_error_log_ch0_u1_axi_m_rdata                => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_rdata,	
  hbm2e_upper_error_log_ch0_u1_axi_m_rresp                => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_rresp,	
  hbm2e_upper_error_log_ch0_u1_axi_m_rvalid               => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_rvalid,	
  hbm2e_upper_error_log_ch0_u1_axi_m_rready               => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_rready, 
  hbm2e_upper_error_log_ch1_u0_axi_m_awaddr               => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_awaddr, 
  hbm2e_upper_error_log_ch1_u0_axi_m_awprot               => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_awprot,
  hbm2e_upper_error_log_ch1_u0_axi_m_awvalid              => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_awvalid,
  hbm2e_upper_error_log_ch1_u0_axi_m_awready              => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_awready, 
  hbm2e_upper_error_log_ch1_u0_axi_m_wdata                => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_wdata,  
  hbm2e_upper_error_log_ch1_u0_axi_m_wstrb                => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_wstrb,  
  hbm2e_upper_error_log_ch1_u0_axi_m_wvalid               => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_wvalid,
  hbm2e_upper_error_log_ch1_u0_axi_m_wready               => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_wready,
  hbm2e_upper_error_log_ch1_u0_axi_m_bresp                => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_bresp,	
  hbm2e_upper_error_log_ch1_u0_axi_m_bvalid               => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_bvalid,	
  hbm2e_upper_error_log_ch1_u0_axi_m_bready               => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_bready,	
  hbm2e_upper_error_log_ch1_u0_axi_m_araddr               => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_araddr, 	
  hbm2e_upper_error_log_ch1_u0_axi_m_arprot               => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_arprot,	
  hbm2e_upper_error_log_ch1_u0_axi_m_arvalid              => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_arvalid,	
  hbm2e_upper_error_log_ch1_u0_axi_m_arready              => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_arready, 
  hbm2e_upper_error_log_ch1_u0_axi_m_rdata                => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_rdata,	
  hbm2e_upper_error_log_ch1_u0_axi_m_rresp                => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_rresp,	
  hbm2e_upper_error_log_ch1_u0_axi_m_rvalid               => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_rvalid,	
  hbm2e_upper_error_log_ch1_u0_axi_m_rready               => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_rready, 
  hbm2e_upper_error_log_ch1_u1_axi_m_awaddr               => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_awaddr, 
  hbm2e_upper_error_log_ch1_u1_axi_m_awprot               => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_awprot,
  hbm2e_upper_error_log_ch1_u1_axi_m_awvalid              => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_awvalid,
  hbm2e_upper_error_log_ch1_u1_axi_m_awready              => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_awready, 
  hbm2e_upper_error_log_ch1_u1_axi_m_wdata                => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_wdata,  
  hbm2e_upper_error_log_ch1_u1_axi_m_wstrb                => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_wstrb,  
  hbm2e_upper_error_log_ch1_u1_axi_m_wvalid               => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_wvalid,
  hbm2e_upper_error_log_ch1_u1_axi_m_wready               => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_wready,
  hbm2e_upper_error_log_ch1_u1_axi_m_bresp                => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_bresp,	
  hbm2e_upper_error_log_ch1_u1_axi_m_bvalid               => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_bvalid,	
  hbm2e_upper_error_log_ch1_u1_axi_m_bready               => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_bready,	
  hbm2e_upper_error_log_ch1_u1_axi_m_araddr               => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_araddr, 	
  hbm2e_upper_error_log_ch1_u1_axi_m_arprot               => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_arprot,	
  hbm2e_upper_error_log_ch1_u1_axi_m_arvalid              => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_arvalid,	
  hbm2e_upper_error_log_ch1_u1_axi_m_arready              => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_arready, 
  hbm2e_upper_error_log_ch1_u1_axi_m_rdata                => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_rdata,	
  hbm2e_upper_error_log_ch1_u1_axi_m_rresp                => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_rresp,	
  hbm2e_upper_error_log_ch1_u1_axi_m_rvalid               => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_rvalid,	
  hbm2e_upper_error_log_ch1_u1_axi_m_rready               => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_rready, 
  hbm2e_upper_error_log_ch2_u0_axi_m_awaddr               => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_awaddr, 
  hbm2e_upper_error_log_ch2_u0_axi_m_awprot               => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_awprot,
  hbm2e_upper_error_log_ch2_u0_axi_m_awvalid              => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_awvalid,
  hbm2e_upper_error_log_ch2_u0_axi_m_awready              => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_awready, 
  hbm2e_upper_error_log_ch2_u0_axi_m_wdata                => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_wdata,  
  hbm2e_upper_error_log_ch2_u0_axi_m_wstrb                => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_wstrb,  
  hbm2e_upper_error_log_ch2_u0_axi_m_wvalid               => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_wvalid,
  hbm2e_upper_error_log_ch2_u0_axi_m_wready               => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_wready,
  hbm2e_upper_error_log_ch2_u0_axi_m_bresp                => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_bresp,	
  hbm2e_upper_error_log_ch2_u0_axi_m_bvalid               => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_bvalid,	
  hbm2e_upper_error_log_ch2_u0_axi_m_bready               => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_bready,	
  hbm2e_upper_error_log_ch2_u0_axi_m_araddr               => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_araddr, 	
  hbm2e_upper_error_log_ch2_u0_axi_m_arprot               => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_arprot,	
  hbm2e_upper_error_log_ch2_u0_axi_m_arvalid              => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_arvalid,	
  hbm2e_upper_error_log_ch2_u0_axi_m_arready              => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_arready, 
  hbm2e_upper_error_log_ch2_u0_axi_m_rdata                => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_rdata,	
  hbm2e_upper_error_log_ch2_u0_axi_m_rresp                => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_rresp,	
  hbm2e_upper_error_log_ch2_u0_axi_m_rvalid               => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_rvalid,	
  hbm2e_upper_error_log_ch2_u0_axi_m_rready               => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_rready, 
  hbm2e_upper_error_log_ch2_u1_axi_m_awaddr               => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_awaddr, 
  hbm2e_upper_error_log_ch2_u1_axi_m_awprot               => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_awprot,
  hbm2e_upper_error_log_ch2_u1_axi_m_awvalid              => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_awvalid,
  hbm2e_upper_error_log_ch2_u1_axi_m_awready              => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_awready, 
  hbm2e_upper_error_log_ch2_u1_axi_m_wdata                => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_wdata,  
  hbm2e_upper_error_log_ch2_u1_axi_m_wstrb                => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_wstrb,  
  hbm2e_upper_error_log_ch2_u1_axi_m_wvalid               => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_wvalid,
  hbm2e_upper_error_log_ch2_u1_axi_m_wready               => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_wready,
  hbm2e_upper_error_log_ch2_u1_axi_m_bresp                => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_bresp,	
  hbm2e_upper_error_log_ch2_u1_axi_m_bvalid               => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_bvalid,	
  hbm2e_upper_error_log_ch2_u1_axi_m_bready               => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_bready,	
  hbm2e_upper_error_log_ch2_u1_axi_m_araddr               => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_araddr, 	
  hbm2e_upper_error_log_ch2_u1_axi_m_arprot               => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_arprot,	
  hbm2e_upper_error_log_ch2_u1_axi_m_arvalid              => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_arvalid,	
  hbm2e_upper_error_log_ch2_u1_axi_m_arready              => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_arready, 
  hbm2e_upper_error_log_ch2_u1_axi_m_rdata                => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_rdata,	
  hbm2e_upper_error_log_ch2_u1_axi_m_rresp                => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_rresp,	
  hbm2e_upper_error_log_ch2_u1_axi_m_rvalid               => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_rvalid,	
  hbm2e_upper_error_log_ch2_u1_axi_m_rready               => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_rready, 
  hbm2e_upper_error_log_ch3_u0_axi_m_awaddr               => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_awaddr, 
  hbm2e_upper_error_log_ch3_u0_axi_m_awprot               => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_awprot,
  hbm2e_upper_error_log_ch3_u0_axi_m_awvalid              => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_awvalid,
  hbm2e_upper_error_log_ch3_u0_axi_m_awready              => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_awready, 
  hbm2e_upper_error_log_ch3_u0_axi_m_wdata                => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_wdata,  
  hbm2e_upper_error_log_ch3_u0_axi_m_wstrb                => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_wstrb,  
  hbm2e_upper_error_log_ch3_u0_axi_m_wvalid               => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_wvalid,
  hbm2e_upper_error_log_ch3_u0_axi_m_wready               => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_wready,
  hbm2e_upper_error_log_ch3_u0_axi_m_bresp                => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_bresp,	
  hbm2e_upper_error_log_ch3_u0_axi_m_bvalid               => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_bvalid,	
  hbm2e_upper_error_log_ch3_u0_axi_m_bready               => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_bready,	
  hbm2e_upper_error_log_ch3_u0_axi_m_araddr               => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_araddr, 	
  hbm2e_upper_error_log_ch3_u0_axi_m_arprot               => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_arprot,	
  hbm2e_upper_error_log_ch3_u0_axi_m_arvalid              => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_arvalid,	
  hbm2e_upper_error_log_ch3_u0_axi_m_arready              => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_arready, 
  hbm2e_upper_error_log_ch3_u0_axi_m_rdata                => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_rdata,	
  hbm2e_upper_error_log_ch3_u0_axi_m_rresp                => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_rresp,	
  hbm2e_upper_error_log_ch3_u0_axi_m_rvalid               => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_rvalid,	
  hbm2e_upper_error_log_ch3_u0_axi_m_rready               => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_rready, 
  hbm2e_upper_error_log_ch3_u1_axi_m_awaddr               => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_awaddr, 
  hbm2e_upper_error_log_ch3_u1_axi_m_awprot               => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_awprot,
  hbm2e_upper_error_log_ch3_u1_axi_m_awvalid              => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_awvalid,
  hbm2e_upper_error_log_ch3_u1_axi_m_awready              => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_awready, 
  hbm2e_upper_error_log_ch3_u1_axi_m_wdata                => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_wdata,  
  hbm2e_upper_error_log_ch3_u1_axi_m_wstrb                => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_wstrb,  
  hbm2e_upper_error_log_ch3_u1_axi_m_wvalid               => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_wvalid,
  hbm2e_upper_error_log_ch3_u1_axi_m_wready               => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_wready,
  hbm2e_upper_error_log_ch3_u1_axi_m_bresp                => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_bresp,	
  hbm2e_upper_error_log_ch3_u1_axi_m_bvalid               => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_bvalid,	
  hbm2e_upper_error_log_ch3_u1_axi_m_bready               => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_bready,	
  hbm2e_upper_error_log_ch3_u1_axi_m_araddr               => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_araddr, 	
  hbm2e_upper_error_log_ch3_u1_axi_m_arprot               => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_arprot,	
  hbm2e_upper_error_log_ch3_u1_axi_m_arvalid              => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_arvalid,	
  hbm2e_upper_error_log_ch3_u1_axi_m_arready              => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_arready, 
  hbm2e_upper_error_log_ch3_u1_axi_m_rdata                => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_rdata,	
  hbm2e_upper_error_log_ch3_u1_axi_m_rresp                => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_rresp,	
  hbm2e_upper_error_log_ch3_u1_axi_m_rvalid               => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_rvalid,	
  hbm2e_upper_error_log_ch3_u1_axi_m_rready               => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_rready, 
  hbm2e_upper_error_log_ch4_u0_axi_m_awaddr               => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_awaddr, 
  hbm2e_upper_error_log_ch4_u0_axi_m_awprot               => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_awprot,
  hbm2e_upper_error_log_ch4_u0_axi_m_awvalid              => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_awvalid,
  hbm2e_upper_error_log_ch4_u0_axi_m_awready              => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_awready, 
  hbm2e_upper_error_log_ch4_u0_axi_m_wdata                => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_wdata,  
  hbm2e_upper_error_log_ch4_u0_axi_m_wstrb                => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_wstrb,  
  hbm2e_upper_error_log_ch4_u0_axi_m_wvalid               => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_wvalid,
  hbm2e_upper_error_log_ch4_u0_axi_m_wready               => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_wready,
  hbm2e_upper_error_log_ch4_u0_axi_m_bresp                => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_bresp,	
  hbm2e_upper_error_log_ch4_u0_axi_m_bvalid               => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_bvalid,	
  hbm2e_upper_error_log_ch4_u0_axi_m_bready               => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_bready,	
  hbm2e_upper_error_log_ch4_u0_axi_m_araddr               => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_araddr, 	
  hbm2e_upper_error_log_ch4_u0_axi_m_arprot               => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_arprot,	
  hbm2e_upper_error_log_ch4_u0_axi_m_arvalid              => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_arvalid,	
  hbm2e_upper_error_log_ch4_u0_axi_m_arready              => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_arready, 
  hbm2e_upper_error_log_ch4_u0_axi_m_rdata                => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_rdata,	
  hbm2e_upper_error_log_ch4_u0_axi_m_rresp                => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_rresp,	
  hbm2e_upper_error_log_ch4_u0_axi_m_rvalid               => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_rvalid,	
  hbm2e_upper_error_log_ch4_u0_axi_m_rready               => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_rready, 
  hbm2e_upper_error_log_ch4_u1_axi_m_awaddr               => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_awaddr, 
  hbm2e_upper_error_log_ch4_u1_axi_m_awprot               => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_awprot,
  hbm2e_upper_error_log_ch4_u1_axi_m_awvalid              => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_awvalid,
  hbm2e_upper_error_log_ch4_u1_axi_m_awready              => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_awready, 
  hbm2e_upper_error_log_ch4_u1_axi_m_wdata                => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_wdata,  
  hbm2e_upper_error_log_ch4_u1_axi_m_wstrb                => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_wstrb,  
  hbm2e_upper_error_log_ch4_u1_axi_m_wvalid               => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_wvalid,
  hbm2e_upper_error_log_ch4_u1_axi_m_wready               => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_wready,
  hbm2e_upper_error_log_ch4_u1_axi_m_bresp                => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_bresp,	
  hbm2e_upper_error_log_ch4_u1_axi_m_bvalid               => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_bvalid,	
  hbm2e_upper_error_log_ch4_u1_axi_m_bready               => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_bready,	
  hbm2e_upper_error_log_ch4_u1_axi_m_araddr               => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_araddr, 	
  hbm2e_upper_error_log_ch4_u1_axi_m_arprot               => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_arprot,	
  hbm2e_upper_error_log_ch4_u1_axi_m_arvalid              => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_arvalid,	
  hbm2e_upper_error_log_ch4_u1_axi_m_arready              => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_arready, 
  hbm2e_upper_error_log_ch4_u1_axi_m_rdata                => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_rdata,	
  hbm2e_upper_error_log_ch4_u1_axi_m_rresp                => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_rresp,	
  hbm2e_upper_error_log_ch4_u1_axi_m_rvalid               => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_rvalid,	
  hbm2e_upper_error_log_ch4_u1_axi_m_rready               => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_rready, 
  hbm2e_upper_error_log_ch5_u0_axi_m_awaddr               => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_awaddr, 
  hbm2e_upper_error_log_ch5_u0_axi_m_awprot               => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_awprot,
  hbm2e_upper_error_log_ch5_u0_axi_m_awvalid              => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_awvalid,
  hbm2e_upper_error_log_ch5_u0_axi_m_awready              => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_awready, 
  hbm2e_upper_error_log_ch5_u0_axi_m_wdata                => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_wdata,  
  hbm2e_upper_error_log_ch5_u0_axi_m_wstrb                => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_wstrb,  
  hbm2e_upper_error_log_ch5_u0_axi_m_wvalid               => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_wvalid,
  hbm2e_upper_error_log_ch5_u0_axi_m_wready               => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_wready,
  hbm2e_upper_error_log_ch5_u0_axi_m_bresp                => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_bresp,	
  hbm2e_upper_error_log_ch5_u0_axi_m_bvalid               => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_bvalid,	
  hbm2e_upper_error_log_ch5_u0_axi_m_bready               => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_bready,	
  hbm2e_upper_error_log_ch5_u0_axi_m_araddr               => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_araddr, 	
  hbm2e_upper_error_log_ch5_u0_axi_m_arprot               => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_arprot,	
  hbm2e_upper_error_log_ch5_u0_axi_m_arvalid              => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_arvalid,	
  hbm2e_upper_error_log_ch5_u0_axi_m_arready              => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_arready, 
  hbm2e_upper_error_log_ch5_u0_axi_m_rdata                => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_rdata,	
  hbm2e_upper_error_log_ch5_u0_axi_m_rresp                => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_rresp,	
  hbm2e_upper_error_log_ch5_u0_axi_m_rvalid               => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_rvalid,	
  hbm2e_upper_error_log_ch5_u0_axi_m_rready               => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_rready, 
  hbm2e_upper_error_log_ch5_u1_axi_m_awaddr               => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_awaddr, 
  hbm2e_upper_error_log_ch5_u1_axi_m_awprot               => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_awprot,
  hbm2e_upper_error_log_ch5_u1_axi_m_awvalid              => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_awvalid,
  hbm2e_upper_error_log_ch5_u1_axi_m_awready              => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_awready, 
  hbm2e_upper_error_log_ch5_u1_axi_m_wdata                => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_wdata,  
  hbm2e_upper_error_log_ch5_u1_axi_m_wstrb                => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_wstrb,  
  hbm2e_upper_error_log_ch5_u1_axi_m_wvalid               => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_wvalid,
  hbm2e_upper_error_log_ch5_u1_axi_m_wready               => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_wready,
  hbm2e_upper_error_log_ch5_u1_axi_m_bresp                => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_bresp,	
  hbm2e_upper_error_log_ch5_u1_axi_m_bvalid               => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_bvalid,	
  hbm2e_upper_error_log_ch5_u1_axi_m_bready               => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_bready,	
  hbm2e_upper_error_log_ch5_u1_axi_m_araddr               => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_araddr, 	
  hbm2e_upper_error_log_ch5_u1_axi_m_arprot               => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_arprot,	
  hbm2e_upper_error_log_ch5_u1_axi_m_arvalid              => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_arvalid,	
  hbm2e_upper_error_log_ch5_u1_axi_m_arready              => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_arready, 
  hbm2e_upper_error_log_ch5_u1_axi_m_rdata                => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_rdata,	
  hbm2e_upper_error_log_ch5_u1_axi_m_rresp                => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_rresp,	
  hbm2e_upper_error_log_ch5_u1_axi_m_rvalid               => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_rvalid,	
  hbm2e_upper_error_log_ch5_u1_axi_m_rready               => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_rready, 
  hbm2e_upper_error_log_ch6_u0_axi_m_awaddr               => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_awaddr, 
  hbm2e_upper_error_log_ch6_u0_axi_m_awprot               => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_awprot,
  hbm2e_upper_error_log_ch6_u0_axi_m_awvalid              => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_awvalid,
  hbm2e_upper_error_log_ch6_u0_axi_m_awready              => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_awready, 
  hbm2e_upper_error_log_ch6_u0_axi_m_wdata                => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_wdata,  
  hbm2e_upper_error_log_ch6_u0_axi_m_wstrb                => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_wstrb,  
  hbm2e_upper_error_log_ch6_u0_axi_m_wvalid               => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_wvalid,
  hbm2e_upper_error_log_ch6_u0_axi_m_wready               => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_wready,
  hbm2e_upper_error_log_ch6_u0_axi_m_bresp                => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_bresp,	
  hbm2e_upper_error_log_ch6_u0_axi_m_bvalid               => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_bvalid,	
  hbm2e_upper_error_log_ch6_u0_axi_m_bready               => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_bready,	
  hbm2e_upper_error_log_ch6_u0_axi_m_araddr               => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_araddr, 	
  hbm2e_upper_error_log_ch6_u0_axi_m_arprot               => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_arprot,	
  hbm2e_upper_error_log_ch6_u0_axi_m_arvalid              => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_arvalid,	
  hbm2e_upper_error_log_ch6_u0_axi_m_arready              => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_arready, 
  hbm2e_upper_error_log_ch6_u0_axi_m_rdata                => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_rdata,	
  hbm2e_upper_error_log_ch6_u0_axi_m_rresp                => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_rresp,	
  hbm2e_upper_error_log_ch6_u0_axi_m_rvalid               => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_rvalid,	
  hbm2e_upper_error_log_ch6_u0_axi_m_rready               => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_rready, 
  hbm2e_upper_error_log_ch6_u1_axi_m_awaddr               => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_awaddr, 
  hbm2e_upper_error_log_ch6_u1_axi_m_awprot               => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_awprot,
  hbm2e_upper_error_log_ch6_u1_axi_m_awvalid              => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_awvalid,
  hbm2e_upper_error_log_ch6_u1_axi_m_awready              => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_awready, 
  hbm2e_upper_error_log_ch6_u1_axi_m_wdata                => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_wdata,  
  hbm2e_upper_error_log_ch6_u1_axi_m_wstrb                => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_wstrb,  
  hbm2e_upper_error_log_ch6_u1_axi_m_wvalid               => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_wvalid,
  hbm2e_upper_error_log_ch6_u1_axi_m_wready               => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_wready,
  hbm2e_upper_error_log_ch6_u1_axi_m_bresp                => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_bresp,	
  hbm2e_upper_error_log_ch6_u1_axi_m_bvalid               => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_bvalid,	
  hbm2e_upper_error_log_ch6_u1_axi_m_bready               => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_bready,	
  hbm2e_upper_error_log_ch6_u1_axi_m_araddr               => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_araddr, 	
  hbm2e_upper_error_log_ch6_u1_axi_m_arprot               => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_arprot,	
  hbm2e_upper_error_log_ch6_u1_axi_m_arvalid              => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_arvalid,	
  hbm2e_upper_error_log_ch6_u1_axi_m_arready              => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_arready, 
  hbm2e_upper_error_log_ch6_u1_axi_m_rdata                => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_rdata,	
  hbm2e_upper_error_log_ch6_u1_axi_m_rresp                => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_rresp,	
  hbm2e_upper_error_log_ch6_u1_axi_m_rvalid               => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_rvalid,	
  hbm2e_upper_error_log_ch6_u1_axi_m_rready               => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_rready, 
  hbm2e_upper_error_log_ch7_u0_axi_m_awaddr               => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_awaddr, 
  hbm2e_upper_error_log_ch7_u0_axi_m_awprot               => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_awprot,
  hbm2e_upper_error_log_ch7_u0_axi_m_awvalid              => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_awvalid,
  hbm2e_upper_error_log_ch7_u0_axi_m_awready              => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_awready, 
  hbm2e_upper_error_log_ch7_u0_axi_m_wdata                => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_wdata,  
  hbm2e_upper_error_log_ch7_u0_axi_m_wstrb                => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_wstrb,  
  hbm2e_upper_error_log_ch7_u0_axi_m_wvalid               => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_wvalid,
  hbm2e_upper_error_log_ch7_u0_axi_m_wready               => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_wready,
  hbm2e_upper_error_log_ch7_u0_axi_m_bresp                => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_bresp,	
  hbm2e_upper_error_log_ch7_u0_axi_m_bvalid               => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_bvalid,	
  hbm2e_upper_error_log_ch7_u0_axi_m_bready               => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_bready,	
  hbm2e_upper_error_log_ch7_u0_axi_m_araddr               => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_araddr, 	
  hbm2e_upper_error_log_ch7_u0_axi_m_arprot               => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_arprot,	
  hbm2e_upper_error_log_ch7_u0_axi_m_arvalid              => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_arvalid,	
  hbm2e_upper_error_log_ch7_u0_axi_m_arready              => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_arready, 
  hbm2e_upper_error_log_ch7_u0_axi_m_rdata                => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_rdata,	
  hbm2e_upper_error_log_ch7_u0_axi_m_rresp                => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_rresp,	
  hbm2e_upper_error_log_ch7_u0_axi_m_rvalid               => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_rvalid,	
  hbm2e_upper_error_log_ch7_u0_axi_m_rready               => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_rready, 
  hbm2e_upper_error_log_ch7_u1_axi_m_awaddr               => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_awaddr, 
  hbm2e_upper_error_log_ch7_u1_axi_m_awprot               => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_awprot,
  hbm2e_upper_error_log_ch7_u1_axi_m_awvalid              => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_awvalid,
  hbm2e_upper_error_log_ch7_u1_axi_m_awready              => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_awready, 
  hbm2e_upper_error_log_ch7_u1_axi_m_wdata                => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_wdata,  
  hbm2e_upper_error_log_ch7_u1_axi_m_wstrb                => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_wstrb,  
  hbm2e_upper_error_log_ch7_u1_axi_m_wvalid               => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_wvalid,
  hbm2e_upper_error_log_ch7_u1_axi_m_wready               => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_wready,
  hbm2e_upper_error_log_ch7_u1_axi_m_bresp                => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_bresp,	
  hbm2e_upper_error_log_ch7_u1_axi_m_bvalid               => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_bvalid,	
  hbm2e_upper_error_log_ch7_u1_axi_m_bready               => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_bready,	
  hbm2e_upper_error_log_ch7_u1_axi_m_araddr               => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_araddr, 	
  hbm2e_upper_error_log_ch7_u1_axi_m_arprot               => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_arprot,	
  hbm2e_upper_error_log_ch7_u1_axi_m_arvalid              => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_arvalid,	
  hbm2e_upper_error_log_ch7_u1_axi_m_arready              => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_arready, 
  hbm2e_upper_error_log_ch7_u1_axi_m_rdata                => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_rdata,	
  hbm2e_upper_error_log_ch7_u1_axi_m_rresp                => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_rresp,	
  hbm2e_upper_error_log_ch7_u1_axi_m_rvalid               => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_rvalid,	
  hbm2e_upper_error_log_ch7_u1_axi_m_rready               => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_rready, 
  hbm2e_lower_test_ch0_u0_axi_m_awaddr                    => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_lower_test_ch0_u0_axi_m_awprot                    => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_awprot,
  hbm2e_lower_test_ch0_u0_axi_m_awvalid                   => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_lower_test_ch0_u0_axi_m_awready                   => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_awready,
  hbm2e_lower_test_ch0_u0_axi_m_wdata                     => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_wdata,
  hbm2e_lower_test_ch0_u0_axi_m_wstrb                     => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_lower_test_ch0_u0_axi_m_wvalid                    => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_lower_test_ch0_u0_axi_m_wready                    => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_wready,
  hbm2e_lower_test_ch0_u0_axi_m_bresp                     => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_bresp,
  hbm2e_lower_test_ch0_u0_axi_m_bvalid                    => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_lower_test_ch0_u0_axi_m_bready                    => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_bready,
  hbm2e_lower_test_ch0_u0_axi_m_araddr                    => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_araddr,
  hbm2e_lower_test_ch0_u0_axi_m_arprot                    => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_arprot,
  hbm2e_lower_test_ch0_u0_axi_m_arvalid                   => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_lower_test_ch0_u0_axi_m_arready                   => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_arready,
  hbm2e_lower_test_ch0_u0_axi_m_rdata                     => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_rdata,
  hbm2e_lower_test_ch0_u0_axi_m_rresp                     => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_rresp,
  hbm2e_lower_test_ch0_u0_axi_m_rvalid                    => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_lower_test_ch0_u0_axi_m_rready                    => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_rready,
  hbm2e_lower_test_ch0_u1_axi_m_awaddr                    => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_lower_test_ch0_u1_axi_m_awprot                    => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_awprot,
  hbm2e_lower_test_ch0_u1_axi_m_awvalid                   => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_lower_test_ch0_u1_axi_m_awready                   => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_awready,
  hbm2e_lower_test_ch0_u1_axi_m_wdata                     => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_wdata,
  hbm2e_lower_test_ch0_u1_axi_m_wstrb                     => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_lower_test_ch0_u1_axi_m_wvalid                    => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_lower_test_ch0_u1_axi_m_wready                    => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_wready,
  hbm2e_lower_test_ch0_u1_axi_m_bresp                     => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_bresp,
  hbm2e_lower_test_ch0_u1_axi_m_bvalid                    => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_lower_test_ch0_u1_axi_m_bready                    => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_bready,
  hbm2e_lower_test_ch0_u1_axi_m_araddr                    => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_araddr,
  hbm2e_lower_test_ch0_u1_axi_m_arprot                    => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_arprot,
  hbm2e_lower_test_ch0_u1_axi_m_arvalid                   => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_lower_test_ch0_u1_axi_m_arready                   => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_arready,
  hbm2e_lower_test_ch0_u1_axi_m_rdata                     => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_rdata,
  hbm2e_lower_test_ch0_u1_axi_m_rresp                     => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_rresp,
  hbm2e_lower_test_ch0_u1_axi_m_rvalid                    => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_lower_test_ch0_u1_axi_m_rready                    => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_rready,
  hbm2e_lower_test_ch1_u0_axi_m_awaddr                    => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_lower_test_ch1_u0_axi_m_awprot                    => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_awprot,
  hbm2e_lower_test_ch1_u0_axi_m_awvalid                   => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_lower_test_ch1_u0_axi_m_awready                   => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_awready,
  hbm2e_lower_test_ch1_u0_axi_m_wdata                     => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_wdata,
  hbm2e_lower_test_ch1_u0_axi_m_wstrb                     => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_lower_test_ch1_u0_axi_m_wvalid                    => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_lower_test_ch1_u0_axi_m_wready                    => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_wready,
  hbm2e_lower_test_ch1_u0_axi_m_bresp                     => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_bresp,
  hbm2e_lower_test_ch1_u0_axi_m_bvalid                    => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_lower_test_ch1_u0_axi_m_bready                    => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_bready,
  hbm2e_lower_test_ch1_u0_axi_m_araddr                    => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_araddr,
  hbm2e_lower_test_ch1_u0_axi_m_arprot                    => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_arprot,
  hbm2e_lower_test_ch1_u0_axi_m_arvalid                   => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_lower_test_ch1_u0_axi_m_arready                   => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_arready,
  hbm2e_lower_test_ch1_u0_axi_m_rdata                     => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_rdata,
  hbm2e_lower_test_ch1_u0_axi_m_rresp                     => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_rresp,
  hbm2e_lower_test_ch1_u0_axi_m_rvalid                    => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_lower_test_ch1_u0_axi_m_rready                    => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_rready,
  hbm2e_lower_test_ch1_u1_axi_m_awaddr                    => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_lower_test_ch1_u1_axi_m_awprot                    => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_awprot,
  hbm2e_lower_test_ch1_u1_axi_m_awvalid                   => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_lower_test_ch1_u1_axi_m_awready                   => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_awready,
  hbm2e_lower_test_ch1_u1_axi_m_wdata                     => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_wdata,
  hbm2e_lower_test_ch1_u1_axi_m_wstrb                     => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_lower_test_ch1_u1_axi_m_wvalid                    => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_lower_test_ch1_u1_axi_m_wready                    => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_wready,
  hbm2e_lower_test_ch1_u1_axi_m_bresp                     => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_bresp,
  hbm2e_lower_test_ch1_u1_axi_m_bvalid                    => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_lower_test_ch1_u1_axi_m_bready                    => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_bready,
  hbm2e_lower_test_ch1_u1_axi_m_araddr                    => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_araddr,
  hbm2e_lower_test_ch1_u1_axi_m_arprot                    => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_arprot,
  hbm2e_lower_test_ch1_u1_axi_m_arvalid                   => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_lower_test_ch1_u1_axi_m_arready                   => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_arready,
  hbm2e_lower_test_ch1_u1_axi_m_rdata                     => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_rdata,
  hbm2e_lower_test_ch1_u1_axi_m_rresp                     => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_rresp,
  hbm2e_lower_test_ch1_u1_axi_m_rvalid                    => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_lower_test_ch1_u1_axi_m_rready                    => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_rready,
  hbm2e_lower_test_ch2_u0_axi_m_awaddr                    => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_lower_test_ch2_u0_axi_m_awprot                    => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_awprot,
  hbm2e_lower_test_ch2_u0_axi_m_awvalid                   => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_lower_test_ch2_u0_axi_m_awready                   => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_awready,
  hbm2e_lower_test_ch2_u0_axi_m_wdata                     => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_wdata,
  hbm2e_lower_test_ch2_u0_axi_m_wstrb                     => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_lower_test_ch2_u0_axi_m_wvalid                    => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_lower_test_ch2_u0_axi_m_wready                    => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_wready,
  hbm2e_lower_test_ch2_u0_axi_m_bresp                     => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_bresp,
  hbm2e_lower_test_ch2_u0_axi_m_bvalid                    => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_lower_test_ch2_u0_axi_m_bready                    => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_bready,
  hbm2e_lower_test_ch2_u0_axi_m_araddr                    => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_araddr,
  hbm2e_lower_test_ch2_u0_axi_m_arprot                    => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_arprot,
  hbm2e_lower_test_ch2_u0_axi_m_arvalid                   => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_lower_test_ch2_u0_axi_m_arready                   => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_arready,
  hbm2e_lower_test_ch2_u0_axi_m_rdata                     => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_rdata,
  hbm2e_lower_test_ch2_u0_axi_m_rresp                     => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_rresp,
  hbm2e_lower_test_ch2_u0_axi_m_rvalid                    => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_lower_test_ch2_u0_axi_m_rready                    => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_rready,
  hbm2e_lower_test_ch2_u1_axi_m_awaddr                    => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_lower_test_ch2_u1_axi_m_awprot                    => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_awprot,
  hbm2e_lower_test_ch2_u1_axi_m_awvalid                   => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_lower_test_ch2_u1_axi_m_awready                   => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_awready,
  hbm2e_lower_test_ch2_u1_axi_m_wdata                     => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_wdata,
  hbm2e_lower_test_ch2_u1_axi_m_wstrb                     => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_lower_test_ch2_u1_axi_m_wvalid                    => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_lower_test_ch2_u1_axi_m_wready                    => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_wready,
  hbm2e_lower_test_ch2_u1_axi_m_bresp                     => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_bresp,
  hbm2e_lower_test_ch2_u1_axi_m_bvalid                    => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_lower_test_ch2_u1_axi_m_bready                    => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_bready,
  hbm2e_lower_test_ch2_u1_axi_m_araddr                    => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_araddr,
  hbm2e_lower_test_ch2_u1_axi_m_arprot                    => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_arprot,
  hbm2e_lower_test_ch2_u1_axi_m_arvalid                   => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_lower_test_ch2_u1_axi_m_arready                   => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_arready,
  hbm2e_lower_test_ch2_u1_axi_m_rdata                     => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_rdata,
  hbm2e_lower_test_ch2_u1_axi_m_rresp                     => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_rresp,
  hbm2e_lower_test_ch2_u1_axi_m_rvalid                    => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_lower_test_ch2_u1_axi_m_rready                    => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_rready,
  hbm2e_lower_test_ch3_u0_axi_m_awaddr                    => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_lower_test_ch3_u0_axi_m_awprot                    => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_awprot,
  hbm2e_lower_test_ch3_u0_axi_m_awvalid                   => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_lower_test_ch3_u0_axi_m_awready                   => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_awready,
  hbm2e_lower_test_ch3_u0_axi_m_wdata                     => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_wdata,
  hbm2e_lower_test_ch3_u0_axi_m_wstrb                     => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_lower_test_ch3_u0_axi_m_wvalid                    => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_lower_test_ch3_u0_axi_m_wready                    => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_wready,
  hbm2e_lower_test_ch3_u0_axi_m_bresp                     => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_bresp,
  hbm2e_lower_test_ch3_u0_axi_m_bvalid                    => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_lower_test_ch3_u0_axi_m_bready                    => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_bready,
  hbm2e_lower_test_ch3_u0_axi_m_araddr                    => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_araddr,
  hbm2e_lower_test_ch3_u0_axi_m_arprot                    => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_arprot,
  hbm2e_lower_test_ch3_u0_axi_m_arvalid                   => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_lower_test_ch3_u0_axi_m_arready                   => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_arready,
  hbm2e_lower_test_ch3_u0_axi_m_rdata                     => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_rdata,
  hbm2e_lower_test_ch3_u0_axi_m_rresp                     => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_rresp,
  hbm2e_lower_test_ch3_u0_axi_m_rvalid                    => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_lower_test_ch3_u0_axi_m_rready                    => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_rready,
  hbm2e_lower_test_ch3_u1_axi_m_awaddr                    => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_lower_test_ch3_u1_axi_m_awprot                    => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_awprot,
  hbm2e_lower_test_ch3_u1_axi_m_awvalid                   => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_lower_test_ch3_u1_axi_m_awready                   => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_awready,
  hbm2e_lower_test_ch3_u1_axi_m_wdata                     => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_wdata,
  hbm2e_lower_test_ch3_u1_axi_m_wstrb                     => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_lower_test_ch3_u1_axi_m_wvalid                    => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_lower_test_ch3_u1_axi_m_wready                    => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_wready,
  hbm2e_lower_test_ch3_u1_axi_m_bresp                     => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_bresp,
  hbm2e_lower_test_ch3_u1_axi_m_bvalid                    => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_lower_test_ch3_u1_axi_m_bready                    => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_bready,
  hbm2e_lower_test_ch3_u1_axi_m_araddr                    => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_araddr,
  hbm2e_lower_test_ch3_u1_axi_m_arprot                    => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_arprot,
  hbm2e_lower_test_ch3_u1_axi_m_arvalid                   => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_lower_test_ch3_u1_axi_m_arready                   => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_arready,
  hbm2e_lower_test_ch3_u1_axi_m_rdata                     => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_rdata,
  hbm2e_lower_test_ch3_u1_axi_m_rresp                     => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_rresp,
  hbm2e_lower_test_ch3_u1_axi_m_rvalid                    => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_lower_test_ch3_u1_axi_m_rready                    => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_rready,
  hbm2e_lower_test_ch4_u0_axi_m_awaddr                    => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_lower_test_ch4_u0_axi_m_awprot                    => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_awprot,
  hbm2e_lower_test_ch4_u0_axi_m_awvalid                   => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_lower_test_ch4_u0_axi_m_awready                   => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_awready,
  hbm2e_lower_test_ch4_u0_axi_m_wdata                     => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_wdata,
  hbm2e_lower_test_ch4_u0_axi_m_wstrb                     => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_lower_test_ch4_u0_axi_m_wvalid                    => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_lower_test_ch4_u0_axi_m_wready                    => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_wready,
  hbm2e_lower_test_ch4_u0_axi_m_bresp                     => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_bresp,
  hbm2e_lower_test_ch4_u0_axi_m_bvalid                    => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_lower_test_ch4_u0_axi_m_bready                    => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_bready,
  hbm2e_lower_test_ch4_u0_axi_m_araddr                    => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_araddr,
  hbm2e_lower_test_ch4_u0_axi_m_arprot                    => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_arprot,
  hbm2e_lower_test_ch4_u0_axi_m_arvalid                   => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_lower_test_ch4_u0_axi_m_arready                   => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_arready,
  hbm2e_lower_test_ch4_u0_axi_m_rdata                     => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_rdata,
  hbm2e_lower_test_ch4_u0_axi_m_rresp                     => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_rresp,
  hbm2e_lower_test_ch4_u0_axi_m_rvalid                    => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_lower_test_ch4_u0_axi_m_rready                    => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_rready,
  hbm2e_lower_test_ch4_u1_axi_m_awaddr                    => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_lower_test_ch4_u1_axi_m_awprot                    => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_awprot,
  hbm2e_lower_test_ch4_u1_axi_m_awvalid                   => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_lower_test_ch4_u1_axi_m_awready                   => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_awready,
  hbm2e_lower_test_ch4_u1_axi_m_wdata                     => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_wdata,
  hbm2e_lower_test_ch4_u1_axi_m_wstrb                     => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_lower_test_ch4_u1_axi_m_wvalid                    => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_lower_test_ch4_u1_axi_m_wready                    => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_wready,
  hbm2e_lower_test_ch4_u1_axi_m_bresp                     => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_bresp,
  hbm2e_lower_test_ch4_u1_axi_m_bvalid                    => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_lower_test_ch4_u1_axi_m_bready                    => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_bready,
  hbm2e_lower_test_ch4_u1_axi_m_araddr                    => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_araddr,
  hbm2e_lower_test_ch4_u1_axi_m_arprot                    => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_arprot,
  hbm2e_lower_test_ch4_u1_axi_m_arvalid                   => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_lower_test_ch4_u1_axi_m_arready                   => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_arready,
  hbm2e_lower_test_ch4_u1_axi_m_rdata                     => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_rdata,
  hbm2e_lower_test_ch4_u1_axi_m_rresp                     => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_rresp,
  hbm2e_lower_test_ch4_u1_axi_m_rvalid                    => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_lower_test_ch4_u1_axi_m_rready                    => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_rready,
  hbm2e_lower_test_ch5_u0_axi_m_awaddr                    => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_lower_test_ch5_u0_axi_m_awprot                    => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_awprot,
  hbm2e_lower_test_ch5_u0_axi_m_awvalid                   => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_lower_test_ch5_u0_axi_m_awready                   => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_awready,
  hbm2e_lower_test_ch5_u0_axi_m_wdata                     => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_wdata,
  hbm2e_lower_test_ch5_u0_axi_m_wstrb                     => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_lower_test_ch5_u0_axi_m_wvalid                    => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_lower_test_ch5_u0_axi_m_wready                    => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_wready,
  hbm2e_lower_test_ch5_u0_axi_m_bresp                     => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_bresp,
  hbm2e_lower_test_ch5_u0_axi_m_bvalid                    => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_lower_test_ch5_u0_axi_m_bready                    => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_bready,
  hbm2e_lower_test_ch5_u0_axi_m_araddr                    => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_araddr,
  hbm2e_lower_test_ch5_u0_axi_m_arprot                    => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_arprot,
  hbm2e_lower_test_ch5_u0_axi_m_arvalid                   => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_lower_test_ch5_u0_axi_m_arready                   => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_arready,
  hbm2e_lower_test_ch5_u0_axi_m_rdata                     => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_rdata,
  hbm2e_lower_test_ch5_u0_axi_m_rresp                     => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_rresp,
  hbm2e_lower_test_ch5_u0_axi_m_rvalid                    => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_lower_test_ch5_u0_axi_m_rready                    => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_rready,
  hbm2e_lower_test_ch5_u1_axi_m_awaddr                    => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_lower_test_ch5_u1_axi_m_awprot                    => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_awprot,
  hbm2e_lower_test_ch5_u1_axi_m_awvalid                   => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_lower_test_ch5_u1_axi_m_awready                   => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_awready,
  hbm2e_lower_test_ch5_u1_axi_m_wdata                     => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_wdata,
  hbm2e_lower_test_ch5_u1_axi_m_wstrb                     => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_lower_test_ch5_u1_axi_m_wvalid                    => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_lower_test_ch5_u1_axi_m_wready                    => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_wready,
  hbm2e_lower_test_ch5_u1_axi_m_bresp                     => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_bresp,
  hbm2e_lower_test_ch5_u1_axi_m_bvalid                    => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_lower_test_ch5_u1_axi_m_bready                    => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_bready,
  hbm2e_lower_test_ch5_u1_axi_m_araddr                    => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_araddr,
  hbm2e_lower_test_ch5_u1_axi_m_arprot                    => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_arprot,
  hbm2e_lower_test_ch5_u1_axi_m_arvalid                   => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_lower_test_ch5_u1_axi_m_arready                   => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_arready,
  hbm2e_lower_test_ch5_u1_axi_m_rdata                     => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_rdata,
  hbm2e_lower_test_ch5_u1_axi_m_rresp                     => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_rresp,
  hbm2e_lower_test_ch5_u1_axi_m_rvalid                    => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_lower_test_ch5_u1_axi_m_rready                    => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_rready,
  hbm2e_lower_test_ch6_u0_axi_m_awaddr                    => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_lower_test_ch6_u0_axi_m_awprot                    => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_awprot,
  hbm2e_lower_test_ch6_u0_axi_m_awvalid                   => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_lower_test_ch6_u0_axi_m_awready                   => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_awready,
  hbm2e_lower_test_ch6_u0_axi_m_wdata                     => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_wdata,
  hbm2e_lower_test_ch6_u0_axi_m_wstrb                     => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_lower_test_ch6_u0_axi_m_wvalid                    => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_lower_test_ch6_u0_axi_m_wready                    => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_wready,
  hbm2e_lower_test_ch6_u0_axi_m_bresp                     => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_bresp,
  hbm2e_lower_test_ch6_u0_axi_m_bvalid                    => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_lower_test_ch6_u0_axi_m_bready                    => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_bready,
  hbm2e_lower_test_ch6_u0_axi_m_araddr                    => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_araddr,
  hbm2e_lower_test_ch6_u0_axi_m_arprot                    => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_arprot,
  hbm2e_lower_test_ch6_u0_axi_m_arvalid                   => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_lower_test_ch6_u0_axi_m_arready                   => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_arready,
  hbm2e_lower_test_ch6_u0_axi_m_rdata                     => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_rdata,
  hbm2e_lower_test_ch6_u0_axi_m_rresp                     => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_rresp,
  hbm2e_lower_test_ch6_u0_axi_m_rvalid                    => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_lower_test_ch6_u0_axi_m_rready                    => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_rready,
  hbm2e_lower_test_ch6_u1_axi_m_awaddr                    => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_lower_test_ch6_u1_axi_m_awprot                    => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_awprot,
  hbm2e_lower_test_ch6_u1_axi_m_awvalid                   => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_lower_test_ch6_u1_axi_m_awready                   => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_awready,
  hbm2e_lower_test_ch6_u1_axi_m_wdata                     => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_wdata,
  hbm2e_lower_test_ch6_u1_axi_m_wstrb                     => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_lower_test_ch6_u1_axi_m_wvalid                    => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_lower_test_ch6_u1_axi_m_wready                    => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_wready,
  hbm2e_lower_test_ch6_u1_axi_m_bresp                     => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_bresp,
  hbm2e_lower_test_ch6_u1_axi_m_bvalid                    => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_lower_test_ch6_u1_axi_m_bready                    => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_bready,
  hbm2e_lower_test_ch6_u1_axi_m_araddr                    => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_araddr,
  hbm2e_lower_test_ch6_u1_axi_m_arprot                    => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_arprot,
  hbm2e_lower_test_ch6_u1_axi_m_arvalid                   => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_lower_test_ch6_u1_axi_m_arready                   => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_arready,
  hbm2e_lower_test_ch6_u1_axi_m_rdata                     => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_rdata,
  hbm2e_lower_test_ch6_u1_axi_m_rresp                     => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_rresp,
  hbm2e_lower_test_ch6_u1_axi_m_rvalid                    => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_lower_test_ch6_u1_axi_m_rready                    => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_rready,
  hbm2e_lower_test_ch7_u0_axi_m_awaddr                    => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_lower_test_ch7_u0_axi_m_awprot                    => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_awprot,
  hbm2e_lower_test_ch7_u0_axi_m_awvalid                   => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_lower_test_ch7_u0_axi_m_awready                   => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_awready,
  hbm2e_lower_test_ch7_u0_axi_m_wdata                     => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_wdata,
  hbm2e_lower_test_ch7_u0_axi_m_wstrb                     => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_lower_test_ch7_u0_axi_m_wvalid                    => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_lower_test_ch7_u0_axi_m_wready                    => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_wready,
  hbm2e_lower_test_ch7_u0_axi_m_bresp                     => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_bresp,
  hbm2e_lower_test_ch7_u0_axi_m_bvalid                    => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_lower_test_ch7_u0_axi_m_bready                    => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_bready,
  hbm2e_lower_test_ch7_u0_axi_m_araddr                    => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_araddr,
  hbm2e_lower_test_ch7_u0_axi_m_arprot                    => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_arprot,
  hbm2e_lower_test_ch7_u0_axi_m_arvalid                   => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_lower_test_ch7_u0_axi_m_arready                   => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_arready,
  hbm2e_lower_test_ch7_u0_axi_m_rdata                     => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_rdata,
  hbm2e_lower_test_ch7_u0_axi_m_rresp                     => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_rresp,
  hbm2e_lower_test_ch7_u0_axi_m_rvalid                    => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_lower_test_ch7_u0_axi_m_rready                    => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_rready,
  hbm2e_lower_test_ch7_u1_axi_m_awaddr                    => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_awaddr,
  hbm2e_lower_test_ch7_u1_axi_m_awprot                    => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_awprot,
  hbm2e_lower_test_ch7_u1_axi_m_awvalid                   => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_awvalid,
  hbm2e_lower_test_ch7_u1_axi_m_awready                   => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_awready,
  hbm2e_lower_test_ch7_u1_axi_m_wdata                     => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_wdata,
  hbm2e_lower_test_ch7_u1_axi_m_wstrb                     => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_wstrb,
  hbm2e_lower_test_ch7_u1_axi_m_wvalid                    => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_wvalid,
  hbm2e_lower_test_ch7_u1_axi_m_wready                    => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_wready,
  hbm2e_lower_test_ch7_u1_axi_m_bresp                     => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_bresp,
  hbm2e_lower_test_ch7_u1_axi_m_bvalid                    => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_bvalid,
  hbm2e_lower_test_ch7_u1_axi_m_bready                    => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_bready,
  hbm2e_lower_test_ch7_u1_axi_m_araddr                    => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_araddr,
  hbm2e_lower_test_ch7_u1_axi_m_arprot                    => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_arprot,
  hbm2e_lower_test_ch7_u1_axi_m_arvalid                   => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_arvalid,
  hbm2e_lower_test_ch7_u1_axi_m_arready                   => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_arready,
  hbm2e_lower_test_ch7_u1_axi_m_rdata                     => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_rdata,
  hbm2e_lower_test_ch7_u1_axi_m_rresp                     => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_rresp,
  hbm2e_lower_test_ch7_u1_axi_m_rvalid                    => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_rvalid,
  hbm2e_lower_test_ch7_u1_axi_m_rready                    => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_rready,
  hbm2e_lower_error_log_ch0_u0_axi_m_awaddr               => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_awaddr, 
  hbm2e_lower_error_log_ch0_u0_axi_m_awprot               => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_awprot,
  hbm2e_lower_error_log_ch0_u0_axi_m_awvalid              => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_awvalid,
  hbm2e_lower_error_log_ch0_u0_axi_m_awready              => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_awready, 
  hbm2e_lower_error_log_ch0_u0_axi_m_wdata                => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_wdata,  
  hbm2e_lower_error_log_ch0_u0_axi_m_wstrb                => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_wstrb,  
  hbm2e_lower_error_log_ch0_u0_axi_m_wvalid               => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_wvalid,
  hbm2e_lower_error_log_ch0_u0_axi_m_wready               => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_wready,
  hbm2e_lower_error_log_ch0_u0_axi_m_bresp                => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_bresp,	
  hbm2e_lower_error_log_ch0_u0_axi_m_bvalid               => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_bvalid,	
  hbm2e_lower_error_log_ch0_u0_axi_m_bready               => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_bready,	
  hbm2e_lower_error_log_ch0_u0_axi_m_araddr               => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_araddr, 	
  hbm2e_lower_error_log_ch0_u0_axi_m_arprot               => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_arprot,	
  hbm2e_lower_error_log_ch0_u0_axi_m_arvalid              => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_arvalid,	
  hbm2e_lower_error_log_ch0_u0_axi_m_arready              => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_arready, 
  hbm2e_lower_error_log_ch0_u0_axi_m_rdata                => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_rdata,	
  hbm2e_lower_error_log_ch0_u0_axi_m_rresp                => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_rresp,	
  hbm2e_lower_error_log_ch0_u0_axi_m_rvalid               => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_rvalid,	
  hbm2e_lower_error_log_ch0_u0_axi_m_rready               => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_rready, 
  hbm2e_lower_error_log_ch0_u1_axi_m_awaddr               => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_awaddr, 
  hbm2e_lower_error_log_ch0_u1_axi_m_awprot               => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_awprot,
  hbm2e_lower_error_log_ch0_u1_axi_m_awvalid              => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_awvalid,
  hbm2e_lower_error_log_ch0_u1_axi_m_awready              => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_awready, 
  hbm2e_lower_error_log_ch0_u1_axi_m_wdata                => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_wdata,  
  hbm2e_lower_error_log_ch0_u1_axi_m_wstrb                => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_wstrb,  
  hbm2e_lower_error_log_ch0_u1_axi_m_wvalid               => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_wvalid,
  hbm2e_lower_error_log_ch0_u1_axi_m_wready               => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_wready,
  hbm2e_lower_error_log_ch0_u1_axi_m_bresp                => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_bresp,	
  hbm2e_lower_error_log_ch0_u1_axi_m_bvalid               => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_bvalid,	
  hbm2e_lower_error_log_ch0_u1_axi_m_bready               => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_bready,	
  hbm2e_lower_error_log_ch0_u1_axi_m_araddr               => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_araddr, 	
  hbm2e_lower_error_log_ch0_u1_axi_m_arprot               => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_arprot,	
  hbm2e_lower_error_log_ch0_u1_axi_m_arvalid              => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_arvalid,	
  hbm2e_lower_error_log_ch0_u1_axi_m_arready              => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_arready, 
  hbm2e_lower_error_log_ch0_u1_axi_m_rdata                => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_rdata,	
  hbm2e_lower_error_log_ch0_u1_axi_m_rresp                => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_rresp,	
  hbm2e_lower_error_log_ch0_u1_axi_m_rvalid               => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_rvalid,	
  hbm2e_lower_error_log_ch0_u1_axi_m_rready               => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_rready, 
  hbm2e_lower_error_log_ch1_u0_axi_m_awaddr               => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_awaddr, 
  hbm2e_lower_error_log_ch1_u0_axi_m_awprot               => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_awprot,
  hbm2e_lower_error_log_ch1_u0_axi_m_awvalid              => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_awvalid,
  hbm2e_lower_error_log_ch1_u0_axi_m_awready              => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_awready, 
  hbm2e_lower_error_log_ch1_u0_axi_m_wdata                => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_wdata,  
  hbm2e_lower_error_log_ch1_u0_axi_m_wstrb                => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_wstrb,  
  hbm2e_lower_error_log_ch1_u0_axi_m_wvalid               => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_wvalid,
  hbm2e_lower_error_log_ch1_u0_axi_m_wready               => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_wready,
  hbm2e_lower_error_log_ch1_u0_axi_m_bresp                => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_bresp,	
  hbm2e_lower_error_log_ch1_u0_axi_m_bvalid               => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_bvalid,	
  hbm2e_lower_error_log_ch1_u0_axi_m_bready               => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_bready,	
  hbm2e_lower_error_log_ch1_u0_axi_m_araddr               => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_araddr, 	
  hbm2e_lower_error_log_ch1_u0_axi_m_arprot               => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_arprot,	
  hbm2e_lower_error_log_ch1_u0_axi_m_arvalid              => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_arvalid,	
  hbm2e_lower_error_log_ch1_u0_axi_m_arready              => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_arready, 
  hbm2e_lower_error_log_ch1_u0_axi_m_rdata                => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_rdata,	
  hbm2e_lower_error_log_ch1_u0_axi_m_rresp                => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_rresp,	
  hbm2e_lower_error_log_ch1_u0_axi_m_rvalid               => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_rvalid,	
  hbm2e_lower_error_log_ch1_u0_axi_m_rready               => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_rready, 
  hbm2e_lower_error_log_ch1_u1_axi_m_awaddr               => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_awaddr, 
  hbm2e_lower_error_log_ch1_u1_axi_m_awprot               => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_awprot,
  hbm2e_lower_error_log_ch1_u1_axi_m_awvalid              => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_awvalid,
  hbm2e_lower_error_log_ch1_u1_axi_m_awready              => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_awready, 
  hbm2e_lower_error_log_ch1_u1_axi_m_wdata                => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_wdata,  
  hbm2e_lower_error_log_ch1_u1_axi_m_wstrb                => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_wstrb,  
  hbm2e_lower_error_log_ch1_u1_axi_m_wvalid               => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_wvalid,
  hbm2e_lower_error_log_ch1_u1_axi_m_wready               => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_wready,
  hbm2e_lower_error_log_ch1_u1_axi_m_bresp                => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_bresp,	
  hbm2e_lower_error_log_ch1_u1_axi_m_bvalid               => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_bvalid,	
  hbm2e_lower_error_log_ch1_u1_axi_m_bready               => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_bready,	
  hbm2e_lower_error_log_ch1_u1_axi_m_araddr               => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_araddr, 	
  hbm2e_lower_error_log_ch1_u1_axi_m_arprot               => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_arprot,	
  hbm2e_lower_error_log_ch1_u1_axi_m_arvalid              => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_arvalid,	
  hbm2e_lower_error_log_ch1_u1_axi_m_arready              => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_arready, 
  hbm2e_lower_error_log_ch1_u1_axi_m_rdata                => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_rdata,	
  hbm2e_lower_error_log_ch1_u1_axi_m_rresp                => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_rresp,	
  hbm2e_lower_error_log_ch1_u1_axi_m_rvalid               => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_rvalid,	
  hbm2e_lower_error_log_ch1_u1_axi_m_rready               => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_rready, 
  hbm2e_lower_error_log_ch2_u0_axi_m_awaddr               => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_awaddr, 
  hbm2e_lower_error_log_ch2_u0_axi_m_awprot               => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_awprot,
  hbm2e_lower_error_log_ch2_u0_axi_m_awvalid              => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_awvalid,
  hbm2e_lower_error_log_ch2_u0_axi_m_awready              => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_awready, 
  hbm2e_lower_error_log_ch2_u0_axi_m_wdata                => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_wdata,  
  hbm2e_lower_error_log_ch2_u0_axi_m_wstrb                => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_wstrb,  
  hbm2e_lower_error_log_ch2_u0_axi_m_wvalid               => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_wvalid,
  hbm2e_lower_error_log_ch2_u0_axi_m_wready               => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_wready,
  hbm2e_lower_error_log_ch2_u0_axi_m_bresp                => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_bresp,	
  hbm2e_lower_error_log_ch2_u0_axi_m_bvalid               => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_bvalid,	
  hbm2e_lower_error_log_ch2_u0_axi_m_bready               => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_bready,	
  hbm2e_lower_error_log_ch2_u0_axi_m_araddr               => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_araddr, 	
  hbm2e_lower_error_log_ch2_u0_axi_m_arprot               => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_arprot,	
  hbm2e_lower_error_log_ch2_u0_axi_m_arvalid              => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_arvalid,	
  hbm2e_lower_error_log_ch2_u0_axi_m_arready              => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_arready, 
  hbm2e_lower_error_log_ch2_u0_axi_m_rdata                => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_rdata,	
  hbm2e_lower_error_log_ch2_u0_axi_m_rresp                => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_rresp,	
  hbm2e_lower_error_log_ch2_u0_axi_m_rvalid               => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_rvalid,	
  hbm2e_lower_error_log_ch2_u0_axi_m_rready               => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_rready, 
  hbm2e_lower_error_log_ch2_u1_axi_m_awaddr               => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_awaddr, 
  hbm2e_lower_error_log_ch2_u1_axi_m_awprot               => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_awprot,
  hbm2e_lower_error_log_ch2_u1_axi_m_awvalid              => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_awvalid,
  hbm2e_lower_error_log_ch2_u1_axi_m_awready              => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_awready, 
  hbm2e_lower_error_log_ch2_u1_axi_m_wdata                => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_wdata,  
  hbm2e_lower_error_log_ch2_u1_axi_m_wstrb                => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_wstrb,  
  hbm2e_lower_error_log_ch2_u1_axi_m_wvalid               => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_wvalid,
  hbm2e_lower_error_log_ch2_u1_axi_m_wready               => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_wready,
  hbm2e_lower_error_log_ch2_u1_axi_m_bresp                => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_bresp,	
  hbm2e_lower_error_log_ch2_u1_axi_m_bvalid               => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_bvalid,	
  hbm2e_lower_error_log_ch2_u1_axi_m_bready               => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_bready,	
  hbm2e_lower_error_log_ch2_u1_axi_m_araddr               => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_araddr, 	
  hbm2e_lower_error_log_ch2_u1_axi_m_arprot               => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_arprot,	
  hbm2e_lower_error_log_ch2_u1_axi_m_arvalid              => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_arvalid,	
  hbm2e_lower_error_log_ch2_u1_axi_m_arready              => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_arready, 
  hbm2e_lower_error_log_ch2_u1_axi_m_rdata                => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_rdata,	
  hbm2e_lower_error_log_ch2_u1_axi_m_rresp                => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_rresp,	
  hbm2e_lower_error_log_ch2_u1_axi_m_rvalid               => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_rvalid,	
  hbm2e_lower_error_log_ch2_u1_axi_m_rready               => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_rready, 
  hbm2e_lower_error_log_ch3_u0_axi_m_awaddr               => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_awaddr, 
  hbm2e_lower_error_log_ch3_u0_axi_m_awprot               => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_awprot,
  hbm2e_lower_error_log_ch3_u0_axi_m_awvalid              => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_awvalid,
  hbm2e_lower_error_log_ch3_u0_axi_m_awready              => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_awready, 
  hbm2e_lower_error_log_ch3_u0_axi_m_wdata                => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_wdata,  
  hbm2e_lower_error_log_ch3_u0_axi_m_wstrb                => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_wstrb,  
  hbm2e_lower_error_log_ch3_u0_axi_m_wvalid               => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_wvalid,
  hbm2e_lower_error_log_ch3_u0_axi_m_wready               => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_wready,
  hbm2e_lower_error_log_ch3_u0_axi_m_bresp                => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_bresp,	
  hbm2e_lower_error_log_ch3_u0_axi_m_bvalid               => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_bvalid,	
  hbm2e_lower_error_log_ch3_u0_axi_m_bready               => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_bready,	
  hbm2e_lower_error_log_ch3_u0_axi_m_araddr               => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_araddr, 	
  hbm2e_lower_error_log_ch3_u0_axi_m_arprot               => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_arprot,	
  hbm2e_lower_error_log_ch3_u0_axi_m_arvalid              => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_arvalid,	
  hbm2e_lower_error_log_ch3_u0_axi_m_arready              => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_arready, 
  hbm2e_lower_error_log_ch3_u0_axi_m_rdata                => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_rdata,	
  hbm2e_lower_error_log_ch3_u0_axi_m_rresp                => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_rresp,	
  hbm2e_lower_error_log_ch3_u0_axi_m_rvalid               => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_rvalid,	
  hbm2e_lower_error_log_ch3_u0_axi_m_rready               => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_rready, 
  hbm2e_lower_error_log_ch3_u1_axi_m_awaddr               => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_awaddr, 
  hbm2e_lower_error_log_ch3_u1_axi_m_awprot               => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_awprot,
  hbm2e_lower_error_log_ch3_u1_axi_m_awvalid              => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_awvalid,
  hbm2e_lower_error_log_ch3_u1_axi_m_awready              => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_awready, 
  hbm2e_lower_error_log_ch3_u1_axi_m_wdata                => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_wdata,  
  hbm2e_lower_error_log_ch3_u1_axi_m_wstrb                => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_wstrb,  
  hbm2e_lower_error_log_ch3_u1_axi_m_wvalid               => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_wvalid,
  hbm2e_lower_error_log_ch3_u1_axi_m_wready               => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_wready,
  hbm2e_lower_error_log_ch3_u1_axi_m_bresp                => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_bresp,	
  hbm2e_lower_error_log_ch3_u1_axi_m_bvalid               => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_bvalid,	
  hbm2e_lower_error_log_ch3_u1_axi_m_bready               => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_bready,	
  hbm2e_lower_error_log_ch3_u1_axi_m_araddr               => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_araddr, 	
  hbm2e_lower_error_log_ch3_u1_axi_m_arprot               => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_arprot,	
  hbm2e_lower_error_log_ch3_u1_axi_m_arvalid              => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_arvalid,	
  hbm2e_lower_error_log_ch3_u1_axi_m_arready              => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_arready, 
  hbm2e_lower_error_log_ch3_u1_axi_m_rdata                => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_rdata,	
  hbm2e_lower_error_log_ch3_u1_axi_m_rresp                => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_rresp,	
  hbm2e_lower_error_log_ch3_u1_axi_m_rvalid               => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_rvalid,	
  hbm2e_lower_error_log_ch3_u1_axi_m_rready               => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_rready, 
  hbm2e_lower_error_log_ch4_u0_axi_m_awaddr               => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_awaddr, 
  hbm2e_lower_error_log_ch4_u0_axi_m_awprot               => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_awprot,
  hbm2e_lower_error_log_ch4_u0_axi_m_awvalid              => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_awvalid,
  hbm2e_lower_error_log_ch4_u0_axi_m_awready              => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_awready, 
  hbm2e_lower_error_log_ch4_u0_axi_m_wdata                => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_wdata,  
  hbm2e_lower_error_log_ch4_u0_axi_m_wstrb                => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_wstrb,  
  hbm2e_lower_error_log_ch4_u0_axi_m_wvalid               => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_wvalid,
  hbm2e_lower_error_log_ch4_u0_axi_m_wready               => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_wready,
  hbm2e_lower_error_log_ch4_u0_axi_m_bresp                => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_bresp,	
  hbm2e_lower_error_log_ch4_u0_axi_m_bvalid               => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_bvalid,	
  hbm2e_lower_error_log_ch4_u0_axi_m_bready               => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_bready,	
  hbm2e_lower_error_log_ch4_u0_axi_m_araddr               => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_araddr, 	
  hbm2e_lower_error_log_ch4_u0_axi_m_arprot               => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_arprot,	
  hbm2e_lower_error_log_ch4_u0_axi_m_arvalid              => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_arvalid,	
  hbm2e_lower_error_log_ch4_u0_axi_m_arready              => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_arready, 
  hbm2e_lower_error_log_ch4_u0_axi_m_rdata                => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_rdata,	
  hbm2e_lower_error_log_ch4_u0_axi_m_rresp                => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_rresp,	
  hbm2e_lower_error_log_ch4_u0_axi_m_rvalid               => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_rvalid,	
  hbm2e_lower_error_log_ch4_u0_axi_m_rready               => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_rready, 
  hbm2e_lower_error_log_ch4_u1_axi_m_awaddr               => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_awaddr, 
  hbm2e_lower_error_log_ch4_u1_axi_m_awprot               => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_awprot,
  hbm2e_lower_error_log_ch4_u1_axi_m_awvalid              => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_awvalid,
  hbm2e_lower_error_log_ch4_u1_axi_m_awready              => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_awready, 
  hbm2e_lower_error_log_ch4_u1_axi_m_wdata                => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_wdata,  
  hbm2e_lower_error_log_ch4_u1_axi_m_wstrb                => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_wstrb,  
  hbm2e_lower_error_log_ch4_u1_axi_m_wvalid               => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_wvalid,
  hbm2e_lower_error_log_ch4_u1_axi_m_wready               => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_wready,
  hbm2e_lower_error_log_ch4_u1_axi_m_bresp                => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_bresp,	
  hbm2e_lower_error_log_ch4_u1_axi_m_bvalid               => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_bvalid,	
  hbm2e_lower_error_log_ch4_u1_axi_m_bready               => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_bready,	
  hbm2e_lower_error_log_ch4_u1_axi_m_araddr               => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_araddr, 	
  hbm2e_lower_error_log_ch4_u1_axi_m_arprot               => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_arprot,	
  hbm2e_lower_error_log_ch4_u1_axi_m_arvalid              => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_arvalid,	
  hbm2e_lower_error_log_ch4_u1_axi_m_arready              => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_arready, 
  hbm2e_lower_error_log_ch4_u1_axi_m_rdata                => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_rdata,	
  hbm2e_lower_error_log_ch4_u1_axi_m_rresp                => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_rresp,	
  hbm2e_lower_error_log_ch4_u1_axi_m_rvalid               => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_rvalid,	
  hbm2e_lower_error_log_ch4_u1_axi_m_rready               => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_rready, 
  hbm2e_lower_error_log_ch5_u0_axi_m_awaddr               => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_awaddr, 
  hbm2e_lower_error_log_ch5_u0_axi_m_awprot               => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_awprot,
  hbm2e_lower_error_log_ch5_u0_axi_m_awvalid              => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_awvalid,
  hbm2e_lower_error_log_ch5_u0_axi_m_awready              => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_awready, 
  hbm2e_lower_error_log_ch5_u0_axi_m_wdata                => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_wdata,  
  hbm2e_lower_error_log_ch5_u0_axi_m_wstrb                => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_wstrb,  
  hbm2e_lower_error_log_ch5_u0_axi_m_wvalid               => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_wvalid,
  hbm2e_lower_error_log_ch5_u0_axi_m_wready               => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_wready,
  hbm2e_lower_error_log_ch5_u0_axi_m_bresp                => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_bresp,	
  hbm2e_lower_error_log_ch5_u0_axi_m_bvalid               => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_bvalid,	
  hbm2e_lower_error_log_ch5_u0_axi_m_bready               => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_bready,	
  hbm2e_lower_error_log_ch5_u0_axi_m_araddr               => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_araddr, 	
  hbm2e_lower_error_log_ch5_u0_axi_m_arprot               => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_arprot,	
  hbm2e_lower_error_log_ch5_u0_axi_m_arvalid              => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_arvalid,	
  hbm2e_lower_error_log_ch5_u0_axi_m_arready              => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_arready, 
  hbm2e_lower_error_log_ch5_u0_axi_m_rdata                => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_rdata,	
  hbm2e_lower_error_log_ch5_u0_axi_m_rresp                => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_rresp,	
  hbm2e_lower_error_log_ch5_u0_axi_m_rvalid               => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_rvalid,	
  hbm2e_lower_error_log_ch5_u0_axi_m_rready               => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_rready, 
  hbm2e_lower_error_log_ch5_u1_axi_m_awaddr               => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_awaddr, 
  hbm2e_lower_error_log_ch5_u1_axi_m_awprot               => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_awprot,
  hbm2e_lower_error_log_ch5_u1_axi_m_awvalid              => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_awvalid,
  hbm2e_lower_error_log_ch5_u1_axi_m_awready              => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_awready, 
  hbm2e_lower_error_log_ch5_u1_axi_m_wdata                => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_wdata,  
  hbm2e_lower_error_log_ch5_u1_axi_m_wstrb                => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_wstrb,  
  hbm2e_lower_error_log_ch5_u1_axi_m_wvalid               => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_wvalid,
  hbm2e_lower_error_log_ch5_u1_axi_m_wready               => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_wready,
  hbm2e_lower_error_log_ch5_u1_axi_m_bresp                => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_bresp,	
  hbm2e_lower_error_log_ch5_u1_axi_m_bvalid               => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_bvalid,	
  hbm2e_lower_error_log_ch5_u1_axi_m_bready               => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_bready,	
  hbm2e_lower_error_log_ch5_u1_axi_m_araddr               => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_araddr, 	
  hbm2e_lower_error_log_ch5_u1_axi_m_arprot               => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_arprot,	
  hbm2e_lower_error_log_ch5_u1_axi_m_arvalid              => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_arvalid,	
  hbm2e_lower_error_log_ch5_u1_axi_m_arready              => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_arready, 
  hbm2e_lower_error_log_ch5_u1_axi_m_rdata                => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_rdata,	
  hbm2e_lower_error_log_ch5_u1_axi_m_rresp                => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_rresp,	
  hbm2e_lower_error_log_ch5_u1_axi_m_rvalid               => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_rvalid,	
  hbm2e_lower_error_log_ch5_u1_axi_m_rready               => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_rready, 
  hbm2e_lower_error_log_ch6_u0_axi_m_awaddr               => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_awaddr, 
  hbm2e_lower_error_log_ch6_u0_axi_m_awprot               => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_awprot,
  hbm2e_lower_error_log_ch6_u0_axi_m_awvalid              => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_awvalid,
  hbm2e_lower_error_log_ch6_u0_axi_m_awready              => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_awready, 
  hbm2e_lower_error_log_ch6_u0_axi_m_wdata                => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_wdata,  
  hbm2e_lower_error_log_ch6_u0_axi_m_wstrb                => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_wstrb,  
  hbm2e_lower_error_log_ch6_u0_axi_m_wvalid               => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_wvalid,
  hbm2e_lower_error_log_ch6_u0_axi_m_wready               => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_wready,
  hbm2e_lower_error_log_ch6_u0_axi_m_bresp                => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_bresp,	
  hbm2e_lower_error_log_ch6_u0_axi_m_bvalid               => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_bvalid,	
  hbm2e_lower_error_log_ch6_u0_axi_m_bready               => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_bready,	
  hbm2e_lower_error_log_ch6_u0_axi_m_araddr               => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_araddr, 	
  hbm2e_lower_error_log_ch6_u0_axi_m_arprot               => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_arprot,	
  hbm2e_lower_error_log_ch6_u0_axi_m_arvalid              => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_arvalid,	
  hbm2e_lower_error_log_ch6_u0_axi_m_arready              => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_arready, 
  hbm2e_lower_error_log_ch6_u0_axi_m_rdata                => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_rdata,	
  hbm2e_lower_error_log_ch6_u0_axi_m_rresp                => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_rresp,	
  hbm2e_lower_error_log_ch6_u0_axi_m_rvalid               => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_rvalid,	
  hbm2e_lower_error_log_ch6_u0_axi_m_rready               => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_rready, 
  hbm2e_lower_error_log_ch6_u1_axi_m_awaddr               => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_awaddr, 
  hbm2e_lower_error_log_ch6_u1_axi_m_awprot               => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_awprot,
  hbm2e_lower_error_log_ch6_u1_axi_m_awvalid              => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_awvalid,
  hbm2e_lower_error_log_ch6_u1_axi_m_awready              => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_awready, 
  hbm2e_lower_error_log_ch6_u1_axi_m_wdata                => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_wdata,  
  hbm2e_lower_error_log_ch6_u1_axi_m_wstrb                => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_wstrb,  
  hbm2e_lower_error_log_ch6_u1_axi_m_wvalid               => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_wvalid,
  hbm2e_lower_error_log_ch6_u1_axi_m_wready               => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_wready,
  hbm2e_lower_error_log_ch6_u1_axi_m_bresp                => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_bresp,	
  hbm2e_lower_error_log_ch6_u1_axi_m_bvalid               => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_bvalid,	
  hbm2e_lower_error_log_ch6_u1_axi_m_bready               => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_bready,	
  hbm2e_lower_error_log_ch6_u1_axi_m_araddr               => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_araddr, 	
  hbm2e_lower_error_log_ch6_u1_axi_m_arprot               => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_arprot,	
  hbm2e_lower_error_log_ch6_u1_axi_m_arvalid              => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_arvalid,	
  hbm2e_lower_error_log_ch6_u1_axi_m_arready              => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_arready, 
  hbm2e_lower_error_log_ch6_u1_axi_m_rdata                => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_rdata,	
  hbm2e_lower_error_log_ch6_u1_axi_m_rresp                => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_rresp,	
  hbm2e_lower_error_log_ch6_u1_axi_m_rvalid               => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_rvalid,	
  hbm2e_lower_error_log_ch6_u1_axi_m_rready               => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_rready, 
  hbm2e_lower_error_log_ch7_u0_axi_m_awaddr               => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_awaddr, 
  hbm2e_lower_error_log_ch7_u0_axi_m_awprot               => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_awprot,
  hbm2e_lower_error_log_ch7_u0_axi_m_awvalid              => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_awvalid,
  hbm2e_lower_error_log_ch7_u0_axi_m_awready              => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_awready, 
  hbm2e_lower_error_log_ch7_u0_axi_m_wdata                => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_wdata,  
  hbm2e_lower_error_log_ch7_u0_axi_m_wstrb                => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_wstrb,  
  hbm2e_lower_error_log_ch7_u0_axi_m_wvalid               => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_wvalid,
  hbm2e_lower_error_log_ch7_u0_axi_m_wready               => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_wready,
  hbm2e_lower_error_log_ch7_u0_axi_m_bresp                => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_bresp,	
  hbm2e_lower_error_log_ch7_u0_axi_m_bvalid               => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_bvalid,	
  hbm2e_lower_error_log_ch7_u0_axi_m_bready               => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_bready,	
  hbm2e_lower_error_log_ch7_u0_axi_m_araddr               => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_araddr, 	
  hbm2e_lower_error_log_ch7_u0_axi_m_arprot               => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_arprot,	
  hbm2e_lower_error_log_ch7_u0_axi_m_arvalid              => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_arvalid,	
  hbm2e_lower_error_log_ch7_u0_axi_m_arready              => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_arready, 
  hbm2e_lower_error_log_ch7_u0_axi_m_rdata                => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_rdata,	
  hbm2e_lower_error_log_ch7_u0_axi_m_rresp                => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_rresp,	
  hbm2e_lower_error_log_ch7_u0_axi_m_rvalid               => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_rvalid,	
  hbm2e_lower_error_log_ch7_u0_axi_m_rready               => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_rready, 
  hbm2e_lower_error_log_ch7_u1_axi_m_awaddr               => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_awaddr, 
  hbm2e_lower_error_log_ch7_u1_axi_m_awprot               => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_awprot,
  hbm2e_lower_error_log_ch7_u1_axi_m_awvalid              => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_awvalid,
  hbm2e_lower_error_log_ch7_u1_axi_m_awready              => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_awready, 
  hbm2e_lower_error_log_ch7_u1_axi_m_wdata                => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_wdata,  
  hbm2e_lower_error_log_ch7_u1_axi_m_wstrb                => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_wstrb,  
  hbm2e_lower_error_log_ch7_u1_axi_m_wvalid               => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_wvalid,
  hbm2e_lower_error_log_ch7_u1_axi_m_wready               => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_wready,
  hbm2e_lower_error_log_ch7_u1_axi_m_bresp                => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_bresp,	
  hbm2e_lower_error_log_ch7_u1_axi_m_bvalid               => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_bvalid,	
  hbm2e_lower_error_log_ch7_u1_axi_m_bready               => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_bready,	
  hbm2e_lower_error_log_ch7_u1_axi_m_araddr               => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_araddr, 	
  hbm2e_lower_error_log_ch7_u1_axi_m_arprot               => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_arprot,	
  hbm2e_lower_error_log_ch7_u1_axi_m_arvalid              => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_arvalid,	
  hbm2e_lower_error_log_ch7_u1_axi_m_arready              => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_arready, 
  hbm2e_lower_error_log_ch7_u1_axi_m_rdata                => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_rdata,	
  hbm2e_lower_error_log_ch7_u1_axi_m_rresp                => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_rresp,	
  hbm2e_lower_error_log_ch7_u1_axi_m_rvalid               => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_rvalid,	
  hbm2e_lower_error_log_ch7_u1_axi_m_rready               => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_rready, 
  hip_serial_rx_n_in0                                     => PCIE_RX_N(0),
  hip_serial_rx_n_in1                                     => PCIE_RX_N(1),
  hip_serial_rx_n_in2                                     => PCIE_RX_N(2),
  hip_serial_rx_n_in3                                     => PCIE_RX_N(3),
  hip_serial_rx_n_in4                                     => PCIE_RX_N(4),
  hip_serial_rx_n_in5                                     => PCIE_RX_N(5),
  hip_serial_rx_n_in6                                     => PCIE_RX_N(6),
  hip_serial_rx_n_in7                                     => PCIE_RX_N(7),
  hip_serial_rx_n_in8                                     => PCIE_RX_N(8),
  hip_serial_rx_n_in9                                     => PCIE_RX_N(9),
  hip_serial_rx_n_in10                                    => PCIE_RX_N(10),
  hip_serial_rx_n_in11                                    => PCIE_RX_N(11),
  hip_serial_rx_n_in12                                    => PCIE_RX_N(12),
  hip_serial_rx_n_in13                                    => PCIE_RX_N(13),
  hip_serial_rx_n_in14                                    => PCIE_RX_N(14),
  hip_serial_rx_n_in15                                    => PCIE_RX_N(15),
  hip_serial_rx_p_in0                                     => PCIE_RX_P(0),
  hip_serial_rx_p_in1                                     => PCIE_RX_P(1),
  hip_serial_rx_p_in2                                     => PCIE_RX_P(2),
  hip_serial_rx_p_in3                                     => PCIE_RX_P(3),
  hip_serial_rx_p_in4                                     => PCIE_RX_P(4),
  hip_serial_rx_p_in5                                     => PCIE_RX_P(5),
  hip_serial_rx_p_in6                                     => PCIE_RX_P(6),
  hip_serial_rx_p_in7                                     => PCIE_RX_P(7),
  hip_serial_rx_p_in8                                     => PCIE_RX_P(8),
  hip_serial_rx_p_in9                                     => PCIE_RX_P(9),
  hip_serial_rx_p_in10                                    => PCIE_RX_P(10),
  hip_serial_rx_p_in11                                    => PCIE_RX_P(11),
  hip_serial_rx_p_in12                                    => PCIE_RX_P(12),
  hip_serial_rx_p_in13                                    => PCIE_RX_P(13),
  hip_serial_rx_p_in14                                    => PCIE_RX_P(14),
  hip_serial_rx_p_in15                                    => PCIE_RX_P(15),
  hip_serial_tx_n_out0                                    => PCIE_TX_N(0),
  hip_serial_tx_n_out1                                    => PCIE_TX_N(1),
  hip_serial_tx_n_out2                                    => PCIE_TX_N(2),
  hip_serial_tx_n_out3                                    => PCIE_TX_N(3),
  hip_serial_tx_n_out4                                    => PCIE_TX_N(4),
  hip_serial_tx_n_out5                                    => PCIE_TX_N(5),
  hip_serial_tx_n_out6                                    => PCIE_TX_N(6),
  hip_serial_tx_n_out7                                    => PCIE_TX_N(7),
  hip_serial_tx_n_out8                                    => PCIE_TX_N(8),
  hip_serial_tx_n_out9                                    => PCIE_TX_N(9),
  hip_serial_tx_n_out10                                   => PCIE_TX_N(10),
  hip_serial_tx_n_out11                                   => PCIE_TX_N(11),
  hip_serial_tx_n_out12                                   => PCIE_TX_N(12),
  hip_serial_tx_n_out13                                   => PCIE_TX_N(13),
  hip_serial_tx_n_out14                                   => PCIE_TX_N(14),
  hip_serial_tx_n_out15                                   => PCIE_TX_N(15),
  hip_serial_tx_p_out0                                    => PCIE_TX_P(0),
  hip_serial_tx_p_out1                                    => PCIE_TX_P(1),
  hip_serial_tx_p_out2                                    => PCIE_TX_P(2),
  hip_serial_tx_p_out3                                    => PCIE_TX_P(3),
  hip_serial_tx_p_out4                                    => PCIE_TX_P(4),
  hip_serial_tx_p_out5                                    => PCIE_TX_P(5),
  hip_serial_tx_p_out6                                    => PCIE_TX_P(6),
  hip_serial_tx_p_out7                                    => PCIE_TX_P(7),
  hip_serial_tx_p_out8                                    => PCIE_TX_P(8),
  hip_serial_tx_p_out9                                    => PCIE_TX_P(9),
  hip_serial_tx_p_out10                                   => PCIE_TX_P(10),
  hip_serial_tx_p_out11                                   => PCIE_TX_P(11),
  hip_serial_tx_p_out12                                   => PCIE_TX_P(12),
  hip_serial_tx_p_out13                                   => PCIE_TX_P(13),
  hip_serial_tx_p_out14                                   => PCIE_TX_P(14),
  hip_serial_tx_p_out15                                   => PCIE_TX_P(15),
  pcie_refclk0_clk                                        => PCIE_REFCLK0,
  pcie_refclk1_clk                                        => PCIE_REFCLK1,
  ninit_done_reset                                        => ninit_done,
  dummy_user_avmm_rst_reset                               => '0',
  pin_perst_reset_n                                       => PERST_L,
  pin_perst_n_o_reset_n                                   => pci_perst_n,
  sl4_reconfig0_m_waitrequest                             => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_waitrequest,
  sl4_reconfig0_m_readdata                                => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_readdata,
  sl4_reconfig0_m_readdatavalid                           => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_readdatavalid,
  sl4_reconfig0_m_burstcount                              => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_burstcount,
  sl4_reconfig0_m_writedata                               => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_writedata,
  sl4_reconfig0_m_address                                 => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_address,
  sl4_reconfig0_m_write                                   => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_write,
  sl4_reconfig0_m_read                                    => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_read,
  sl4_reconfig0_m_byteenable                              => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_byteenable,
  sl4_reconfig0_m_debugaccess                             => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_debugaccess,
  xcvr_reconfig0_m_waitrequest                            => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_waitrequest,
  xcvr_reconfig0_m_readdata                               => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_readdata,
  xcvr_reconfig0_m_readdatavalid                          => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_readdatavalid,
  xcvr_reconfig0_m_burstcount                             => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_burstcount,
  xcvr_reconfig0_m_writedata                              => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_writedata,
  xcvr_reconfig0_m_address                                => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_address,
  xcvr_reconfig0_m_write                                  => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_write,
  xcvr_reconfig0_m_read                                   => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_read,
  xcvr_reconfig0_m_byteenable                             => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_byteenable,
  xcvr_reconfig0_m_debugaccess                            => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_debugaccess,
  sl4_reconfig1_m_waitrequest                             => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_waitrequest,
  sl4_reconfig1_m_readdata                                => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_readdata,
  sl4_reconfig1_m_readdatavalid                           => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_readdatavalid,
  sl4_reconfig1_m_burstcount                              => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_burstcount,
  sl4_reconfig1_m_writedata                               => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_writedata,
  sl4_reconfig1_m_address                                 => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_address,
  sl4_reconfig1_m_write                                   => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_write,
  sl4_reconfig1_m_read                                    => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_read,
  sl4_reconfig1_m_byteenable                              => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_byteenable,
  sl4_reconfig1_m_debugaccess                             => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_debugaccess,
  xcvr_reconfig1_m_waitrequest                            => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_waitrequest,
  xcvr_reconfig1_m_readdata                               => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_readdata,
  xcvr_reconfig1_m_readdatavalid                          => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_readdatavalid,
  xcvr_reconfig1_m_burstcount                             => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_burstcount,
  xcvr_reconfig1_m_writedata                              => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_writedata,
  xcvr_reconfig1_m_address                                => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_address,
  xcvr_reconfig1_m_write                                  => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_write,
  xcvr_reconfig1_m_read                                   => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_read,
  xcvr_reconfig1_m_byteenable                             => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_byteenable,
  xcvr_reconfig1_m_debugaccess                            => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_debugaccess,
  sl4_reconfig2_m_waitrequest                             => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_waitrequest,
  sl4_reconfig2_m_readdata                                => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_readdata,
  sl4_reconfig2_m_readdatavalid                           => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_readdatavalid,
  sl4_reconfig2_m_burstcount                              => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_burstcount,
  sl4_reconfig2_m_writedata                               => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_writedata,
  sl4_reconfig2_m_address                                 => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_address,
  sl4_reconfig2_m_write                                   => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_write,
  sl4_reconfig2_m_read                                    => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_read,
  sl4_reconfig2_m_byteenable                              => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_byteenable,
  sl4_reconfig2_m_debugaccess                             => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_debugaccess,
  xcvr_reconfig2_m_waitrequest                            => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_waitrequest,
  xcvr_reconfig2_m_readdata                               => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_readdata,
  xcvr_reconfig2_m_readdatavalid                          => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_readdatavalid,
  xcvr_reconfig2_m_burstcount                             => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_burstcount,
  xcvr_reconfig2_m_writedata                              => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_writedata,
  xcvr_reconfig2_m_address                                => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_address,
  xcvr_reconfig2_m_write                                  => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_write,
  xcvr_reconfig2_m_read                                   => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_read,
  xcvr_reconfig2_m_byteenable                             => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_byteenable,
  xcvr_reconfig2_m_debugaccess                            => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_debugaccess,
  spi_ig_sclk                                             => FPGA_IG_SPI_SCK,
  spi_ig_ss_n                                             => FPGA_IG_SPI_PCS0,
  spi_ig_mosi                                             => FPGA_IG_SPI_MOSI,
  spi_ig_miso                                             => FPGA_IG_SPI_MISO,
  bmc_if_present_n_bmc_if_ready_n                         => BMC_IF_PRESENT_L,
  f2b_irq_n_f2b_irq_n                                     => FPGA_TO_BMC_IRQ,
  spi_eg_sclk                                             => FPGA_EG_SPI_SCK,
  spi_eg_ss_n                                             => FPGA_EG_SPI_PCS0,
  spi_eg_mosi                                             => FPGA_EG_SPI_MOSI,
  spi_eg_miso                                             => FPGA_EG_SPI_MISO,
  b2f_irq_n_b2f_irq_n                                     => BMC_TO_FPGA_IRQ,
  bmc3_telemetry_eeprom_data                              => eeprom_data,			         
  bmc3_telemetry_qspfdd0_ctrl_status_rst_n                => qsfpdd0_rst_n,			        
  bmc3_telemetry_qspfdd0_ctrl_status_lpmode               => qsfpdd0_lpmode,			         
  bmc3_telemetry_qspfdd0_ctrl_status_int_n                => qsfpdd0_int_n,			     
  bmc3_telemetry_qspfdd0_ctrl_status_present_n            => qsfpdd0_present_n,			         
  bmc3_telemetry_qspfdd1_ctrl_status_rst_n                => qsfpdd1_rst_n,			        
  bmc3_telemetry_qspfdd1_ctrl_status_lpmode               => qsfpdd1_lpmode,			         
  bmc3_telemetry_qspfdd1_ctrl_status_int_n                => qsfpdd1_int_n,			     
  bmc3_telemetry_qspfdd1_ctrl_status_present_n            => qsfpdd1_present_n,			         
  bmc3_telemetry_qspfdd2_ctrl_status_rst_n                => qsfpdd2_rst_n,			        
  bmc3_telemetry_qspfdd2_ctrl_status_lpmode               => qsfpdd2_lpmode,			         
  bmc3_telemetry_qspfdd2_ctrl_status_int_n                => qsfpdd2_int_n,			     
  bmc3_telemetry_qspfdd2_ctrl_status_present_n            => qsfpdd2_present_n			           
  );						          

u1_version_and_scratchpad : version_plus_scratchpad 
port map (
  aclk                            => sys_clk,
  areset                          => sys_reset(3),
  awaddr                          => versionid_axi.version_awaddr,              
  awvalid                         => versionid_axi.version_awvalid,             
  awready                         => versionid_axi.version_awready,             
  awprot                          => versionid_axi.version_awprot,              
  wdata                           => versionid_axi.version_wdata,               
  wstrb                           => versionid_axi.version_wstrb,               
  wvalid                          => versionid_axi.version_wvalid,              
  wready                          => versionid_axi.version_wready,              
  bresp                           => versionid_axi.version_bresp,		        		
  bvalid                          => versionid_axi.version_bvalid,		       
  bready                          => versionid_axi.version_bready,		       
  araddr                          => versionid_axi.version_araddr,		       		
  arvalid                         => versionid_axi.version_arvalid,		      
  arready                         => versionid_axi.version_arready,		      
  arprot                          => versionid_axi.version_arprot,              
  rdata                           => versionid_axi.version_rdata,		        
  rresp                           => versionid_axi.version_rresp,		        
  rvalid                          => versionid_axi.version_rvalid,	          
  rready                          => versionid_axi.version_rready	              
  );

test_clocks <= (
                '0',                    -- Clocks19 - Unused
                '0',                    -- Clocks18 - Unused
                '0',                    -- Clocks17 - Unused
                '0',                    -- Clocks16 - Unused
                '0',                    -- Clocks15 - Unused
                '0',                    -- Clocks14 - Unused
                '0',                    -- Clocks13 - Unused
                '0',                    -- Clocks12 - Unused
                usr_clk1_clk100,        -- Clock11 - USR_CLK1 (via PLL), 100MHz
                U1PPS,                  -- Clock10 - 1PPS Clock, 10MHz 
                CLKA,                   -- Clock9 - External Reference Clock, 10MHz
                hbm_tst_clk1,           -- Clock8 - HBM Upper Test Clock, 350MHz
                hbm_tst_clk0,           -- Clock7 - HBM Lower Test Clock, 350MHz
                m2_refclk_pll,          -- Clock6 - M.2 SSD Reference Clock, 100MHz
                mcio_refclk_pll,        -- Clock5 - MCIO Reference Clock, 100MHz
                qsfpdd2_refclk_pll,     -- Clock4 - QSFPDD2 Reference Clock, 156.25MHz
                qsfpdd1_refclk_pll,     -- Clock3 - QSFPDD1 Reference Clock, 156.25MHz
                qsfpdd0_refclk_pll,     -- Clock2 - QSFPDD0 Reference Clock, 156.25MHz
                pcie_usr_clk,           -- Clock1 - PCIe User Clock, 500MHz
                sys_clk                 -- Clock0 - System Clock, 50MHz, 
                );

test_clocks_status <= (
                       '0',                     -- No clock
                       '0',                     -- No clock
                       '0',                     -- No clock
                       '0',                     -- No clock
                       '0',                     -- No clock
                       '0',                     -- No clock
                       '0',                     -- No clock
                       '0',                     -- No clock
                       pll_locked1,             -- User Clock 1 PLL Locked
                       '1',                     -- Always active (straight from pin)
                       '1',                     -- Always active (straight from pin)
                       hbm_fbr_clk1_locked,     -- PLL Locked from HBM_FBR_CLK_PLL_TOP
                       hbm_fbr_clk0_locked,     -- PLL Locked from HBM_FBR_CLK_PLL_BOTTOM
                       qsfpdd2_refclk_lock,     -- Shares a PLL with QSFPDD2 Reference Clock
                       qsfpdd1_refclk_lock,     -- Shares a PLL with QSFPDD1 Reference Clock
                       qsfpdd2_refclk_lock,     -- QSFPDD2 PLL Lock
                       qsfpdd1_refclk_lock,     -- QSFPDD1 PLL Lock
                       qsfpdd0_refclk_lock,     -- QSFPDD0 PLL Lock
                       pcie_usr_resetn,         -- PCIe Clock reset# acts as pll locked
                       pll_locked0              -- System Clock is from PLL
                       );

u2_0_clocks : clock_test
generic map (
  VERSION_MINOR                               => CLK_CAP_VERSION_MINOR,
  VERSION_MAJOR                               => CLK_CAP_VERSION_MAJOR,
  CLOCK0_TYPE                                 => CLK_TEST_CLOCK0_TYPE,
  CLOCK0_EN                                   => CLK_TEST_CLOCK0_EN,
  CLOCK0_FREQ                                 => CLK_TEST_CLOCK0_FREQ,
  CLOCK0_NAME                                 => CLK_TEST_CLOCK0_NAME,
  CLOCK1_TYPE                                 => CLK_TEST_CLOCK1_TYPE,
  CLOCK1_EN                                   => CLK_TEST_CLOCK1_EN,
  CLOCK1_FREQ                                 => CLK_TEST_CLOCK1_FREQ,
  CLOCK1_NAME                                 => CLK_TEST_CLOCK1_NAME,
  CLOCK2_TYPE                                 => CLK_TEST_CLOCK2_TYPE,
  CLOCK2_EN                                   => CLK_TEST_CLOCK2_EN,
  CLOCK2_FREQ                                 => CLK_TEST_CLOCK2_FREQ,
  CLOCK2_NAME                                 => CLK_TEST_CLOCK2_NAME,
  CLOCK3_TYPE                                 => CLK_TEST_CLOCK3_TYPE,
  CLOCK3_EN                                   => CLK_TEST_CLOCK3_EN,
  CLOCK3_FREQ                                 => CLK_TEST_CLOCK3_FREQ,
  CLOCK3_NAME                                 => CLK_TEST_CLOCK3_NAME,
  CLOCK4_TYPE                                 => CLK_TEST_CLOCK4_TYPE,
  CLOCK4_EN                                   => CLK_TEST_CLOCK4_EN,
  CLOCK4_FREQ                                 => CLK_TEST_CLOCK4_FREQ,
  CLOCK4_NAME                                 => CLK_TEST_CLOCK4_NAME,
  CLOCK5_TYPE                                 => CLK_TEST_CLOCK5_TYPE,
  CLOCK5_EN                                   => CLK_TEST_CLOCK5_EN,
  CLOCK5_FREQ                                 => CLK_TEST_CLOCK5_FREQ,
  CLOCK5_NAME                                 => CLK_TEST_CLOCK5_NAME,
  CLOCK6_TYPE                                 => CLK_TEST_CLOCK6_TYPE,
  CLOCK6_EN                                   => CLK_TEST_CLOCK6_EN,
  CLOCK6_FREQ                                 => CLK_TEST_CLOCK6_FREQ,
  CLOCK6_NAME                                 => CLK_TEST_CLOCK6_NAME,
  CLOCK7_TYPE                                 => CLK_TEST_CLOCK7_TYPE,
  CLOCK7_EN                                   => CLK_TEST_CLOCK7_EN,
  CLOCK7_FREQ                                 => CLK_TEST_CLOCK7_FREQ,
  CLOCK7_NAME                                 => CLK_TEST_CLOCK7_NAME,
  CLOCK8_TYPE                                 => CLK_TEST_CLOCK8_TYPE,
  CLOCK8_EN                                   => CLK_TEST_CLOCK8_EN,
  CLOCK8_FREQ                                 => CLK_TEST_CLOCK8_FREQ,
  CLOCK8_NAME                                 => CLK_TEST_CLOCK8_NAME,
  CLOCK9_TYPE                                 => CLK_TEST_CLOCK9_TYPE,
  CLOCK9_EN                                   => CLK_TEST_CLOCK9_EN,
  CLOCK9_FREQ                                 => CLK_TEST_CLOCK9_FREQ,
  CLOCK9_NAME                                 => CLK_TEST_CLOCK9_NAME,
  CLOCK10_TYPE                                => CLK_TEST_CLOCK10_TYPE,
  CLOCK10_EN                                  => CLK_TEST_CLOCK10_EN,
  CLOCK10_FREQ                                => CLK_TEST_CLOCK10_FREQ,
  CLOCK10_NAME                                => CLK_TEST_CLOCK10_NAME,
  CLOCK11_TYPE                                => CLK_TEST_CLOCK11_TYPE,
  CLOCK11_EN                                  => CLK_TEST_CLOCK11_EN,
  CLOCK11_FREQ                                => CLK_TEST_CLOCK11_FREQ,
  CLOCK11_NAME                                => CLK_TEST_CLOCK11_NAME,
  CLOCK12_TYPE                                => CLK_TEST_CLOCK12_TYPE,
  CLOCK12_EN                                  => CLK_TEST_CLOCK12_EN,
  CLOCK12_FREQ                                => CLK_TEST_CLOCK12_FREQ,
  CLOCK12_NAME                                => CLK_TEST_CLOCK12_NAME,
  CLOCK13_TYPE                                => CLK_TEST_CLOCK13_TYPE,
  CLOCK13_EN                                  => CLK_TEST_CLOCK13_EN,
  CLOCK13_FREQ                                => CLK_TEST_CLOCK13_FREQ,
  CLOCK13_NAME                                => CLK_TEST_CLOCK13_NAME,
  CLOCK14_TYPE                                => CLK_TEST_CLOCK14_TYPE,
  CLOCK14_EN                                  => CLK_TEST_CLOCK14_EN,
  CLOCK14_FREQ                                => CLK_TEST_CLOCK14_FREQ,
  CLOCK14_NAME                                => CLK_TEST_CLOCK14_NAME,
  CLOCK15_TYPE                                => CLK_TEST_CLOCK15_TYPE,
  CLOCK15_EN                                  => CLK_TEST_CLOCK15_EN,
  CLOCK15_FREQ                                => CLK_TEST_CLOCK15_FREQ,
  CLOCK15_NAME                                => CLK_TEST_CLOCK15_NAME,
  CLOCK16_TYPE                                => CLK_TEST_CLOCK16_TYPE,
  CLOCK16_EN                                  => CLK_TEST_CLOCK16_EN,
  CLOCK16_FREQ                                => CLK_TEST_CLOCK16_FREQ,
  CLOCK16_NAME                                => CLK_TEST_CLOCK16_NAME,
  CLOCK17_TYPE                                => CLK_TEST_CLOCK17_TYPE,
  CLOCK17_EN                                  => CLK_TEST_CLOCK17_EN,
  CLOCK17_FREQ                                => CLK_TEST_CLOCK17_FREQ,
  CLOCK17_NAME                                => CLK_TEST_CLOCK17_NAME,
  CLOCK18_TYPE                                => CLK_TEST_CLOCK18_TYPE,
  CLOCK18_EN                                  => CLK_TEST_CLOCK18_EN,
  CLOCK18_FREQ                                => CLK_TEST_CLOCK18_FREQ,
  CLOCK18_NAME                                => CLK_TEST_CLOCK18_NAME,
  CLOCK19_TYPE                                => CLK_TEST_CLOCK19_TYPE,
  CLOCK19_EN                                  => CLK_TEST_CLOCK19_EN,
  CLOCK19_FREQ                                => CLK_TEST_CLOCK19_FREQ,
  CLOCK19_NAME                                => CLK_TEST_CLOCK19_NAME
  )
port map (
  clocks_test_aclk      					  => sys_clk,
  clocks_test_areset    					  => sys_reset(4),
  clocks_test_awaddr						  => clock_test_axi.clock_test_awaddr,   
  clocks_test_awvalid 					  	  => clock_test_axi.clock_test_awvalid,  
  clocks_test_awready 					  	  => clock_test_axi.clock_test_awready,  
  clocks_test_awprot						  => clock_test_axi.clock_test_awprot,   
  clocks_test_wdata						  	  => clock_test_axi.clock_test_wdata,    
  clocks_test_wstrb							  => clock_test_axi.clock_test_wstrb,    
  clocks_test_wvalid						  => clock_test_axi.clock_test_wvalid,   
  clocks_test_wready						  => clock_test_axi.clock_test_wready,   
  clocks_test_bresp                           => clock_test_axi.clock_test_bresp,    				
  clocks_test_bvalid                          => clock_test_axi.clock_test_bvalid,   		
  clocks_test_bready                          => clock_test_axi.clock_test_bready,   		
  clocks_test_araddr                          => clock_test_axi.clock_test_araddr,   				
  clocks_test_arvalid                         => clock_test_axi.clock_test_arvalid,  	
  clocks_test_arready                         => clock_test_axi.clock_test_arready,  	
  clocks_test_arprot                          => clock_test_axi.clock_test_arprot,   
  clocks_test_rdata                           => clock_test_axi.clock_test_rdata,    		
  clocks_test_rresp                           => clock_test_axi.clock_test_rresp,    		
  clocks_test_rvalid                          => clock_test_axi.clock_test_rvalid,   
  clocks_test_rready                          => clock_test_axi.clock_test_rready,   
  clocks_test_test_clock                      => test_clocks,
  clocks_test_test_clock_stat                 => test_clocks_status,
  clocks_cap_aclk                             => sys_clk,
  clocks_cap_areset                           => sys_reset(5),
  clocks_cap_awaddr                           => clock_test_capability_axi.clock_test_cap_awaddr,   
  clocks_cap_awvalid                          => clock_test_capability_axi.clock_test_cap_awvalid,  
  clocks_cap_awready                          => clock_test_capability_axi.clock_test_cap_awready,  
  clocks_cap_awprot                           => clock_test_capability_axi.clock_test_cap_awprot,   
  clocks_cap_wdata                            => clock_test_capability_axi.clock_test_cap_wdata,    
  clocks_cap_wstrb                            => clock_test_capability_axi.clock_test_cap_wstrb,    
  clocks_cap_wvalid                           => clock_test_capability_axi.clock_test_cap_wvalid,   
  clocks_cap_wready                           => clock_test_capability_axi.clock_test_cap_wready,   
  clocks_cap_bresp                            => clock_test_capability_axi.clock_test_cap_bresp,    				
  clocks_cap_bvalid                           => clock_test_capability_axi.clock_test_cap_bvalid,   		
  clocks_cap_bready                           => clock_test_capability_axi.clock_test_cap_bready,   		
  clocks_cap_araddr                           => clock_test_capability_axi.clock_test_cap_araddr,   				
  clocks_cap_arvalid                          => clock_test_capability_axi.clock_test_cap_arvalid,  	
  clocks_cap_arready                          => clock_test_capability_axi.clock_test_cap_arready,  	
  clocks_cap_arprot                           => clock_test_capability_axi.clock_test_cap_arprot,   
  clocks_cap_rdata                            => clock_test_capability_axi.clock_test_cap_rdata,    		
  clocks_cap_rresp                            => clock_test_capability_axi.clock_test_cap_rresp,    		
  clocks_cap_rvalid                           => clock_test_capability_axi.clock_test_cap_rvalid,   
  clocks_cap_rready                           => clock_test_capability_axi.clock_test_cap_rready   
  );
  
u3_led_test : led_control
generic map (
  LED_NUMBER                      => 1
  )
port map (
  aclk                            => sys_clk,
  areset                          => sys_reset(6),
  awaddr                          => leds_test_axi.leds_test_awaddr,                        
  awvalid                         => leds_test_axi.leds_test_awvalid,                       
  awready                         => leds_test_axi.leds_test_awready,                       
  awprot                          => leds_test_axi.leds_test_awprot,                        
  wdata                           => leds_test_axi.leds_test_wdata,                         
  wstrb                           => leds_test_axi.leds_test_wstrb,                         
  wvalid                          => leds_test_axi.leds_test_wvalid,                        
  wready                          => leds_test_axi.leds_test_wready,                        
  bresp                           => leds_test_axi.leds_test_bresp,		                    
  bvalid                          => leds_test_axi.leds_test_bvalid,                        
  bready                          => leds_test_axi.leds_test_bready,                        
  araddr                          => leds_test_axi.leds_test_araddr,		                
  arvalid                         => leds_test_axi.leds_test_arvalid,                       
  arready                         => leds_test_axi.leds_test_arready,                       
  arprot                          => leds_test_axi.leds_test_arprot,                        
  rdata                           => leds_test_axi.leds_test_rdata,                         
  rresp                           => leds_test_axi.leds_test_rresp,                         
  rvalid                          => leds_test_axi.leds_test_rvalid,                        
  rready                          => leds_test_axi.leds_test_rready,                        
  led_r(0)                        => FPGA_LED_R_L,
  led_g(0)                        => FPGA_LED_G_L
  );

hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_awaddr(43 downto 29) <= (others => '0');
hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_awaddr(28 downto 27) <= "00";
hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_awaddr(26 downto 12) <= (others => '0');
hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_awaddr(43 downto 29) <= (others => '0');
hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_awaddr(28 downto 27) <= "01";
hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_awaddr(26 downto 12) <= (others => '0');
hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_awaddr(43 downto 29) <= (others => '0');
hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_awaddr(28 downto 27) <= "10";
hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_awaddr(26 downto 12) <= (others => '0');
hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_awaddr(43 downto 29) <= (others => '0');
hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_awaddr(28 downto 27) <= "11";
hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_awaddr(26 downto 12) <= (others => '0');						          

hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_araddr(43 downto 29) <= (others => '0');
hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_araddr(28 downto 27) <= "00";
hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_araddr(26 downto 12) <= (others => '0');
hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_araddr(43 downto 29) <= (others => '0');
hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_araddr(28 downto 27) <= "01";
hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_araddr(26 downto 12) <= (others => '0');
hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_araddr(43 downto 29) <= (others => '0');
hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_araddr(28 downto 27) <= "10";
hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_araddr(26 downto 12) <= (others => '0');
hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_araddr(43 downto 29) <= (others => '0');
hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_araddr(28 downto 27) <= "11";
hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_araddr(26 downto 12) <= (others => '0');	

hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_awaddr(43 downto 29) <= (others => '0');
hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_awaddr(28 downto 27) <= "00";
hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_awaddr(26 downto 12) <= (others => '0');
hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_awaddr(43 downto 29) <= (others => '0');
hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_awaddr(28 downto 27) <= "01";
hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_awaddr(26 downto 12) <= (others => '0');
hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_awaddr(43 downto 29) <= (others => '0');
hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_awaddr(28 downto 27) <= "10";
hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_awaddr(26 downto 12) <= (others => '0');
hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_awaddr(43 downto 29) <= (others => '0');
hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_awaddr(28 downto 27) <= "11";
hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_awaddr(26 downto 12) <= (others => '0');						          

hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_araddr(43 downto 29) <= (others => '0');
hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_araddr(28 downto 27) <= "00";
hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_araddr(26 downto 12) <= (others => '0');
hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_araddr(43 downto 29) <= (others => '0');
hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_araddr(28 downto 27) <= "01";
hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_araddr(26 downto 12) <= (others => '0');
hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_araddr(43 downto 29) <= (others => '0');
hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_araddr(28 downto 27) <= "10";
hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_araddr(26 downto 12) <= (others => '0');
hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_araddr(43 downto 29) <= (others => '0');
hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_araddr(28 downto 27) <= "11";
hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_araddr(26 downto 12) <= (others => '0');	

u4_hbm2_upper_status_noc_initiator : axi4_lite_x4_noc_initiator
port map (
  s0_axi4lite_awaddr        => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_awaddr,				   
  s0_axi4lite_awvalid       => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_awvalid,				   
  s0_axi4lite_awready       => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_awready,				   
  s0_axi4lite_wdata         => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_wdata,				   
  s0_axi4lite_wstrb         => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_wstrb,				   
  s0_axi4lite_wvalid        => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_wvalid,				   
  s0_axi4lite_wready        => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_wready,				   
  s0_axi4lite_bresp         => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_bresp,				   
  s0_axi4lite_bvalid        => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_bvalid,				   
  s0_axi4lite_bready        => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_bready,				   
  s0_axi4lite_araddr        => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_araddr,				   
  s0_axi4lite_arvalid       => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_arvalid,				   
  s0_axi4lite_arready       => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_arready,				   
  s0_axi4lite_rdata         => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_rdata,				   
  s0_axi4lite_rresp         => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_rresp,				   
  s0_axi4lite_rvalid        => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_rvalid,				   
  s0_axi4lite_rready        => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_rready,				   
  s0_axi4lite_awprot        => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_awprot,				   
  s0_axi4lite_arprot        => hbm2e_upper_ch0_ch1_status_axi.hbm2e_status_arprot,				   
  s1_axi4lite_awaddr        => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_awaddr,					   
  s1_axi4lite_awvalid       => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_awvalid,					   
  s1_axi4lite_awready       => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_awready,					   
  s1_axi4lite_wdata         => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_wdata,					   
  s1_axi4lite_wstrb         => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_wstrb,					   
  s1_axi4lite_wvalid        => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_wvalid,					   
  s1_axi4lite_wready        => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_wready,					   
  s1_axi4lite_bresp         => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_bresp,					   
  s1_axi4lite_bvalid        => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_bvalid,					   
  s1_axi4lite_bready        => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_bready,					   
  s1_axi4lite_araddr        => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_araddr,					   
  s1_axi4lite_arvalid       => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_arvalid,					   
  s1_axi4lite_arready       => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_arready,					   
  s1_axi4lite_rdata         => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_rdata,					   
  s1_axi4lite_rresp         => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_rresp,					   
  s1_axi4lite_rvalid        => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_rvalid,					   
  s1_axi4lite_rready        => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_rready,					   
  s1_axi4lite_awprot        => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_awprot,					   
  s1_axi4lite_arprot        => hbm2e_upper_ch2_ch3_status_axi.hbm2e_status_arprot,					   
  s2_axi4lite_awaddr        => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_awaddr,					   
  s2_axi4lite_awvalid       => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_awvalid,					   
  s2_axi4lite_awready       => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_awready,					   
  s2_axi4lite_wdata         => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_wdata,					   
  s2_axi4lite_wstrb         => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_wstrb,					   
  s2_axi4lite_wvalid        => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_wvalid,					   
  s2_axi4lite_wready        => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_wready,					   
  s2_axi4lite_bresp         => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_bresp,					   
  s2_axi4lite_bvalid        => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_bvalid,					   
  s2_axi4lite_bready        => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_bready,					   
  s2_axi4lite_araddr        => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_araddr,					   
  s2_axi4lite_arvalid       => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_arvalid,					   
  s2_axi4lite_arready       => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_arready,					   
  s2_axi4lite_rdata         => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_rdata,					   
  s2_axi4lite_rresp         => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_rresp,					   
  s2_axi4lite_rvalid        => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_rvalid,					   
  s2_axi4lite_rready        => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_rready,					   
  s2_axi4lite_awprot        => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_awprot,					   
  s2_axi4lite_arprot        => hbm2e_upper_ch4_ch5_status_axi.hbm2e_status_arprot,					   
  s3_axi4lite_awaddr        => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_awaddr,					   
  s3_axi4lite_awvalid       => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_awvalid,					   
  s3_axi4lite_awready       => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_awready,					   
  s3_axi4lite_wdata         => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_wdata,					   
  s3_axi4lite_wstrb         => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_wstrb,					   
  s3_axi4lite_wvalid        => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_wvalid,					   
  s3_axi4lite_wready        => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_wready,					   
  s3_axi4lite_bresp         => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_bresp,					   
  s3_axi4lite_bvalid        => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_bvalid,					   
  s3_axi4lite_bready        => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_bready,					   
  s3_axi4lite_araddr        => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_araddr,					   
  s3_axi4lite_arvalid       => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_arvalid,					   
  s3_axi4lite_arready       => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_arready,					   
  s3_axi4lite_rdata         => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_rdata,					   
  s3_axi4lite_rresp         => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_rresp,					   
  s3_axi4lite_rvalid        => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_rvalid,					   
  s3_axi4lite_rready        => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_rready,					   
  s3_axi4lite_awprot        => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_awprot,					   
  s3_axi4lite_arprot        => hbm2e_upper_ch6_ch7_status_axi.hbm2e_status_arprot,					   
  s0_axi4lite_aclk          => sys_clk,
  s0_axi4lite_aresetn       => sys_resetn(7),
  s1_axi4lite_aclk          => sys_clk,
  s1_axi4lite_aresetn       => sys_resetn(8),
  s2_axi4lite_aclk          => sys_clk,
  s2_axi4lite_aresetn       => sys_resetn(9),
  s3_axi4lite_aclk          => sys_clk,
  s3_axi4lite_aresetn       => sys_resetn(10)
  );

u5_hbm2_lower_status_noc_initiator : axi4_lite_x4_noc_initiator
port map (
  s0_axi4lite_awaddr        => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_awaddr,				   
  s0_axi4lite_awvalid       => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_awvalid,				   
  s0_axi4lite_awready       => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_awready,				   
  s0_axi4lite_wdata         => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_wdata,				   
  s0_axi4lite_wstrb         => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_wstrb,				   
  s0_axi4lite_wvalid        => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_wvalid,				   
  s0_axi4lite_wready        => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_wready,				   
  s0_axi4lite_bresp         => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_bresp,				   
  s0_axi4lite_bvalid        => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_bvalid,				   
  s0_axi4lite_bready        => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_bready,				   
  s0_axi4lite_araddr        => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_araddr,				   
  s0_axi4lite_arvalid       => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_arvalid,				   
  s0_axi4lite_arready       => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_arready,				   
  s0_axi4lite_rdata         => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_rdata,				   
  s0_axi4lite_rresp         => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_rresp,				   
  s0_axi4lite_rvalid        => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_rvalid,				   
  s0_axi4lite_rready        => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_rready,				   
  s0_axi4lite_awprot        => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_awprot,				   
  s0_axi4lite_arprot        => hbm2e_lower_ch0_ch1_status_axi.hbm2e_status_arprot,				   
  s1_axi4lite_awaddr        => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_awaddr,					   
  s1_axi4lite_awvalid       => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_awvalid,					   
  s1_axi4lite_awready       => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_awready,					   
  s1_axi4lite_wdata         => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_wdata,					   
  s1_axi4lite_wstrb         => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_wstrb,					   
  s1_axi4lite_wvalid        => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_wvalid,					   
  s1_axi4lite_wready        => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_wready,					   
  s1_axi4lite_bresp         => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_bresp,					   
  s1_axi4lite_bvalid        => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_bvalid,					   
  s1_axi4lite_bready        => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_bready,					   
  s1_axi4lite_araddr        => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_araddr,					   
  s1_axi4lite_arvalid       => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_arvalid,					   
  s1_axi4lite_arready       => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_arready,					   
  s1_axi4lite_rdata         => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_rdata,					   
  s1_axi4lite_rresp         => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_rresp,					   
  s1_axi4lite_rvalid        => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_rvalid,					   
  s1_axi4lite_rready        => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_rready,					   
  s1_axi4lite_awprot        => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_awprot,					   
  s1_axi4lite_arprot        => hbm2e_lower_ch2_ch3_status_axi.hbm2e_status_arprot,					   
  s2_axi4lite_awaddr        => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_awaddr,					   
  s2_axi4lite_awvalid       => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_awvalid,					   
  s2_axi4lite_awready       => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_awready,					   
  s2_axi4lite_wdata         => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_wdata,					   
  s2_axi4lite_wstrb         => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_wstrb,					   
  s2_axi4lite_wvalid        => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_wvalid,					   
  s2_axi4lite_wready        => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_wready,					   
  s2_axi4lite_bresp         => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_bresp,					   
  s2_axi4lite_bvalid        => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_bvalid,					   
  s2_axi4lite_bready        => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_bready,					   
  s2_axi4lite_araddr        => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_araddr,					   
  s2_axi4lite_arvalid       => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_arvalid,					   
  s2_axi4lite_arready       => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_arready,					   
  s2_axi4lite_rdata         => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_rdata,					   
  s2_axi4lite_rresp         => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_rresp,					   
  s2_axi4lite_rvalid        => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_rvalid,					   
  s2_axi4lite_rready        => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_rready,					   
  s2_axi4lite_awprot        => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_awprot,					   
  s2_axi4lite_arprot        => hbm2e_lower_ch4_ch5_status_axi.hbm2e_status_arprot,					   
  s3_axi4lite_awaddr        => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_awaddr,					   
  s3_axi4lite_awvalid       => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_awvalid,					   
  s3_axi4lite_awready       => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_awready,					   
  s3_axi4lite_wdata         => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_wdata,					   
  s3_axi4lite_wstrb         => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_wstrb,					   
  s3_axi4lite_wvalid        => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_wvalid,					   
  s3_axi4lite_wready        => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_wready,					   
  s3_axi4lite_bresp         => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_bresp,					   
  s3_axi4lite_bvalid        => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_bvalid,					   
  s3_axi4lite_bready        => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_bready,					   
  s3_axi4lite_araddr        => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_araddr,					   
  s3_axi4lite_arvalid       => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_arvalid,					   
  s3_axi4lite_arready       => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_arready,					   
  s3_axi4lite_rdata         => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_rdata,					   
  s3_axi4lite_rresp         => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_rresp,					   
  s3_axi4lite_rvalid        => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_rvalid,					   
  s3_axi4lite_rready        => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_rready,					   
  s3_axi4lite_awprot        => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_awprot,					   
  s3_axi4lite_arprot        => hbm2e_lower_ch6_ch7_status_axi.hbm2e_status_arprot,					   
  s0_axi4lite_aclk          => sys_clk,
  s0_axi4lite_aresetn       => sys_resetn(11),
  s1_axi4lite_aclk          => sys_clk,
  s1_axi4lite_aresetn       => sys_resetn(12),
  s2_axi4lite_aclk          => sys_clk,
  s2_axi4lite_aresetn       => sys_resetn(13),
  s3_axi4lite_aclk          => sys_clk,
  s3_axi4lite_aresetn       => sys_resetn(14)
  );

u6_hbm2_upper_test : hbm2e_upper_test
generic map (
  TEST_CTRL_CLK_PERIOD     => 20
  )
port map (
  sys_clk                  => sys_clk, 
  sys_reset                => sys_reset(15), 
  hbm2e_refclk             => HBM_REFCLK1, 
  hbm2e_cattrip_in         => HBM_CATRIP1,
  hbm2e_temp_in            => HBM_TEMP1,
  initiator_clk            => hbm_initiator_clk1,
  mem_usr_clk              => hbm_tst_clk1, 
  mem_usr_reset            => hbmu_user_reset_d4, 
  test_ctrl0_0_awaddr      => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_awaddr,  			
  test_ctrl0_0_awvalid     => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_awvalid, 			
  test_ctrl0_0_awready     => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_awready, 			
  test_ctrl0_0_awprot      => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_awprot,  			
  test_ctrl0_0_wdata       => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_wdata,   			
  test_ctrl0_0_wstrb       => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_wstrb,   			
  test_ctrl0_0_wvalid      => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_wvalid,  			
  test_ctrl0_0_wready      => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_wready,  			
  test_ctrl0_0_bresp       => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_bresp,   				
  test_ctrl0_0_bvalid      => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_bvalid,  				
  test_ctrl0_0_bready      => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_bready,  				
  test_ctrl0_0_araddr      => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_araddr,  				
  test_ctrl0_0_arvalid     => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_arvalid, 			
  test_ctrl0_0_arready     => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_arready, 			
  test_ctrl0_0_arprot      => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_arprot,  			
  test_ctrl0_0_rdata       => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_rdata,   			
  test_ctrl0_0_rresp       => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_rresp,   			
  test_ctrl0_0_rvalid      => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_rvalid,  			
  test_ctrl0_0_rready      => hbm2e_upper_test_ch0_u0_axi.hbm2e_test_ctrl_rready, 			
  error_log0_0_awaddr      => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_awaddr, 
  error_log0_0_awvalid     => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_awvalid,
  error_log0_0_awready     => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_awready,
  error_log0_0_awprot      => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_awprot, 
  error_log0_0_wdata       => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_wdata,  
  error_log0_0_wstrb       => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_wstrb,  
  error_log0_0_wvalid      => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_wvalid,
  error_log0_0_wready      => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_wready,
  error_log0_0_bresp       => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_bresp,			
  error_log0_0_bvalid      => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_bvalid,			
  error_log0_0_bready      => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_bready,		
  error_log0_0_araddr      => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_araddr, 						
  error_log0_0_arvalid     => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_arvalid,	
  error_log0_0_arready     => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_arready,		
  error_log0_0_arprot      => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_arprot, 
  error_log0_0_rdata       => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_rdata,	
  error_log0_0_rresp       => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_rresp,	
  error_log0_0_rvalid      => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_rvalid,	
  error_log0_0_rready      => hbm2e_upper_error_log_ch0_u0_axi.hbm2e_error_log_rready, 
  test_ctrl0_1_awaddr      => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_awaddr, 
  test_ctrl0_1_awvalid     => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_awvalid,
  test_ctrl0_1_awready     => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_awready,
  test_ctrl0_1_awprot      => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_awprot, 
  test_ctrl0_1_wdata       => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_wdata,  
  test_ctrl0_1_wstrb       => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_wstrb,  
  test_ctrl0_1_wvalid      => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_wvalid, 
  test_ctrl0_1_wready      => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_wready, 
  test_ctrl0_1_bresp       => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_bresp,  			
  test_ctrl0_1_bvalid      => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_bvalid, 			
  test_ctrl0_1_bready      => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_bready, 			
  test_ctrl0_1_araddr      => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_araddr, 			
  test_ctrl0_1_arvalid     => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_arvalid,		
  test_ctrl0_1_arready     => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_arready,		
  test_ctrl0_1_arprot      => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_arprot, 
  test_ctrl0_1_rdata       => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_rdata,  	
  test_ctrl0_1_rresp       => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_rresp,  	
  test_ctrl0_1_rvalid      => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_rvalid, 	
  test_ctrl0_1_rready      => hbm2e_upper_test_ch0_u1_axi.hbm2e_test_ctrl_rready, 
  error_log0_1_awaddr      => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_awaddr,  
  error_log0_1_awvalid     => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_awvalid,
  error_log0_1_awready     => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_awready,
  error_log0_1_awprot      => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_awprot,  
  error_log0_1_wdata       => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_wdata,   
  error_log0_1_wstrb       => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_wstrb,   
  error_log0_1_wvalid      => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_wvalid,
  error_log0_1_wready      => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_wready,
  error_log0_1_bresp       => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_bresp,					
  error_log0_1_bvalid      => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_bvalid,					
  error_log0_1_bready      => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_bready,				
  error_log0_1_araddr      => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_araddr, 		 					
  error_log0_1_arvalid     => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_arvalid,			
  error_log0_1_arready     => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_arready,				
  error_log0_1_arprot      => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_arprot,  
  error_log0_1_rdata       => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_rdata,			
  error_log0_1_rresp       => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_rresp,			
  error_log0_1_rvalid      => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_rvalid,			
  error_log0_1_rready      => hbm2e_upper_error_log_ch0_u1_axi.hbm2e_error_log_rready, 
  test_ctrl1_0_awaddr      => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_awaddr,  	
  test_ctrl1_0_awvalid     => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_awvalid, 	
  test_ctrl1_0_awready     => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_awready, 	
  test_ctrl1_0_awprot      => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_awprot,  	
  test_ctrl1_0_wdata       => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_wdata,   	
  test_ctrl1_0_wstrb       => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_wstrb,   	
  test_ctrl1_0_wvalid      => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_wvalid,  	
  test_ctrl1_0_wready      => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_wready,  	
  test_ctrl1_0_bresp       => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_bresp,   				
  test_ctrl1_0_bvalid      => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_bvalid,  				
  test_ctrl1_0_bready      => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_bready,  				
  test_ctrl1_0_araddr      => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_araddr,  				
  test_ctrl1_0_arvalid     => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_arvalid, 			
  test_ctrl1_0_arready     => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_arready, 			
  test_ctrl1_0_arprot      => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_arprot,  	
  test_ctrl1_0_rdata       => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_rdata,   		
  test_ctrl1_0_rresp       => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_rresp,   		
  test_ctrl1_0_rvalid      => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_rvalid,  		
  test_ctrl1_0_rready      => hbm2e_upper_test_ch1_u0_axi.hbm2e_test_ctrl_rready, 	
  error_log1_0_awaddr      => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_awaddr,  
  error_log1_0_awvalid     => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_awvalid,
  error_log1_0_awready     => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_awready,
  error_log1_0_awprot      => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_awprot,  
  error_log1_0_wdata       => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_wdata,   
  error_log1_0_wstrb       => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_wstrb,   
  error_log1_0_wvalid      => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_wvalid,
  error_log1_0_wready      => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_wready,
  error_log1_0_bresp       => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_bresp,						
  error_log1_0_bvalid      => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_bvalid,						
  error_log1_0_bready      => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_bready,					
  error_log1_0_araddr      => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_araddr, 	 								
  error_log1_0_arvalid     => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_arvalid,			
  error_log1_0_arready     => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_arready,				
  error_log1_0_arprot      => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_arprot,  
  error_log1_0_rdata       => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_rdata,		
  error_log1_0_rresp       => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_rresp,		
  error_log1_0_rvalid      => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_rvalid,		
  error_log1_0_rready      => hbm2e_upper_error_log_ch1_u0_axi.hbm2e_error_log_rready, 
  test_ctrl1_1_awaddr      => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_awaddr, 
  test_ctrl1_1_awvalid     => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_awvalid,
  test_ctrl1_1_awready     => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_awready,
  test_ctrl1_1_awprot      => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_awprot, 
  test_ctrl1_1_wdata       => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_wdata,  
  test_ctrl1_1_wstrb       => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_wstrb,  
  test_ctrl1_1_wvalid      => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_wvalid, 
  test_ctrl1_1_wready      => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_wready, 
  test_ctrl1_1_bresp       => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_bresp,  				
  test_ctrl1_1_bvalid      => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_bvalid, 				
  test_ctrl1_1_bready      => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_bready, 				
  test_ctrl1_1_araddr      => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_araddr, 				
  test_ctrl1_1_arvalid     => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_arvalid,			
  test_ctrl1_1_arready     => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_arready,			
  test_ctrl1_1_arprot      => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_arprot, 
  test_ctrl1_1_rdata       => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_rdata,  		
  test_ctrl1_1_rresp       => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_rresp,  		
  test_ctrl1_1_rvalid      => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_rvalid, 		
  test_ctrl1_1_rready      => hbm2e_upper_test_ch1_u1_axi.hbm2e_test_ctrl_rready, 
  error_log1_1_awaddr      => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_awaddr, 
  error_log1_1_awvalid     => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_awvalid,
  error_log1_1_awready     => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_awready,
  error_log1_1_awprot      => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_awprot, 
  error_log1_1_wdata       => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_wdata,  
  error_log1_1_wstrb       => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_wstrb,  
  error_log1_1_wvalid      => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_wvalid,
  error_log1_1_wready      => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_wready,
  error_log1_1_bresp       => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_bresp,								
  error_log1_1_bvalid      => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_bvalid,								
  error_log1_1_bready      => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_bready,							
  error_log1_1_araddr      => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_araddr, 									
  error_log1_1_arvalid     => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_arvalid,					
  error_log1_1_arready     => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_arready,						
  error_log1_1_arprot      => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_arprot, 
  error_log1_1_rdata       => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_rdata,				
  error_log1_1_rresp       => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_rresp,				
  error_log1_1_rvalid      => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_rvalid,				
  error_log1_1_rready      => hbm2e_upper_error_log_ch1_u1_axi.hbm2e_error_log_rready, 
  test_ctrl2_0_awaddr      => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_awaddr,  			
  test_ctrl2_0_awvalid     => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_awvalid, 			
  test_ctrl2_0_awready     => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_awready, 			
  test_ctrl2_0_awprot      => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_awprot,  			
  test_ctrl2_0_wdata       => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_wdata,   			
  test_ctrl2_0_wstrb       => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_wstrb,   			
  test_ctrl2_0_wvalid      => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_wvalid,  			
  test_ctrl2_0_wready      => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_wready,  			
  test_ctrl2_0_bresp       => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_bresp,   			
  test_ctrl2_0_bvalid      => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_bvalid,  			
  test_ctrl2_0_bready      => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_bready,  			
  test_ctrl2_0_araddr      => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_araddr,  			
  test_ctrl2_0_arvalid     => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_arvalid, 			
  test_ctrl2_0_arready     => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_arready, 			
  test_ctrl2_0_arprot      => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_arprot,  			
  test_ctrl2_0_rdata       => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_rdata,   			
  test_ctrl2_0_rresp       => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_rresp,   			
  test_ctrl2_0_rvalid      => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_rvalid,  			
  test_ctrl2_0_rready      => hbm2e_upper_test_ch2_u0_axi.hbm2e_test_ctrl_rready, 			
  error_log2_0_awaddr      => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_awaddr, 
  error_log2_0_awvalid     => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_awvalid,
  error_log2_0_awready     => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_awready,
  error_log2_0_awprot      => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_awprot, 
  error_log2_0_wdata       => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_wdata,  
  error_log2_0_wstrb       => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_wstrb,  
  error_log2_0_wvalid      => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_wvalid,
  error_log2_0_wready      => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_wready,
  error_log2_0_bresp       => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_bresp,			
  error_log2_0_bvalid      => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_bvalid,			
  error_log2_0_bready      => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_bready,		
  error_log2_0_araddr      => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_araddr, 					
  error_log2_0_arvalid     => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_arvalid,	
  error_log2_0_arready     => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_arready,		
  error_log2_0_arprot      => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_arprot, 
  error_log2_0_rdata       => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_rdata,	
  error_log2_0_rresp       => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_rresp,	
  error_log2_0_rvalid      => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_rvalid,	
  error_log2_0_rready      => hbm2e_upper_error_log_ch2_u0_axi.hbm2e_error_log_rready, 
  test_ctrl2_1_awaddr      => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_awaddr, 
  test_ctrl2_1_awvalid     => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_awvalid,
  test_ctrl2_1_awready     => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_awready,
  test_ctrl2_1_awprot      => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_awprot, 
  test_ctrl2_1_wdata       => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_wdata,  
  test_ctrl2_1_wstrb       => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_wstrb,  
  test_ctrl2_1_wvalid      => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_wvalid, 
  test_ctrl2_1_wready      => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_wready, 
  test_ctrl2_1_bresp       => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_bresp,  			
  test_ctrl2_1_bvalid      => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_bvalid, 			
  test_ctrl2_1_bready      => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_bready, 			
  test_ctrl2_1_araddr      => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_araddr, 			
  test_ctrl2_1_arvalid     => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_arvalid,		
  test_ctrl2_1_arready     => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_arready,		
  test_ctrl2_1_arprot      => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_arprot, 
  test_ctrl2_1_rdata       => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_rdata,  	
  test_ctrl2_1_rresp       => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_rresp,  	
  test_ctrl2_1_rvalid      => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_rvalid, 	
  test_ctrl2_1_rready      => hbm2e_upper_test_ch2_u1_axi.hbm2e_test_ctrl_rready, 
  error_log2_1_awaddr      => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_awaddr,  
  error_log2_1_awvalid     => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_awvalid,
  error_log2_1_awready     => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_awready,
  error_log2_1_awprot      => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_awprot,  
  error_log2_1_wdata       => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_wdata,   
  error_log2_1_wstrb       => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_wstrb,   
  error_log2_1_wvalid      => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_wvalid,
  error_log2_1_wready      => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_wready,
  error_log2_1_bresp       => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_bresp,					
  error_log2_1_bvalid      => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_bvalid,					
  error_log2_1_bready      => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_bready,				
  error_log2_1_araddr      => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_araddr, 		 					
  error_log2_1_arvalid     => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_arvalid,			
  error_log2_1_arready     => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_arready,				
  error_log2_1_arprot      => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_arprot,  
  error_log2_1_rdata       => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_rdata,			
  error_log2_1_rresp       => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_rresp,			
  error_log2_1_rvalid      => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_rvalid,			
  error_log2_1_rready      => hbm2e_upper_error_log_ch2_u1_axi.hbm2e_error_log_rready, 
  test_ctrl3_0_awaddr      => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_awaddr,  	
  test_ctrl3_0_awvalid     => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_awvalid, 	
  test_ctrl3_0_awready     => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_awready, 	
  test_ctrl3_0_awprot      => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_awprot,  	
  test_ctrl3_0_wdata       => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_wdata,   	
  test_ctrl3_0_wstrb       => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_wstrb,   	
  test_ctrl3_0_wvalid      => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_wvalid,  	
  test_ctrl3_0_wready      => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_wready,  	
  test_ctrl3_0_bresp       => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_bresp,   			
  test_ctrl3_0_bvalid      => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_bvalid,  			
  test_ctrl3_0_bready      => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_bready,  			
  test_ctrl3_0_araddr      => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_araddr,  			
  test_ctrl3_0_arvalid     => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_arvalid, 			
  test_ctrl3_0_arready     => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_arready, 			
  test_ctrl3_0_arprot      => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_arprot,  	
  test_ctrl3_0_rdata       => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_rdata,   		
  test_ctrl3_0_rresp       => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_rresp,   		
  test_ctrl3_0_rvalid      => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_rvalid,  		
  test_ctrl3_0_rready      => hbm2e_upper_test_ch3_u0_axi.hbm2e_test_ctrl_rready, 	
  error_log3_0_awaddr      => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_awaddr, 
  error_log3_0_awvalid     => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_awvalid,
  error_log3_0_awready     => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_awready,
  error_log3_0_awprot      => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_awprot, 
  error_log3_0_wdata       => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_wdata,  
  error_log3_0_wstrb       => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_wstrb,  
  error_log3_0_wvalid      => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_wvalid,
  error_log3_0_wready      => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_wready,
  error_log3_0_bresp       => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_bresp,						
  error_log3_0_bvalid      => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_bvalid,						
  error_log3_0_bready      => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_bready,					
  error_log3_0_araddr      => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_araddr, 								
  error_log3_0_arvalid     => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_arvalid,			
  error_log3_0_arready     => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_arready,				
  error_log3_0_arprot      => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_arprot, 
  error_log3_0_rdata       => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_rdata,		
  error_log3_0_rresp       => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_rresp,		
  error_log3_0_rvalid      => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_rvalid,		
  error_log3_0_rready      => hbm2e_upper_error_log_ch3_u0_axi.hbm2e_error_log_rready, 
  test_ctrl3_1_awaddr      => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_awaddr, 
  test_ctrl3_1_awvalid     => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_awvalid,
  test_ctrl3_1_awready     => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_awready,
  test_ctrl3_1_awprot      => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_awprot, 
  test_ctrl3_1_wdata       => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_wdata,  
  test_ctrl3_1_wstrb       => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_wstrb,  
  test_ctrl3_1_wvalid      => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_wvalid, 
  test_ctrl3_1_wready      => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_wready, 
  test_ctrl3_1_bresp       => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_bresp,  			
  test_ctrl3_1_bvalid      => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_bvalid, 			
  test_ctrl3_1_bready      => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_bready, 			
  test_ctrl3_1_araddr      => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_araddr, 			
  test_ctrl3_1_arvalid     => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_arvalid,			
  test_ctrl3_1_arready     => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_arready,			
  test_ctrl3_1_arprot      => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_arprot, 
  test_ctrl3_1_rdata       => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_rdata,  		
  test_ctrl3_1_rresp       => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_rresp,  		
  test_ctrl3_1_rvalid      => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_rvalid, 		
  test_ctrl3_1_rready      => hbm2e_upper_test_ch3_u1_axi.hbm2e_test_ctrl_rready, 
  error_log3_1_awaddr      => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_awaddr,  
  error_log3_1_awvalid     => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_awvalid,
  error_log3_1_awready     => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_awready,
  error_log3_1_awprot      => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_awprot,  
  error_log3_1_wdata       => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_wdata,   
  error_log3_1_wstrb       => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_wstrb,   
  error_log3_1_wvalid      => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_wvalid,
  error_log3_1_wready      => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_wready,
  error_log3_1_bresp       => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_bresp,							
  error_log3_1_bvalid      => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_bvalid,							
  error_log3_1_bready      => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_bready,						
  error_log3_1_araddr      => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_araddr, 		 							
  error_log3_1_arvalid     => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_arvalid,					
  error_log3_1_arready     => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_arready,						
  error_log3_1_arprot      => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_arprot,  
  error_log3_1_rdata       => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_rdata,				
  error_log3_1_rresp       => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_rresp,				
  error_log3_1_rvalid      => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_rvalid,				
  error_log3_1_rready      => hbm2e_upper_error_log_ch3_u1_axi.hbm2e_error_log_rready, 
  test_ctrl4_0_awaddr      => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_awaddr,  		
  test_ctrl4_0_awvalid     => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_awvalid, 		
  test_ctrl4_0_awready     => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_awready, 		
  test_ctrl4_0_awprot      => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_awprot,  		
  test_ctrl4_0_wdata       => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_wdata,   		
  test_ctrl4_0_wstrb       => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_wstrb,   		
  test_ctrl4_0_wvalid      => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_wvalid,  		
  test_ctrl4_0_wready      => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_wready,  		
  test_ctrl4_0_bresp       => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_bresp,   			
  test_ctrl4_0_bvalid      => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_bvalid,  			
  test_ctrl4_0_bready      => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_bready,  			
  test_ctrl4_0_araddr      => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_araddr,  			
  test_ctrl4_0_arvalid     => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_arvalid, 		
  test_ctrl4_0_arready     => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_arready, 		
  test_ctrl4_0_arprot      => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_arprot,  		
  test_ctrl4_0_rdata       => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_rdata,   		
  test_ctrl4_0_rresp       => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_rresp,   		
  test_ctrl4_0_rvalid      => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_rvalid,  		
  test_ctrl4_0_rready      => hbm2e_upper_test_ch4_u0_axi.hbm2e_test_ctrl_rready, 		
  error_log4_0_awaddr      => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_awaddr, 
  error_log4_0_awvalid     => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_awvalid,
  error_log4_0_awready     => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_awready,
  error_log4_0_awprot      => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_awprot, 
  error_log4_0_wdata       => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_wdata,  
  error_log4_0_wstrb       => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_wstrb,  
  error_log4_0_wvalid      => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_wvalid,
  error_log4_0_wready      => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_wready,
  error_log4_0_bresp       => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_bresp,			
  error_log4_0_bvalid      => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_bvalid,			
  error_log4_0_bready      => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_bready,		
  error_log4_0_araddr      => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_araddr, 					
  error_log4_0_arvalid     => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_arvalid,	
  error_log4_0_arready     => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_arready,	
  error_log4_0_arprot      => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_arprot, 
  error_log4_0_rdata       => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_rdata,	
  error_log4_0_rresp       => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_rresp,	
  error_log4_0_rvalid      => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_rvalid,	
  error_log4_0_rready      => hbm2e_upper_error_log_ch4_u0_axi.hbm2e_error_log_rready, 
  test_ctrl4_1_awaddr      => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_awaddr, 
  test_ctrl4_1_awvalid     => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_awvalid,
  test_ctrl4_1_awready     => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_awready,
  test_ctrl4_1_awprot      => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_awprot, 
  test_ctrl4_1_wdata       => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_wdata,  
  test_ctrl4_1_wstrb       => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_wstrb,  
  test_ctrl4_1_wvalid      => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_wvalid, 
  test_ctrl4_1_wready      => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_wready, 
  test_ctrl4_1_bresp       => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_bresp,  			
  test_ctrl4_1_bvalid      => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_bvalid, 			
  test_ctrl4_1_bready      => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_bready, 			
  test_ctrl4_1_araddr      => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_araddr, 			
  test_ctrl4_1_arvalid     => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_arvalid,		
  test_ctrl4_1_arready     => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_arready,		
  test_ctrl4_1_arprot      => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_arprot, 
  test_ctrl4_1_rdata       => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_rdata,  	
  test_ctrl4_1_rresp       => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_rresp,  	
  test_ctrl4_1_rvalid      => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_rvalid, 	
  test_ctrl4_1_rready      => hbm2e_upper_test_ch4_u1_axi.hbm2e_test_ctrl_rready, 
  error_log4_1_awaddr      => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_awaddr, 
  error_log4_1_awvalid     => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_awvalid,
  error_log4_1_awready     => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_awready,
  error_log4_1_awprot      => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_awprot, 
  error_log4_1_wdata       => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_wdata,  
  error_log4_1_wstrb       => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_wstrb,  
  error_log4_1_wvalid      => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_wvalid,
  error_log4_1_wready      => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_wready,
  error_log4_1_bresp       => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_bresp,						
  error_log4_1_bvalid      => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_bvalid,						
  error_log4_1_bready      => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_bready,					
  error_log4_1_araddr      => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_araddr, 							
  error_log4_1_arvalid     => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_arvalid,			
  error_log4_1_arready     => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_arready,				
  error_log4_1_arprot      => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_arprot, 
  error_log4_1_rdata       => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_rdata,			
  error_log4_1_rresp       => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_rresp,			
  error_log4_1_rvalid      => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_rvalid,			
  error_log4_1_rready      => hbm2e_upper_error_log_ch4_u1_axi.hbm2e_error_log_rready, 
  test_ctrl5_0_awaddr      => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_awaddr,  	
  test_ctrl5_0_awvalid     => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_awvalid, 	
  test_ctrl5_0_awready     => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_awready, 	
  test_ctrl5_0_awprot      => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_awprot,  	
  test_ctrl5_0_wdata       => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_wdata,   	
  test_ctrl5_0_wstrb       => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_wstrb,   	
  test_ctrl5_0_wvalid      => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_wvalid,  	
  test_ctrl5_0_wready      => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_wready,  	
  test_ctrl5_0_bresp       => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_bresp,   			
  test_ctrl5_0_bvalid      => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_bvalid,  			
  test_ctrl5_0_bready      => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_bready,  			
  test_ctrl5_0_araddr      => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_araddr,  			
  test_ctrl5_0_arvalid     => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_arvalid, 		
  test_ctrl5_0_arready     => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_arready, 		
  test_ctrl5_0_arprot      => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_arprot,  	
  test_ctrl5_0_rdata       => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_rdata,   		
  test_ctrl5_0_rresp       => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_rresp,   		
  test_ctrl5_0_rvalid      => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_rvalid,  		
  test_ctrl5_0_rready      => hbm2e_upper_test_ch5_u0_axi.hbm2e_test_ctrl_rready, 	
  error_log5_0_awaddr      => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_awaddr, 
  error_log5_0_awvalid     => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_awvalid,
  error_log5_0_awready     => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_awready,
  error_log5_0_awprot      => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_awprot, 
  error_log5_0_wdata       => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_wdata,  
  error_log5_0_wstrb       => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_wstrb,  
  error_log5_0_wvalid      => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_wvalid,
  error_log5_0_wready      => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_wready,
  error_log5_0_bresp       => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_bresp,						
  error_log5_0_bvalid      => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_bvalid,						
  error_log5_0_bready      => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_bready,					
  error_log5_0_araddr      => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_araddr, 							
  error_log5_0_arvalid     => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_arvalid,		
  error_log5_0_arready     => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_arready,			
  error_log5_0_arprot      => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_arprot, 
  error_log5_0_rdata       => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_rdata,	
  error_log5_0_rresp       => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_rresp,	
  error_log5_0_rvalid      => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_rvalid,	
  error_log5_0_rready      => hbm2e_upper_error_log_ch5_u0_axi.hbm2e_error_log_rready, 
  test_ctrl5_1_awaddr      => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_awaddr, 
  test_ctrl5_1_awvalid     => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_awvalid,
  test_ctrl5_1_awready     => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_awready,
  test_ctrl5_1_awprot      => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_awprot, 
  test_ctrl5_1_wdata       => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_wdata,  
  test_ctrl5_1_wstrb       => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_wstrb,  
  test_ctrl5_1_wvalid      => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_wvalid, 
  test_ctrl5_1_wready      => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_wready, 
  test_ctrl5_1_bresp       => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_bresp,  			
  test_ctrl5_1_bvalid      => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_bvalid, 			
  test_ctrl5_1_bready      => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_bready, 			
  test_ctrl5_1_araddr      => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_araddr, 			
  test_ctrl5_1_arvalid     => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_arvalid,		
  test_ctrl5_1_arready     => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_arready,		
  test_ctrl5_1_arprot      => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_arprot, 
  test_ctrl5_1_rdata       => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_rdata,  		
  test_ctrl5_1_rresp       => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_rresp,  		
  test_ctrl5_1_rvalid      => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_rvalid, 		
  test_ctrl5_1_rready      => hbm2e_upper_test_ch5_u1_axi.hbm2e_test_ctrl_rready, 
  error_log5_1_awaddr      => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_awaddr, 
  error_log5_1_awvalid     => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_awvalid,
  error_log5_1_awready     => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_awready,
  error_log5_1_awprot      => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_awprot, 
  error_log5_1_wdata       => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_wdata,  
  error_log5_1_wstrb       => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_wstrb,  
  error_log5_1_wvalid      => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_wvalid,
  error_log5_1_wready      => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_wready,
  error_log5_1_bresp       => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_bresp,							
  error_log5_1_bvalid      => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_bvalid,							
  error_log5_1_bready      => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_bready,						
  error_log5_1_araddr      => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_araddr, 								
  error_log5_1_arvalid     => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_arvalid,					
  error_log5_1_arready     => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_arready,						
  error_log5_1_arprot      => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_arprot, 
  error_log5_1_rdata       => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_rdata,				
  error_log5_1_rresp       => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_rresp,				
  error_log5_1_rvalid      => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_rvalid,				
  error_log5_1_rready      => hbm2e_upper_error_log_ch5_u1_axi.hbm2e_error_log_rready, 
  test_ctrl6_0_awaddr      => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_awaddr,  		
  test_ctrl6_0_awvalid     => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_awvalid, 		
  test_ctrl6_0_awready     => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_awready, 		
  test_ctrl6_0_awprot      => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_awprot,  		
  test_ctrl6_0_wdata       => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_wdata,   		
  test_ctrl6_0_wstrb       => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_wstrb,   		
  test_ctrl6_0_wvalid      => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_wvalid,  		
  test_ctrl6_0_wready      => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_wready,  		
  test_ctrl6_0_bresp       => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_bresp,   			
  test_ctrl6_0_bvalid      => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_bvalid,  			
  test_ctrl6_0_bready      => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_bready,  			
  test_ctrl6_0_araddr      => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_araddr,  			
  test_ctrl6_0_arvalid     => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_arvalid, 		
  test_ctrl6_0_arready     => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_arready, 		
  test_ctrl6_0_arprot      => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_arprot,  		
  test_ctrl6_0_rdata       => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_rdata,   		
  test_ctrl6_0_rresp       => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_rresp,   		
  test_ctrl6_0_rvalid      => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_rvalid,  		
  test_ctrl6_0_rready      => hbm2e_upper_test_ch6_u0_axi.hbm2e_test_ctrl_rready, 		
  error_log6_0_awaddr      => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_awaddr, 
  error_log6_0_awvalid     => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_awvalid,
  error_log6_0_awready     => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_awready,
  error_log6_0_awprot      => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_awprot, 
  error_log6_0_wdata       => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_wdata,  
  error_log6_0_wstrb       => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_wstrb,  
  error_log6_0_wvalid      => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_wvalid,
  error_log6_0_wready      => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_wready,
  error_log6_0_bresp       => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_bresp,			
  error_log6_0_bvalid      => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_bvalid,			
  error_log6_0_bready      => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_bready,		
  error_log6_0_araddr      => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_araddr, 					
  error_log6_0_arvalid     => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_arvalid,	
  error_log6_0_arready     => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_arready,	
  error_log6_0_arprot      => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_arprot, 
  error_log6_0_rdata       => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_rdata,	
  error_log6_0_rresp       => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_rresp,	
  error_log6_0_rvalid      => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_rvalid,	
  error_log6_0_rready      => hbm2e_upper_error_log_ch6_u0_axi.hbm2e_error_log_rready, 
  test_ctrl6_1_awaddr      => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_awaddr, 
  test_ctrl6_1_awvalid     => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_awvalid,
  test_ctrl6_1_awready     => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_awready,
  test_ctrl6_1_awprot      => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_awprot, 
  test_ctrl6_1_wdata       => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_wdata,  
  test_ctrl6_1_wstrb       => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_wstrb,  
  test_ctrl6_1_wvalid      => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_wvalid, 
  test_ctrl6_1_wready      => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_wready, 
  test_ctrl6_1_bresp       => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_bresp,  			
  test_ctrl6_1_bvalid      => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_bvalid, 			
  test_ctrl6_1_bready      => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_bready, 			
  test_ctrl6_1_araddr      => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_araddr, 			
  test_ctrl6_1_arvalid     => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_arvalid,		
  test_ctrl6_1_arready     => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_arready,		
  test_ctrl6_1_arprot      => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_arprot, 
  test_ctrl6_1_rdata       => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_rdata,  	
  test_ctrl6_1_rresp       => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_rresp,  	
  test_ctrl6_1_rvalid      => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_rvalid, 	
  test_ctrl6_1_rready      => hbm2e_upper_test_ch6_u1_axi.hbm2e_test_ctrl_rready, 
  error_log6_1_awaddr      => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_awaddr, 
  error_log6_1_awvalid     => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_awvalid,
  error_log6_1_awready     => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_awready,
  error_log6_1_awprot      => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_awprot, 
  error_log6_1_wdata       => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_wdata,  
  error_log6_1_wstrb       => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_wstrb,  
  error_log6_1_wvalid      => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_wvalid,
  error_log6_1_wready      => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_wready,
  error_log6_1_bresp       => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_bresp,						
  error_log6_1_bvalid      => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_bvalid,						
  error_log6_1_bready      => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_bready,					
  error_log6_1_araddr      => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_araddr, 							
  error_log6_1_arvalid     => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_arvalid,			
  error_log6_1_arready     => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_arready,				
  error_log6_1_arprot      => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_arprot, 
  error_log6_1_rdata       => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_rdata,			
  error_log6_1_rresp       => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_rresp,			
  error_log6_1_rvalid      => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_rvalid,			
  error_log6_1_rready      => hbm2e_upper_error_log_ch6_u1_axi.hbm2e_error_log_rready, 
  test_ctrl7_0_awaddr      => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_awaddr,  	
  test_ctrl7_0_awvalid     => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_awvalid, 	
  test_ctrl7_0_awready     => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_awready, 	
  test_ctrl7_0_awprot      => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_awprot,  	
  test_ctrl7_0_wdata       => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_wdata,   	
  test_ctrl7_0_wstrb       => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_wstrb,   	
  test_ctrl7_0_wvalid      => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_wvalid,  	
  test_ctrl7_0_wready      => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_wready,  	
  test_ctrl7_0_bresp       => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_bresp,   			
  test_ctrl7_0_bvalid      => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_bvalid,  			
  test_ctrl7_0_bready      => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_bready,  			
  test_ctrl7_0_araddr      => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_araddr,  			
  test_ctrl7_0_arvalid     => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_arvalid, 		
  test_ctrl7_0_arready     => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_arready, 		
  test_ctrl7_0_arprot      => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_arprot,  	
  test_ctrl7_0_rdata       => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_rdata,   		
  test_ctrl7_0_rresp       => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_rresp,   		
  test_ctrl7_0_rvalid      => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_rvalid,  		
  test_ctrl7_0_rready      => hbm2e_upper_test_ch7_u0_axi.hbm2e_test_ctrl_rready, 	
  error_log7_0_awaddr      => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_awaddr, 
  error_log7_0_awvalid     => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_awvalid,
  error_log7_0_awready     => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_awready,
  error_log7_0_awprot      => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_awprot, 
  error_log7_0_wdata       => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_wdata,  
  error_log7_0_wstrb       => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_wstrb,  
  error_log7_0_wvalid      => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_wvalid,
  error_log7_0_wready      => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_wready,
  error_log7_0_bresp       => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_bresp,						
  error_log7_0_bvalid      => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_bvalid,						
  error_log7_0_bready      => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_bready,					
  error_log7_0_araddr      => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_araddr, 							
  error_log7_0_arvalid     => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_arvalid,		
  error_log7_0_arready     => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_arready,			
  error_log7_0_arprot      => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_arprot, 
  error_log7_0_rdata       => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_rdata,	
  error_log7_0_rresp       => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_rresp,	
  error_log7_0_rvalid      => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_rvalid,	
  error_log7_0_rready      => hbm2e_upper_error_log_ch7_u0_axi.hbm2e_error_log_rready, 
  test_ctrl7_1_awaddr      => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_awaddr, 
  test_ctrl7_1_awvalid     => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_awvalid,
  test_ctrl7_1_awready     => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_awready,
  test_ctrl7_1_awprot      => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_awprot, 
  test_ctrl7_1_wdata       => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_wdata,  
  test_ctrl7_1_wstrb       => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_wstrb,  
  test_ctrl7_1_wvalid      => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_wvalid, 
  test_ctrl7_1_wready      => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_wready, 
  test_ctrl7_1_bresp       => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_bresp,  			
  test_ctrl7_1_bvalid      => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_bvalid, 			
  test_ctrl7_1_bready      => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_bready, 			
  test_ctrl7_1_araddr      => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_araddr, 			
  test_ctrl7_1_arvalid     => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_arvalid,		
  test_ctrl7_1_arready     => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_arready,		
  test_ctrl7_1_arprot      => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_arprot, 
  test_ctrl7_1_rdata       => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_rdata,  		
  test_ctrl7_1_rresp       => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_rresp,  		
  test_ctrl7_1_rvalid      => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_rvalid, 		
  test_ctrl7_1_rready      => hbm2e_upper_test_ch7_u1_axi.hbm2e_test_ctrl_rready, 
  error_log7_1_awaddr      => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_awaddr, 
  error_log7_1_awvalid     => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_awvalid,
  error_log7_1_awready     => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_awready,
  error_log7_1_awprot      => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_awprot, 
  error_log7_1_wdata       => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_wdata,  
  error_log7_1_wstrb       => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_wstrb,  
  error_log7_1_wvalid      => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_wvalid,
  error_log7_1_wready      => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_wready,
  error_log7_1_bresp       => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_bresp,						
  error_log7_1_bvalid      => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_bvalid,						
  error_log7_1_bready      => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_bready,					
  error_log7_1_araddr      => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_araddr, 							
  error_log7_1_arvalid     => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_arvalid,			
  error_log7_1_arready     => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_arready,				
  error_log7_1_arprot      => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_arprot, 
  error_log7_1_rdata       => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_rdata,			
  error_log7_1_rresp       => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_rresp,			
  error_log7_1_rvalid      => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_rvalid,			
  error_log7_1_rready      => hbm2e_upper_error_log_ch7_u1_axi.hbm2e_error_log_rready 
  );

u7_hbm2_lower_test : hbm2e_lower_test
generic map (
  TEST_CTRL_CLK_PERIOD     => 20
  )
port map (
  sys_clk                  => sys_clk, 
  sys_reset                => sys_reset(16), 
  hbm2e_refclk             => HBM_REFCLK0, 
  hbm2e_cattrip_in         => HBM_CATRIP0,
  hbm2e_temp_in            => HBM_TEMP0,
  initiator_clk            => hbm_initiator_clk0,
  mem_usr_clk              => hbm_tst_clk0, 
  mem_usr_reset            => hbml_user_reset_d4, 
  test_ctrl0_0_awaddr      => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_awaddr,  			
  test_ctrl0_0_awvalid     => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_awvalid, 			
  test_ctrl0_0_awready     => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_awready, 			
  test_ctrl0_0_awprot      => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_awprot,  			
  test_ctrl0_0_wdata       => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_wdata,   			
  test_ctrl0_0_wstrb       => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_wstrb,   			
  test_ctrl0_0_wvalid      => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_wvalid,  			
  test_ctrl0_0_wready      => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_wready,  			
  test_ctrl0_0_bresp       => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_bresp,   				
  test_ctrl0_0_bvalid      => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_bvalid,  				
  test_ctrl0_0_bready      => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_bready,  				
  test_ctrl0_0_araddr      => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_araddr,  				
  test_ctrl0_0_arvalid     => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_arvalid, 			
  test_ctrl0_0_arready     => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_arready, 			
  test_ctrl0_0_arprot      => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_arprot,  			
  test_ctrl0_0_rdata       => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_rdata,   			
  test_ctrl0_0_rresp       => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_rresp,   			
  test_ctrl0_0_rvalid      => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_rvalid,  			
  test_ctrl0_0_rready      => hbm2e_lower_test_ch0_u0_axi.hbm2e_test_ctrl_rready, 			
  error_log0_0_awaddr      => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_awaddr, 
  error_log0_0_awvalid     => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_awvalid,
  error_log0_0_awready     => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_awready,
  error_log0_0_awprot      => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_awprot, 
  error_log0_0_wdata       => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_wdata,  
  error_log0_0_wstrb       => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_wstrb,  
  error_log0_0_wvalid      => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_wvalid,
  error_log0_0_wready      => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_wready,
  error_log0_0_bresp       => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_bresp,	
  error_log0_0_bvalid      => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_bvalid,	
  error_log0_0_bready      => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_bready,	
  error_log0_0_araddr      => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_araddr, 		
  error_log0_0_arvalid     => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_arvalid,
  error_log0_0_arready     => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_arready,
  error_log0_0_arprot      => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_arprot, 
  error_log0_0_rdata       => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_rdata,	
  error_log0_0_rresp       => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_rresp,	
  error_log0_0_rvalid      => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_rvalid,	
  error_log0_0_rready      => hbm2e_lower_error_log_ch0_u0_axi.hbm2e_error_log_rready, 
  test_ctrl0_1_awaddr      => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_awaddr, 
  test_ctrl0_1_awvalid     => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_awvalid,
  test_ctrl0_1_awready     => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_awready,
  test_ctrl0_1_awprot      => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_awprot, 
  test_ctrl0_1_wdata       => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_wdata,  
  test_ctrl0_1_wstrb       => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_wstrb,  
  test_ctrl0_1_wvalid      => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_wvalid, 
  test_ctrl0_1_wready      => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_wready, 
  test_ctrl0_1_bresp       => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_bresp,  			
  test_ctrl0_1_bvalid      => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_bvalid, 			
  test_ctrl0_1_bready      => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_bready, 			
  test_ctrl0_1_araddr      => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_araddr, 			
  test_ctrl0_1_arvalid     => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_arvalid,		
  test_ctrl0_1_arready     => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_arready,		
  test_ctrl0_1_arprot      => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_arprot, 
  test_ctrl0_1_rdata       => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_rdata,  	
  test_ctrl0_1_rresp       => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_rresp,  	
  test_ctrl0_1_rvalid      => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_rvalid, 	
  test_ctrl0_1_rready      => hbm2e_lower_test_ch0_u1_axi.hbm2e_test_ctrl_rready, 
  error_log0_1_awaddr      => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_awaddr, 
  error_log0_1_awvalid     => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_awvalid,
  error_log0_1_awready     => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_awready,
  error_log0_1_awprot      => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_awprot, 
  error_log0_1_wdata       => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_wdata,  
  error_log0_1_wstrb       => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_wstrb,  
  error_log0_1_wvalid      => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_wvalid,
  error_log0_1_wready      => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_wready,
  error_log0_1_bresp       => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_bresp,					
  error_log0_1_bvalid      => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_bvalid,					
  error_log0_1_bready      => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_bready,				
  error_log0_1_araddr      => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_araddr,  					
  error_log0_1_arvalid     => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_arvalid,		
  error_log0_1_arready     => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_arready,			
  error_log0_1_arprot      => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_arprot, 
  error_log0_1_rdata       => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_rdata,			
  error_log0_1_rresp       => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_rresp,			
  error_log0_1_rvalid      => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_rvalid,			
  error_log0_1_rready      => hbm2e_lower_error_log_ch0_u1_axi.hbm2e_error_log_rready, 
  test_ctrl1_0_awaddr      => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_awaddr,  	
  test_ctrl1_0_awvalid     => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_awvalid, 	
  test_ctrl1_0_awready     => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_awready, 	
  test_ctrl1_0_awprot      => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_awprot,  	
  test_ctrl1_0_wdata       => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_wdata,   	
  test_ctrl1_0_wstrb       => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_wstrb,   	
  test_ctrl1_0_wvalid      => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_wvalid,  	
  test_ctrl1_0_wready      => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_wready,  	
  test_ctrl1_0_bresp       => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_bresp,   				
  test_ctrl1_0_bvalid      => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_bvalid,  				
  test_ctrl1_0_bready      => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_bready,  				
  test_ctrl1_0_araddr      => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_araddr,  				
  test_ctrl1_0_arvalid     => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_arvalid, 			
  test_ctrl1_0_arready     => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_arready, 			
  test_ctrl1_0_arprot      => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_arprot,  	
  test_ctrl1_0_rdata       => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_rdata,   		
  test_ctrl1_0_rresp       => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_rresp,   		
  test_ctrl1_0_rvalid      => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_rvalid,  		
  test_ctrl1_0_rready      => hbm2e_lower_test_ch1_u0_axi.hbm2e_test_ctrl_rready, 	
  error_log1_0_awaddr      => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_awaddr, 
  error_log1_0_awvalid     => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_awvalid,
  error_log1_0_awready     => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_awready,
  error_log1_0_awprot      => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_awprot, 
  error_log1_0_wdata       => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_wdata,  
  error_log1_0_wstrb       => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_wstrb,  
  error_log1_0_wvalid      => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_wvalid,
  error_log1_0_wready      => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_wready,
  error_log1_0_bresp       => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_bresp,						
  error_log1_0_bvalid      => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_bvalid,						
  error_log1_0_bready      => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_bready,					
  error_log1_0_araddr      => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_araddr, 							
  error_log1_0_arvalid     => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_arvalid,		
  error_log1_0_arready     => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_arready,			
  error_log1_0_arprot      => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_arprot, 
  error_log1_0_rdata       => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_rdata,		
  error_log1_0_rresp       => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_rresp,		
  error_log1_0_rvalid      => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_rvalid,		
  error_log1_0_rready      => hbm2e_lower_error_log_ch1_u0_axi.hbm2e_error_log_rready, 
  test_ctrl1_1_awaddr      => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_awaddr, 
  test_ctrl1_1_awvalid     => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_awvalid,
  test_ctrl1_1_awready     => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_awready,
  test_ctrl1_1_awprot      => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_awprot, 
  test_ctrl1_1_wdata       => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_wdata,  
  test_ctrl1_1_wstrb       => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_wstrb,  
  test_ctrl1_1_wvalid      => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_wvalid, 
  test_ctrl1_1_wready      => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_wready, 
  test_ctrl1_1_bresp       => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_bresp,  				
  test_ctrl1_1_bvalid      => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_bvalid, 				
  test_ctrl1_1_bready      => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_bready, 				
  test_ctrl1_1_araddr      => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_araddr, 				
  test_ctrl1_1_arvalid     => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_arvalid,			
  test_ctrl1_1_arready     => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_arready,			
  test_ctrl1_1_arprot      => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_arprot, 
  test_ctrl1_1_rdata       => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_rdata,  		
  test_ctrl1_1_rresp       => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_rresp,  		
  test_ctrl1_1_rvalid      => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_rvalid, 		
  test_ctrl1_1_rready      => hbm2e_lower_test_ch1_u1_axi.hbm2e_test_ctrl_rready, 
  error_log1_1_awaddr      => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_awaddr,  
  error_log1_1_awvalid     => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_awvalid,
  error_log1_1_awready     => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_awready,
  error_log1_1_awprot      => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_awprot,  
  error_log1_1_wdata       => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_wdata,   
  error_log1_1_wstrb       => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_wstrb,   
  error_log1_1_wvalid      => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_wvalid,
  error_log1_1_wready      => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_wready,
  error_log1_1_bresp       => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_bresp,								
  error_log1_1_bvalid      => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_bvalid,								
  error_log1_1_bready      => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_bready,							
  error_log1_1_araddr      => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_araddr, 	 								
  error_log1_1_arvalid     => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_arvalid,				
  error_log1_1_arready     => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_arready,					
  error_log1_1_arprot      => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_arprot,  
  error_log1_1_rdata       => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_rdata,				
  error_log1_1_rresp       => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_rresp,				
  error_log1_1_rvalid      => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_rvalid,				
  error_log1_1_rready      => hbm2e_lower_error_log_ch1_u1_axi.hbm2e_error_log_rready, 
  test_ctrl2_0_awaddr      => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_awaddr,  			
  test_ctrl2_0_awvalid     => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_awvalid, 			
  test_ctrl2_0_awready     => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_awready, 			
  test_ctrl2_0_awprot      => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_awprot,  			
  test_ctrl2_0_wdata       => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_wdata,   			
  test_ctrl2_0_wstrb       => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_wstrb,   			
  test_ctrl2_0_wvalid      => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_wvalid,  			
  test_ctrl2_0_wready      => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_wready,  			
  test_ctrl2_0_bresp       => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_bresp,   			
  test_ctrl2_0_bvalid      => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_bvalid,  			
  test_ctrl2_0_bready      => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_bready,  			
  test_ctrl2_0_araddr      => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_araddr,  			
  test_ctrl2_0_arvalid     => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_arvalid, 			
  test_ctrl2_0_arready     => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_arready, 			
  test_ctrl2_0_arprot      => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_arprot,  			
  test_ctrl2_0_rdata       => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_rdata,   			
  test_ctrl2_0_rresp       => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_rresp,   			
  test_ctrl2_0_rvalid      => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_rvalid,  			
  test_ctrl2_0_rready      => hbm2e_lower_test_ch2_u0_axi.hbm2e_test_ctrl_rready, 			
  error_log2_0_awaddr      => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_awaddr, 
  error_log2_0_awvalid     => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_awvalid,
  error_log2_0_awready     => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_awready,
  error_log2_0_awprot      => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_awprot, 
  error_log2_0_wdata       => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_wdata,  
  error_log2_0_wstrb       => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_wstrb,  
  error_log2_0_wvalid      => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_wvalid,
  error_log2_0_wready      => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_wready,
  error_log2_0_bresp       => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_bresp,			
  error_log2_0_bvalid      => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_bvalid,			
  error_log2_0_bready      => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_bready,		
  error_log2_0_araddr      => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_araddr, 				
  error_log2_0_arvalid     => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_arvalid,
  error_log2_0_arready     => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_arready,	
  error_log2_0_arprot      => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_arprot, 
  error_log2_0_rdata       => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_rdata,	
  error_log2_0_rresp       => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_rresp,	
  error_log2_0_rvalid      => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_rvalid,	
  error_log2_0_rready      => hbm2e_lower_error_log_ch2_u0_axi.hbm2e_error_log_rready, 
  test_ctrl2_1_awaddr      => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_awaddr, 
  test_ctrl2_1_awvalid     => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_awvalid,
  test_ctrl2_1_awready     => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_awready,
  test_ctrl2_1_awprot      => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_awprot, 
  test_ctrl2_1_wdata       => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_wdata,  
  test_ctrl2_1_wstrb       => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_wstrb,  
  test_ctrl2_1_wvalid      => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_wvalid, 
  test_ctrl2_1_wready      => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_wready, 
  test_ctrl2_1_bresp       => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_bresp,  			
  test_ctrl2_1_bvalid      => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_bvalid, 			
  test_ctrl2_1_bready      => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_bready, 			
  test_ctrl2_1_araddr      => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_araddr, 			
  test_ctrl2_1_arvalid     => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_arvalid,		
  test_ctrl2_1_arready     => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_arready,		
  test_ctrl2_1_arprot      => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_arprot, 
  test_ctrl2_1_rdata       => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_rdata,  	
  test_ctrl2_1_rresp       => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_rresp,  	
  test_ctrl2_1_rvalid      => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_rvalid, 	
  test_ctrl2_1_rready      => hbm2e_lower_test_ch2_u1_axi.hbm2e_test_ctrl_rready, 
  error_log2_1_awaddr      => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_awaddr, 
  error_log2_1_awvalid     => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_awvalid,
  error_log2_1_awready     => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_awready,
  error_log2_1_awprot      => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_awprot, 
  error_log2_1_wdata       => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_wdata,  
  error_log2_1_wstrb       => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_wstrb,  
  error_log2_1_wvalid      => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_wvalid,
  error_log2_1_wready      => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_wready,
  error_log2_1_bresp       => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_bresp,					
  error_log2_1_bvalid      => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_bvalid,					
  error_log2_1_bready      => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_bready,				
  error_log2_1_araddr      => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_araddr,  					
  error_log2_1_arvalid     => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_arvalid,		
  error_log2_1_arready     => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_arready,			
  error_log2_1_arprot      => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_arprot, 
  error_log2_1_rdata       => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_rdata,			
  error_log2_1_rresp       => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_rresp,			
  error_log2_1_rvalid      => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_rvalid,			
  error_log2_1_rready      => hbm2e_lower_error_log_ch2_u1_axi.hbm2e_error_log_rready, 
  test_ctrl3_0_awaddr      => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_awaddr,  	
  test_ctrl3_0_awvalid     => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_awvalid, 	
  test_ctrl3_0_awready     => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_awready, 	
  test_ctrl3_0_awprot      => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_awprot,  	
  test_ctrl3_0_wdata       => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_wdata,   	
  test_ctrl3_0_wstrb       => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_wstrb,   	
  test_ctrl3_0_wvalid      => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_wvalid,  	
  test_ctrl3_0_wready      => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_wready,  	
  test_ctrl3_0_bresp       => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_bresp,   			
  test_ctrl3_0_bvalid      => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_bvalid,  			
  test_ctrl3_0_bready      => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_bready,  			
  test_ctrl3_0_araddr      => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_araddr,  			
  test_ctrl3_0_arvalid     => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_arvalid, 			
  test_ctrl3_0_arready     => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_arready, 			
  test_ctrl3_0_arprot      => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_arprot,  	
  test_ctrl3_0_rdata       => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_rdata,   		
  test_ctrl3_0_rresp       => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_rresp,   		
  test_ctrl3_0_rvalid      => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_rvalid,  		
  test_ctrl3_0_rready      => hbm2e_lower_test_ch3_u0_axi.hbm2e_test_ctrl_rready, 	
  error_log3_0_awaddr      => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_awaddr, 
  error_log3_0_awvalid     => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_awvalid,
  error_log3_0_awready     => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_awready,
  error_log3_0_awprot      => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_awprot, 
  error_log3_0_wdata       => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_wdata,  
  error_log3_0_wstrb       => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_wstrb,  
  error_log3_0_wvalid      => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_wvalid,
  error_log3_0_wready      => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_wready,
  error_log3_0_bresp       => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_bresp,						
  error_log3_0_bvalid      => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_bvalid,						
  error_log3_0_bready      => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_bready,					
  error_log3_0_araddr      => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_araddr, 							
  error_log3_0_arvalid     => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_arvalid,		
  error_log3_0_arready     => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_arready,			
  error_log3_0_arprot      => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_arprot, 
  error_log3_0_rdata       => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_rdata,		
  error_log3_0_rresp       => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_rresp,		
  error_log3_0_rvalid      => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_rvalid,		
  error_log3_0_rready      => hbm2e_lower_error_log_ch3_u0_axi.hbm2e_error_log_rready, 
  test_ctrl3_1_awaddr      => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_awaddr, 
  test_ctrl3_1_awvalid     => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_awvalid,
  test_ctrl3_1_awready     => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_awready,
  test_ctrl3_1_awprot      => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_awprot, 
  test_ctrl3_1_wdata       => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_wdata,  
  test_ctrl3_1_wstrb       => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_wstrb,  
  test_ctrl3_1_wvalid      => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_wvalid, 
  test_ctrl3_1_wready      => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_wready, 
  test_ctrl3_1_bresp       => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_bresp,  			
  test_ctrl3_1_bvalid      => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_bvalid, 			
  test_ctrl3_1_bready      => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_bready, 			
  test_ctrl3_1_araddr      => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_araddr, 			
  test_ctrl3_1_arvalid     => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_arvalid,			
  test_ctrl3_1_arready     => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_arready,			
  test_ctrl3_1_arprot      => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_arprot, 
  test_ctrl3_1_rdata       => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_rdata,  		
  test_ctrl3_1_rresp       => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_rresp,  		
  test_ctrl3_1_rvalid      => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_rvalid, 		
  test_ctrl3_1_rready      => hbm2e_lower_test_ch3_u1_axi.hbm2e_test_ctrl_rready, 
  error_log3_1_awaddr      => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_awaddr, 
  error_log3_1_awvalid     => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_awvalid,
  error_log3_1_awready     => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_awready,
  error_log3_1_awprot      => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_awprot, 
  error_log3_1_wdata       => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_wdata,  
  error_log3_1_wstrb       => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_wstrb,  
  error_log3_1_wvalid      => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_wvalid,
  error_log3_1_wready      => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_wready,
  error_log3_1_bresp       => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_bresp,							
  error_log3_1_bvalid      => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_bvalid,							
  error_log3_1_bready      => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_bready,						
  error_log3_1_araddr      => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_araddr,  							
  error_log3_1_arvalid     => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_arvalid,				
  error_log3_1_arready     => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_arready,					
  error_log3_1_arprot      => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_arprot, 
  error_log3_1_rdata       => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_rdata,				
  error_log3_1_rresp       => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_rresp,				
  error_log3_1_rvalid      => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_rvalid,				
  error_log3_1_rready      => hbm2e_lower_error_log_ch3_u1_axi.hbm2e_error_log_rready, 
  test_ctrl4_0_awaddr      => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_awaddr,  		
  test_ctrl4_0_awvalid     => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_awvalid, 		
  test_ctrl4_0_awready     => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_awready, 		
  test_ctrl4_0_awprot      => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_awprot,  		
  test_ctrl4_0_wdata       => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_wdata,   		
  test_ctrl4_0_wstrb       => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_wstrb,   		
  test_ctrl4_0_wvalid      => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_wvalid,  		
  test_ctrl4_0_wready      => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_wready,  		
  test_ctrl4_0_bresp       => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_bresp,   			
  test_ctrl4_0_bvalid      => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_bvalid,  			
  test_ctrl4_0_bready      => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_bready,  			
  test_ctrl4_0_araddr      => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_araddr,  			
  test_ctrl4_0_arvalid     => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_arvalid, 		
  test_ctrl4_0_arready     => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_arready, 		
  test_ctrl4_0_arprot      => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_arprot,  		
  test_ctrl4_0_rdata       => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_rdata,   		
  test_ctrl4_0_rresp       => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_rresp,   		
  test_ctrl4_0_rvalid      => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_rvalid,  		
  test_ctrl4_0_rready      => hbm2e_lower_test_ch4_u0_axi.hbm2e_test_ctrl_rready, 		
  error_log4_0_awaddr      => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_awaddr, 
  error_log4_0_awvalid     => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_awvalid,
  error_log4_0_awready     => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_awready,
  error_log4_0_awprot      => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_awprot, 
  error_log4_0_wdata       => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_wdata,  
  error_log4_0_wstrb       => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_wstrb,  
  error_log4_0_wvalid      => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_wvalid,
  error_log4_0_wready      => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_wready,
  error_log4_0_bresp       => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_bresp,				
  error_log4_0_bvalid      => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_bvalid,				
  error_log4_0_bready      => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_bready,			
  error_log4_0_araddr      => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_araddr, 					
  error_log4_0_arvalid     => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_arvalid,
  error_log4_0_arready     => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_arready,	
  error_log4_0_arprot      => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_arprot, 
  error_log4_0_rdata       => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_rdata,	
  error_log4_0_rresp       => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_rresp,	
  error_log4_0_rvalid      => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_rvalid,	
  error_log4_0_rready      => hbm2e_lower_error_log_ch4_u0_axi.hbm2e_error_log_rready, 
  test_ctrl4_1_awaddr      => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_awaddr, 
  test_ctrl4_1_awvalid     => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_awvalid,
  test_ctrl4_1_awready     => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_awready,
  test_ctrl4_1_awprot      => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_awprot, 
  test_ctrl4_1_wdata       => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_wdata,  
  test_ctrl4_1_wstrb       => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_wstrb,  
  test_ctrl4_1_wvalid      => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_wvalid, 
  test_ctrl4_1_wready      => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_wready, 
  test_ctrl4_1_bresp       => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_bresp,  			
  test_ctrl4_1_bvalid      => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_bvalid, 			
  test_ctrl4_1_bready      => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_bready, 			
  test_ctrl4_1_araddr      => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_araddr, 			
  test_ctrl4_1_arvalid     => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_arvalid,		
  test_ctrl4_1_arready     => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_arready,		
  test_ctrl4_1_arprot      => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_arprot, 
  test_ctrl4_1_rdata       => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_rdata,  	
  test_ctrl4_1_rresp       => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_rresp,  	
  test_ctrl4_1_rvalid      => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_rvalid, 	
  test_ctrl4_1_rready      => hbm2e_lower_test_ch4_u1_axi.hbm2e_test_ctrl_rready, 
  error_log4_1_awaddr      => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_awaddr, 
  error_log4_1_awvalid     => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_awvalid,
  error_log4_1_awready     => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_awready,
  error_log4_1_awprot      => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_awprot, 
  error_log4_1_wdata       => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_wdata,  
  error_log4_1_wstrb       => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_wstrb,  
  error_log4_1_wvalid      => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_wvalid,
  error_log4_1_wready      => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_wready,
  error_log4_1_bresp       => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_bresp,						
  error_log4_1_bvalid      => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_bvalid,						
  error_log4_1_bready      => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_bready,					
  error_log4_1_araddr      => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_araddr, 						
  error_log4_1_arvalid     => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_arvalid,		
  error_log4_1_arready     => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_arready,			
  error_log4_1_arprot      => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_arprot, 
  error_log4_1_rdata       => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_rdata,			
  error_log4_1_rresp       => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_rresp,			
  error_log4_1_rvalid      => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_rvalid,			
  error_log4_1_rready      => hbm2e_lower_error_log_ch4_u1_axi.hbm2e_error_log_rready, 
  test_ctrl5_0_awaddr      => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_awaddr,  	
  test_ctrl5_0_awvalid     => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_awvalid, 	
  test_ctrl5_0_awready     => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_awready, 	
  test_ctrl5_0_awprot      => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_awprot,  	
  test_ctrl5_0_wdata       => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_wdata,   	
  test_ctrl5_0_wstrb       => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_wstrb,   	
  test_ctrl5_0_wvalid      => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_wvalid,  	
  test_ctrl5_0_wready      => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_wready,  	
  test_ctrl5_0_bresp       => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_bresp,   			
  test_ctrl5_0_bvalid      => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_bvalid,  			
  test_ctrl5_0_bready      => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_bready,  			
  test_ctrl5_0_araddr      => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_araddr,  			
  test_ctrl5_0_arvalid     => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_arvalid, 		
  test_ctrl5_0_arready     => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_arready, 		
  test_ctrl5_0_arprot      => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_arprot,  	
  test_ctrl5_0_rdata       => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_rdata,   		
  test_ctrl5_0_rresp       => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_rresp,   		
  test_ctrl5_0_rvalid      => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_rvalid,  		
  test_ctrl5_0_rready      => hbm2e_lower_test_ch5_u0_axi.hbm2e_test_ctrl_rready, 	
  error_log5_0_awaddr      => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_awaddr, 
  error_log5_0_awvalid     => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_awvalid,
  error_log5_0_awready     => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_awready,
  error_log5_0_awprot      => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_awprot, 
  error_log5_0_wdata       => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_wdata,  
  error_log5_0_wstrb       => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_wstrb,  
  error_log5_0_wvalid      => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_wvalid,
  error_log5_0_wready      => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_wready,
  error_log5_0_bresp       => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_bresp,						
  error_log5_0_bvalid      => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_bvalid,						
  error_log5_0_bready      => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_bready,					
  error_log5_0_araddr      => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_araddr, 						
  error_log5_0_arvalid     => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_arvalid,	
  error_log5_0_arready     => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_arready,		
  error_log5_0_arprot      => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_arprot, 
  error_log5_0_rdata       => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_rdata,	
  error_log5_0_rresp       => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_rresp,	
  error_log5_0_rvalid      => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_rvalid,	
  error_log5_0_rready      => hbm2e_lower_error_log_ch5_u0_axi.hbm2e_error_log_rready, 
  test_ctrl5_1_awaddr      => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_awaddr, 
  test_ctrl5_1_awvalid     => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_awvalid,
  test_ctrl5_1_awready     => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_awready,
  test_ctrl5_1_awprot      => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_awprot, 
  test_ctrl5_1_wdata       => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_wdata,  
  test_ctrl5_1_wstrb       => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_wstrb,  
  test_ctrl5_1_wvalid      => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_wvalid, 
  test_ctrl5_1_wready      => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_wready, 
  test_ctrl5_1_bresp       => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_bresp,  			
  test_ctrl5_1_bvalid      => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_bvalid, 			
  test_ctrl5_1_bready      => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_bready, 			
  test_ctrl5_1_araddr      => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_araddr, 			
  test_ctrl5_1_arvalid     => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_arvalid,		
  test_ctrl5_1_arready     => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_arready,		
  test_ctrl5_1_arprot      => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_arprot, 
  test_ctrl5_1_rdata       => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_rdata,  		
  test_ctrl5_1_rresp       => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_rresp,  		
  test_ctrl5_1_rvalid      => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_rvalid, 		
  test_ctrl5_1_rready      => hbm2e_lower_test_ch5_u1_axi.hbm2e_test_ctrl_rready, 
  error_log5_1_awaddr      => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_awaddr, 
  error_log5_1_awvalid     => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_awvalid,
  error_log5_1_awready     => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_awready,
  error_log5_1_awprot      => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_awprot, 
  error_log5_1_wdata       => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_wdata,  
  error_log5_1_wstrb       => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_wstrb,  
  error_log5_1_wvalid      => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_wvalid,
  error_log5_1_wready      => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_wready,
  error_log5_1_bresp       => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_bresp,						
  error_log5_1_bvalid      => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_bvalid,						
  error_log5_1_bready      => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_bready,					
  error_log5_1_araddr      => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_araddr, 							
  error_log5_1_arvalid     => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_arvalid,			
  error_log5_1_arready     => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_arready,				
  error_log5_1_arprot      => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_arprot, 
  error_log5_1_rdata       => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_rdata,			
  error_log5_1_rresp       => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_rresp,			
  error_log5_1_rvalid      => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_rvalid,			
  error_log5_1_rready      => hbm2e_lower_error_log_ch5_u1_axi.hbm2e_error_log_rready, 
  test_ctrl6_0_awaddr      => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_awaddr,  		
  test_ctrl6_0_awvalid     => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_awvalid, 		
  test_ctrl6_0_awready     => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_awready, 		
  test_ctrl6_0_awprot      => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_awprot,  		
  test_ctrl6_0_wdata       => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_wdata,   		
  test_ctrl6_0_wstrb       => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_wstrb,   		
  test_ctrl6_0_wvalid      => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_wvalid,  		
  test_ctrl6_0_wready      => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_wready,  		
  test_ctrl6_0_bresp       => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_bresp,   			
  test_ctrl6_0_bvalid      => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_bvalid,  			
  test_ctrl6_0_bready      => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_bready,  			
  test_ctrl6_0_araddr      => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_araddr,  			
  test_ctrl6_0_arvalid     => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_arvalid, 		
  test_ctrl6_0_arready     => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_arready, 		
  test_ctrl6_0_arprot      => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_arprot,  		
  test_ctrl6_0_rdata       => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_rdata,   		
  test_ctrl6_0_rresp       => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_rresp,   		
  test_ctrl6_0_rvalid      => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_rvalid,  		
  test_ctrl6_0_rready      => hbm2e_lower_test_ch6_u0_axi.hbm2e_test_ctrl_rready, 		
  error_log6_0_awaddr      => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_awaddr, 
  error_log6_0_awvalid     => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_awvalid,
  error_log6_0_awready     => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_awready,
  error_log6_0_awprot      => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_awprot, 
  error_log6_0_wdata       => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_wdata,  
  error_log6_0_wstrb       => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_wstrb,  
  error_log6_0_wvalid      => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_wvalid,
  error_log6_0_wready      => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_wready,
  error_log6_0_bresp       => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_bresp,				
  error_log6_0_bvalid      => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_bvalid,				
  error_log6_0_bready      => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_bready,			
  error_log6_0_araddr      => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_araddr, 						
  error_log6_0_arvalid     => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_arvalid,
  error_log6_0_arready     => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_arready,	
  error_log6_0_arprot      => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_arprot, 
  error_log6_0_rdata       => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_rdata,	
  error_log6_0_rresp       => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_rresp,	
  error_log6_0_rvalid      => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_rvalid,	
  error_log6_0_rready      => hbm2e_lower_error_log_ch6_u0_axi.hbm2e_error_log_rready, 
  test_ctrl6_1_awaddr      => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_awaddr, 
  test_ctrl6_1_awvalid     => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_awvalid,
  test_ctrl6_1_awready     => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_awready,
  test_ctrl6_1_awprot      => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_awprot, 
  test_ctrl6_1_wdata       => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_wdata,  
  test_ctrl6_1_wstrb       => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_wstrb,  
  test_ctrl6_1_wvalid      => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_wvalid, 
  test_ctrl6_1_wready      => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_wready, 
  test_ctrl6_1_bresp       => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_bresp,  			
  test_ctrl6_1_bvalid      => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_bvalid, 			
  test_ctrl6_1_bready      => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_bready, 			
  test_ctrl6_1_araddr      => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_araddr, 			
  test_ctrl6_1_arvalid     => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_arvalid,		
  test_ctrl6_1_arready     => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_arready,		
  test_ctrl6_1_arprot      => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_arprot, 
  test_ctrl6_1_rdata       => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_rdata,  	
  test_ctrl6_1_rresp       => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_rresp,  	
  test_ctrl6_1_rvalid      => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_rvalid, 	
  test_ctrl6_1_rready      => hbm2e_lower_test_ch6_u1_axi.hbm2e_test_ctrl_rready, 
  error_log6_1_awaddr      => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_awaddr, 
  error_log6_1_awvalid     => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_awvalid,
  error_log6_1_awready     => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_awready,
  error_log6_1_awprot      => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_awprot, 
  error_log6_1_wdata       => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_wdata,  
  error_log6_1_wstrb       => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_wstrb,  
  error_log6_1_wvalid      => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_wvalid,
  error_log6_1_wready      => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_wready,
  error_log6_1_bresp       => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_bresp,						
  error_log6_1_bvalid      => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_bvalid,						
  error_log6_1_bready      => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_bready,					
  error_log6_1_araddr      => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_araddr, 						
  error_log6_1_arvalid     => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_arvalid,		
  error_log6_1_arready     => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_arready,			
  error_log6_1_arprot      => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_arprot, 
  error_log6_1_rdata       => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_rdata,			
  error_log6_1_rresp       => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_rresp,			
  error_log6_1_rvalid      => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_rvalid,			
  error_log6_1_rready      => hbm2e_lower_error_log_ch6_u1_axi.hbm2e_error_log_rready, 
  test_ctrl7_0_awaddr      => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_awaddr,  	
  test_ctrl7_0_awvalid     => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_awvalid, 	
  test_ctrl7_0_awready     => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_awready, 	
  test_ctrl7_0_awprot      => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_awprot,  	
  test_ctrl7_0_wdata       => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_wdata,   	
  test_ctrl7_0_wstrb       => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_wstrb,   	
  test_ctrl7_0_wvalid      => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_wvalid,  	
  test_ctrl7_0_wready      => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_wready,  	
  test_ctrl7_0_bresp       => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_bresp,   			
  test_ctrl7_0_bvalid      => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_bvalid,  			
  test_ctrl7_0_bready      => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_bready,  			
  test_ctrl7_0_araddr      => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_araddr,  			
  test_ctrl7_0_arvalid     => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_arvalid, 		
  test_ctrl7_0_arready     => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_arready, 		
  test_ctrl7_0_arprot      => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_arprot,  	
  test_ctrl7_0_rdata       => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_rdata,   		
  test_ctrl7_0_rresp       => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_rresp,   		
  test_ctrl7_0_rvalid      => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_rvalid,  		
  test_ctrl7_0_rready      => hbm2e_lower_test_ch7_u0_axi.hbm2e_test_ctrl_rready, 	
  error_log7_0_awaddr      => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_awaddr,  
  error_log7_0_awvalid     => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_awvalid,
  error_log7_0_awready     => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_awready,
  error_log7_0_awprot      => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_awprot,  
  error_log7_0_wdata       => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_wdata,  
  error_log7_0_wstrb       => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_wstrb,  
  error_log7_0_wvalid      => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_wvalid,
  error_log7_0_wready      => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_wready,
  error_log7_0_bresp       => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_bresp,							
  error_log7_0_bvalid      => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_bvalid,							
  error_log7_0_bready      => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_bready,						
  error_log7_0_araddr      => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_araddr, 								
  error_log7_0_arvalid     => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_arvalid,			
  error_log7_0_arready     => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_arready,				
  error_log7_0_arprot      => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_arprot,  
  error_log7_0_rdata       => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_rdata,		
  error_log7_0_rresp       => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_rresp,		
  error_log7_0_rvalid      => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_rvalid,		
  error_log7_0_rready      => hbm2e_lower_error_log_ch7_u0_axi.hbm2e_error_log_rready, 
  test_ctrl7_1_awaddr      => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_awaddr, 
  test_ctrl7_1_awvalid     => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_awvalid,
  test_ctrl7_1_awready     => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_awready,
  test_ctrl7_1_awprot      => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_awprot, 
  test_ctrl7_1_wdata       => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_wdata,  
  test_ctrl7_1_wstrb       => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_wstrb,  
  test_ctrl7_1_wvalid      => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_wvalid, 
  test_ctrl7_1_wready      => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_wready, 
  test_ctrl7_1_bresp       => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_bresp,  			
  test_ctrl7_1_bvalid      => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_bvalid, 			
  test_ctrl7_1_bready      => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_bready, 			
  test_ctrl7_1_araddr      => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_araddr, 			
  test_ctrl7_1_arvalid     => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_arvalid,		
  test_ctrl7_1_arready     => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_arready,		
  test_ctrl7_1_arprot      => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_arprot, 
  test_ctrl7_1_rdata       => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_rdata,  		
  test_ctrl7_1_rresp       => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_rresp,  		
  test_ctrl7_1_rvalid      => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_rvalid, 		
  test_ctrl7_1_rready      => hbm2e_lower_test_ch7_u1_axi.hbm2e_test_ctrl_rready, 
  error_log7_1_awaddr      => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_awaddr,  
  error_log7_1_awvalid     => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_awvalid,
  error_log7_1_awready     => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_awready,
  error_log7_1_awprot      => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_awprot,  
  error_log7_1_wdata       => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_wdata,  
  error_log7_1_wstrb       => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_wstrb,  
  error_log7_1_wvalid      => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_wvalid,
  error_log7_1_wready      => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_wready,
  error_log7_1_bresp       => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_bresp,							
  error_log7_1_bvalid      => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_bvalid,							
  error_log7_1_bready      => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_bready,					
  error_log7_1_araddr      => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_araddr, 	 							
  error_log7_1_arvalid     => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_arvalid,				
  error_log7_1_arready     => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_arready,						
  error_log7_1_arprot      => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_arprot,  
  error_log7_1_rdata       => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_rdata,				
  error_log7_1_rresp       => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_rresp,				
  error_log7_1_rvalid      => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_rvalid,				
  error_log7_1_rready      => hbm2e_lower_error_log_ch7_u1_axi.hbm2e_error_log_rready 
  );

u8_bmc_spi_telemetry_test : telemetry_test
generic map (
  QSFPDD_NUM                      => 3
  )
port map (
  aclk                            => sys_clk,
  areset                          => sys_reset(17),
  awaddr                          => telemetry_test_axi.telemetry_test_awaddr,
  awvalid                         => telemetry_test_axi.telemetry_test_awvalid,
  awready                         => telemetry_test_axi.telemetry_test_awready,
  awprot                          => telemetry_test_axi.telemetry_test_awprot,
  wdata                           => telemetry_test_axi.telemetry_test_wdata,
  wstrb                           => telemetry_test_axi.telemetry_test_wstrb,
  wvalid                          => telemetry_test_axi.telemetry_test_wvalid,
  wready                          => telemetry_test_axi.telemetry_test_wready,
  bresp                           => telemetry_test_axi.telemetry_test_bresp,					
  bvalid                          => telemetry_test_axi.telemetry_test_bvalid,						
  bready                          => telemetry_test_axi.telemetry_test_bready,						
  araddr                          => telemetry_test_axi.telemetry_test_araddr,					
  arvalid                         => telemetry_test_axi.telemetry_test_arvalid,					
  arready                         => telemetry_test_axi.telemetry_test_arready,					
  arprot                          => telemetry_test_axi.telemetry_test_arprot,
  rdata                           => telemetry_test_axi.telemetry_test_rdata,			
  rresp                           => telemetry_test_axi.telemetry_test_rresp,			
  rvalid                          => telemetry_test_axi.telemetry_test_rvalid,				
  rready                          => telemetry_test_axi.telemetry_test_rready,				
  qsfpdd0_rst_n                   => qsfpdd0_rst_n,	        
  qsfpdd0_lpmode                  => qsfpdd0_lpmode,	        
  qsfpdd0_int_n                   => qsfpdd0_int_n,	        
  qsfpdd0_present_n               => qsfpdd0_present_n,	
  qsfpdd1_rst_n                   => qsfpdd1_rst_n,	        
  qsfpdd1_lpmode                  => qsfpdd1_lpmode,	        
  qsfpdd1_int_n                   => qsfpdd1_int_n,	        
  qsfpdd1_present_n               => qsfpdd1_present_n,	
  qsfpdd2_rst_n                   => qsfpdd2_rst_n,	        
  qsfpdd2_lpmode                  => qsfpdd2_lpmode,	        
  qsfpdd2_int_n                   => qsfpdd2_int_n,	        
  qsfpdd2_present_n               => qsfpdd2_present_n,	
  eeprom_data                     => eeprom_data
  );  

u9_qsfpdd0_test : xcvr_if
generic map (
  RATE0                         => QSFPDD0_RATE,         
  CONFIGCLK_PERIOD              => 20             -- sys_clk runs at 50MHz
  )
port map  (
  refclk_fgt_2                  => '0',
  refclk_fgt_5                  => QSFP0_REFCLK,
  coreclk_fgt_2                 => open,
  coreclk_fgt_5                 => qsfpdd0_refclk_pll, 
  systempll_synthlock_322       => qsfpdd0_refclk_lock322,
  systempll_synthlock_805       => qsfpdd0_refclk_lock805,
  systempll_synthlock_830       => qsfpdd0_refclk_lock830,
  tx_serial_data_0              => QSFP0_TX_P,
  tx_serial_data_0_n            => QSFP0_TX_N,
  rx_serial_data_0              => QSFP0_RX_P,
  rx_serial_data_0_n            => QSFP0_RX_N,
  reconfig_0_write              => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_write,
  reconfig_0_read               => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_read,
  reconfig_0_address            => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_address,
  reconfig_0_byteenable         => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_byteenable,
  reconfig_0_writedata          => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_writedata,
  reconfig_0_readdata           => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_readdata,
  reconfig_0_waitrequest        => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_waitrequest,
  reconfig_0_readdatavalid      => qsfpdd0_xcvr_reconfig_avmm.xcvr_reconfig_readdatavalid,
  reconfig_sl_0_write           => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_write,
  reconfig_sl_0_read            => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_read,
  reconfig_sl_0_address         => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_address,
  reconfig_sl_0_byteenable      => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_byteenable,
  reconfig_sl_0_writedata       => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_writedata,
  reconfig_sl_0_readdata        => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_readdata,
  reconfig_sl_0_waitrequest     => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_waitrequest,
  reconfig_sl_0_readdatavalid   => qsfpdd0_sl4_reconfig_avmm.sl4_reconfig_readdatavalid,
  config_clk                    => sys_clk,			    
  config_rstn                   => sys_resetn(18),			    
  awaddr                        => qsfpdd0_test_axi.qsfpdd_test_awaddr,			    
  awvalid                       => qsfpdd0_test_axi.qsfpdd_test_awvalid,			    
  awready                       => qsfpdd0_test_axi.qsfpdd_test_awready,			    
  wdata                         => qsfpdd0_test_axi.qsfpdd_test_wdata,			    
  wstrb                         => qsfpdd0_test_axi.qsfpdd_test_wstrb,			    
  wvalid                        => qsfpdd0_test_axi.qsfpdd_test_wvalid,			    
  wready                        => qsfpdd0_test_axi.qsfpdd_test_wready,			    
  bresp                         => qsfpdd0_test_axi.qsfpdd_test_bresp,			    
  bvalid                        => qsfpdd0_test_axi.qsfpdd_test_bvalid,			    
  bready                        => qsfpdd0_test_axi.qsfpdd_test_bready,			    
  araddr                        => qsfpdd0_test_axi.qsfpdd_test_araddr,			    
  arvalid                       => qsfpdd0_test_axi.qsfpdd_test_arvalid,			    
  arready                       => qsfpdd0_test_axi.qsfpdd_test_arready,			    
  rdata                         => qsfpdd0_test_axi.qsfpdd_test_rdata,			    
  rresp                         => qsfpdd0_test_axi.qsfpdd_test_rresp,			    
  rvalid                        => qsfpdd0_test_axi.qsfpdd_test_rvalid,			    
  rready                        => qsfpdd0_test_axi.qsfpdd_test_rready			    
  ); 							    

qsfpdd0_refclk_lock <= qsfpdd0_refclk_lock322 when QSFPDD0_RATE=0 else 
                       qsfpdd0_refclk_lock805 when QSFPDD0_RATE=1 else
                       qsfpdd0_refclk_lock830 when QSFPDD0_RATE=2 else
                       '0';

u10_qsfpdd1_test : xcvr_if
generic map (
  RATE0                         => QSFPDD1_RATE,         
  CONFIGCLK_PERIOD              => 20             -- sys_clk runs at 50MHz
  )
port map  (
  refclk_fgt_2                  => MCIO_REFCLK,
  refclk_fgt_5                  => QSFP1_REFCLK,
  coreclk_fgt_2                 => mcio_refclk_pll,
  coreclk_fgt_5                 => qsfpdd1_refclk_pll,
  systempll_synthlock_322       => qsfpdd1_refclk_lock322,
  systempll_synthlock_805       => qsfpdd1_refclk_lock805,
  systempll_synthlock_830       => qsfpdd1_refclk_lock830,
  tx_serial_data_0              => QSFP1_TX_P,
  tx_serial_data_0_n            => QSFP1_TX_N,
  rx_serial_data_0              => QSFP1_RX_P,
  rx_serial_data_0_n            => QSFP1_RX_N,
  reconfig_0_write              => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_write,
  reconfig_0_read               => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_read,
  reconfig_0_address            => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_address,
  reconfig_0_byteenable         => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_byteenable,
  reconfig_0_writedata          => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_writedata,
  reconfig_0_readdata           => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_readdata,
  reconfig_0_waitrequest        => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_waitrequest,
  reconfig_0_readdatavalid      => qsfpdd1_xcvr_reconfig_avmm.xcvr_reconfig_readdatavalid,
  reconfig_sl_0_write           => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_write,
  reconfig_sl_0_read            => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_read,
  reconfig_sl_0_address         => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_address,
  reconfig_sl_0_byteenable      => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_byteenable,
  reconfig_sl_0_writedata       => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_writedata,
  reconfig_sl_0_readdata        => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_readdata,
  reconfig_sl_0_waitrequest     => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_waitrequest,
  reconfig_sl_0_readdatavalid   => qsfpdd1_sl4_reconfig_avmm.sl4_reconfig_readdatavalid,
  config_clk                    => sys_clk,			    
  config_rstn                   => sys_resetn(19),			    
  awaddr                        => qsfpdd1_test_axi.qsfpdd_test_awaddr,			    
  awvalid                       => qsfpdd1_test_axi.qsfpdd_test_awvalid,			    
  awready                       => qsfpdd1_test_axi.qsfpdd_test_awready,			    
  wdata                         => qsfpdd1_test_axi.qsfpdd_test_wdata,			    
  wstrb                         => qsfpdd1_test_axi.qsfpdd_test_wstrb,			    
  wvalid                        => qsfpdd1_test_axi.qsfpdd_test_wvalid,			    
  wready                        => qsfpdd1_test_axi.qsfpdd_test_wready,			    
  bresp                         => qsfpdd1_test_axi.qsfpdd_test_bresp,			    
  bvalid                        => qsfpdd1_test_axi.qsfpdd_test_bvalid,			    
  bready                        => qsfpdd1_test_axi.qsfpdd_test_bready,			    
  araddr                        => qsfpdd1_test_axi.qsfpdd_test_araddr,			    
  arvalid                       => qsfpdd1_test_axi.qsfpdd_test_arvalid,			    
  arready                       => qsfpdd1_test_axi.qsfpdd_test_arready,			    
  rdata                         => qsfpdd1_test_axi.qsfpdd_test_rdata,			    
  rresp                         => qsfpdd1_test_axi.qsfpdd_test_rresp,			    
  rvalid                        => qsfpdd1_test_axi.qsfpdd_test_rvalid,			    
  rready                        => qsfpdd1_test_axi.qsfpdd_test_rready			    
  ); 							

qsfpdd1_refclk_lock <= qsfpdd1_refclk_lock322 when QSFPDD1_RATE=0 else 
                       qsfpdd1_refclk_lock805 when QSFPDD1_RATE=1 else
                       qsfpdd1_refclk_lock830 when QSFPDD1_RATE=2 else
                       '0';
 
u11_qsfpdd2_test : xcvr_if
generic map (
  RATE0                         => QSFPDD2_RATE,         
  CONFIGCLK_PERIOD              => 20             -- sys_clk runs at 50MHz
  )
port map  (
  refclk_fgt_2                  => M2_REFCLK,
  refclk_fgt_5                  => QSFP2_REFCLK,
  coreclk_fgt_2                 => m2_refclk_pll,
  coreclk_fgt_5                 => qsfpdd2_refclk_pll,
  systempll_synthlock_322       => qsfpdd2_refclk_lock322,
  systempll_synthlock_805       => qsfpdd2_refclk_lock805,
  systempll_synthlock_830       => qsfpdd2_refclk_lock830,
  tx_serial_data_0              => QSFP2_TX_P,
  tx_serial_data_0_n            => QSFP2_TX_N,
  rx_serial_data_0              => QSFP2_RX_P,
  rx_serial_data_0_n            => QSFP2_RX_N,
  reconfig_0_write              => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_write,
  reconfig_0_read               => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_read,
  reconfig_0_address            => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_address,
  reconfig_0_byteenable         => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_byteenable,
  reconfig_0_writedata          => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_writedata,
  reconfig_0_readdata           => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_readdata,
  reconfig_0_waitrequest        => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_waitrequest,
  reconfig_0_readdatavalid      => qsfpdd2_xcvr_reconfig_avmm.xcvr_reconfig_readdatavalid,
  reconfig_sl_0_write           => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_write,
  reconfig_sl_0_read            => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_read,
  reconfig_sl_0_address         => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_address,
  reconfig_sl_0_byteenable      => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_byteenable,
  reconfig_sl_0_writedata       => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_writedata,
  reconfig_sl_0_readdata        => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_readdata,
  reconfig_sl_0_waitrequest     => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_waitrequest,
  reconfig_sl_0_readdatavalid   => qsfpdd2_sl4_reconfig_avmm.sl4_reconfig_readdatavalid,
  config_clk                    => sys_clk,			    
  config_rstn                   => sys_resetn(20),			    
  awaddr                        => qsfpdd2_test_axi.qsfpdd_test_awaddr,			    
  awvalid                       => qsfpdd2_test_axi.qsfpdd_test_awvalid,			    
  awready                       => qsfpdd2_test_axi.qsfpdd_test_awready,			    
  wdata                         => qsfpdd2_test_axi.qsfpdd_test_wdata,			    
  wstrb                         => qsfpdd2_test_axi.qsfpdd_test_wstrb,			    
  wvalid                        => qsfpdd2_test_axi.qsfpdd_test_wvalid,			    
  wready                        => qsfpdd2_test_axi.qsfpdd_test_wready,			    
  bresp                         => qsfpdd2_test_axi.qsfpdd_test_bresp,			    
  bvalid                        => qsfpdd2_test_axi.qsfpdd_test_bvalid,			    
  bready                        => qsfpdd2_test_axi.qsfpdd_test_bready,			    
  araddr                        => qsfpdd2_test_axi.qsfpdd_test_araddr,			    
  arvalid                       => qsfpdd2_test_axi.qsfpdd_test_arvalid,			    
  arready                       => qsfpdd2_test_axi.qsfpdd_test_arready,			    
  rdata                         => qsfpdd2_test_axi.qsfpdd_test_rdata,			    
  rresp                         => qsfpdd2_test_axi.qsfpdd_test_rresp,			    
  rvalid                        => qsfpdd2_test_axi.qsfpdd_test_rvalid,			    
  rready                        => qsfpdd2_test_axi.qsfpdd_test_rready			    
  );  

qsfpdd2_refclk_lock <= qsfpdd2_refclk_lock322 when QSFPDD2_RATE=0 else 
                       qsfpdd2_refclk_lock805 when QSFPDD2_RATE=1 else
                       qsfpdd2_refclk_lock830 when QSFPDD2_RATE=2 else
                       '0';
 
u12_powerburner : powerburner_controller
generic map (
  CORE_CLK_FREQUENCY              => 600000000,
  POWERBURNER_INSTANCES           => PB_INSTANCES,
  BRAM_HW_TARGET                  => PB_BRAM_NUM,
  SREG_HW_TARGET                  => PB_REG_NUM,
  DSP_HW_TARGET                   => PB_DSP_NUM
  )
port map (
  aclk                            => sys_clk,
  areset                          => sys_reset(21),
  awaddr                          => pwr_burner_axi.pwr_burner_awaddr,                                
  awvalid                         => pwr_burner_axi.pwr_burner_awvalid,                               
  awready                         => pwr_burner_axi.pwr_burner_awready,                               
  awprot                          => pwr_burner_axi.pwr_burner_awprot,                                
  wdata                           => pwr_burner_axi.pwr_burner_wdata,                                 
  wstrb                           => pwr_burner_axi.pwr_burner_wstrb,                                 
  wvalid                          => pwr_burner_axi.pwr_burner_wvalid,                                
  wready                          => pwr_burner_axi.pwr_burner_wready,                                
  bresp                           => pwr_burner_axi.pwr_burner_bresp,                                 
  bvalid                          => pwr_burner_axi.pwr_burner_bvalid,                                
  bready                          => pwr_burner_axi.pwr_burner_bready,                                
  araddr                          => pwr_burner_axi.pwr_burner_araddr,                                
  arvalid                         => pwr_burner_axi.pwr_burner_arvalid,                               
  arready                         => pwr_burner_axi.pwr_burner_arready,                               
  arprot                          => pwr_burner_axi.pwr_burner_arprot,                                
  rdata                           => pwr_burner_axi.pwr_burner_rdata,                                 
  rresp                           => pwr_burner_axi.pwr_burner_rresp,                                 
  rvalid                          => pwr_burner_axi.pwr_burner_rvalid,                                
  rready                          => pwr_burner_axi.pwr_burner_rready,                                
  pb_clk                          => powerburner_clk
  );

u13_lvds_gpio : lvds_gpio_test 
port map (
  aclk                            => sys_clk,
  areset                          => sys_reset(22),
  awaddr                          => lvds_gpio_test_axi.lvds_gpio_test_awaddr,
  awvalid                         => lvds_gpio_test_axi.lvds_gpio_test_awvalid,
  awready                         => lvds_gpio_test_axi.lvds_gpio_test_awready,
  awprot                          => lvds_gpio_test_axi.lvds_gpio_test_awprot,
  wdata                           => lvds_gpio_test_axi.lvds_gpio_test_wdata,
  wstrb                           => lvds_gpio_test_axi.lvds_gpio_test_wstrb,
  wvalid                          => lvds_gpio_test_axi.lvds_gpio_test_wvalid,
  wready                          => lvds_gpio_test_axi.lvds_gpio_test_wready,
  bresp                           => lvds_gpio_test_axi.lvds_gpio_test_bresp,				
  bvalid                          => lvds_gpio_test_axi.lvds_gpio_test_bvalid,		
  bready                          => lvds_gpio_test_axi.lvds_gpio_test_bready,		
  araddr                          => lvds_gpio_test_axi.lvds_gpio_test_araddr,				
  arvalid                         => lvds_gpio_test_axi.lvds_gpio_test_arvalid,	                     
  arready                         => lvds_gpio_test_axi.lvds_gpio_test_arready,	                    
  arprot                          => lvds_gpio_test_axi.lvds_gpio_test_arprot,                      
  rdata                           => lvds_gpio_test_axi.lvds_gpio_test_rdata,		
  rresp                           => lvds_gpio_test_axi.lvds_gpio_test_rresp,		
  rvalid                          => lvds_gpio_test_axi.lvds_gpio_test_rvalid,
  rready                          => lvds_gpio_test_axi.lvds_gpio_test_rready,
  lvds_clock                      => EXT_SE_CLK,
  lvds_out                        => EXT_GPIO_OUT,
  lvds_in                         => EXT_GPIO_IN
  );

u14_hps_dram_test : hps_dram_test
generic map (
  TEST_CTRL_CLK_PERIOD      => 20
  )
port map (
  ref_clk                   => HPS_DDR4_REFCLK,        
  mem_ck_t                  => HPS_DDR4_CLK_P,                     
  mem_ck_c                  => HPS_DDR4_CLK_N,                 
  mem_cke                   => HPS_DDR4_CKE,               
  mem_odt                   => HPS_DDR4_ODT,                    
  mem_cs_n                  => HPS_DDR4_CS_L,                    
  mem_a                     => HPS_DDR4_A,                   
  mem_ba                    => HPS_DDR4_BA,                  
  mem_bg                    => HPS_DDR4_BG,                 
  mem_act_n                 => HPS_DDR4_ACT_L,                 
  mem_par                   => HPS_DDR4_PARITY,                   
  mem_alert_n               => HPS_DDR4_ALERT_L,         
  mem_reset_n               => HPS_DDR4_RESET_L,               
  mem_dq                    => HPS_DDR4_DQ,            
  mem_dqs_t                 => HPS_DDR4_DQS_P,         
  mem_dqs_c                 => HPS_DDR4_DQS_N,         
  mem_dbi_n                 => HPS_DDR4_DM,           
  oct_rzqin                 => HPS_DDR4_RZQ,
  sys_clk                   => sys_clk,
  sys_reset                 => sys_reset(24),
  initiator_clk             => dram_usr_clk,  -- Shouldn't be used
  mem_usr_clk               => dram_usr_clk,
  mem_usr_reset             => dram_usr_reset,
  test_ctrl_awaddr          => dram_test_ctrl_axi.hbm2e_test_ctrl_awaddr,  
  test_ctrl_awvalid         => dram_test_ctrl_axi.hbm2e_test_ctrl_awvalid, 
  test_ctrl_awready         => dram_test_ctrl_axi.hbm2e_test_ctrl_awready, 
  test_ctrl_awprot          => dram_test_ctrl_axi.hbm2e_test_ctrl_awprot,  
  test_ctrl_wdata           => dram_test_ctrl_axi.hbm2e_test_ctrl_wdata,   
  test_ctrl_wstrb           => dram_test_ctrl_axi.hbm2e_test_ctrl_wstrb,   
  test_ctrl_wvalid          => dram_test_ctrl_axi.hbm2e_test_ctrl_wvalid,  
  test_ctrl_wready          => dram_test_ctrl_axi.hbm2e_test_ctrl_wready,  
  test_ctrl_bresp           => dram_test_ctrl_axi.hbm2e_test_ctrl_bresp,   			
  test_ctrl_bvalid          => dram_test_ctrl_axi.hbm2e_test_ctrl_bvalid,  	
  test_ctrl_bready          => dram_test_ctrl_axi.hbm2e_test_ctrl_bready,  	
  test_ctrl_araddr          => dram_test_ctrl_axi.hbm2e_test_ctrl_araddr,  			
  test_ctrl_arvalid         => dram_test_ctrl_axi.hbm2e_test_ctrl_arvalid, 
  test_ctrl_arready         => dram_test_ctrl_axi.hbm2e_test_ctrl_arready, 
  test_ctrl_arprot          => dram_test_ctrl_axi.hbm2e_test_ctrl_arprot,  
  test_ctrl_rdata           => dram_test_ctrl_axi.hbm2e_test_ctrl_rdata,   	
  test_ctrl_rresp           => dram_test_ctrl_axi.hbm2e_test_ctrl_rresp,   	
  test_ctrl_rvalid          => dram_test_ctrl_axi.hbm2e_test_ctrl_rvalid,  
  test_ctrl_rready          => dram_test_ctrl_axi.hbm2e_test_ctrl_rready,  
  error_log_awaddr          => dram_error_log_axi.hbm2e_error_log_awaddr,  
  error_log_awvalid         => dram_error_log_axi.hbm2e_error_log_awvalid, 
  error_log_awready         => dram_error_log_axi.hbm2e_error_log_awready, 
  error_log_awprot          => dram_error_log_axi.hbm2e_error_log_awprot,  
  error_log_wdata           => dram_error_log_axi.hbm2e_error_log_wdata,   
  error_log_wstrb           => dram_error_log_axi.hbm2e_error_log_wstrb,   
  error_log_wvalid          => dram_error_log_axi.hbm2e_error_log_wvalid,  
  error_log_wready          => dram_error_log_axi.hbm2e_error_log_wready,  
  error_log_bresp           => dram_error_log_axi.hbm2e_error_log_bresp,   
  error_log_bvalid          => dram_error_log_axi.hbm2e_error_log_bvalid,  
  error_log_bready          => dram_error_log_axi.hbm2e_error_log_bready,  
  error_log_araddr          => dram_error_log_axi.hbm2e_error_log_araddr,  	
  error_log_arvalid         => dram_error_log_axi.hbm2e_error_log_arvalid, 
  error_log_arready         => dram_error_log_axi.hbm2e_error_log_arready, 
  error_log_arprot          => dram_error_log_axi.hbm2e_error_log_arprot,  
  error_log_rdata           => dram_error_log_axi.hbm2e_error_log_rdata,   
  error_log_rresp           => dram_error_log_axi.hbm2e_error_log_rresp,   
  error_log_rvalid          => dram_error_log_axi.hbm2e_error_log_rvalid,  
  error_log_rready          => dram_error_log_axi.hbm2e_error_log_rready  
  );
  
end rtl;					
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						