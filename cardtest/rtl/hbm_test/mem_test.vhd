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
-- Title       : Memory Test Top Level
-- Project     : Memory Test
--------------------------------------------------------------------------------
-- Description : Memory test that encapsulates the following subcomponents:
--               mem_test_control_regs           - Test Control Registers
--               mem_test_error_logging_regs     - Error Logging RAMs
--               mem_test_data_check             - Data Gen & Verification
--               mem_test_axi4_shim_with_parity  - AXI4 Interface Conversion
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

entity mem_test is 
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
  -- Test Control AXI4-Lite Interface
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
  -- Test Error Logging AXI4-Lite Interface
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
  -- Memory User Clock and Reset
  mem_usr_clk            : in   std_logic;
  mem_usr_reset          : in   std_logic;
  -- Memory Reset and Status
  mem_reset              : out  std_logic;
  mem_reset_status       : in   std_logic;
  calibration_success    : in   std_logic;
  calibration_fail       : in   std_logic;
  cattrip                : in   std_logic;
  temp                   : in   std_logic_vector(2 downto 0); 
  initiator_reset        : out  std_logic;
  -- Memory IP AXI4 Interface
  mem_axi_aclk           : in    std_logic;
  mem_axi_areset         : in    std_logic;
  mem_axi_awready        : in    std_logic;
  mem_axi_awvalid        : out   std_logic;
  mem_axi_awid           : out   std_logic_vector(6 downto 0);
  mem_axi_awaddr         : out   std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_axi_awlen          : out   std_logic_vector(7 downto 0);
  mem_axi_awsize         : out   std_logic_vector(2 downto 0);
  mem_axi_awburst        : out   std_logic_vector(1 downto 0);
  mem_axi_awlock         : out   std_logic_vector(0 downto 0);
  mem_axi_awprot         : out   std_logic_vector(2 downto 0);
  mem_axi_awqos          : out   std_logic_vector(3 downto 0);
  mem_axi_awuser         : out   std_logic_vector(10 downto 0);
  mem_axi_arready        : in    std_logic;
  mem_axi_arvalid        : out   std_logic;
  mem_axi_arid           : out   std_logic_vector(6 downto 0);
  mem_axi_araddr         : out   std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_axi_arlen          : out   std_logic_vector(7 downto 0);
  mem_axi_arsize         : out   std_logic_vector(2 downto 0);
  mem_axi_arburst        : out   std_logic_vector(1 downto 0);
  mem_axi_arlock         : out   std_logic_vector(0 downto 0);
  mem_axi_arprot         : out   std_logic_vector(2 downto 0);
  mem_axi_arqos          : out   std_logic_vector(3 downto 0);
  mem_axi_aruser         : out   std_logic_vector(10 downto 0);
  mem_axi_wready         : in    std_logic;
  mem_axi_wvalid         : out   std_logic;
  mem_axi_wdata          : out   std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
  mem_axi_wuser          : out   std_logic_vector((AXI_WUSER_WIDTH-1) downto 0);
  mem_axi_wstrb          : out   std_logic_vector(((EMIF_DATA_WIDTH/8)-1) downto 0);
  mem_axi_wlast          : out   std_logic;
  mem_axi_bready         : out   std_logic;
  mem_axi_bvalid         : in    std_logic;
  mem_axi_bid            : in    std_logic_vector(6 downto 0);
  mem_axi_bresp          : in    std_logic_vector(1 downto 0);
  mem_axi_rready         : out   std_logic;
  mem_axi_rvalid         : in    std_logic;
  mem_axi_rid            : in    std_logic_vector(6 downto 0);
  mem_axi_rdata          : in    std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
  mem_axi_ruser          : in    std_logic_vector((AXI_RUSER_WIDTH-1) downto 0);
  mem_axi_rresp          : in    std_logic_vector(1 downto 0);
  mem_axi_rlast          : in    std_logic
  );
end entity mem_test;

architecture rtl of mem_test is

function get_end_address (addr_width : integer;
                          num_bytes  : integer
                          ) 
                          return std_logic_vector is

  variable address: std_logic_vector(addr_width-1 downto 0);

begin

  address := (others => '1');
  address := address-(num_bytes-1);
  
  return address;

end get_end_address;

component mem_test_control_regs
generic (
  MEM_DATA_WIDTH                  :      integer := 64;
  TEST_CTRL_CLK_PERIOD            :      integer := 10
  );
port (
  aclk                            : in   std_logic;
  areset                          : in   std_logic;
  awaddr                          : in   std_logic_vector(5 downto 0);
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
  araddr                          : in   std_logic_vector(5 downto 0);						
  arvalid                         : in   std_logic;								
  arready                         : out  std_logic;								
  arprot                          : in   std_logic_vector(2 downto 0);
  rdata                           : out  std_logic_vector(31 downto 0);				
  rresp                           : out  std_logic_vector(1 downto 0);				
  rvalid                          : out  std_logic;							
  rready                          : in   std_logic;							
  mem_reset                       : out  std_logic;
  mem_reset_status                : in   std_logic;
  calibration_success             : in   std_logic;
  calibration_fail                : in   std_logic;
  cattrip                         : in   std_logic;
  temp                            : in   std_logic_vector(2 downto 0);
  test_reset                      : out  std_logic;
  test_enable                     : out  std_logic;
  test_pattern_sel                : out  std_logic_vector(5 downto 0);
  test_write_once                 : out  std_logic;
  test_running                    : in   std_logic;
  test_fail                       : in   std_logic;
  test_complete_count             : in   std_logic_vector(31 downto 0);
  test_error_count                : in   std_logic_vector(31 downto 0);
  test_error_bits                 : in   std_logic_vector(MEM_DATA_WIDTH-1 downto 0);
  axi_bresp_error_count           : in   std_logic_vector(31 downto 0);
  axi_rresp_error_count           : in   std_logic_vector(31 downto 0);
  write_timeout                   : in   std_logic;
  read_timeout                    : in   std_logic;
  sample_toggle                   : out  std_logic;
  write_bandwidth                 : in   std_logic_vector(31 downto 0);
  read_bandwidth                  : in   std_logic_vector(31 downto 0)  
  );
