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
-- Title       : HBM2e Upper Test
-- Project     : Multi
--------------------------------------------------------------------------------
-- Description : HBM2e Memory Test + HBM2e Instance.
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity hbm2e_upper_test is
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
end entity hbm2e_upper_test;

architecture rtl of hbm2e_upper_test is

component hbm2e_upper 
port (
  ch0_u0_wmc_intr       : out std_logic;
  ch0_u1_wmc_intr       : out std_logic;
  ch1_u0_wmc_intr       : out std_logic;
  ch1_u1_wmc_intr       : out std_logic;
  ch2_u0_wmc_intr       : out std_logic;
  ch2_u1_wmc_intr       : out std_logic;
  ch3_u0_wmc_intr       : out std_logic;
  ch3_u1_wmc_intr       : out std_logic;
  ch4_u0_wmc_intr       : out std_logic;
  ch4_u1_wmc_intr       : out std_logic;
  ch5_u0_wmc_intr       : out std_logic;
  ch5_u1_wmc_intr       : out std_logic;
  ch6_u0_wmc_intr       : out std_logic;
  ch6_u1_wmc_intr       : out std_logic;
  ch7_u0_wmc_intr       : out std_logic;
  ch7_u1_wmc_intr       : out std_logic;
  fabric_clk            : in  std_logic;
  hbm_reset_n           : in  std_logic;
  hbm_reset_in_prog     : out std_logic;
  hbm_cattrip           : out std_logic;
  hbm_cattrip_i         : in  std_logic;
  hbm_temp              : out std_logic_vector(2 downto 0);
  hbm_temp_i            : in  std_logic_vector(2 downto 0);
  local_cal_success     : out std_logic;
  local_cal_fail        : out std_logic;
  uibpll_refclk         : in  std_logic
  );
end component;

component mem_test_initiator_wrapper
generic (
  TEST_CTRL_CLK_PERIOD   :      integer := 10;
  ADDR_WIDTH             :      integer := 32;
  MEM_DATA_WIDTH         :      integer := 64;
  EMIF_DATA_WIDTH        :      integer := 512;
  AXI_BURST_LENGTH       :      integer := 256
  );
port (
  test_ctrl_aclk         : in   std_logic;
  test_ctrl_areset       : in   std_logic;
  test_ctrl_awaddr       : in   std_logic_vector(5 downto 0);
  test_ctrl_awvalid      : in   std_logic;
  test_ctrl_awready      : out  std_logic;
  test_ctrl_awprot       : in   std_logic_vector(2 downto 0);
  test_ctrl_wdata        : in   std_logic_vector(31 downto 0);
  test_ctrl_wstrb        : in   std_logic_vector(3 downto 0);
  test_ctrl_wvalid       : in   std_logic;
  test_ctrl_wready       : out  std_logic;
  test_ctrl_bresp        : out  std_logic_vector(1 downto 0);						
  test_ctrl_bvalid       : out  std_logic;									
  test_ctrl_bready       : in   std_logic;									
  test_ctrl_araddr       : in   std_logic_vector(5 downto 0);						
  test_ctrl_arvalid      : in   std_logic;								
  test_ctrl_arready      : out  std_logic;								
  test_ctrl_arprot       : in   std_logic_vector(2 downto 0);
  test_ctrl_rdata        : out  std_logic_vector(31 downto 0);				
  test_ctrl_rresp        : out  std_logic_vector(1 downto 0);				
  test_ctrl_rvalid       : out  std_logic;							
  test_ctrl_rready       : in   std_logic;  
  error_log_aclk         : in   std_logic;
  error_log_areset       : in   std_logic;
  error_log_awaddr       : in   std_logic_vector(7 downto 0);
  error_log_awvalid      : in   std_logic;
  error_log_awready      : out  std_logic;
  error_log_awprot       : in   std_logic_vector(2 downto 0);
  error_log_wdata        : in   std_logic_vector(31 downto 0);
  error_log_wstrb        : in   std_logic_vector(3 downto 0);
  error_log_wvalid       : in   std_logic;
  error_log_wready       : out  std_logic;
  error_log_bresp        : out  std_logic_vector(1 downto 0);						
  error_log_bvalid       : out  std_logic;									
  error_log_bready       : in   std_logic;									
  error_log_araddr       : in   std_logic_vector(7 downto 0);						
  error_log_arvalid      : in   std_logic;								
  error_log_arready      : out  std_logic;								
  error_log_arprot       : in   std_logic_vector(2 downto 0);
  error_log_rdata        : out  std_logic_vector(31 downto 0);				
  error_log_rresp        : out  std_logic_vector(1 downto 0);				
  error_log_rvalid       : out  std_logic;							
  error_log_rready       : in   std_logic;
  initiator_clk          : in   std_logic;
  mem_usr_clk            : in   std_logic;
  mem_usr_reset          : in   std_logic;
  mem_reset              : out  std_logic;
  mem_reset_status       : in   std_logic;
  calibration_success    : in   std_logic;
  calibration_fail       : in   std_logic;
  cattrip                : in   std_logic;
  temp                   : in   std_logic_vector(2 downto 0)
  );
end component;

constant AXI_BURST_LENGTH : integer range 1 to 256 := 32;
constant ADDR_WIDTH       : integer := 30; -- Do Not Change
constant MEM_DATA_WIDTH   : integer := 72; -- Do Not Change
constant EMIF_DATA_WIDTH  : integer := 576; -- Do Not Change

signal mem_reset_final   : std_logic;

signal mem_reset_final_d1: std_logic;
signal mem_reset_final_d2: std_logic;
signal mem_reset_final_n : std_logic;
signal mem_reset         : std_logic_vector(15 downto 0);
signal mem_reset_status  : std_logic;
signal local_cal_success : std_logic;
signal local_cal_fail    : std_logic;
signal local_cattrip     : std_logic;
signal local_temp        : std_logic_vector(2 downto 0);

begin

mem_reset_final     <= mem_reset(0);
mem_reset_final_n <= not (mem_reset_final);

