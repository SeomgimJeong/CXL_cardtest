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
-- Title       : Memory Test NoC Initator Wrapper
-- Project     : Memory Test with NoC
--------------------------------------------------------------------------------
-- Description : More dedicated memory test for NoC.
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

entity mem_test_initiator_wrapper is
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
  mem_usr_clk            : in   std_logic;
  mem_usr_reset          : in   std_logic;
  initiator_clk          : in   std_logic;
  mem_reset              : out  std_logic;
  mem_reset_status       : in   std_logic;
  calibration_success    : in   std_logic;
  calibration_fail       : in   std_logic;
  cattrip                : in   std_logic;
  temp                   : in   std_logic_vector(2 downto 0)
  );
end entity mem_test_initiator_wrapper;

architecture rtl of mem_test_initiator_wrapper is

-- A function to calculate the parity (if there are parity bits)
function get_parity (data_width : integer) return integer is

  variable remainder : integer;
  
begin

  if data_width < 64 then
    remainder := data_width-32;
  elsif data_width < 128 then
    remainder := data_width-64;
  elsif data_width < 256 then
    remainder := data_width-128;
  elsif data_width < 512 then
    remainder := data_width-256;
  else
    remainder := data_width-512;
  end if;
  
  return remainder;
  
end get_parity;

-- A function to calculate the parity (if there are parity bits)
function get_user_width (data_width : integer) return integer is

  variable user_width : integer;
  
begin

  if data_width = 256 then
    user_width := 32;
  elsif data_width = 288 then
    user_width := 32;
  elsif data_width = 512 then
    user_width := 64;
  else
    user_width := 64;
  end if;
  
  return user_width;
  
end get_user_width;

component mem_test_initiator_256
port (
  s0_axi4_arid          : in  std_logic_vector(6 downto 0);   
  s0_axi4_araddr        : in  std_logic_vector(43 downto 0);  
  s0_axi4_arlen         : in  std_logic_vector(7 downto 0);   
  s0_axi4_arsize        : in  std_logic_vector(2 downto 0);   
  s0_axi4_arburst       : in  std_logic_vector(1 downto 0);   
  s0_axi4_arlock        : in  std_logic; 
  s0_axi4_arprot        : in  std_logic_vector(2 downto 0);   
  s0_axi4_arqos         : in  std_logic_vector(3 downto 0);   
  s0_axi4_aruser        : in  std_logic_vector(10 downto 0);  
  s0_axi4_arvalid       : in  std_logic;                   
  s0_axi4_arready       : out std_logic;                   
  s0_axi4_rid           : out std_logic_vector(6 downto 0);   
  s0_axi4_rdata         : out std_logic_vector(255 downto 0); 
  s0_axi4_rresp         : out std_logic_vector(1 downto 0);   
  s0_axi4_rlast         : out std_logic;                   
  s0_axi4_ruser         : out std_logic_vector(31 downto 0);  
  s0_axi4_rvalid        : out std_logic;                    
  s0_axi4_rready        : in  std_logic;                    
  s0_axi4_awid          : in  std_logic_vector(6 downto 0);   
  s0_axi4_awaddr        : in  std_logic_vector(43 downto 0);  
  s0_axi4_awlen         : in  std_logic_vector(7 downto 0);   
  s0_axi4_awsize        : in  std_logic_vector(2 downto 0);   
  s0_axi4_awburst       : in  std_logic_vector(1 downto 0);   
  s0_axi4_awlock        : in  std_logic;                   
  s0_axi4_awprot        : in  std_logic_vector(2 downto 0);   
  s0_axi4_awqos         : in  std_logic_vector(3 downto 0);   
  s0_axi4_awuser        : in  std_logic_vector(10 downto 0);  
  s0_axi4_awvalid       : in  std_logic;                    
  s0_axi4_awready       : out std_logic;                    
  s0_axi4_wdata         : in  std_logic_vector(255 downto 0); 
  s0_axi4_wstrb         : in  std_logic_vector(31 downto 0);  
  s0_axi4_wlast         : in  std_logic;                   
  s0_axi4_wuser         : in  std_logic_vector(31 downto 0);  
  s0_axi4_wvalid        : in  std_logic;                    
  s0_axi4_wready        : out std_logic;                    
  s0_axi4_bid           : out std_logic_vector(6 downto 0);   
  s0_axi4_bresp         : out std_logic_vector(1 downto 0);   
  s0_axi4_bvalid        : out std_logic;       
  s0_axi4_bready        : in  std_logic;       
  s0_axi4_aclk          : in  std_logic;       
  s0_axi4_aresetn       : in  std_logic        
  );
end component;