end component;

component mem_test_error_logging_regs
generic (
  ADDR_WIDTH                      :      integer := 32;
  EMIF_DATA_WIDTH                 :      integer := 512;
  MEM_DATA_WIDTH                  :      integer := 64
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
  mem_clk                         : in   std_logic;
  mem_reset                       : in   std_logic;
  words_stored                    : in   std_logic_vector(15 downto 0);
  address_mem_wr                  : in   std_logic;
  address_mem_addr                : in   std_logic_vector(9 downto 0);
  address_mem_data                : in   std_logic_vector(ADDR_WIDTH-1 downto 0);
  expected_mem_wr                 : in   std_logic;
  expected_mem_addr               : in   std_logic_vector(9 downto 0);
  expected_mem_data               : in   std_logic_vector(EMIF_DATA_WIDTH-1 downto 0);
  received_mem_wr                 : in   std_logic;
  received_mem_addr               : in   std_logic_vector(9 downto 0);
  received_mem_data               : in   std_logic_vector(EMIF_DATA_WIDTH-1 downto 0)
  );
end component;

component mem_test_data_check
generic (
  ADDR_WIDTH                 : integer := 10;
  MEM_DATA_WIDTH             : integer range 1 to 128  := 64;  
  EMIF_DATA_WIDTH            : integer range 1 to 1024 := 512   
  );			     
port (			     
  mem_clk                    : in    std_logic;
  mem_reset                  : in    std_logic;
  mem_waddr                  : out   std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_wdata                  : out   std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
  mem_wbyte_en               : out   std_logic_vector(((EMIF_DATA_WIDTH/8)-1) downto 0);
  mem_wvalid                 : out   std_logic;
  mem_wready                 : in    std_logic;
  mem_raddr                  : out   std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_rvalid                 : out   std_logic;
  mem_rready                 : in    std_logic;
  mem_rdata                  : in    std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
  mem_rdatavalid             : in    std_logic;
  mem_cal_complete           : in    std_logic;
  mem_test_reset             : in    std_logic;
  mem_test_enable            : in    std_logic;
  mem_test_pattern           : in    std_logic_vector(5 downto 0);
  mem_test_write_once        : in    std_logic;
  mem_test_start_addr        : in    std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_test_end_addr          : in    std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_test_running           : out   std_logic;
  mem_test_fail              : out   std_logic;
  mem_test_completed_cnt     : out   std_logic_vector(31 downto 0);
  mem_test_error_cnt         : out   std_logic_vector(31 downto 0);
  mem_test_error_bits        : out   std_logic_vector((MEM_DATA_WIDTH-1) downto 0);
  words_stored               : out   std_logic_vector(15 downto 0);
  address_mem_wr             : out   std_logic;
  address_mem_addr           : out   std_logic_vector(9 downto 0);
  address_mem_data           : out   std_logic_vector(ADDR_WIDTH-1 downto 0);
  expected_mem_wr            : out   std_logic;
  expected_mem_addr          : out   std_logic_vector(9 downto 0);
  expected_mem_data          : out   std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
  received_mem_wr            : out   std_logic;
  received_mem_addr          : out   std_logic_vector(9 downto 0);
  received_mem_data          : out   std_logic_vector((EMIF_DATA_WIDTH-1) downto 0)
  );
end component;

component mem_test_axi4_shim_with_parity 
generic (
  ADDR_WIDTH             :       integer := 10;
  DATA_WIDTH             :       integer := 512;
  PARITY_WIDTH           :       integer := 64;
  BURST_LENGTH           :       integer := 256;
  MEM_BURST              :       integer := 8;
  MEM_DATA_WIDTH         :       integer := 64;
  MEM_PARITY_WIDTH       :       integer := 8
  );