uut : hbm2e_upper
port map (
  ch0_u0_wmc_intr       => open,
  ch0_u1_wmc_intr       => open,
  ch1_u0_wmc_intr       => open,
  ch1_u1_wmc_intr       => open,
  ch2_u0_wmc_intr       => open,
  ch2_u1_wmc_intr       => open,
  ch3_u0_wmc_intr       => open,
  ch3_u1_wmc_intr       => open,
  ch4_u0_wmc_intr       => open,
  ch4_u1_wmc_intr       => open,
  ch5_u0_wmc_intr       => open,
  ch5_u1_wmc_intr       => open,
  ch6_u0_wmc_intr       => open,
  ch6_u1_wmc_intr       => open,
  ch7_u0_wmc_intr       => open,
  ch7_u1_wmc_intr       => open,
  fabric_clk            => sys_clk,
  hbm_reset_n           => mem_reset_final_n,
  hbm_reset_in_prog     => mem_reset_status,
  hbm_cattrip           => local_cattrip,
  hbm_cattrip_i         => hbm2e_cattrip_in,
  hbm_temp              => local_temp,
  hbm_temp_i            => hbm2e_temp_in,
  local_cal_success     => local_cal_success,
  local_cal_fail        => local_cal_fail,
  uibpll_refclk         => hbm2e_refclk
  );

u0_ch0_0 : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  EMIF_DATA_WIDTH        => EMIF_DATA_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl0_0_awaddr, 
  test_ctrl_awvalid      => test_ctrl0_0_awvalid, 
  test_ctrl_awready      => test_ctrl0_0_awready, 
  test_ctrl_awprot       => test_ctrl0_0_awprot, 
  test_ctrl_wdata        => test_ctrl0_0_wdata, 
  test_ctrl_wstrb        => test_ctrl0_0_wstrb, 
  test_ctrl_wvalid       => test_ctrl0_0_wvalid, 
  test_ctrl_wready       => test_ctrl0_0_wready, 
  test_ctrl_bresp        => test_ctrl0_0_bresp, 			
  test_ctrl_bvalid       => test_ctrl0_0_bvalid, 				
  test_ctrl_bready       => test_ctrl0_0_bready, 				
  test_ctrl_araddr       => test_ctrl0_0_araddr, 			
  test_ctrl_arvalid      => test_ctrl0_0_arvalid, 			
  test_ctrl_arready      => test_ctrl0_0_arready, 			
  test_ctrl_arprot       => test_ctrl0_0_arprot, 
  test_ctrl_rdata        => test_ctrl0_0_rdata, 	
  test_ctrl_rresp        => test_ctrl0_0_rresp, 	
  test_ctrl_rvalid       => test_ctrl0_0_rvalid, 		
  test_ctrl_rready       => test_ctrl0_0_rready, 
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log0_0_awaddr,    
  error_log_awvalid      => error_log0_0_awvalid,    
  error_log_awready      => error_log0_0_awready,    
  error_log_awprot       => error_log0_0_awprot,    
  error_log_wdata        => error_log0_0_wdata,    
  error_log_wstrb        => error_log0_0_wstrb,    
  error_log_wvalid       => error_log0_0_wvalid,    
  error_log_wready       => error_log0_0_wready,    
  error_log_bresp        => error_log0_0_bresp ,    			
  error_log_bvalid       => error_log0_0_bvalid,    				
  error_log_bready       => error_log0_0_bready,    				
  error_log_araddr       => error_log0_0_araddr,    			
  error_log_arvalid      => error_log0_0_arvalid,    			
  error_log_arready      => error_log0_0_arready,    			
  error_log_arprot       => error_log0_0_arprot,    
  error_log_rdata        => error_log0_0_rdata,    	
  error_log_rresp        => error_log0_0_rresp,    	
  error_log_rvalid       => error_log0_0_rvalid,				
  error_log_rready       => error_log0_0_rready,
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset(0),
  mem_reset              => mem_reset(0),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => local_cattrip,
  temp                   => local_temp  
  );

u1_ch0_1 : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  EMIF_DATA_WIDTH        => EMIF_DATA_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl0_1_awaddr, 
  test_ctrl_awvalid      => test_ctrl0_1_awvalid, 
  test_ctrl_awready      => test_ctrl0_1_awready, 
  test_ctrl_awprot       => test_ctrl0_1_awprot, 
  test_ctrl_wdata        => test_ctrl0_1_wdata, 
  test_ctrl_wstrb        => test_ctrl0_1_wstrb, 
  test_ctrl_wvalid       => test_ctrl0_1_wvalid, 
  test_ctrl_wready       => test_ctrl0_1_wready, 
  test_ctrl_bresp        => test_ctrl0_1_bresp, 			
  test_ctrl_bvalid       => test_ctrl0_1_bvalid, 				
  test_ctrl_bready       => test_ctrl0_1_bready, 				
  test_ctrl_araddr       => test_ctrl0_1_araddr, 			
  test_ctrl_arvalid      => test_ctrl0_1_arvalid, 			
  test_ctrl_arready      => test_ctrl0_1_arready, 			
  test_ctrl_arprot       => test_ctrl0_1_arprot, 
  test_ctrl_rdata        => test_ctrl0_1_rdata, 	
  test_ctrl_rresp        => test_ctrl0_1_rresp, 	
  test_ctrl_rvalid       => test_ctrl0_1_rvalid, 		
  test_ctrl_rready       => test_ctrl0_1_rready, 
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log0_1_awaddr,    
  error_log_awvalid      => error_log0_1_awvalid,    
  error_log_awready      => error_log0_1_awready,    
  error_log_awprot       => error_log0_1_awprot,    
  error_log_wdata        => error_log0_1_wdata,    
  error_log_wstrb        => error_log0_1_wstrb,    
  error_log_wvalid       => error_log0_1_wvalid,    
  error_log_wready       => error_log0_1_wready,    
  error_log_bresp        => error_log0_1_bresp ,    			
  error_log_bvalid       => error_log0_1_bvalid,    				
  error_log_bready       => error_log0_1_bready,    				
  error_log_araddr       => error_log0_1_araddr,    			
  error_log_arvalid      => error_log0_1_arvalid,    			
  error_log_arready      => error_log0_1_arready,    			
  error_log_arprot       => error_log0_1_arprot,    
  error_log_rdata        => error_log0_1_rdata,    	
  error_log_rresp        => error_log0_1_rresp,    	
  error_log_rvalid       => error_log0_1_rvalid,				
  error_log_rready       => error_log0_1_rready,
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset(1),
  mem_reset              => mem_reset(1),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => local_cattrip,
  temp                   => local_temp   
  );