component mem_test_initiator_288
port (
  s0_axi4_arid          : in  std_logic_vector(6 downto 0);   
  s0_axi4_araddr        : in  std_logic_vector(43 downto 0);  
  s0_axi4_arlen         : in  std_logic_vector(7 downto 0);   
  s0_axi4_arsize        : in  std_logic_vector(2 downto 0);   
  s0_axi4_arburst       : in  std_logic_vector(1 downto 0);   
  s0_axi4_arlock        : in  std_logic; 
  s0_axi4_arprot        : in  std_logic_vector(2 downto 0);   
  s0_axi4_arqos         : in  std_logic_vector(3 downto 0);   
  s0_axi4_aruser        : in  std_logic_vector(10 downto 0);  
  s0_axi4_arvalid       : in  std_logic;                   
  s0_axi4_arready       : out std_logic;                   
  s0_axi4_rid           : out std_logic_vector(6 downto 0);   
  s0_axi4_rdata         : out std_logic_vector(255 downto 0); 
  s0_axi4_rresp         : out std_logic_vector(1 downto 0);   
  s0_axi4_rlast         : out std_logic;                   
  s0_axi4_ruser         : out std_logic_vector(31 downto 0);  
  s0_axi4_rvalid        : out std_logic;                    
  s0_axi4_rready        : in  std_logic;                    
  s0_axi4_awid          : in  std_logic_vector(6 downto 0);   
  s0_axi4_awaddr        : in  std_logic_vector(43 downto 0);  
  s0_axi4_awlen         : in  std_logic_vector(7 downto 0);   
  s0_axi4_awsize        : in  std_logic_vector(2 downto 0);   
  s0_axi4_awburst       : in  std_logic_vector(1 downto 0);   
  s0_axi4_awlock        : in  std_logic;                   
  s0_axi4_awprot        : in  std_logic_vector(2 downto 0);   
  s0_axi4_awqos         : in  std_logic_vector(3 downto 0);   
  s0_axi4_awuser        : in  std_logic_vector(10 downto 0);  
  s0_axi4_awvalid       : in  std_logic;                    
  s0_axi4_awready       : out std_logic;                    
  s0_axi4_wdata         : in  std_logic_vector(255 downto 0); 
  s0_axi4_wstrb         : in  std_logic_vector(31 downto 0);  
  s0_axi4_wlast         : in  std_logic;                   
  s0_axi4_wuser         : in  std_logic_vector(31 downto 0);  
  s0_axi4_wvalid        : in  std_logic;                    
  s0_axi4_wready        : out std_logic;                    
  s0_axi4_bid           : out std_logic_vector(6 downto 0);   
  s0_axi4_bresp         : out std_logic_vector(1 downto 0);   
  s0_axi4_bvalid        : out std_logic;       
  s0_axi4_bready        : in  std_logic;       
  s0_axi4_aclk          : in  std_logic;       
  s0_axi4_aresetn       : in  std_logic        
  );
end component;

component mem_test_initiator_512
port (
  s0_axi4_arid          : in  std_logic_vector(6 downto 0);   
  s0_axi4_araddr        : in  std_logic_vector(43 downto 0);  
  s0_axi4_arlen         : in  std_logic_vector(7 downto 0);   
  s0_axi4_arsize        : in  std_logic_vector(2 downto 0);   
  s0_axi4_arburst       : in  std_logic_vector(1 downto 0);   
  s0_axi4_arlock        : in  std_logic; 
  s0_axi4_arprot        : in  std_logic_vector(2 downto 0);   
  s0_axi4_arqos         : in  std_logic_vector(3 downto 0);   
  s0_axi4_aruser        : in  std_logic_vector(10 downto 0);  
  s0_axi4_arvalid       : in  std_logic;                   
  s0_axi4_arready       : out std_logic;                   
  s0_axi4_rid           : out std_logic_vector(6 downto 0);   
  s0_axi4_rdata         : out std_logic_vector(511 downto 0); 
  s0_axi4_rresp         : out std_logic_vector(1 downto 0);   
  s0_axi4_rlast         : out std_logic;                   
  s0_axi4_ruser         : out std_logic_vector(63 downto 0);  
  s0_axi4_rvalid        : out std_logic;                    
  s0_axi4_rready        : in  std_logic;                    
  s0_axi4_awid          : in  std_logic_vector(6 downto 0);   
  s0_axi4_awaddr        : in  std_logic_vector(43 downto 0);  
  s0_axi4_awlen         : in  std_logic_vector(7 downto 0);   
  s0_axi4_awsize        : in  std_logic_vector(2 downto 0);   
  s0_axi4_awburst       : in  std_logic_vector(1 downto 0);   
  s0_axi4_awlock        : in  std_logic;                   
  s0_axi4_awprot        : in  std_logic_vector(2 downto 0);   
  s0_axi4_awqos         : in  std_logic_vector(3 downto 0);   
  s0_axi4_awuser        : in  std_logic_vector(10 downto 0);  
  s0_axi4_awvalid       : in  std_logic;                    
  s0_axi4_awready       : out std_logic;                    
  s0_axi4_wdata         : in  std_logic_vector(511 downto 0); 
  s0_axi4_wstrb         : in  std_logic_vector(63 downto 0);  
  s0_axi4_wlast         : in  std_logic;                   
  s0_axi4_wuser         : in  std_logic_vector(63 downto 0);  
  s0_axi4_wvalid        : in  std_logic;                    
  s0_axi4_wready        : out std_logic;                    
  s0_axi4_bid           : out std_logic_vector(6 downto 0);   
  s0_axi4_bresp         : out std_logic_vector(1 downto 0);   
  s0_axi4_bvalid        : out std_logic;       
  s0_axi4_bready        : in  std_logic;  
  noc_bridge_fabric_clk : in  std_logic;  
  s0_axi4_aclk          : in  std_logic;       
  s0_axi4_aresetn       : in  std_logic        
  );