port (
  axi4_aclk              : in    std_logic;
  axi4_areset            : in    std_logic;
  axi4_awready           : in    std_logic;
  axi4_awvalid           : out   std_logic;
  axi4_awid              : out   std_logic_vector(6 downto 0);
  axi4_awaddr            : out   std_logic_vector(ADDR_WIDTH-1 downto 0);
  axi4_awlen             : out   std_logic_vector(7 downto 0);
  axi4_awsize            : out   std_logic_vector(2 downto 0);
  axi4_awburst           : out   std_logic_vector(1 downto 0);
  axi4_awlock            : out   std_logic_vector(0 downto 0);
  axi4_awprot            : out   std_logic_vector(2 downto 0);
  axi4_awqos             : out   std_logic_vector(3 downto 0);
  axi4_awuser            : out   std_logic_vector(10 downto 0);
  axi4_arready           : in    std_logic;
  axi4_arvalid           : out   std_logic;
  axi4_arid              : out   std_logic_vector(6 downto 0);
  axi4_araddr            : out   std_logic_vector(ADDR_WIDTH-1 downto 0);
  axi4_arlen             : out   std_logic_vector(7 downto 0);
  axi4_arsize            : out   std_logic_vector(2 downto 0);
  axi4_arburst           : out   std_logic_vector(1 downto 0);
  axi4_arlock            : out   std_logic_vector(0 downto 0);
  axi4_arprot            : out   std_logic_vector(2 downto 0);
  axi4_arqos             : out   std_logic_vector(3 downto 0);
  axi4_aruser            : out   std_logic_vector(10 downto 0);
  axi4_wready            : in    std_logic;
  axi4_wvalid            : out   std_logic;
  axi4_wdata             : out   std_logic_vector((DATA_WIDTH-1) downto 0);
  axi4_wuser             : out   std_logic_vector((PARITY_WIDTH-1) downto 0);
  axi4_wstrb             : out   std_logic_vector(((DATA_WIDTH/8)-1) downto 0);
  axi4_wlast             : out   std_logic;
  axi4_bready            : out   std_logic;
  axi4_bvalid            : in    std_logic;
  axi4_bid               : in    std_logic_vector(6 downto 0);
  axi4_bresp             : in    std_logic_vector(1 downto 0);
  axi4_rready            : out   std_logic;
  axi4_rvalid            : in    std_logic;
  axi4_rid               : in    std_logic_vector(6 downto 0);
  axi4_rdata             : in    std_logic_vector((DATA_WIDTH-1) downto 0);
  axi4_ruser             : in    std_logic_vector((PARITY_WIDTH-1) downto 0);
  axi4_rresp             : in    std_logic_vector(1 downto 0);
  axi4_rlast             : in    std_logic;
  bresp_error_count      : out   std_logic_vector(31 downto 0);
  rresp_error_count      : out   std_logic_vector(31 downto 0);
  write_timeout          : out   std_logic;
  read_timeout           : out   std_logic;
  sample_pulse           : in    std_logic;
  write_bandwidth        : out   std_logic_vector(31 downto 0);
  read_bandwidth         : out   std_logic_vector(31 downto 0);
  mem_clk                : in    std_logic;
  mem_reset              : in    std_logic;
  mem_waddr              : in    std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_wdata              : in    std_logic_vector(((DATA_WIDTH+PARITY_WIDTH)-1) downto 0);
  mem_wbyte_en           : in    std_logic_vector((((DATA_WIDTH+PARITY_WIDTH)/8)-1) downto 0);
  mem_wvalid             : in    std_logic;
  mem_wready             : out   std_logic;
  mem_raddr              : in    std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_rvalid             : in    std_logic;
  mem_rready             : out   std_logic;
  mem_rdata              : out   std_logic_vector(((DATA_WIDTH+PARITY_WIDTH)-1) downto 0);
  mem_rdatavalid         : out   std_logic
  );
end component;

component mem_test_axi4_shim_no_parity
generic (
  ADDR_WIDTH             :       integer := 10;
  DATA_WIDTH             :       integer := 512;
  USER_WIDTH             :       integer := 64;
  BURST_LENGTH           :       integer := 256;
  MEM_BURST              :       integer := 8;
  MEM_DATA_WIDTH         :       integer := 64
  );
port (
  axi4_aclk              : in    std_logic;
  axi4_areset            : in    std_logic;
  axi4_awready           : in    std_logic;
  axi4_awvalid           : out   std_logic;
  axi4_awid              : out   std_logic_vector(6 downto 0);
  axi4_awaddr            : out   std_logic_vector(ADDR_WIDTH-1 downto 0);
  axi4_awlen             : out   std_logic_vector(7 downto 0);
  axi4_awsize            : out   std_logic_vector(2 downto 0);
  axi4_awburst           : out   std_logic_vector(1 downto 0);
  axi4_awlock            : out   std_logic_vector(0 downto 0);
  axi4_awprot            : out   std_logic_vector(2 downto 0);
  axi4_awqos             : out   std_logic_vector(3 downto 0);
  axi4_awuser            : out   std_logic_vector(10 downto 0);
  axi4_arready           : in    std_logic;
  axi4_arvalid           : out   std_logic;
  axi4_arid              : out   std_logic_vector(6 downto 0);
  axi4_araddr            : out   std_logic_vector(ADDR_WIDTH-1 downto 0);
  axi4_arlen             : out   std_logic_vector(7 downto 0);
  axi4_arsize            : out   std_logic_vector(2 downto 0);
  axi4_arburst           : out   std_logic_vector(1 downto 0);
  axi4_arlock            : out   std_logic_vector(0 downto 0);
  axi4_arprot            : out   std_logic_vector(2 downto 0);
  axi4_arqos             : out   std_logic_vector(3 downto 0);
  axi4_aruser            : out   std_logic_vector(10 downto 0);
  axi4_wready            : in    std_logic;
  axi4_wvalid            : out   std_logic;
  axi4_wdata             : out   std_logic_vector((DATA_WIDTH-1) downto 0);
  axi4_wuser             : out   std_logic_vector((USER_WIDTH-1) downto 0);
  axi4_wstrb             : out   std_logic_vector(((DATA_WIDTH/8)-1) downto 0);
  axi4_wlast             : out   std_logic;
  axi4_bready            : out   std_logic;
  axi4_bvalid            : in    std_logic;
  axi4_bid               : in    std_logic_vector(6 downto 0);
  axi4_bresp             : in    std_logic_vector(1 downto 0);
  axi4_rready            : out   std_logic;
  axi4_rvalid            : in    std_logic;
  axi4_rid               : in    std_logic_vector(6 downto 0);
  axi4_rdata             : in    std_logic_vector((DATA_WIDTH-1) downto 0);
  axi4_ruser             : in    std_logic_vector((USER_WIDTH-1) downto 0);
  axi4_rresp             : in    std_logic_vector(1 downto 0);
  axi4_rlast             : in    std_logic;
  bresp_error_count      : out   std_logic_vector(31 downto 0);
  rresp_error_count      : out   std_logic_vector(31 downto 0);
  write_timeout          : out   std_logic;
  read_timeout           : out   std_logic;
  sample_pulse           : in    std_logic;
  write_bandwidth        : out   std_logic_vector(31 downto 0);
  read_bandwidth         : out   std_logic_vector(31 downto 0);
  mem_clk                : in    std_logic;
  mem_reset              : in    std_logic;
  mem_waddr              : in    std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_wdata              : in    std_logic_vector(DATA_WIDTH-1 downto 0);
  mem_wbyte_en           : in    std_logic_vector(((DATA_WIDTH/8)-1) downto 0);
  mem_wvalid             : in    std_logic;
  mem_wready             : out   std_logic;
  mem_raddr              : in    std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_rvalid             : in    std_logic;
  mem_rready             : out   std_logic;
  mem_rdata              : out   std_logic_vector(DATA_WIDTH-1 downto 0);
  mem_rdatavalid         : out   std_logic
  );
