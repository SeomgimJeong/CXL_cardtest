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
-- Title       : HPS DDR4 SDRAM Test
-- Project     : IA-860m
--------------------------------------------------------------------------------
-- Description : DDR4 SDRAM Test + DDR4 EMIF Instance + DDR4 Calibration Status 
--               Polling
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity hps_dram_test is
generic (
  TEST_CTRL_CLK_PERIOD      :      integer := 10
  );
port (
  -- DRAM Interface
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
  -- System Clock (Drives AXI Interface)
  sys_clk                   : in   std_logic;
  sys_reset                 : in   std_logic;
  -- Initiator Clock (if needed)
  initiator_clk             : in   std_logic;  
  -- Test Clock & Reset
  mem_usr_clk               : in   std_logic;
  mem_usr_reset             : in   std_logic;
  -- AXI Control/Status
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
end entity hps_dram_test;

architecture rtl of hps_dram_test is

component hps_ddr4
port (
  ref_clk             : in    std_logic                     := '0';             
  mem_0_ck_t          : out   std_logic;                                        
  mem_0_ck_c          : out   std_logic;                                        
  mem_0_cke           : out   std_logic;                                        
  mem_0_odt           : out   std_logic;                                        
  mem_0_cs_n          : out   std_logic;                                        
  mem_0_a             : out   std_logic_vector(16 downto 0);                    
  mem_0_ba            : out   std_logic_vector(1 downto 0);                     
  mem_0_bg            : out   std_logic;                                        
  mem_0_act_n         : out   std_logic;                                        
  mem_0_par           : out   std_logic;                                        
  mem_0_alert_n       : in    std_logic                     := '0';             
  mem_0_reset_n       : out   std_logic;                                        
  mem_0_dq            : inout std_logic_vector(39 downto 0) := (others => '0'); 
  mem_0_dqs_t         : inout std_logic_vector(4 downto 0)  := (others => '0'); 
  mem_0_dqs_c         : inout std_logic_vector(4 downto 0)  := (others => '0'); 
  mem_0_dbi_n         : inout std_logic_vector(4 downto 0)  := (others => '0'); 
  oct_rzqin_0         : in    std_logic                     := '0';             
  s0_axi4lite_clock   : in    std_logic                     := '0';             
  s0_axi4lite_reset_n : in    std_logic                     := '0'              
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

component cal_status_polling 
port (
  sys_clk                : in   std_logic;
  sys_reset              : in   std_logic;
  mem_reset              : in   std_logic;
  calibration_busy       : out  std_logic;
  calibration_fail       : out  std_logic;
  calibration_success    : out  std_logic
  );
end component;

constant AXI_BURST_LENGTH : integer range 1 to 256 := 64;

signal sys_reset_n       : std_logic;

signal mem_reset_final   : std_logic;
signal mem_reset_final_n : std_logic;
signal mem_reset         : std_logic_vector(0 downto 0);
signal mem_reset_status  : std_logic;

signal local_cal_busy    : std_logic;
signal local_cal_success : std_logic;
signal local_cal_fail    : std_logic;

begin

sys_reset_n         <= not sys_reset;

mem_reset_final     <= mem_reset(0);
mem_reset_final_n   <= not mem_reset_final;

uut : hps_ddr4
port map (
  ref_clk                => ref_clk,
  mem_0_ck_t             => mem_ck_t,
  mem_0_ck_c             => mem_ck_c,
  mem_0_cke              => mem_cke,
  mem_0_odt              => mem_odt,
  mem_0_cs_n             => mem_cs_n,
  mem_0_a                => mem_a,
  mem_0_ba               => mem_ba,
  mem_0_bg               => mem_bg,
  mem_0_act_n            => mem_act_n,
  mem_0_par              => mem_par,
  mem_0_alert_n          => mem_alert_n,
  mem_0_reset_n          => mem_reset_n,
  mem_0_dq               => mem_dq,
  mem_0_dqs_t            => mem_dqs_t,
  mem_0_dqs_c            => mem_dqs_c,
  mem_0_dbi_n            => mem_dbi_n,
  oct_rzqin_0            => oct_rzqin,
  s0_axi4lite_clock      => sys_clk,
  s0_axi4lite_reset_n    => sys_reset_n
  );

u0_mem_test : mem_test_initiator_wrapper
generic map (
  TEST_CTRL_CLK_PERIOD   => TEST_CTRL_CLK_PERIOD,
  ADDR_WIDTH             => 32,
  MEM_DATA_WIDTH         => 32,
  EMIF_DATA_WIDTH        => 256,
  AXI_BURST_LENGTH       => AXI_BURST_LENGTH
  )
port map (
  test_ctrl_aclk         => sys_clk,
  test_ctrl_areset       => sys_reset,
  test_ctrl_awaddr       => test_ctrl_awaddr, 
  test_ctrl_awvalid      => test_ctrl_awvalid, 
  test_ctrl_awready      => test_ctrl_awready, 
  test_ctrl_awprot       => test_ctrl_awprot, 
  test_ctrl_wdata        => test_ctrl_wdata, 
  test_ctrl_wstrb        => test_ctrl_wstrb, 
  test_ctrl_wvalid       => test_ctrl_wvalid, 
  test_ctrl_wready       => test_ctrl_wready, 
  test_ctrl_bresp        => test_ctrl_bresp, 			
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
  error_log_aclk         => sys_clk,    
  error_log_areset       => sys_reset,    
  error_log_awaddr       => error_log_awaddr,    
  error_log_awvalid      => error_log_awvalid,    
  error_log_awready      => error_log_awready,    
  error_log_awprot       => error_log_awprot,    
  error_log_wdata        => error_log_wdata,    
  error_log_wstrb        => error_log_wstrb,    
  error_log_wvalid       => error_log_wvalid,    
  error_log_wready       => error_log_wready,    
  error_log_bresp        => error_log_bresp ,    			
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
  initiator_clk          => initiator_clk,
  mem_usr_clk            => mem_usr_clk,
  mem_usr_reset          => mem_usr_reset,
  mem_reset              => mem_reset(0),
  mem_reset_status       => mem_reset_status,
  calibration_success    => local_cal_success,
  calibration_fail       => local_cal_fail,
  cattrip                => '0',
  temp                   => (others => '0')  
  );

u1_calibration_polling : cal_status_polling
port map (
  sys_clk                => sys_clk,
  sys_reset              => sys_reset,
  mem_reset              => mem_reset_final,
  calibration_busy       => local_cal_busy,   
  calibration_fail       => local_cal_fail,
  calibration_success    => local_cal_success   
  );

mem_reset_status <= not local_cal_busy;

end rtl;