end component;

component mem_test_initiator_576
port (
  s0_axi4_arid          : in  std_logic_vector(6 downto 0);   
  s0_axi4_araddr        : in  std_logic_vector(43 downto 0);  
  s0_axi4_arlen         : in  std_logic_vector(7 downto 0);   
  s0_axi4_arsize        : in  std_logic_vector(2 downto 0);   
  s0_axi4_arburst       : in  std_logic_vector(1 downto 0);   
  s0_axi4_arlock        : in  std_logic; 
  s0_axi4_arprot        : in  std_logic_vector(2 downto 0);   
  s0_axi4_arqos         : in  std_logic_vector(3 downto 0);   
  s0_axi4_aruser        : in  std_logic_vector(10 downto 0);  
  s0_axi4_arvalid       : in  std_logic;                   
  s0_axi4_arready       : out std_logic;                   
  s0_axi4_rid           : out std_logic_vector(6 downto 0);   
  s0_axi4_rdata         : out std_logic_vector(511 downto 0); 
  s0_axi4_rresp         : out std_logic_vector(1 downto 0);   
  s0_axi4_rlast         : out std_logic;                   
  s0_axi4_ruser         : out std_logic_vector(63 downto 0);  
  s0_axi4_rvalid        : out std_logic;                    
  s0_axi4_rready        : in  std_logic;                    
  s0_axi4_awid          : in  std_logic_vector(6 downto 0);   
  s0_axi4_awaddr        : in  std_logic_vector(43 downto 0);  
  s0_axi4_awlen         : in  std_logic_vector(7 downto 0);   
  s0_axi4_awsize        : in  std_logic_vector(2 downto 0);   
  s0_axi4_awburst       : in  std_logic_vector(1 downto 0);   
  s0_axi4_awlock        : in  std_logic;                   
  s0_axi4_awprot        : in  std_logic_vector(2 downto 0);   
  s0_axi4_awqos         : in  std_logic_vector(3 downto 0);   
  s0_axi4_awuser        : in  std_logic_vector(10 downto 0);  
  s0_axi4_awvalid       : in  std_logic;                    
  s0_axi4_awready       : out std_logic;                    
  s0_axi4_wdata         : in  std_logic_vector(511 downto 0); 
  s0_axi4_wstrb         : in  std_logic_vector(63 downto 0);  
  s0_axi4_wlast         : in  std_logic;                   
  s0_axi4_wuser         : in  std_logic_vector(63 downto 0);  
  s0_axi4_wvalid        : in  std_logic;                    
  s0_axi4_wready        : out std_logic;                    
  s0_axi4_bid           : out std_logic_vector(6 downto 0);   
  s0_axi4_bresp         : out std_logic_vector(1 downto 0);   
  s0_axi4_bvalid        : out std_logic;       
  s0_axi4_bready        : in  std_logic;       
  noc_bridge_fabric_clk : in  std_logic;  
  s0_axi4_aclk          : in  std_logic;       
  s0_axi4_aresetn       : in  std_logic       
  );
end component;