end component;

component retime
generic (
  DEPTH     : integer := 2;           
  WIDTH     : integer := 1           
  );
port (
  reset     : in  std_logic;
  clock     : in  std_logic;
  d         : in  std_logic_vector(WIDTH-1 downto 0);
  q         : out std_logic_vector(WIDTH-1 downto 0)
  );
end component;

constant MEM_BURST               : integer := EMIF_DATA_WIDTH/MEM_DATA_WIDTH;
constant EMIF_BYTES              : integer := EMIF_DATA_WIDTH/8;
constant EMIF_START_ADDR         : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
constant EMIF_END_ADDR           : std_logic_vector(ADDR_WIDTH-1 downto 0) := get_end_address(ADDR_WIDTH, EMIF_BYTES);
  
signal test_reset_sys            : std_logic;
signal test_enable_sys           : std_logic;
signal test_pattern_select_sys   : std_logic_vector(5 downto 0);
signal test_write_once_sys       : std_logic;
signal test_running_sys          : std_logic;
signal test_fail_sys             : std_logic;
signal test_complete_count_sys   : std_logic_vector(31 downto 0);
signal test_error_count_sys      : std_logic_vector(31 downto 0);
signal test_error_bits_sys       : std_logic_vector((MEM_DATA_WIDTH+MEM_PARITY_WIDTH)-1 downto 0);

signal test_reset_mem            : std_logic;
signal test_enable_mem           : std_logic;
signal test_pattern_select_mem   : std_logic_vector(5 downto 0);
signal test_write_once_mem       : std_logic;
signal test_running_mem          : std_logic;
signal test_fail_mem             : std_logic;
signal test_complete_count_mem   : std_logic_vector(31 downto 0);
signal test_error_count_mem      : std_logic_vector(31 downto 0);
signal test_error_bits_mem       : std_logic_vector((MEM_DATA_WIDTH+MEM_PARITY_WIDTH)-1 downto 0);

signal test_start_addr           : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal test_end_addr             : std_logic_vector(ADDR_WIDTH-1 downto 0);

signal error_words_stored        : std_logic_vector(15 downto 0);
signal address_mem_wr            : std_logic;
signal address_mem_addr          : std_logic_vector(9 downto 0);
signal address_mem_data          : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal expected_mem_wr           : std_logic;
signal expected_mem_addr         : std_logic_vector(9 downto 0);
signal expected_mem_data         : std_logic_vector((EMIF_DATA_WIDTH+EMIF_PARITY_WIDTH)-1 downto 0);
signal received_mem_wr           : std_logic;
signal received_mem_addr         : std_logic_vector(9 downto 0);
signal received_mem_data         : std_logic_vector((EMIF_DATA_WIDTH+EMIF_PARITY_WIDTH)-1 downto 0);

signal mem_test_waddr            : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal mem_test_wdata            : std_logic_vector((EMIF_DATA_WIDTH+EMIF_PARITY_WIDTH)-1 downto 0);
signal mem_test_wbyte_en         : std_logic_vector(((EMIF_DATA_WIDTH+EMIF_PARITY_WIDTH)/8)-1 downto 0);
signal mem_test_wvalid           : std_logic;
signal mem_test_wready           : std_logic;
signal mem_test_raddr            : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal mem_test_rvalid           : std_logic;
signal mem_test_rready           : std_logic;
signal mem_test_rdata            : std_logic_vector((EMIF_DATA_WIDTH+EMIF_PARITY_WIDTH)-1 downto 0);
signal mem_test_rdatavalid       : std_logic;

signal mem_axi_wuser_i           : std_logic_vector(EMIF_PARITY_WIDTH-1 downto 0);
signal mem_axi_ruser_i           : std_logic_vector(EMIF_PARITY_WIDTH-1 downto 0);

signal mem_data_path_flush       : std_logic;

signal bresp_error_count_mem     : std_logic_vector(31 downto 0);
signal rresp_error_count_mem     : std_logic_vector(31 downto 0);
signal bresp_error_count_sys     : std_logic_vector(31 downto 0);
signal rresp_error_count_sys     : std_logic_vector(31 downto 0);
signal write_timeout_mem         : std_logic;
signal write_timeout_sys         : std_logic;
signal read_timeout_mem          : std_logic;
signal read_timeout_sys          : std_logic;

signal sample_toggle_sys         : std_logic;
signal sample_toggle_mem_meta    : std_logic_vector(3 downto 0);
signal sample_pulse              : std_logic;