u2_ch1_0 : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  EMIF_DATA_WIDTH        => EMIF_DATA_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl1_0_awaddr, 
  test_ctrl_awvalid      => test_ctrl1_0_awvalid, 
  test_ctrl_awready      => test_ctrl1_0_awready, 
  test_ctrl_awprot       => test_ctrl1_0_awprot, 
  test_ctrl_wdata        => test_ctrl1_0_wdata, 
  test_ctrl_wstrb        => test_ctrl1_0_wstrb, 
  test_ctrl_wvalid       => test_ctrl1_0_wvalid, 
  test_ctrl_wready       => test_ctrl1_0_wready, 
  test_ctrl_bresp        => test_ctrl1_0_bresp, 			
  test_ctrl_bvalid       => test_ctrl1_0_bvalid, 				
  test_ctrl_bready       => test_ctrl1_0_bready, 				
  test_ctrl_araddr       => test_ctrl1_0_araddr, 			
  test_ctrl_arvalid      => test_ctrl1_0_arvalid, 			
  test_ctrl_arready      => test_ctrl1_0_arready, 			
  test_ctrl_arprot       => test_ctrl1_0_arprot, 
  test_ctrl_rdata        => test_ctrl1_0_rdata, 	
  test_ctrl_rresp        => test_ctrl1_0_rresp, 	
  test_ctrl_rvalid       => test_ctrl1_0_rvalid, 		
  test_ctrl_rready       => test_ctrl1_0_rready, 
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log1_0_awaddr,    
  error_log_awvalid      => error_log1_0_awvalid,    
  error_log_awready      => error_log1_0_awready,    
  error_log_awprot       => error_log1_0_awprot,    
  error_log_wdata        => error_log1_0_wdata,    
  error_log_wstrb        => error_log1_0_wstrb,    
  error_log_wvalid       => error_log1_0_wvalid,    
  error_log_wready       => error_log1_0_wready,    
  error_log_bresp        => error_log1_0_bresp ,    			
  error_log_bvalid       => error_log1_0_bvalid,    				
  error_log_bready       => error_log1_0_bready,    				
  error_log_araddr       => error_log1_0_araddr,    			
  error_log_arvalid      => error_log1_0_arvalid,    			
  error_log_arready      => error_log1_0_arready,    			
  error_log_arprot       => error_log1_0_arprot,    
  error_log_rdata        => error_log1_0_rdata,    	
  error_log_rresp        => error_log1_0_rresp,    	
  error_log_rvalid       => error_log1_0_rvalid,				
  error_log_rready       => error_log1_0_rready,
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset(2),
  mem_reset              => mem_reset(2),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => local_cattrip,
  temp                   => local_temp   
  );

u3_ch1_1 : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  EMIF_DATA_WIDTH        => EMIF_DATA_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl1_1_awaddr, 
  test_ctrl_awvalid      => test_ctrl1_1_awvalid, 
  test_ctrl_awready      => test_ctrl1_1_awready, 
  test_ctrl_awprot       => test_ctrl1_1_awprot, 
  test_ctrl_wdata        => test_ctrl1_1_wdata, 
  test_ctrl_wstrb        => test_ctrl1_1_wstrb, 
  test_ctrl_wvalid       => test_ctrl1_1_wvalid, 
  test_ctrl_wready       => test_ctrl1_1_wready, 
  test_ctrl_bresp        => test_ctrl1_1_bresp, 			
  test_ctrl_bvalid       => test_ctrl1_1_bvalid, 				
  test_ctrl_bready       => test_ctrl1_1_bready, 				
  test_ctrl_araddr       => test_ctrl1_1_araddr, 			
  test_ctrl_arvalid      => test_ctrl1_1_arvalid, 			
  test_ctrl_arready      => test_ctrl1_1_arready, 			
  test_ctrl_arprot       => test_ctrl1_1_arprot, 
  test_ctrl_rdata        => test_ctrl1_1_rdata, 	
  test_ctrl_rresp        => test_ctrl1_1_rresp, 	
  test_ctrl_rvalid       => test_ctrl1_1_rvalid, 		
  test_ctrl_rready       => test_ctrl1_1_rready, 
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log1_1_awaddr,    
  error_log_awvalid      => error_log1_1_awvalid,    
  error_log_awready      => error_log1_1_awready,    
  error_log_awprot       => error_log1_1_awprot,    
  error_log_wdata        => error_log1_1_wdata,    
  error_log_wstrb        => error_log1_1_wstrb,    
  error_log_wvalid       => error_log1_1_wvalid,    
  error_log_wready       => error_log1_1_wready,    
  error_log_bresp        => error_log1_1_bresp ,    			
  error_log_bvalid       => error_log1_1_bvalid,    				
  error_log_bready       => error_log1_1_bready,    				
  error_log_araddr       => error_log1_1_araddr,    			
  error_log_arvalid      => error_log1_1_arvalid,    			
  error_log_arready      => error_log1_1_arready,    			
  error_log_arprot       => error_log1_1_arprot,    
  error_log_rdata        => error_log1_1_rdata,    	
  error_log_rresp        => error_log1_1_rresp,    	
  error_log_rvalid       => error_log1_1_rvalid,				
  error_log_rready       => error_log1_1_rready,
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset(3),
  mem_reset              => mem_reset(3),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => local_cattrip,
  temp                   => local_temp   
  );