component mem_test
generic (
  TEST_CTRL_CLK_PERIOD   :      integer := 10;
  ADDR_WIDTH             :      integer := 32;
  MEM_DATA_WIDTH         :      integer := 64;
  MEM_PARITY_WIDTH       :      integer := 8;
  EMIF_DATA_WIDTH        :      integer := 512;
  EMIF_PARITY_WIDTH      :      integer := 64;
  AXI_WUSER_WIDTH        :      integer := 64;
  AXI_RUSER_WIDTH        :      integer := 64;
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
  mem_usr_clk            : in   std_logic;
  mem_usr_reset          : in   std_logic;
  mem_reset              : out  std_logic;
  mem_reset_status       : in   std_logic;
  calibration_success    : in   std_logic;
  calibration_fail       : in   std_logic;
  cattrip                : in   std_logic;
  temp                   : in   std_logic_vector(2 downto 0);
  initiator_reset        : out  std_logic;
  mem_axi_aclk           : in   std_logic;
  mem_axi_areset         : in   std_logic;
  mem_axi_awready        : in   std_logic;
  mem_axi_awvalid        : out  std_logic;
  mem_axi_awid           : out  std_logic_vector(6 downto 0);
  mem_axi_awaddr         : out  std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_axi_awlen          : out  std_logic_vector(7 downto 0);
  mem_axi_awsize         : out  std_logic_vector(2 downto 0);
  mem_axi_awburst        : out  std_logic_vector(1 downto 0);
  mem_axi_awlock         : out  std_logic_vector(0 downto 0);
  mem_axi_awprot         : out  std_logic_vector(2 downto 0);
  mem_axi_awqos          : out  std_logic_vector(3 downto 0);
  mem_axi_awuser         : out  std_logic_vector(10 downto 0);
  mem_axi_arready        : in   std_logic;
  mem_axi_arvalid        : out  std_logic;
  mem_axi_arid           : out  std_logic_vector(6 downto 0);
  mem_axi_araddr         : out  std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_axi_arlen          : out  std_logic_vector(7 downto 0);
  mem_axi_arsize         : out  std_logic_vector(2 downto 0);
  mem_axi_arburst        : out  std_logic_vector(1 downto 0);
  mem_axi_arlock         : out  std_logic_vector(0 downto 0);
  mem_axi_arprot         : out  std_logic_vector(2 downto 0);
  mem_axi_arqos          : out  std_logic_vector(3 downto 0);
  mem_axi_aruser         : out  std_logic_vector(10 downto 0);
  mem_axi_wready         : in   std_logic;
  mem_axi_wvalid         : out  std_logic;
  mem_axi_wdata          : out  std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
  mem_axi_wuser          : out  std_logic_vector((AXI_WUSER_WIDTH-1) downto 0);
  mem_axi_wstrb          : out  std_logic_vector(((EMIF_DATA_WIDTH/8)-1) downto 0);
  mem_axi_wlast          : out  std_logic;
  mem_axi_bready         : out  std_logic;
  mem_axi_bvalid         : in   std_logic;
  mem_axi_bid            : in   std_logic_vector(6 downto 0);
  mem_axi_bresp          : in   std_logic_vector(1 downto 0);
  mem_axi_rready         : out  std_logic;
  mem_axi_rvalid         : in   std_logic;
  mem_axi_rid            : in   std_logic_vector(6 downto 0);
  mem_axi_rdata          : in   std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
  mem_axi_ruser          : in   std_logic_vector((AXI_RUSER_WIDTH-1) downto 0);
  mem_axi_rresp          : in   std_logic_vector(1 downto 0);
  mem_axi_rlast          : in   std_logic
  );
end component;

constant IF_PARITY_WIDTH            : integer := get_parity(EMIF_DATA_WIDTH); 
constant IF_DATA_WIDTH              : integer := EMIF_DATA_WIDTH-IF_PARITY_WIDTH;

constant M_PARITY_WIDTH             : integer := get_parity(MEM_DATA_WIDTH);
constant M_DATA_WIDTH               : integer := MEM_DATA_WIDTH-M_PARITY_WIDTH;

constant AXI_WUSER_WIDTH            : integer := get_user_width(EMIF_DATA_WIDTH);
constant AXI_RUSER_WIDTH            : integer := get_user_width(EMIF_DATA_WIDTH);

signal noc_axi_aclk                 : std_logic;
signal noc_axi_areset               : std_logic;
signal noc_axi_awready              : std_logic;
signal noc_axi_awvalid              : std_logic;
signal noc_axi_awid                 : std_logic_vector(6 downto 0);
signal noc_axi_awaddr               : std_logic_vector(43 downto 0);
signal noc_axi_awaddr_i             : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal noc_axi_awlen                : std_logic_vector(7 downto 0);
signal noc_axi_awsize               : std_logic_vector(2 downto 0);
signal noc_axi_awburst              : std_logic_vector(1 downto 0);
signal noc_axi_awlock               : std_logic_vector(0 downto 0);
signal noc_axi_awprot               : std_logic_vector(2 downto 0);
signal noc_axi_awqos                : std_logic_vector(3 downto 0);
signal noc_axi_awuser               : std_logic_vector(10 downto 0);
signal noc_axi_arready              : std_logic;
signal noc_axi_arvalid              : std_logic;
signal noc_axi_arid                 : std_logic_vector(6 downto 0);
signal noc_axi_araddr               : std_logic_vector(43 downto 0);
signal noc_axi_araddr_i             : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal noc_axi_arlen                : std_logic_vector(7 downto 0);
signal noc_axi_arsize               : std_logic_vector(2 downto 0);
signal noc_axi_arburst              : std_logic_vector(1 downto 0);
signal noc_axi_arlock               : std_logic_vector(0 downto 0);
signal noc_axi_arprot               : std_logic_vector(2 downto 0);
signal noc_axi_arqos                : std_logic_vector(3 downto 0);
signal noc_axi_aruser               : std_logic_vector(10 downto 0);
signal noc_axi_wready               : std_logic;
signal noc_axi_wvalid               : std_logic;
signal noc_axi_wdata                : std_logic_vector((IF_DATA_WIDTH-1) downto 0);
signal noc_axi_wuser                : std_logic_vector((AXI_WUSER_WIDTH-1) downto 0);
signal noc_axi_wstrb                : std_logic_vector(((IF_DATA_WIDTH/8)-1) downto 0);
signal noc_axi_wlast                : std_logic;
signal noc_axi_bready               : std_logic;
signal noc_axi_bvalid               : std_logic;
signal noc_axi_bid                  : std_logic_vector(6 downto 0);
signal noc_axi_bresp                : std_logic_vector(1 downto 0);
signal noc_axi_rready               : std_logic;
signal noc_axi_rvalid               : std_logic;
signal noc_axi_rid                  : std_logic_vector(6 downto 0);
signal noc_axi_rdata                : std_logic_vector((IF_DATA_WIDTH-1) downto 0);
signal noc_axi_ruser                : std_logic_vector((AXI_RUSER_WIDTH-1) downto 0);
signal noc_axi_rresp                : std_logic_vector(1 downto 0);
signal noc_axi_rlast                : std_logic;