signal write_bandwidth_mem       : std_logic_vector(31 downto 0);
signal read_bandwidth_mem        : std_logic_vector(31 downto 0);
signal write_bandwidth_sys       : std_logic_vector(31 downto 0);
signal read_bandwidth_sys        : std_logic_vector(31 downto 0);

signal mem_data_path_flush_meta  : std_logic_vector(3 downto 0);
signal initiator_reset_meta      : std_logic_vector(3 downto 0);

begin

test_start_addr                       <= EMIF_START_ADDR;
test_end_addr                         <= EMIF_END_ADDR;

mem_data_path_flush_meta(0)           <= '1' when mem_usr_reset='1' else    
                                         '1' when test_reset_mem='1' else
                                         '0';
process (mem_usr_clk)
begin  
  if rising_edge(mem_usr_clk) then
    mem_data_path_flush_meta(3 downto 1) <= mem_data_path_flush_meta(2 downto 0);
  end if;
end process;

mem_data_path_flush                   <= mem_data_path_flush_meta(3);

initiator_reset_meta(0)               <= '1' when mem_usr_reset='1' else    
                                         '1' when test_reset_mem='1' else
                                         '0';
process (mem_axi_aclk)
begin  
  if rising_edge(mem_axi_aclk) then
    initiator_reset_meta(3 downto 1)     <= initiator_reset_meta(2 downto 0);
  end if;
end process;

initiator_reset                       <= initiator_reset_meta(3);

------------------------------------------
--
-- Test Control Interface
--
-- AXI4-Lite interface required
-- to control the memory test.
--
------------------------------------------
u0_test_control_regs : mem_test_control_regs
generic map (
  MEM_DATA_WIDTH                  => (MEM_DATA_WIDTH+MEM_PARITY_WIDTH),
  TEST_CTRL_CLK_PERIOD            => TEST_CTRL_CLK_PERIOD
  )
port map (
  aclk                            => test_ctrl_aclk,
  areset                          => test_ctrl_areset,
  awaddr                          => test_ctrl_awaddr,
  awvalid                         => test_ctrl_awvalid,
  awready                         => test_ctrl_awready,
  awprot                          => test_ctrl_awprot,
  wdata                           => test_ctrl_wdata,
  wstrb                           => test_ctrl_wstrb,
  wvalid                          => test_ctrl_wvalid,
  wready                          => test_ctrl_wready,
  bresp                           => test_ctrl_bresp,			
  bvalid                          => test_ctrl_bvalid,				
  bready                          => test_ctrl_bready,				
  araddr                          => test_ctrl_araddr,			
  arvalid                         => test_ctrl_arvalid,			
  arready                         => test_ctrl_arready,			
  arprot                          => test_ctrl_arprot,
  rdata                           => test_ctrl_rdata,	
  rresp                           => test_ctrl_rresp,	
  rvalid                          => test_ctrl_rvalid,		
  rready                          => test_ctrl_rready,		
  mem_reset                       => mem_reset,
  mem_reset_status                => mem_reset_status,
  calibration_success             => calibration_success,
  calibration_fail                => calibration_fail,
  cattrip                         => cattrip,
  temp                            => temp,
  test_reset                      => test_reset_sys,
  test_enable                     => test_enable_sys,
  test_pattern_sel                => test_pattern_select_sys,
  test_write_once                 => test_write_once_sys,
  test_running                    => test_running_sys,
  test_fail                       => test_fail_sys,
  test_complete_count             => test_complete_count_sys,
  test_error_count                => test_error_count_sys,
  test_error_bits                 => test_error_bits_sys,
  axi_bresp_error_count           => bresp_error_count_sys,
  axi_rresp_error_count           => rresp_error_count_sys,
  write_timeout                   => write_timeout_sys,
  read_timeout                    => read_timeout_sys,
  sample_toggle                   => sample_toggle_sys,
  write_bandwidth                 => write_bandwidth_sys,
  read_bandwidth                  => read_bandwidth_sys
  );

------------------------------------------
--
-- Error Logging Registers
--
-- The memory test loads BRAM with errors
-- whilst the test is running.
-- This data can then be read via an
-- AXI4-Lite interface.
--
------------------------------------------
u1_error_logging : mem_test_error_logging_regs
generic map (
  ADDR_WIDTH                     => ADDR_WIDTH,
  EMIF_DATA_WIDTH                => (EMIF_DATA_WIDTH+EMIF_PARITY_WIDTH),
  MEM_DATA_WIDTH                 => (MEM_DATA_WIDTH+MEM_PARITY_WIDTH)
  )
port map (
  aclk                           => error_log_aclk, 	 
  areset                         => error_log_areset, 	 
  awaddr                         => error_log_awaddr, 	 
  awvalid                        => error_log_awvalid, 	 
  awready                        => error_log_awready, 	 
  awprot                         => error_log_awprot, 	 
  wdata                          => error_log_wdata, 	 
  wstrb                          => error_log_wstrb, 	 
  wvalid                         => error_log_wvalid, 	 
  wready                         => error_log_wready, 	 
  bresp                          => error_log_bresp, 	 		
  bvalid                         => error_log_bvalid, 	 			
  bready                         => error_log_bready, 	 			
  araddr                         => error_log_araddr, 	 		
  arvalid                        => error_log_arvalid, 	 		
  arready                        => error_log_arready, 	 		
  arprot                         => error_log_arprot, 	 
  rdata                          => error_log_rdata, 	 
  rresp                          => error_log_rresp, 	 
  rvalid                         => error_log_rvalid, 	 	
  rready                         => error_log_rready, 	 	
  mem_clk                        => mem_usr_clk, 
  mem_reset                      => mem_usr_reset, 
  words_stored                   => error_words_stored, 
  address_mem_wr                 => address_mem_wr, 
  address_mem_addr               => address_mem_addr, 
  address_mem_data               => address_mem_data, 
  expected_mem_wr                => expected_mem_wr, 
  expected_mem_addr              => expected_mem_addr, 
  expected_mem_data              => expected_mem_data, 
  received_mem_wr                => received_mem_wr, 
  received_mem_addr              => received_mem_addr, 
  received_mem_data              => received_mem_data 
  );

