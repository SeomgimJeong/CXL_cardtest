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
-- Title       : HPS DDR4 Calibration Polling
-- Project     : IA-860m
--------------------------------------------------------------------------------
-- Description : DDR4 Calibration Status Polling.
--               For M-Series EMIF, the AXI-Lite bus must be polled for 
--               calibration status.
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

entity cal_status_polling is
port (
  sys_clk                : in   std_logic;
  sys_reset              : in   std_logic;
  mem_reset              : in   std_logic;
  calibration_busy       : out  std_logic;
  calibration_fail       : out  std_logic;
  calibration_success    : out  std_logic
  );
end entity cal_status_polling;

architecture rtl of cal_status_polling is

component hps_emif_status_noc_initiator
port (
  s0_axi4lite_awaddr  : in  std_logic_vector(43 downto 0) := (others => '0'); 
  s0_axi4lite_awvalid : in  std_logic                     := '0';             
  s0_axi4lite_awready : out std_logic;                                        
  s0_axi4lite_wdata   : in  std_logic_vector(31 downto 0) := (others => '0'); 
  s0_axi4lite_wstrb   : in  std_logic_vector(3 downto 0)  := (others => '0'); 
  s0_axi4lite_wvalid  : in  std_logic                     := '0';             
  s0_axi4lite_wready  : out std_logic;                                        
  s0_axi4lite_bresp   : out std_logic_vector(1 downto 0);                     
  s0_axi4lite_bvalid  : out std_logic;                                        
  s0_axi4lite_bready  : in  std_logic                     := '0';             
  s0_axi4lite_araddr  : in  std_logic_vector(43 downto 0) := (others => '0'); 
  s0_axi4lite_arvalid : in  std_logic                     := '0';             
  s0_axi4lite_arready : out std_logic;                                        
  s0_axi4lite_rdata   : out std_logic_vector(31 downto 0);                    
  s0_axi4lite_rresp   : out std_logic_vector(1 downto 0);                     
  s0_axi4lite_rvalid  : out std_logic;                                        
  s0_axi4lite_rready  : in  std_logic                     := '0';             
  s0_axi4lite_awprot  : in  std_logic_vector(2 downto 0)  := (others => '0'); 
  s0_axi4lite_arprot  : in  std_logic_vector(2 downto 0)  := (others => '0'); 
  s0_axi4lite_aclk    : in  std_logic                     := '0';             
  s0_axi4lite_aresetn : in  std_logic                     := '0'              
);
end component;

component axilite_conversion_44 
port (
  ACLK                 : in    std_logic;
  ARESET               : in    std_logic;
  mstr_addr            : in    std_logic_vector(43 downto 0);
  mstr_wr_data         : in    std_logic_vector(31 downto 0);
  mstr_wr_byte_en      : in    std_logic_vector(3 downto 0);
  mstr_wr_en           : in    std_logic;
  mstr_rd_en           : in    std_logic;
  mstr_wr_rdy          : out   std_logic;
  mstr_rd_data         : out   std_logic_vector(31 downto 0);
  mstr_rd_rdy          : out   std_logic;
  AWADDR               : out   std_logic_vector(43 downto 0);
  AWVALID              : out   std_logic;
  AWREADY              : in    std_logic;
  WDATA                : out   std_logic_vector(31 downto 0);
  WSTRB                : out   std_logic_vector(3 downto 0);
  WVALID               : out   std_logic;
  WREADY               : in    std_logic;
  BRESP                : in    std_logic_vector(1 downto 0);
  BVALID               : in    std_logic;
  BREADY               : out   std_logic;
  ARADDR               : out   std_logic_vector(43 downto 0);
  ARVALID              : out   std_logic;
  ARREADY              : in    std_logic;
  RDATA                : in    std_logic_vector(31 downto 0);
  RRESP                : in    std_logic_vector(1 downto 0);
  RVALID               : in    std_logic;
  RREADY               : out   std_logic;
  resp_err             : out   std_logic_vector(1 downto 0);
  to_err               : out   std_logic;
  clear_errors         : in    std_logic
  );
end component;  

signal sys_reset_n          : std_logic;

signal test_addr            : std_logic_vector(43 downto 0) := (others => '0');
signal test_wr_data         : std_logic_vector(31 downto 0) := (others => '0');
signal test_wr_byte_en      : std_logic_vector(3 downto 0) := (others => '0');
signal test_wr_en           : std_logic := '0';
signal test_rd_en           : std_logic := '0';
signal test_wr_rdy          : std_logic;
signal test_rd_data         : std_logic_vector(31 downto 0);
signal test_rd_rdy          : std_logic;

signal awaddr               : std_logic_vector(43 downto 0);
signal awvalid              : std_logic;
signal awready              : std_logic;
signal wdata                : std_logic_vector(31 downto 0);
signal wstrb                : std_logic_vector(3 downto 0);
signal wvalid               : std_logic;
signal wready               : std_logic;
signal bresp                : std_logic_vector(1 downto 0);
signal bvalid               : std_logic;
signal bready               : std_logic;
signal araddr               : std_logic_vector(43 downto 0);
signal arvalid              : std_logic;
signal arready              : std_logic;
signal rdata                : std_logic_vector(31 downto 0);
signal rresp                : std_logic_vector(1 downto 0);
signal rvalid               : std_logic;
signal rready               : std_logic;