signal mem_usr_reset_n              : std_logic;

signal initiator_reset              : std_logic;
signal initiator_reset_n            : std_logic;

begin

mem_usr_reset_n <= not(mem_usr_reset);
initiator_reset_n <= not(initiator_reset);

u0_main_test : mem_test
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => ADDR_WIDTH,
  MEM_DATA_WIDTH         => M_DATA_WIDTH,
  MEM_PARITY_WIDTH       => M_PARITY_WIDTH,
  EMIF_DATA_WIDTH        => IF_DATA_WIDTH,
  EMIF_PARITY_WIDTH      => IF_PARITY_WIDTH,
  AXI_WUSER_WIDTH        => AXI_WUSER_WIDTH,
  AXI_RUSER_WIDTH        => AXI_RUSER_WIDTH,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => test_ctrl_aclk,
  test_ctrl_areset       => test_ctrl_areset,
  test_ctrl_awaddr       => test_ctrl_awaddr,
  test_ctrl_awvalid      => test_ctrl_awvalid,
  test_ctrl_awready      => test_ctrl_awready,
  test_ctrl_awprot       => test_ctrl_awprot,
  test_ctrl_wdata        => test_ctrl_wdata,
  test_ctrl_wstrb        => test_ctrl_wstrb,
  test_ctrl_wvalid       => test_ctrl_wvalid,
  test_ctrl_wready       => test_ctrl_wready,
  test_ctrl_bresp        => test_ctrl_bresp ,		
  test_ctrl_bvalid       => test_ctrl_bvalid,			
  test_ctrl_bready       => test_ctrl_bready,			
  test_ctrl_araddr       => test_ctrl_araddr,		
  test_ctrl_arvalid      => test_ctrl_arvalid,		
  test_ctrl_arready      => test_ctrl_arready,		
  test_ctrl_arprot       => test_ctrl_arprot,
  test_ctrl_rdata        => test_ctrl_rdata,
  test_ctrl_rresp        => test_ctrl_rresp,
  test_ctrl_rvalid       => test_ctrl_rvalid,	
  test_ctrl_rready       => test_ctrl_rready,
  error_log_aclk         => error_log_aclk,
  error_log_areset       => error_log_areset,
  error_log_awaddr       => error_log_awaddr,
  error_log_awvalid      => error_log_awvalid,
  error_log_awready      => error_log_awready,
  error_log_awprot       => error_log_awprot,
  error_log_wdata        => error_log_wdata,
  error_log_wstrb        => error_log_wstrb,
  error_log_wvalid       => error_log_wvalid,
  error_log_wready       => error_log_wready,
  error_log_bresp        => error_log_bresp,		
  error_log_bvalid       => error_log_bvalid,			
  error_log_bready       => error_log_bready,			
  error_log_araddr       => error_log_araddr,		
  error_log_arvalid      => error_log_arvalid,		
  error_log_arready      => error_log_arready,		
  error_log_arprot       => error_log_arprot,
  error_log_rdata        => error_log_rdata,
  error_log_rresp        => error_log_rresp,
  error_log_rvalid       => error_log_rvalid,	
  error_log_rready       => error_log_rready,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset,
  mem_reset              => mem_reset,
  mem_reset_status       => mem_reset_status,
  calibration_success    => calibration_success,
  calibration_fail       => calibration_fail,
  cattrip                => cattrip,
  temp                   => temp,
  initiator_reset        => initiator_reset,
  mem_axi_aclk           => mem_usr_clk,
  mem_axi_areset         => initiator_reset,
  mem_axi_awready        => noc_axi_awready,
  mem_axi_awvalid        => noc_axi_awvalid,
  mem_axi_awid           => noc_axi_awid,
  mem_axi_awaddr         => noc_axi_awaddr_i,
  mem_axi_awlen          => noc_axi_awlen,
  mem_axi_awsize         => noc_axi_awsize,
  mem_axi_awburst        => noc_axi_awburst,
  mem_axi_awlock         => noc_axi_awlock,
  mem_axi_awprot         => noc_axi_awprot,
  mem_axi_awqos          => noc_axi_awqos,
  mem_axi_awuser         => noc_axi_awuser,
  mem_axi_arready        => noc_axi_arready,
  mem_axi_arvalid        => noc_axi_arvalid,
  mem_axi_arid           => noc_axi_arid,
  mem_axi_araddr         => noc_axi_araddr_i,
  mem_axi_arlen          => noc_axi_arlen,
  mem_axi_arsize         => noc_axi_arsize,
  mem_axi_arburst        => noc_axi_arburst,
  mem_axi_arlock         => noc_axi_arlock,
  mem_axi_arprot         => noc_axi_arprot,
  mem_axi_arqos          => noc_axi_arqos,
  mem_axi_aruser         => noc_axi_aruser,
  mem_axi_wready         => noc_axi_wready,
  mem_axi_wvalid         => noc_axi_wvalid,
  mem_axi_wdata          => noc_axi_wdata,
  mem_axi_wuser          => noc_axi_wuser,
  mem_axi_wstrb          => noc_axi_wstrb,
  mem_axi_wlast          => noc_axi_wlast,
  mem_axi_bready         => noc_axi_bready,
  mem_axi_bvalid         => noc_axi_bvalid,
  mem_axi_bid            => noc_axi_bid,
  mem_axi_bresp          => noc_axi_bresp,
  mem_axi_rready         => noc_axi_rready,
  mem_axi_rvalid         => noc_axi_rvalid,
  mem_axi_rid            => noc_axi_rid,
  mem_axi_rdata          => noc_axi_rdata,
  mem_axi_ruser          => noc_axi_ruser,
  mem_axi_rresp          => noc_axi_rresp,
  mem_axi_rlast          => noc_axi_rlast
  );