------------------------------------------
--
-- Memory Test Data Generation & Verification
--
-- This is the main engine behind the 
-- memory test.
-- Data is generated (from a number of
-- test patterns) and sent out to the 
-- main memory interface.
-- Data is then read and the return data
-- is verified against what was sent.
--
------------------------------------------
u2_datagen_and_verification : mem_test_data_check
generic map (
  ADDR_WIDTH                 => ADDR_WIDTH,
  MEM_DATA_WIDTH             => (MEM_DATA_WIDTH+MEM_PARITY_WIDTH),  
  EMIF_DATA_WIDTH            => (EMIF_DATA_WIDTH+EMIF_PARITY_WIDTH) 
  )			     
port map (			     
  mem_clk                    => mem_usr_clk,
  mem_reset                  => mem_usr_reset,
  mem_waddr                  => mem_test_waddr,
  mem_wdata                  => mem_test_wdata,
  mem_wbyte_en               => mem_test_wbyte_en,
  mem_wvalid                 => mem_test_wvalid,
  mem_wready                 => mem_test_wready,
  mem_raddr                  => mem_test_raddr,
  mem_rvalid                 => mem_test_rvalid,
  mem_rready                 => mem_test_rready,
  mem_rdata                  => mem_test_rdata,
  mem_rdatavalid             => mem_test_rdatavalid,
  mem_cal_complete           => calibration_success,
  mem_test_reset             => test_reset_mem,
  mem_test_enable            => test_enable_mem,
  mem_test_pattern           => test_pattern_select_mem,
  mem_test_write_once        => test_write_once_mem,
  mem_test_start_addr        => test_start_addr,
  mem_test_end_addr          => test_end_addr,
  mem_test_running           => test_running_mem,
  mem_test_fail              => test_fail_mem,
  mem_test_completed_cnt     => test_complete_count_mem,
  mem_test_error_cnt         => test_error_count_mem,
  mem_test_error_bits        => test_error_bits_mem,
  words_stored               => error_words_stored,
  address_mem_wr             => address_mem_wr,
  address_mem_addr           => address_mem_addr,
  address_mem_data           => address_mem_data,
  expected_mem_wr            => expected_mem_wr,
  expected_mem_addr          => expected_mem_addr,
  expected_mem_data          => expected_mem_data,
  received_mem_wr            => received_mem_wr,
  received_mem_addr          => received_mem_addr,
  received_mem_data          => received_mem_data
  );

------------------------------------------
--
-- Memory AXI Interface (pre-NoC)
--
-- If-Generates will be used to support 
-- a parity-based interface and a 
-- non-parity based interface.
--
------------------------------------------
g0_axi_if_with_parity : if EMIF_PARITY_WIDTH /= 0 generate

u3_axi4_if : mem_test_axi4_shim_with_parity 
generic map (
  ADDR_WIDTH             => ADDR_WIDTH,
  DATA_WIDTH             => EMIF_DATA_WIDTH,
  PARITY_WIDTH           => EMIF_PARITY_WIDTH,
  BURST_LENGTH           => AXI_BURST_LENGTH,
  MEM_BURST              => MEM_BURST,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH,
  MEM_PARITY_WIDTH       => MEM_PARITY_WIDTH
  )
port map (
  axi4_aclk              => mem_axi_aclk,
  axi4_areset            => mem_axi_areset,
  axi4_awready           => mem_axi_awready,
  axi4_awvalid           => mem_axi_awvalid,
  axi4_awid              => mem_axi_awid,
  axi4_awaddr            => mem_axi_awaddr,
  axi4_awlen             => mem_axi_awlen,
  axi4_awsize            => mem_axi_awsize,
  axi4_awburst           => mem_axi_awburst,
  axi4_awlock            => mem_axi_awlock,
  axi4_awprot            => mem_axi_awprot,
  axi4_awqos             => mem_axi_awqos,
  axi4_awuser            => mem_axi_awuser,
  axi4_arready           => mem_axi_arready,
  axi4_arvalid           => mem_axi_arvalid,
  axi4_arid              => mem_axi_arid,
  axi4_araddr            => mem_axi_araddr,
  axi4_arlen             => mem_axi_arlen,
  axi4_arsize            => mem_axi_arsize,
  axi4_arburst           => mem_axi_arburst,
  axi4_arlock            => mem_axi_arlock,
  axi4_arprot            => mem_axi_arprot,
  axi4_arqos             => mem_axi_arqos,
  axi4_aruser            => mem_axi_aruser,
  axi4_wready            => mem_axi_wready,
  axi4_wvalid            => mem_axi_wvalid,
  axi4_wdata             => mem_axi_wdata,
  axi4_wuser             => mem_axi_wuser_i,
  axi4_wstrb             => mem_axi_wstrb,
  axi4_wlast             => mem_axi_wlast,
  axi4_bready            => mem_axi_bready,
  axi4_bvalid            => mem_axi_bvalid,
  axi4_bid               => mem_axi_bid,
  axi4_bresp             => mem_axi_bresp,
  axi4_rready            => mem_axi_rready,
  axi4_rvalid            => mem_axi_rvalid,
  axi4_rid               => mem_axi_rid,
  axi4_rdata             => mem_axi_rdata,
  axi4_ruser             => mem_axi_ruser_i,
  axi4_rresp             => mem_axi_rresp,
  axi4_rlast             => mem_axi_rlast,
  bresp_error_count      => bresp_error_count_mem,
  rresp_error_count      => rresp_error_count_mem,
  write_timeout          => write_timeout_mem,
  read_timeout           => read_timeout_mem,
  sample_pulse           => sample_pulse,
  write_bandwidth        => write_bandwidth_mem,
  read_bandwidth         => read_bandwidth_mem,
  mem_clk                => mem_usr_clk,
  mem_reset              => mem_data_path_flush,
  mem_waddr              => mem_test_waddr,
  mem_wdata              => mem_test_wdata,
  mem_wbyte_en           => mem_test_wbyte_en,
  mem_wvalid             => mem_test_wvalid,
  mem_wready             => mem_test_wready,
  mem_raddr              => mem_test_raddr,
  mem_rvalid             => mem_test_rvalid,
  mem_rready             => mem_test_rready,
  mem_rdata              => mem_test_rdata,
  mem_rdatavalid         => mem_test_rdatavalid
  );