u4_ch2_0 : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  EMIF_DATA_WIDTH        => EMIF_DATA_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl2_0_awaddr, 
  test_ctrl_awvalid      => test_ctrl2_0_awvalid, 
  test_ctrl_awready      => test_ctrl2_0_awready, 
  test_ctrl_awprot       => test_ctrl2_0_awprot, 
  test_ctrl_wdata        => test_ctrl2_0_wdata, 
  test_ctrl_wstrb        => test_ctrl2_0_wstrb, 
  test_ctrl_wvalid       => test_ctrl2_0_wvalid, 
  test_ctrl_wready       => test_ctrl2_0_wready, 
  test_ctrl_bresp        => test_ctrl2_0_bresp, 			
  test_ctrl_bvalid       => test_ctrl2_0_bvalid, 				
  test_ctrl_bready       => test_ctrl2_0_bready, 				
  test_ctrl_araddr       => test_ctrl2_0_araddr, 			
  test_ctrl_arvalid      => test_ctrl2_0_arvalid, 			
  test_ctrl_arready      => test_ctrl2_0_arready, 			
  test_ctrl_arprot       => test_ctrl2_0_arprot, 
  test_ctrl_rdata        => test_ctrl2_0_rdata, 	
  test_ctrl_rresp        => test_ctrl2_0_rresp, 	
  test_ctrl_rvalid       => test_ctrl2_0_rvalid, 		
  test_ctrl_rready       => test_ctrl2_0_rready, 
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log2_0_awaddr,    
  error_log_awvalid      => error_log2_0_awvalid,    
  error_log_awready      => error_log2_0_awready,    
  error_log_awprot       => error_log2_0_awprot,    
  error_log_wdata        => error_log2_0_wdata,    
  error_log_wstrb        => error_log2_0_wstrb,    
  error_log_wvalid       => error_log2_0_wvalid,    
  error_log_wready       => error_log2_0_wready,    
  error_log_bresp        => error_log2_0_bresp ,    			
  error_log_bvalid       => error_log2_0_bvalid,    				
  error_log_bready       => error_log2_0_bready,    				
  error_log_araddr       => error_log2_0_araddr,    			
  error_log_arvalid      => error_log2_0_arvalid,    			
  error_log_arready      => error_log2_0_arready,    			
  error_log_arprot       => error_log2_0_arprot,    
  error_log_rdata        => error_log2_0_rdata,    	
  error_log_rresp        => error_log2_0_rresp,    	
  error_log_rvalid       => error_log2_0_rvalid,				
  error_log_rready       => error_log2_0_rready,
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset(4),
  mem_reset              => mem_reset(4),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => local_cattrip,
  temp                   => local_temp   
  );

u5_ch2_1 : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  EMIF_DATA_WIDTH        => EMIF_DATA_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl2_1_awaddr, 
  test_ctrl_awvalid      => test_ctrl2_1_awvalid, 
  test_ctrl_awready      => test_ctrl2_1_awready, 
  test_ctrl_awprot       => test_ctrl2_1_awprot, 
  test_ctrl_wdata        => test_ctrl2_1_wdata, 
  test_ctrl_wstrb        => test_ctrl2_1_wstrb, 
  test_ctrl_wvalid       => test_ctrl2_1_wvalid, 
  test_ctrl_wready       => test_ctrl2_1_wready, 
  test_ctrl_bresp        => test_ctrl2_1_bresp, 			
  test_ctrl_bvalid       => test_ctrl2_1_bvalid, 				
  test_ctrl_bready       => test_ctrl2_1_bready, 				
  test_ctrl_araddr       => test_ctrl2_1_araddr, 			
  test_ctrl_arvalid      => test_ctrl2_1_arvalid, 			
  test_ctrl_arready      => test_ctrl2_1_arready, 			
  test_ctrl_arprot       => test_ctrl2_1_arprot, 
  test_ctrl_rdata        => test_ctrl2_1_rdata, 	
  test_ctrl_rresp        => test_ctrl2_1_rresp, 	
  test_ctrl_rvalid       => test_ctrl2_1_rvalid, 		
  test_ctrl_rready       => test_ctrl2_1_rready, 
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log2_1_awaddr,    
  error_log_awvalid      => error_log2_1_awvalid,    
  error_log_awready      => error_log2_1_awready,    
  error_log_awprot       => error_log2_1_awprot,    
  error_log_wdata        => error_log2_1_wdata,    
  error_log_wstrb        => error_log2_1_wstrb,    
  error_log_wvalid       => error_log2_1_wvalid,    
  error_log_wready       => error_log2_1_wready,    
  error_log_bresp        => error_log2_1_bresp ,    			
  error_log_bvalid       => error_log2_1_bvalid,    				
  error_log_bready       => error_log2_1_bready,    				
  error_log_araddr       => error_log2_1_araddr,    			
  error_log_arvalid      => error_log2_1_arvalid,    			
  error_log_arready      => error_log2_1_arready,    			
  error_log_arprot       => error_log2_1_arprot,    
  error_log_rdata        => error_log2_1_rdata,    	
  error_log_rresp        => error_log2_1_rresp,    	
  error_log_rvalid       => error_log2_1_rvalid,				
  error_log_rready       => error_log2_1_rready,
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset(5),
  mem_reset              => mem_reset(5),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => local_cattrip,
  temp                   => local_temp   
  );

u6_ch3_0 : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  EMIF_DATA_WIDTH        => EMIF_DATA_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl3_0_awaddr, 
  test_ctrl_awvalid      => test_ctrl3_0_awvalid, 
  test_ctrl_awready      => test_ctrl3_0_awready, 
  test_ctrl_awprot       => test_ctrl3_0_awprot, 
  test_ctrl_wdata        => test_ctrl3_0_wdata, 
  test_ctrl_wstrb        => test_ctrl3_0_wstrb, 
  test_ctrl_wvalid       => test_ctrl3_0_wvalid, 
  test_ctrl_wready       => test_ctrl3_0_wready, 
  test_ctrl_bresp        => test_ctrl3_0_bresp, 			
  test_ctrl_bvalid       => test_ctrl3_0_bvalid, 				
  test_ctrl_bready       => test_ctrl3_0_bready, 				
  test_ctrl_araddr       => test_ctrl3_0_araddr, 			
  test_ctrl_arvalid      => test_ctrl3_0_arvalid, 			
  test_ctrl_arready      => test_ctrl3_0_arready, 			
  test_ctrl_arprot       => test_ctrl3_0_arprot, 
  test_ctrl_rdata        => test_ctrl3_0_rdata, 	
  test_ctrl_rresp        => test_ctrl3_0_rresp, 	
  test_ctrl_rvalid       => test_ctrl3_0_rvalid, 		
  test_ctrl_rready       => test_ctrl3_0_rready, 
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log3_0_awaddr,    
  error_log_awvalid      => error_log3_0_awvalid,    
  error_log_awready      => error_log3_0_awready,    
  error_log_awprot       => error_log3_0_awprot,    
  error_log_wdata        => error_log3_0_wdata,    
  error_log_wstrb        => error_log3_0_wstrb,    
  error_log_wvalid       => error_log3_0_wvalid,    
  error_log_wready       => error_log3_0_wready,    
  error_log_bresp        => error_log3_0_bresp ,    			
  error_log_bvalid       => error_log3_0_bvalid,    				
  error_log_bready       => error_log3_0_bready,    				
  error_log_araddr       => error_log3_0_araddr,    			
  error_log_arvalid      => error_log3_0_arvalid,    			
  error_log_arready      => error_log3_0_arready,    			
  error_log_arprot       => error_log3_0_arprot,    
  error_log_rdata        => error_log3_0_rdata,    	
  error_log_rresp        => error_log3_0_rresp,    	
  error_log_rvalid       => error_log3_0_rvalid,				
  error_log_rready       => error_log3_0_rready,
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset(6),
  mem_reset              => mem_reset(6),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => local_cattrip,
  temp                   => local_temp  
  );