g0_axi_address_width_44 : if ADDR_WIDTH=44 generate

noc_axi_awaddr   <= noc_axi_awaddr_i;
noc_axi_araddr   <= noc_axi_araddr_i;

end generate g0_axi_address_width_44;

g0_axi_address_width_lt44 : if ADDR_WIDTH < 44 generate

noc_axi_awaddr(43 downto ADDR_WIDTH)  <= (others => '0');
noc_axi_awaddr(ADDR_WIDTH-1 downto 0) <= noc_axi_awaddr_i;

noc_axi_araddr(43 downto ADDR_WIDTH)  <= (others => '0');
noc_axi_araddr(ADDR_WIDTH-1 downto 0) <= noc_axi_araddr_i;

end generate g0_axi_address_width_lt44;

-----------------------------------------------
--
-- Generate Initator based on EMIF_DATA_WIDTH
--
-----------------------------------------------
g1_initiator256 : if EMIF_DATA_WIDTH=256 generate

u1_noc_initiator : mem_test_initiator_256
port map (
  s0_axi4_arid          => noc_axi_arid,			  
  s0_axi4_araddr        => noc_axi_araddr,			  
  s0_axi4_arlen         => noc_axi_arlen,			  
  s0_axi4_arsize        => noc_axi_arsize,			  
  s0_axi4_arburst       => noc_axi_arburst,			  
  s0_axi4_arlock        => noc_axi_arlock(0),			  
  s0_axi4_arprot        => noc_axi_arprot,			  
  s0_axi4_arqos         => noc_axi_arqos,			  
  s0_axi4_aruser        => noc_axi_aruser,			  
  s0_axi4_arvalid       => noc_axi_arvalid,			  
  s0_axi4_arready       => noc_axi_arready,			  
  s0_axi4_rid           => noc_axi_rid,			          
  s0_axi4_rdata         => noc_axi_rdata,			  
  s0_axi4_rresp         => noc_axi_rresp,			  
  s0_axi4_rlast         => noc_axi_rlast,			  
  s0_axi4_ruser         => noc_axi_ruser,			  
  s0_axi4_rvalid        => noc_axi_rvalid,			  
  s0_axi4_rready        => noc_axi_rready,			  
  s0_axi4_awid          => noc_axi_awid,			  
  s0_axi4_awaddr        => noc_axi_awaddr,			  
  s0_axi4_awlen         => noc_axi_awlen,			  
  s0_axi4_awsize        => noc_axi_awsize,			  
  s0_axi4_awburst       => noc_axi_awburst,			  
  s0_axi4_awlock        => noc_axi_awlock(0),			  
  s0_axi4_awprot        => noc_axi_awprot,			  
  s0_axi4_awqos         => noc_axi_awqos,			  
  s0_axi4_awuser        => noc_axi_awuser,			  
  s0_axi4_awvalid       => noc_axi_awvalid,			  
  s0_axi4_awready       => noc_axi_awready,			  
  s0_axi4_wdata         => noc_axi_wdata,			  
  s0_axi4_wstrb         => noc_axi_wstrb,			  
  s0_axi4_wlast         => noc_axi_wlast,			  
  s0_axi4_wuser         => noc_axi_wuser,			  
  s0_axi4_wvalid        => noc_axi_wvalid,			  
  s0_axi4_wready        => noc_axi_wready,			  
  s0_axi4_bid           => noc_axi_bid,			          
  s0_axi4_bresp         => noc_axi_bresp,			  
  s0_axi4_bvalid        => noc_axi_bvalid,			  
  s0_axi4_bready        => noc_axi_bready,			  
  s0_axi4_aclk          => mem_usr_clk,			           
  s0_axi4_aresetn       => initiator_reset_n			   
  );