g0_0_wuser0 : if AXI_WUSER_WIDTH = EMIF_PARITY_WIDTH generate

mem_axi_wuser <= mem_axi_wuser_i;

end generate g0_0_wuser0;

g0_0_wuser1 : if AXI_WUSER_WIDTH > EMIF_PARITY_WIDTH generate

mem_axi_wuser(EMIF_PARITY_WIDTH-1 downto 0)               <= mem_axi_wuser_i;
mem_axi_wuser(AXI_WUSER_WIDTH-1 downto EMIF_PARITY_WIDTH) <= (others => '0');

end generate g0_0_wuser1;

g0_1_ruser0 : if AXI_RUSER_WIDTH = EMIF_PARITY_WIDTH generate

mem_axi_ruser_i <= mem_axi_ruser;

end generate g0_1_ruser0;

g0_1_ruser1 : if AXI_RUSER_WIDTH > EMIF_PARITY_WIDTH generate

mem_axi_ruser_i <= mem_axi_ruser(EMIF_PARITY_WIDTH-1 downto 0);

end generate g0_1_ruser1;

end generate g0_axi_if_with_parity;
 
g1_axi_if_no_parity : if EMIF_PARITY_WIDTH = 0 generate

u3_axi4_if : mem_test_axi4_shim_no_parity 
generic map (
  ADDR_WIDTH             => ADDR_WIDTH,
  DATA_WIDTH             => EMIF_DATA_WIDTH,
  USER_WIDTH             => EMIF_BYTES,
  BURST_LENGTH           => AXI_BURST_LENGTH,
  MEM_BURST              => MEM_BURST,
  MEM_DATA_WIDTH         => MEM_DATA_WIDTH
  )
port map (
  axi4_aclk              => mem_axi_aclk,
  axi4_areset            => mem_axi_areset,
  axi4_awready           => mem_axi_awready,
  axi4_awvalid           => mem_axi_awvalid,
  axi4_awid              => mem_axi_awid,
  axi4_awaddr            => mem_axi_awaddr,
  axi4_awlen             => mem_axi_awlen,
  axi4_awsize            => mem_axi_awsize,
  axi4_awburst           => mem_axi_awburst,
  axi4_awlock            => mem_axi_awlock,
  axi4_awprot            => mem_axi_awprot,
  axi4_awqos             => mem_axi_awqos,
  axi4_awuser            => mem_axi_awuser,
  axi4_arready           => mem_axi_arready,
  axi4_arvalid           => mem_axi_arvalid,
  axi4_arid              => mem_axi_arid,
  axi4_araddr            => mem_axi_araddr,
  axi4_arlen             => mem_axi_arlen,
  axi4_arsize            => mem_axi_arsize,
  axi4_arburst           => mem_axi_arburst,
  axi4_arlock            => mem_axi_arlock,
  axi4_arprot            => mem_axi_arprot,
  axi4_arqos             => mem_axi_arqos,
  axi4_aruser            => mem_axi_aruser,
  axi4_wready            => mem_axi_wready,
  axi4_wvalid            => mem_axi_wvalid,
  axi4_wdata             => mem_axi_wdata,
  axi4_wuser             => mem_axi_wuser,
  axi4_wstrb             => mem_axi_wstrb,
  axi4_wlast             => mem_axi_wlast,
  axi4_bready            => mem_axi_bready,
  axi4_bvalid            => mem_axi_bvalid,
  axi4_bid               => mem_axi_bid,
  axi4_bresp             => mem_axi_bresp,
  axi4_rready            => mem_axi_rready,
  axi4_rvalid            => mem_axi_rvalid,
  axi4_rid               => mem_axi_rid,
  axi4_rdata             => mem_axi_rdata,
  axi4_ruser             => mem_axi_ruser,
  axi4_rresp             => mem_axi_rresp,
  axi4_rlast             => mem_axi_rlast,
  bresp_error_count      => bresp_error_count_mem,
  rresp_error_count      => rresp_error_count_mem,
  write_timeout          => write_timeout_mem,
  read_timeout           => read_timeout_mem,
  sample_pulse           => sample_pulse,
  write_bandwidth        => write_bandwidth_mem,
  read_bandwidth         => read_bandwidth_mem,
  mem_clk                => mem_usr_clk,
  mem_reset              => mem_data_path_flush,
  mem_waddr              => mem_test_waddr,
  mem_wdata              => mem_test_wdata,
  mem_wbyte_en           => mem_test_wbyte_en,
  mem_wvalid             => mem_test_wvalid,
  mem_wready             => mem_test_wready,
  mem_raddr              => mem_test_raddr,
  mem_rvalid             => mem_test_rvalid,
  mem_rready             => mem_test_rready,
  mem_rdata              => mem_test_rdata,
  mem_rdatavalid         => mem_test_rdatavalid
  );