u7_ch3_1 : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  EMIF_DATA_WIDTH        => EMIF_DATA_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl3_1_awaddr, 
  test_ctrl_awvalid      => test_ctrl3_1_awvalid, 
  test_ctrl_awready      => test_ctrl3_1_awready, 
  test_ctrl_awprot       => test_ctrl3_1_awprot, 
  test_ctrl_wdata        => test_ctrl3_1_wdata, 
  test_ctrl_wstrb        => test_ctrl3_1_wstrb, 
  test_ctrl_wvalid       => test_ctrl3_1_wvalid, 
  test_ctrl_wready       => test_ctrl3_1_wready, 
  test_ctrl_bresp        => test_ctrl3_1_bresp, 			
  test_ctrl_bvalid       => test_ctrl3_1_bvalid, 				
  test_ctrl_bready       => test_ctrl3_1_bready, 				
  test_ctrl_araddr       => test_ctrl3_1_araddr, 			
  test_ctrl_arvalid      => test_ctrl3_1_arvalid, 			
  test_ctrl_arready      => test_ctrl3_1_arready, 			
  test_ctrl_arprot       => test_ctrl3_1_arprot, 
  test_ctrl_rdata        => test_ctrl3_1_rdata, 	
  test_ctrl_rresp        => test_ctrl3_1_rresp, 	
  test_ctrl_rvalid       => test_ctrl3_1_rvalid, 		
  test_ctrl_rready       => test_ctrl3_1_rready, 
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log3_1_awaddr,    
  error_log_awvalid      => error_log3_1_awvalid,    
  error_log_awready      => error_log3_1_awready,    
  error_log_awprot       => error_log3_1_awprot,    
  error_log_wdata        => error_log3_1_wdata,    
  error_log_wstrb        => error_log3_1_wstrb,    
  error_log_wvalid       => error_log3_1_wvalid,    
  error_log_wready       => error_log3_1_wready,    
  error_log_bresp        => error_log3_1_bresp ,    			
  error_log_bvalid       => error_log3_1_bvalid,    				
  error_log_bready       => error_log3_1_bready,    				
  error_log_araddr       => error_log3_1_araddr,    			
  error_log_arvalid      => error_log3_1_arvalid,    			
  error_log_arready      => error_log3_1_arready,    			
  error_log_arprot       => error_log3_1_arprot,    
  error_log_rdata        => error_log3_1_rdata,    	
  error_log_rresp        => error_log3_1_rresp,    	
  error_log_rvalid       => error_log3_1_rvalid,				
  error_log_rready       => error_log3_1_rready,
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset(7),
  mem_reset              => mem_reset(7),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => local_cattrip,
  temp                   => local_temp   
  );
  
u8_ch4_0 : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  EMIF_DATA_WIDTH        => EMIF_DATA_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl4_0_awaddr, 
  test_ctrl_awvalid      => test_ctrl4_0_awvalid, 
  test_ctrl_awready      => test_ctrl4_0_awready, 
  test_ctrl_awprot       => test_ctrl4_0_awprot, 
  test_ctrl_wdata        => test_ctrl4_0_wdata, 
  test_ctrl_wstrb        => test_ctrl4_0_wstrb, 
  test_ctrl_wvalid       => test_ctrl4_0_wvalid, 
  test_ctrl_wready       => test_ctrl4_0_wready, 
  test_ctrl_bresp        => test_ctrl4_0_bresp, 			
  test_ctrl_bvalid       => test_ctrl4_0_bvalid, 				
  test_ctrl_bready       => test_ctrl4_0_bready, 				
  test_ctrl_araddr       => test_ctrl4_0_araddr, 			
  test_ctrl_arvalid      => test_ctrl4_0_arvalid, 			
  test_ctrl_arready      => test_ctrl4_0_arready, 			
  test_ctrl_arprot       => test_ctrl4_0_arprot, 
  test_ctrl_rdata        => test_ctrl4_0_rdata, 	
  test_ctrl_rresp        => test_ctrl4_0_rresp, 	
  test_ctrl_rvalid       => test_ctrl4_0_rvalid, 		
  test_ctrl_rready       => test_ctrl4_0_rready, 
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log4_0_awaddr,    
  error_log_awvalid      => error_log4_0_awvalid,    
  error_log_awready      => error_log4_0_awready,    
  error_log_awprot       => error_log4_0_awprot,    
  error_log_wdata        => error_log4_0_wdata,    
  error_log_wstrb        => error_log4_0_wstrb,    
  error_log_wvalid       => error_log4_0_wvalid,    
  error_log_wready       => error_log4_0_wready,    
  error_log_bresp        => error_log4_0_bresp ,    			
  error_log_bvalid       => error_log4_0_bvalid,    				
  error_log_bready       => error_log4_0_bready,    				
  error_log_araddr       => error_log4_0_araddr,    			
  error_log_arvalid      => error_log4_0_arvalid,    			
  error_log_arready      => error_log4_0_arready,    			
  error_log_arprot       => error_log4_0_arprot,    
  error_log_rdata        => error_log4_0_rdata,    	
  error_log_rresp        => error_log4_0_rresp,    	
  error_log_rvalid       => error_log4_0_rvalid,				
  error_log_rready       => error_log4_0_rready,
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset(8),
  mem_reset              => mem_reset(8),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => local_cattrip,
  temp                   => local_temp   
  );