end generate g1_initiator256;

g1_initiator288 : if EMIF_DATA_WIDTH=288 generate

u1_noc_initiator : mem_test_initiator_288
port map (
  s0_axi4_arid          => noc_axi_arid,			  
  s0_axi4_araddr        => noc_axi_araddr,			  
  s0_axi4_arlen         => noc_axi_arlen,			  
  s0_axi4_arsize        => noc_axi_arsize,			  
  s0_axi4_arburst       => noc_axi_arburst,			  
  s0_axi4_arlock        => noc_axi_arlock(0),			  
  s0_axi4_arprot        => noc_axi_arprot,			  
  s0_axi4_arqos         => noc_axi_arqos,			  
  s0_axi4_aruser        => noc_axi_aruser,			  
  s0_axi4_arvalid       => noc_axi_arvalid,			  
  s0_axi4_arready       => noc_axi_arready,			  
  s0_axi4_rid           => noc_axi_rid,			          
  s0_axi4_rdata         => noc_axi_rdata,			  
  s0_axi4_rresp         => noc_axi_rresp,			  
  s0_axi4_rlast         => noc_axi_rlast,			  
  s0_axi4_ruser         => noc_axi_ruser,			  
  s0_axi4_rvalid        => noc_axi_rvalid,			  
  s0_axi4_rready        => noc_axi_rready,			  
  s0_axi4_awid          => noc_axi_awid,			  
  s0_axi4_awaddr        => noc_axi_awaddr,			  
  s0_axi4_awlen         => noc_axi_awlen,			  
  s0_axi4_awsize        => noc_axi_awsize,			  
  s0_axi4_awburst       => noc_axi_awburst,			  
  s0_axi4_awlock        => noc_axi_awlock(0),			  
  s0_axi4_awprot        => noc_axi_awprot,			  
  s0_axi4_awqos         => noc_axi_awqos,			  
  s0_axi4_awuser        => noc_axi_awuser,			  
  s0_axi4_awvalid       => noc_axi_awvalid,			  
  s0_axi4_awready       => noc_axi_awready,			  
  s0_axi4_wdata         => noc_axi_wdata,			  
  s0_axi4_wstrb         => noc_axi_wstrb,			  
  s0_axi4_wlast         => noc_axi_wlast,			  
  s0_axi4_wuser         => noc_axi_wuser,			  
  s0_axi4_wvalid        => noc_axi_wvalid,			  
  s0_axi4_wready        => noc_axi_wready,			  
  s0_axi4_bid           => noc_axi_bid,			          
  s0_axi4_bresp         => noc_axi_bresp,			  
  s0_axi4_bvalid        => noc_axi_bvalid,			  
  s0_axi4_bready        => noc_axi_bready,			  
  s0_axi4_aclk          => mem_usr_clk,			           
  s0_axi4_aresetn       => initiator_reset_n			   
  );

end generate g1_initiator288;

g1_initiator512 : if EMIF_DATA_WIDTH=512 generate