end generate g1_axi_if_no_parity;
 
-- Retime logic between the test control registers
-- and the main BIST engine.
u4_retime_reset : retime
generic map (
  DEPTH     => 3,           
  WIDTH     => 1          
  )
port map (
  reset     => mem_usr_reset,
  clock     => mem_usr_clk,
  d(0)      => test_reset_sys,
  q(0)      => test_reset_mem
  );

u5_retime_enable : retime
generic map (
  DEPTH     => 3,           
  WIDTH     => 1          
  )
port map (
  reset     => mem_usr_reset,
  clock     => mem_usr_clk,
  d(0)      => test_enable_sys,
  q(0)      => test_enable_mem
  );

u6_retime_pattern_select : retime
generic map (
  DEPTH     => 3,           
  WIDTH     => 6          
  )
port map (
  reset     => mem_usr_reset,
  clock     => mem_usr_clk,
  d         => test_pattern_select_sys,
  q         => test_pattern_select_mem
  );

u7_retime_wr_once : retime
generic map (
  DEPTH     => 3,           
  WIDTH     => 1          
  )
port map (
  reset     => mem_usr_reset,
  clock     => mem_usr_clk,
  d(0)      => test_write_once_sys,
  q(0)      => test_write_once_mem
  );
  
u8_retime_running : retime
generic map (
  DEPTH     => 3,           
  WIDTH     => 1          
  )
port map (
  reset     => test_ctrl_areset,
  clock     => test_ctrl_aclk,
  d(0)      => test_running_mem,
  q(0)      => test_running_sys
  );

u9_retime_fail : retime
generic map (
  DEPTH     => 3,           
  WIDTH     => 1          
  )
port map (
  reset     => test_ctrl_areset,
  clock     => test_ctrl_aclk,
  d(0)      => test_fail_mem,
  q(0)      => test_fail_sys
  );

u10_retime_tests_complete : retime
generic map (
  DEPTH     => 3,           
  WIDTH     => 32          
  )
port map (
  reset     => test_ctrl_areset,
  clock     => test_ctrl_aclk,
  d         => test_complete_count_mem,
  q         => test_complete_count_sys
  );

u11_retime_errors : retime
generic map (
  DEPTH     => 3,           
  WIDTH     => 32          
  )
port map (
  reset     => test_ctrl_areset,
  clock     => test_ctrl_aclk,
  d         => test_error_count_mem,
  q         => test_error_count_sys
  );

u12_retime_error_bits : retime
generic map (
  DEPTH     => 3,           
  WIDTH     => (MEM_DATA_WIDTH+MEM_PARITY_WIDTH)          
  )
port map (
  reset     => test_ctrl_areset,
  clock     => test_ctrl_aclk,
  d         => test_error_bits_mem,
  q         => test_error_bits_sys
  ); 

u13_retime_bresp_errors : retime
generic map (
  DEPTH     => 3,
  WIDTH     => 32
  )
port map (
  reset     => test_ctrl_areset,
  clock     => test_ctrl_aclk,
  d         => bresp_error_count_mem,
  q         => bresp_error_count_sys
  );

u14_retime_rresp_errors : retime
generic map (
  DEPTH     => 3,
  WIDTH     => 32
  )
port map (
  reset     => test_ctrl_areset,
  clock     => test_ctrl_aclk,
  d         => rresp_error_count_mem,
  q         => rresp_error_count_sys
  );
  
process (mem_axi_aclk)
begin
  if rising_edge(mem_axi_aclk) then
    sample_toggle_mem_meta    <= sample_toggle_mem_meta(2 downto 0) & sample_toggle_sys;
  end if;
end process;

process (mem_axi_aclk)
begin 
  if rising_edge(mem_axi_aclk) then
    if mem_axi_areset='1' then
      sample_pulse       <= '0';
    else
      sample_pulse       <= sample_toggle_mem_meta(3) xor sample_toggle_mem_meta(2);
    end if;
  end if;
end process;

u15_retime_wr_bw : retime
generic map (
  DEPTH     => 3,
  WIDTH     => 32
  )
port map (
  reset     => test_ctrl_areset,
  clock     => test_ctrl_aclk,
  d         => write_bandwidth_mem,
  q         => write_bandwidth_sys
  );

u16_retime_rd_bw : retime
generic map (
  DEPTH     => 3,
  WIDTH     => 32
  )
port map (
  reset     => test_ctrl_areset,
  clock     => test_ctrl_aclk,
  d         => read_bandwidth_mem,
  q         => read_bandwidth_sys
  );

u17_retime_wr_timeout : retime
generic map (
  DEPTH     => 3,
  WIDTH     => 1
  )
port map (
  reset     => test_ctrl_areset,
  clock     => test_ctrl_aclk,
  d(0)      => write_timeout_mem,
  q(0)      => write_timeout_sys
  );

u18_retime_rd_timeout : retime
generic map (
  DEPTH     => 3,
  WIDTH     => 1
  )
port map (
  reset     => test_ctrl_areset,
  clock     => test_ctrl_aclk,
  d(0)      => read_timeout_mem,
  q(0)      => read_timeout_sys
  );
 
end rtl;
  
  
  
 