u9_ch4_1 : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  EMIF_DATA_WIDTH        => EMIF_DATA_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl4_1_awaddr, 
  test_ctrl_awvalid      => test_ctrl4_1_awvalid, 
  test_ctrl_awready      => test_ctrl4_1_awready, 
  test_ctrl_awprot       => test_ctrl4_1_awprot, 
  test_ctrl_wdata        => test_ctrl4_1_wdata, 
  test_ctrl_wstrb        => test_ctrl4_1_wstrb, 
  test_ctrl_wvalid       => test_ctrl4_1_wvalid, 
  test_ctrl_wready       => test_ctrl4_1_wready, 
  test_ctrl_bresp        => test_ctrl4_1_bresp, 			
  test_ctrl_bvalid       => test_ctrl4_1_bvalid, 				
  test_ctrl_bready       => test_ctrl4_1_bready, 				
  test_ctrl_araddr       => test_ctrl4_1_araddr, 			
  test_ctrl_arvalid      => test_ctrl4_1_arvalid, 			
  test_ctrl_arready      => test_ctrl4_1_arready, 			
  test_ctrl_arprot       => test_ctrl4_1_arprot, 
  test_ctrl_rdata        => test_ctrl4_1_rdata, 	
  test_ctrl_rresp        => test_ctrl4_1_rresp, 	
  test_ctrl_rvalid       => test_ctrl4_1_rvalid, 		
  test_ctrl_rready       => test_ctrl4_1_rready, 
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log4_1_awaddr,    
  error_log_awvalid      => error_log4_1_awvalid,    
  error_log_awready      => error_log4_1_awready,    
  error_log_awprot       => error_log4_1_awprot,    
  error_log_wdata        => error_log4_1_wdata,    
  error_log_wstrb        => error_log4_1_wstrb,    
  error_log_wvalid       => error_log4_1_wvalid,    
  error_log_wready       => error_log4_1_wready,    
  error_log_bresp        => error_log4_1_bresp ,    			
  error_log_bvalid       => error_log4_1_bvalid,    				
  error_log_bready       => error_log4_1_bready,    				
  error_log_araddr       => error_log4_1_araddr,    			
  error_log_arvalid      => error_log4_1_arvalid,    			
  error_log_arready      => error_log4_1_arready,    			
  error_log_arprot       => error_log4_1_arprot,    
  error_log_rdata        => error_log4_1_rdata,    	
  error_log_rresp        => error_log4_1_rresp,    	
  error_log_rvalid       => error_log4_1_rvalid,				
  error_log_rready       => error_log4_1_rready,
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset(9),
  mem_reset              => mem_reset(9),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => local_cattrip,
  temp                   => local_temp   
  );

u10_ch5_0 : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  EMIF_DATA_WIDTH        => EMIF_DATA_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl5_0_awaddr, 
  test_ctrl_awvalid      => test_ctrl5_0_awvalid, 
  test_ctrl_awready      => test_ctrl5_0_awready, 
  test_ctrl_awprot       => test_ctrl5_0_awprot, 
  test_ctrl_wdata        => test_ctrl5_0_wdata, 
  test_ctrl_wstrb        => test_ctrl5_0_wstrb, 
  test_ctrl_wvalid       => test_ctrl5_0_wvalid, 
  test_ctrl_wready       => test_ctrl5_0_wready, 
  test_ctrl_bresp        => test_ctrl5_0_bresp, 			
  test_ctrl_bvalid       => test_ctrl5_0_bvalid, 				
  test_ctrl_bready       => test_ctrl5_0_bready, 				
  test_ctrl_araddr       => test_ctrl5_0_araddr, 			
  test_ctrl_arvalid      => test_ctrl5_0_arvalid, 			
  test_ctrl_arready      => test_ctrl5_0_arready, 			
  test_ctrl_arprot       => test_ctrl5_0_arprot, 
  test_ctrl_rdata        => test_ctrl5_0_rdata, 	
  test_ctrl_rresp        => test_ctrl5_0_rresp, 	
  test_ctrl_rvalid       => test_ctrl5_0_rvalid, 		
  test_ctrl_rready       => test_ctrl5_0_rready, 
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log5_0_awaddr,    
  error_log_awvalid      => error_log5_0_awvalid,    
  error_log_awready      => error_log5_0_awready,    
  error_log_awprot       => error_log5_0_awprot,    
  error_log_wdata        => error_log5_0_wdata,    
  error_log_wstrb        => error_log5_0_wstrb,    
  error_log_wvalid       => error_log5_0_wvalid,    
  error_log_wready       => error_log5_0_wready,    
  error_log_bresp        => error_log5_0_bresp ,    			
  error_log_bvalid       => error_log5_0_bvalid,    				
  error_log_bready       => error_log5_0_bready,    				
  error_log_araddr       => error_log5_0_araddr,    			
  error_log_arvalid      => error_log5_0_arvalid,    			
  error_log_arready      => error_log5_0_arready,    			
  error_log_arprot       => error_log5_0_arprot,    
  error_log_rdata        => error_log5_0_rdata,    	
  error_log_rresp        => error_log5_0_rresp,    	
  error_log_rvalid       => error_log5_0_rvalid,				
  error_log_rready       => error_log5_0_rready,
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset(10),
  mem_reset              => mem_reset(10),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => local_cattrip,
  temp                   => local_temp   
  );