type POLLING_STATES is (IDLE, WAIT_100, READ_STATUS, SET_STATUS_EXT, POLLING_COMPLETE);
signal polling_fsm          : POLLING_STATES;

signal wait_count           : integer range 0 to 100;
signal cal_status           : std_logic_vector(2 downto 0);

begin

sys_reset_n <= not sys_reset;

process (sys_clk)
begin
  if rising_edge(sys_clk) then
    if sys_reset='1' or mem_reset='1' then
      polling_fsm               <= IDLE;
      test_addr                 <= (others => '0');
      test_wr_data              <= (others => '0');
      test_wr_byte_en           <= (others => '0');
      test_wr_en                <= '0';
      test_rd_en                <= '0';
      wait_count                <= 100;
      cal_status                <= "100";
      calibration_busy          <= '1';
      calibration_fail          <= '0';
      calibration_success       <= '0';
    else                        
      case polling_fsm is       
        when IDLE =>            
          polling_fsm           <= WAIT_100;
          wait_count            <= 100;
        when WAIT_100 =>
          if wait_count=0 then
            polling_fsm         <= READ_STATUS;
          else
            wait_count          <= wait_count-1;
          end if;
        when READ_STATUS =>
          if test_rd_en='1' and test_rd_rdy='1' then
            cal_status          <= test_rd_data(2 downto 0);
            test_rd_en          <= '0';
            polling_fsm         <= SET_STATUS_EXT;
          else                  
            test_rd_en          <= '1';
            test_addr           <= x"00005000400";
          end if;
        when SET_STATUS_EXT =>
          calibration_busy      <= cal_status(2);
          calibration_fail      <= cal_status(1);
          calibration_success   <= cal_status(0);
          if cal_status="001" then
            polling_fsm         <= POLLING_COMPLETE;
          else
            polling_fsm         <= IDLE;
          end if;
        when POLLING_COMPLETE =>
          polling_fsm           <= POLLING_COMPLETE;
        when others =>
          polling_fsm           <= IDLE;
          test_addr             <= (others => '0');
          test_wr_data          <= (others => '0');
          test_wr_byte_en       <= (others => '0');
          test_wr_en            <= '0';
          test_rd_en            <= '0';
          wait_count            <= 100;
          cal_status            <= "100";
          calibration_busy      <= '1';
          calibration_fail      <= '0';
          calibration_success   <= '0';
      end case;
    end if;
  end if;
end process;         
    
u0_noc_initiator : hps_emif_status_noc_initiator
port map (
  s0_axi4lite_awaddr  => awaddr,
  s0_axi4lite_awvalid => awvalid,
  s0_axi4lite_awready => awready,
  s0_axi4lite_wdata   => wdata,
  s0_axi4lite_wstrb   => wstrb,
  s0_axi4lite_wvalid  => wvalid,
  s0_axi4lite_wready  => wready,
  s0_axi4lite_bresp   => bresp,
  s0_axi4lite_bvalid  => bvalid,
  s0_axi4lite_bready  => bready,
  s0_axi4lite_araddr  => araddr,
  s0_axi4lite_arvalid => arvalid,
  s0_axi4lite_arready => arready,
  s0_axi4lite_rdata   => rdata,
  s0_axi4lite_rresp   => rresp,
  s0_axi4lite_rvalid  => rvalid,
  s0_axi4lite_rready  => rready,
  s0_axi4lite_awprot  => "010",
  s0_axi4lite_arprot  => "010",
  s0_axi4lite_aclk    => sys_clk,
  s0_axi4lite_aresetn => sys_reset_n
);

u1_ctrl2axilite : axilite_conversion_44 
port map (
  ACLK                 => sys_clk,
  ARESET               => sys_reset,
  mstr_addr            => test_addr,                       
  mstr_wr_data         => test_wr_data,                    
  mstr_wr_byte_en      => test_wr_byte_en,                 
  mstr_wr_en           => test_wr_en,                      
  mstr_rd_en           => test_rd_en,                      
  mstr_wr_rdy          => test_wr_rdy,                     
  mstr_rd_data         => test_rd_data,                    
  mstr_rd_rdy          => test_rd_rdy,                     
  AWADDR               => awaddr,
  AWVALID              => awvalid,
  AWREADY              => awready,
  WDATA                => wdata,
  WSTRB                => wstrb,
  WVALID               => wvalid,
  WREADY               => wready,
  BRESP                => bresp,
  BVALID               => bvalid,
  BREADY               => bready,
  ARADDR               => araddr,
  ARVALID              => arvalid,
  ARREADY              => arready,
  RDATA                => rdata,
  RRESP                => rresp,
  RVALID               => rvalid,
  RREADY               => rready,
  resp_err             => open,
  to_err               => open,
  clear_errors         => '0'
  );

end rtl;