u1_noc_initiator : mem_test_initiator_512
port map (
  s0_axi4_arid          => noc_axi_arid,			  
  s0_axi4_araddr        => noc_axi_araddr,			  
  s0_axi4_arlen         => noc_axi_arlen,			  
  s0_axi4_arsize        => noc_axi_arsize,			  
  s0_axi4_arburst       => noc_axi_arburst,			  
  s0_axi4_arlock        => noc_axi_arlock(0),			  
  s0_axi4_arprot        => noc_axi_arprot,			  
  s0_axi4_arqos         => noc_axi_arqos,			  
  s0_axi4_aruser        => noc_axi_aruser,			  
  s0_axi4_arvalid       => noc_axi_arvalid,			  
  s0_axi4_arready       => noc_axi_arready,			  
  s0_axi4_rid           => noc_axi_rid,			          
  s0_axi4_rdata         => noc_axi_rdata,			  
  s0_axi4_rresp         => noc_axi_rresp,			  
  s0_axi4_rlast         => noc_axi_rlast,			  
  s0_axi4_ruser         => noc_axi_ruser,			  
  s0_axi4_rvalid        => noc_axi_rvalid,			  
  s0_axi4_rready        => noc_axi_rready,			  
  s0_axi4_awid          => noc_axi_awid,			  
  s0_axi4_awaddr        => noc_axi_awaddr,			  
  s0_axi4_awlen         => noc_axi_awlen,			  
  s0_axi4_awsize        => noc_axi_awsize,			  
  s0_axi4_awburst       => noc_axi_awburst,			  
  s0_axi4_awlock        => noc_axi_awlock(0),			  
  s0_axi4_awprot        => noc_axi_awprot,			  
  s0_axi4_awqos         => noc_axi_awqos,			  
  s0_axi4_awuser        => noc_axi_awuser,			  
  s0_axi4_awvalid       => noc_axi_awvalid,			  
  s0_axi4_awready       => noc_axi_awready,			  
  s0_axi4_wdata         => noc_axi_wdata,			  
  s0_axi4_wstrb         => noc_axi_wstrb,			  
  s0_axi4_wlast         => noc_axi_wlast,			  
  s0_axi4_wuser         => noc_axi_wuser,			  
  s0_axi4_wvalid        => noc_axi_wvalid,			  
  s0_axi4_wready        => noc_axi_wready,			  
  s0_axi4_bid           => noc_axi_bid,			          
  s0_axi4_bresp         => noc_axi_bresp,			  
  s0_axi4_bvalid        => noc_axi_bvalid,			  
  s0_axi4_bready        => noc_axi_bready,	
  noc_bridge_fabric_clk => initiator_clk,  
  s0_axi4_aclk          => mem_usr_clk,			           
  s0_axi4_aresetn       => initiator_reset_n			   
  );

end generate g1_initiator512;

g1_initiator576 : if EMIF_DATA_WIDTH=576 generate

u1_noc_initiator : mem_test_initiator_576
port map (
  s0_axi4_arid          => noc_axi_arid,			  
  s0_axi4_araddr        => noc_axi_araddr,			  
  s0_axi4_arlen         => noc_axi_arlen,			  
  s0_axi4_arsize        => noc_axi_arsize,			  
  s0_axi4_arburst       => noc_axi_arburst,			  
  s0_axi4_arlock        => noc_axi_arlock(0),			  
  s0_axi4_arprot        => noc_axi_arprot,			  
  s0_axi4_arqos         => noc_axi_arqos,			  
  s0_axi4_aruser        => noc_axi_aruser,			  
  s0_axi4_arvalid       => noc_axi_arvalid,			  
  s0_axi4_arready       => noc_axi_arready,			  
  s0_axi4_rid           => noc_axi_rid,			          
  s0_axi4_rdata         => noc_axi_rdata,			  
  s0_axi4_rresp         => noc_axi_rresp,			  
  s0_axi4_rlast         => noc_axi_rlast,			  
  s0_axi4_ruser         => noc_axi_ruser,			  
  s0_axi4_rvalid        => noc_axi_rvalid,			  
  s0_axi4_rready        => noc_axi_rready,			  
  s0_axi4_awid          => noc_axi_awid,			  
  s0_axi4_awaddr        => noc_axi_awaddr,			  
  s0_axi4_awlen         => noc_axi_awlen,			  
  s0_axi4_awsize        => noc_axi_awsize,			  
  s0_axi4_awburst       => noc_axi_awburst,			  
  s0_axi4_awlock        => noc_axi_awlock(0),			  
  s0_axi4_awprot        => noc_axi_awprot,			  
  s0_axi4_awqos         => noc_axi_awqos,			  
  s0_axi4_awuser        => noc_axi_awuser,			  
  s0_axi4_awvalid       => noc_axi_awvalid,			  
  s0_axi4_awready       => noc_axi_awready,			  
  s0_axi4_wdata         => noc_axi_wdata,			  
  s0_axi4_wstrb         => noc_axi_wstrb,			  
  s0_axi4_wlast         => noc_axi_wlast,			  
  s0_axi4_wuser         => noc_axi_wuser,			  
  s0_axi4_wvalid        => noc_axi_wvalid,			  
  s0_axi4_wready        => noc_axi_wready,			  
  s0_axi4_bid           => noc_axi_bid,			          
  s0_axi4_bresp         => noc_axi_bresp,			  
  s0_axi4_bvalid        => noc_axi_bvalid,			  
  s0_axi4_bready        => noc_axi_bready,			  
  noc_bridge_fabric_clk => initiator_clk,  
  s0_axi4_aclk          => mem_usr_clk,			           
  s0_axi4_aresetn       => initiator_reset_n			   
  );

end generate g1_initiator576;

end rtl;