u11_ch5_1 : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  EMIF_DATA_WIDTH        => EMIF_DATA_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl5_1_awaddr, 
  test_ctrl_awvalid      => test_ctrl5_1_awvalid, 
  test_ctrl_awready      => test_ctrl5_1_awready, 
  test_ctrl_awprot       => test_ctrl5_1_awprot, 
  test_ctrl_wdata        => test_ctrl5_1_wdata, 
  test_ctrl_wstrb        => test_ctrl5_1_wstrb, 
  test_ctrl_wvalid       => test_ctrl5_1_wvalid, 
  test_ctrl_wready       => test_ctrl5_1_wready, 
  test_ctrl_bresp        => test_ctrl5_1_bresp, 			
  test_ctrl_bvalid       => test_ctrl5_1_bvalid, 				
  test_ctrl_bready       => test_ctrl5_1_bready, 				
  test_ctrl_araddr       => test_ctrl5_1_araddr, 			
  test_ctrl_arvalid      => test_ctrl5_1_arvalid, 			
  test_ctrl_arready      => test_ctrl5_1_arready, 			
  test_ctrl_arprot       => test_ctrl5_1_arprot, 
  test_ctrl_rdata        => test_ctrl5_1_rdata, 	
  test_ctrl_rresp        => test_ctrl5_1_rresp, 	
  test_ctrl_rvalid       => test_ctrl5_1_rvalid, 		
  test_ctrl_rready       => test_ctrl5_1_rready, 
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log5_1_awaddr,    
  error_log_awvalid      => error_log5_1_awvalid,    
  error_log_awready      => error_log5_1_awready,    
  error_log_awprot       => error_log5_1_awprot,    
  error_log_wdata        => error_log5_1_wdata,    
  error_log_wstrb        => error_log5_1_wstrb,    
  error_log_wvalid       => error_log5_1_wvalid,    
  error_log_wready       => error_log5_1_wready,    
  error_log_bresp        => error_log5_1_bresp ,    			
  error_log_bvalid       => error_log5_1_bvalid,    				
  error_log_bready       => error_log5_1_bready,    				
  error_log_araddr       => error_log5_1_araddr,    			
  error_log_arvalid      => error_log5_1_arvalid,    			
  error_log_arready      => error_log5_1_arready,    			
  error_log_arprot       => error_log5_1_arprot,    
  error_log_rdata        => error_log5_1_rdata,    	
  error_log_rresp        => error_log5_1_rresp,    	
  error_log_rvalid       => error_log5_1_rvalid,				
  error_log_rready       => error_log5_1_rready,
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset(11),
  mem_reset              => mem_reset(11),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => local_cattrip,
  temp                   => local_temp   
  );

u12_ch6_0 : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  EMIF_DATA_WIDTH        => EMIF_DATA_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl6_0_awaddr, 
  test_ctrl_awvalid      => test_ctrl6_0_awvalid, 
  test_ctrl_awready      => test_ctrl6_0_awready, 
  test_ctrl_awprot       => test_ctrl6_0_awprot, 
  test_ctrl_wdata        => test_ctrl6_0_wdata, 
  test_ctrl_wstrb        => test_ctrl6_0_wstrb, 
  test_ctrl_wvalid       => test_ctrl6_0_wvalid, 
  test_ctrl_wready       => test_ctrl6_0_wready, 
  test_ctrl_bresp        => test_ctrl6_0_bresp, 			
  test_ctrl_bvalid       => test_ctrl6_0_bvalid, 				
  test_ctrl_bready       => test_ctrl6_0_bready, 				
  test_ctrl_araddr       => test_ctrl6_0_araddr, 			
  test_ctrl_arvalid      => test_ctrl6_0_arvalid, 			
  test_ctrl_arready      => test_ctrl6_0_arready, 			
  test_ctrl_arprot       => test_ctrl6_0_arprot, 
  test_ctrl_rdata        => test_ctrl6_0_rdata, 	
  test_ctrl_rresp        => test_ctrl6_0_rresp, 	
  test_ctrl_rvalid       => test_ctrl6_0_rvalid, 		
  test_ctrl_rready       => test_ctrl6_0_rready, 
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log6_0_awaddr,    
  error_log_awvalid      => error_log6_0_awvalid,    
  error_log_awready      => error_log6_0_awready,    
  error_log_awprot       => error_log6_0_awprot,    
  error_log_wdata        => error_log6_0_wdata,    
  error_log_wstrb        => error_log6_0_wstrb,    
  error_log_wvalid       => error_log6_0_wvalid,    
  error_log_wready       => error_log6_0_wready,    
  error_log_bresp        => error_log6_0_bresp ,    			
  error_log_bvalid       => error_log6_0_bvalid,    				
  error_log_bready       => error_log6_0_bready,    				
  error_log_araddr       => error_log6_0_araddr,    			
  error_log_arvalid      => error_log6_0_arvalid,    			
  error_log_arready      => error_log6_0_arready,    			
  error_log_arprot       => error_log6_0_arprot,    
  error_log_rdata        => error_log6_0_rdata,    	
  error_log_rresp        => error_log6_0_rresp,    	
  error_log_rvalid       => error_log6_0_rvalid,				
  error_log_rready       => error_log6_0_rready,
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset(12),
  mem_reset              => mem_reset(12),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => local_cattrip,
  temp                   => local_temp   
  );

u13_ch6_1 : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  EMIF_DATA_WIDTH        => EMIF_DATA_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl6_1_awaddr, 
  test_ctrl_awvalid      => test_ctrl6_1_awvalid, 
  test_ctrl_awready      => test_ctrl6_1_awready, 
  test_ctrl_awprot       => test_ctrl6_1_awprot, 
  test_ctrl_wdata        => test_ctrl6_1_wdata, 
  test_ctrl_wstrb        => test_ctrl6_1_wstrb, 
  test_ctrl_wvalid       => test_ctrl6_1_wvalid, 
  test_ctrl_wready       => test_ctrl6_1_wready, 
  test_ctrl_bresp        => test_ctrl6_1_bresp, 			
  test_ctrl_bvalid       => test_ctrl6_1_bvalid, 				
  test_ctrl_bready       => test_ctrl6_1_bready, 				
  test_ctrl_araddr       => test_ctrl6_1_araddr, 			
  test_ctrl_arvalid      => test_ctrl6_1_arvalid, 			
  test_ctrl_arready      => test_ctrl6_1_arready, 			
  test_ctrl_arprot       => test_ctrl6_1_arprot, 
  test_ctrl_rdata        => test_ctrl6_1_rdata, 	
  test_ctrl_rresp        => test_ctrl6_1_rresp, 	
  test_ctrl_rvalid       => test_ctrl6_1_rvalid, 		
  test_ctrl_rready       => test_ctrl6_1_rready, 
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log6_1_awaddr,    
  error_log_awvalid      => error_log6_1_awvalid,    
  error_log_awready      => error_log6_1_awready,    
  error_log_awprot       => error_log6_1_awprot,    
  error_log_wdata        => error_log6_1_wdata,    
  error_log_wstrb        => error_log6_1_wstrb,    
  error_log_wvalid       => error_log6_1_wvalid,    
  error_log_wready       => error_log6_1_wready,    
  error_log_bresp        => error_log6_1_bresp ,    			
  error_log_bvalid       => error_log6_1_bvalid,    				
  error_log_bready       => error_log6_1_bready,    				
  error_log_araddr       => error_log6_1_araddr,    			
  error_log_arvalid      => error_log6_1_arvalid,    			
  error_log_arready      => error_log6_1_arready,    			
  error_log_arprot       => error_log6_1_arprot,    
  error_log_rdata        => error_log6_1_rdata,    	
  error_log_rresp        => error_log6_1_rresp,    	
  error_log_rvalid       => error_log6_1_rvalid,				
  error_log_rready       => error_log6_1_rready,
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset(13),
  mem_reset              => mem_reset(13),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => local_cattrip,
  temp                   => local_temp   
  );

u14_ch7_0 : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  EMIF_DATA_WIDTH        => EMIF_DATA_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl7_0_awaddr, 
  test_ctrl_awvalid      => test_ctrl7_0_awvalid, 
  test_ctrl_awready      => test_ctrl7_0_awready, 
  test_ctrl_awprot       => test_ctrl7_0_awprot, 
  test_ctrl_wdata        => test_ctrl7_0_wdata, 
  test_ctrl_wstrb        => test_ctrl7_0_wstrb, 
  test_ctrl_wvalid       => test_ctrl7_0_wvalid, 
  test_ctrl_wready       => test_ctrl7_0_wready, 
  test_ctrl_bresp        => test_ctrl7_0_bresp, 			
  test_ctrl_bvalid       => test_ctrl7_0_bvalid, 				
  test_ctrl_bready       => test_ctrl7_0_bready, 				
  test_ctrl_araddr       => test_ctrl7_0_araddr, 			
  test_ctrl_arvalid      => test_ctrl7_0_arvalid, 			
  test_ctrl_arready      => test_ctrl7_0_arready, 			
  test_ctrl_arprot       => test_ctrl7_0_arprot, 
  test_ctrl_rdata        => test_ctrl7_0_rdata, 	
  test_ctrl_rresp        => test_ctrl7_0_rresp, 	
  test_ctrl_rvalid       => test_ctrl7_0_rvalid, 		
  test_ctrl_rready       => test_ctrl7_0_rready, 
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log7_0_awaddr,    
  error_log_awvalid      => error_log7_0_awvalid,    
  error_log_awready      => error_log7_0_awready,    
  error_log_awprot       => error_log7_0_awprot,    
  error_log_wdata        => error_log7_0_wdata,    
  error_log_wstrb        => error_log7_0_wstrb,    
  error_log_wvalid       => error_log7_0_wvalid,    
  error_log_wready       => error_log7_0_wready,    
  error_log_bresp        => error_log7_0_bresp ,    			
  error_log_bvalid       => error_log7_0_bvalid,    				
  error_log_bready       => error_log7_0_bready,    				
  error_log_araddr       => error_log7_0_araddr,    			
  error_log_arvalid      => error_log7_0_arvalid,    			
  error_log_arready      => error_log7_0_arready,    			
  error_log_arprot       => error_log7_0_arprot,    
  error_log_rdata        => error_log7_0_rdata,    	
  error_log_rresp        => error_log7_0_rresp,    	
  error_log_rvalid       => error_log7_0_rvalid,				
  error_log_rready       => error_log7_0_rready,
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset(14),
  mem_reset              => mem_reset(14),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => local_cattrip,
  temp                   => local_temp   
  );

u15_ch7_1 : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  EMIF_DATA_WIDTH        => EMIF_DATA_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl7_1_awaddr, 
  test_ctrl_awvalid      => test_ctrl7_1_awvalid, 
  test_ctrl_awready      => test_ctrl7_1_awready, 
  test_ctrl_awprot       => test_ctrl7_1_awprot, 
  test_ctrl_wdata        => test_ctrl7_1_wdata, 
  test_ctrl_wstrb        => test_ctrl7_1_wstrb, 
  test_ctrl_wvalid       => test_ctrl7_1_wvalid, 
  test_ctrl_wready       => test_ctrl7_1_wready, 
  test_ctrl_bresp        => test_ctrl7_1_bresp, 			
  test_ctrl_bvalid       => test_ctrl7_1_bvalid, 				
  test_ctrl_bready       => test_ctrl7_1_bready, 				
  test_ctrl_araddr       => test_ctrl7_1_araddr, 			
  test_ctrl_arvalid      => test_ctrl7_1_arvalid, 			
  test_ctrl_arready      => test_ctrl7_1_arready, 			
  test_ctrl_arprot       => test_ctrl7_1_arprot, 
  test_ctrl_rdata        => test_ctrl7_1_rdata, 	
  test_ctrl_rresp        => test_ctrl7_1_rresp, 	
  test_ctrl_rvalid       => test_ctrl7_1_rvalid, 		
  test_ctrl_rready       => test_ctrl7_1_rready, 
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log7_1_awaddr,    
  error_log_awvalid      => error_log7_1_awvalid,    
  error_log_awready      => error_log7_1_awready,    
  error_log_awprot       => error_log7_1_awprot,    
  error_log_wdata        => error_log7_1_wdata,    
  error_log_wstrb        => error_log7_1_wstrb,    
  error_log_wvalid       => error_log7_1_wvalid,    
  error_log_wready       => error_log7_1_wready,    
  error_log_bresp        => error_log7_1_bresp ,    			
  error_log_bvalid       => error_log7_1_bvalid,    				
  error_log_bready       => error_log7_1_bready,    				
  error_log_araddr       => error_log7_1_araddr,    			
  error_log_arvalid      => error_log7_1_arvalid,    			
  error_log_arready      => error_log7_1_arready,    			
  error_log_arprot       => error_log7_1_arprot,    
  error_log_rdata        => error_log7_1_rdata,    	
  error_log_rresp        => error_log7_1_rresp,    	
  error_log_rvalid       => error_log7_1_rvalid,				
  error_log_rready       => error_log7_1_rready,
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset(15),
  mem_reset              => mem_reset(15),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => local_cattrip,
  temp                   => local_temp   
  );

end rtl;