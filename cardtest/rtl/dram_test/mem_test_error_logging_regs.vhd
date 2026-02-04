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
-- Title       : Error Logging Interface
-- Project     : Memory Test
--------------------------------------------------------------------------------
-- Description : This component provides an AXI4-Lite interface to access the
--               error logging RAMs.
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
-- None
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity mem_test_error_logging_regs is
generic (
  ADDR_WIDTH                      :      integer := 32;
  EMIF_DATA_WIDTH                 :      integer := 512;
  MEM_DATA_WIDTH                  :      integer := 64
  );
port (
  -- Clock and Reset
  aclk                            : in   std_logic;
  areset                          : in   std_logic;
  -- Write Address Interface      
  awaddr                          : in   std_logic_vector(7 downto 0);
  awvalid                         : in   std_logic;
  awready                         : out  std_logic;
  awprot                          : in   std_logic_vector(2 downto 0);
  -- Write Data Interface         
  wdata                           : in   std_logic_vector(31 downto 0);
  wstrb                           : in   std_logic_vector(3 downto 0);
  wvalid                          : in   std_logic;
  wready                          : out  std_logic;
  -- Write Response Interface     
  bresp                           : out  std_logic_vector(1 downto 0);						
  bvalid                          : out  std_logic;									
  bready                          : in   std_logic;									
  -- Read Address Interface     											
  araddr                          : in   std_logic_vector(7 downto 0);						
  arvalid                         : in   std_logic;								
  arready                         : out  std_logic;								
  arprot                          : in   std_logic_vector(2 downto 0);
  -- Read Response Interface     										
  rdata                           : out  std_logic_vector(31 downto 0);				
  rresp                           : out  std_logic_vector(1 downto 0);				
  rvalid                          : out  std_logic;							
  rready                          : in   std_logic;							
  -- Error Logging Interface (From Memory Test)
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
end entity mem_test_error_logging_regs;

architecture rtl of mem_test_error_logging_regs is

component altera_dprw_ram
generic (
  AWIDTH   : natural := 9;
  DWIDTH   : natural := 32
  );
port (
  clka     : in  std_logic;
  clkb     : in  std_logic;
  wea      : in  std_logic;
  web      : in  std_logic;
  addra    : in  std_logic_vector(AWIDTH-1 downto 0);
  addrb    : in  std_logic_vector(AWIDTH-1 downto 0);
  dia      : in  std_logic_vector(DWIDTH-1 downto 0);
  dib      : in  std_logic_vector(DWIDTH-1 downto 0);
  doa      : out std_logic_vector(DWIDTH-1 downto 0);
  dob      : out std_logic_vector(DWIDTH-1 downto 0)
  );
end component;

constant BURST_LENGTH                      : integer := EMIF_DATA_WIDTH/MEM_DATA_WIDTH;

type READ_STATES is (RS_ADDR, RS_DATA);
signal rstate                              : READ_STATES;

type WRITE_STATES is (WS_ADDR, WS_DATA, WS_RESP);
signal wstate                              : WRITE_STATES;

signal arready_i                           : std_logic;
signal rvalid_i                            : std_logic;
signal rdata_i                             : std_logic_vector(31 downto 0);
signal awready_i                           : std_logic;
signal wready_i                            : std_logic;
signal bvalid_i                            : std_logic;

signal waddr                               : std_logic_vector(7 downto 0);

-- Address Constants
constant ERROR_LOG_ADDR                    : std_logic_vector(7 downto 0) := x"00";
constant FAILED_ADDR0_ADDR                 : std_logic_vector(7 downto 0) := x"04";
constant FAILED_ADDR1_ADDR                 : std_logic_vector(7 downto 0) := x"08";
constant EXPECTED_DATA0_0_ADDR             : std_logic_vector(7 downto 0) := x"0C";
constant EXPECTED_DATA0_1_ADDR             : std_logic_vector(7 downto 0) := x"10";
constant EXPECTED_DATA0_2_ADDR             : std_logic_vector(7 downto 0) := x"14";
constant EXPECTED_DATA1_0_ADDR             : std_logic_vector(7 downto 0) := x"18";
constant EXPECTED_DATA1_1_ADDR             : std_logic_vector(7 downto 0) := x"1C";
constant EXPECTED_DATA1_2_ADDR             : std_logic_vector(7 downto 0) := x"20";
constant EXPECTED_DATA2_0_ADDR             : std_logic_vector(7 downto 0) := x"24";
constant EXPECTED_DATA2_1_ADDR             : std_logic_vector(7 downto 0) := x"28";
constant EXPECTED_DATA2_2_ADDR             : std_logic_vector(7 downto 0) := x"2C";
constant EXPECTED_DATA3_0_ADDR             : std_logic_vector(7 downto 0) := x"30";
constant EXPECTED_DATA3_1_ADDR             : std_logic_vector(7 downto 0) := x"34";
constant EXPECTED_DATA3_2_ADDR             : std_logic_vector(7 downto 0) := x"38";
constant EXPECTED_DATA4_0_ADDR             : std_logic_vector(7 downto 0) := x"3C";
constant EXPECTED_DATA4_1_ADDR             : std_logic_vector(7 downto 0) := x"40";
constant EXPECTED_DATA4_2_ADDR             : std_logic_vector(7 downto 0) := x"44";
constant EXPECTED_DATA5_0_ADDR             : std_logic_vector(7 downto 0) := x"48";
constant EXPECTED_DATA5_1_ADDR             : std_logic_vector(7 downto 0) := x"4C";
constant EXPECTED_DATA5_2_ADDR             : std_logic_vector(7 downto 0) := x"50";
constant EXPECTED_DATA6_0_ADDR             : std_logic_vector(7 downto 0) := x"54";
constant EXPECTED_DATA6_1_ADDR             : std_logic_vector(7 downto 0) := x"58";
constant EXPECTED_DATA6_2_ADDR             : std_logic_vector(7 downto 0) := x"5C";
constant EXPECTED_DATA7_0_ADDR             : std_logic_vector(7 downto 0) := x"60";
constant EXPECTED_DATA7_1_ADDR             : std_logic_vector(7 downto 0) := x"64";
constant EXPECTED_DATA7_2_ADDR             : std_logic_vector(7 downto 0) := x"68";
constant RECEIVED_DATA0_0_ADDR             : std_logic_vector(7 downto 0) := x"6C";
constant RECEIVED_DATA0_1_ADDR             : std_logic_vector(7 downto 0) := x"70";
constant RECEIVED_DATA0_2_ADDR             : std_logic_vector(7 downto 0) := x"74";
constant RECEIVED_DATA1_0_ADDR             : std_logic_vector(7 downto 0) := x"78";
constant RECEIVED_DATA1_1_ADDR             : std_logic_vector(7 downto 0) := x"7C";
constant RECEIVED_DATA1_2_ADDR             : std_logic_vector(7 downto 0) := x"80";
constant RECEIVED_DATA2_0_ADDR             : std_logic_vector(7 downto 0) := x"84";
constant RECEIVED_DATA2_1_ADDR             : std_logic_vector(7 downto 0) := x"88";
constant RECEIVED_DATA2_2_ADDR             : std_logic_vector(7 downto 0) := x"8C";
constant RECEIVED_DATA3_0_ADDR             : std_logic_vector(7 downto 0) := x"90";
constant RECEIVED_DATA3_1_ADDR             : std_logic_vector(7 downto 0) := x"94";
constant RECEIVED_DATA3_2_ADDR             : std_logic_vector(7 downto 0) := x"98";
constant RECEIVED_DATA4_0_ADDR             : std_logic_vector(7 downto 0) := x"9C";
constant RECEIVED_DATA4_1_ADDR             : std_logic_vector(7 downto 0) := x"A0";
constant RECEIVED_DATA4_2_ADDR             : std_logic_vector(7 downto 0) := x"A4";
constant RECEIVED_DATA5_0_ADDR             : std_logic_vector(7 downto 0) := x"A8";
constant RECEIVED_DATA5_1_ADDR             : std_logic_vector(7 downto 0) := x"AC";
constant RECEIVED_DATA5_2_ADDR             : std_logic_vector(7 downto 0) := x"B0";
constant RECEIVED_DATA6_0_ADDR             : std_logic_vector(7 downto 0) := x"B4";
constant RECEIVED_DATA6_1_ADDR             : std_logic_vector(7 downto 0) := x"B8";
constant RECEIVED_DATA6_2_ADDR             : std_logic_vector(7 downto 0) := x"BC";
constant RECEIVED_DATA7_0_ADDR             : std_logic_vector(7 downto 0) := x"C0";
constant RECEIVED_DATA7_1_ADDR             : std_logic_vector(7 downto 0) := x"C4";
constant RECEIVED_DATA7_2_ADDR             : std_logic_vector(7 downto 0) := x"C8";

signal error_log_address                   : std_logic_vector(9 downto 0);

signal address_mem_rdata                   : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal expected_mem_rdata                  : std_logic_vector(EMIF_DATA_WIDTH-1 downto 0);
signal received_mem_rdata                  : std_logic_vector(EMIF_DATA_WIDTH-1 downto 0);

signal failed_addr0                        : std_logic_vector(31 downto 0):= (others => '0');
signal failed_addr1                        : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data0_0                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data0_1                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data0_2                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data1_0                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data1_1                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data1_2                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data2_0                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data2_1                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data2_2                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data3_0                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data3_1                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data3_2                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data4_0                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data4_1                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data4_2                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data5_0                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data5_1                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data5_2                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data6_0                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data6_1                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data6_2                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data7_0                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data7_1                    : std_logic_vector(31 downto 0):= (others => '0');
signal expected_data7_2                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data0_0                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data0_1                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data0_2                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data1_0                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data1_1                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data1_2                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data2_0                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data2_1                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data2_2                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data3_0                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data3_1                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data3_2                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data4_0                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data4_1                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data4_2                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data5_0                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data5_1                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data5_2                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data6_0                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data6_1                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data6_2                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data7_0                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data7_1                    : std_logic_vector(31 downto 0):= (others => '0');
signal received_data7_2                    : std_logic_vector(31 downto 0):= (others => '0');

begin

-- Error Log RAMs
-- Error Address
u0_error_addr_ram : altera_dprw_ram
generic map (
  AWIDTH   => 10,
  DWIDTH   => ADDR_WIDTH
  )
port map (
  clka     => mem_clk,
  clkb     => aclk,
  wea      => address_mem_wr,
  web      => '0',
  addra    => address_mem_addr,
  addrb    => error_log_address,
  dia      => address_mem_data,
  dib      => (others => '0'),
  doa      => open,
  dob      => address_mem_rdata
  );

-- Expected Data  
u1_expected_data_ram : altera_dprw_ram
generic map (
  AWIDTH   => 10,
  DWIDTH   => EMIF_DATA_WIDTH
  )
port map (
  clka     => mem_clk,
  clkb     => aclk,
  wea      => expected_mem_wr,
  web      => '0',
  addra    => expected_mem_addr,
  addrb    => error_log_address,
  dia      => expected_mem_data,
  dib      => (others => '0'),
  doa      => open,
  dob      => expected_mem_rdata
  );

-- Received Data  
u2_expected_data_ram : altera_dprw_ram
generic map (
  AWIDTH   => 10,
  DWIDTH   => EMIF_DATA_WIDTH
  )
port map (
  clka     => mem_clk,
  clkb     => aclk,
  wea      => received_mem_wr,
  web      => '0',
  addra    => received_mem_addr,
  addrb    => error_log_address,
  dia      => received_mem_data,
  dib      => (others => '0'),
  doa      => open,
  dob      => received_mem_rdata
  );

-- As the data widths of the memories are flexible, we will create determine the data for their relative 
-- register address locations here.
-- For the data, the presumptions will be that we either have a burst of 4 or burst of 8.
-- Will also presume that a memory interface will be 32-bits, 40-bits, 64-bits or 72-bits.
g_failed_addr_lessthan32 : if ADDR_WIDTH < 32 generate
  failed_addr0(31 downto ADDR_WIDTH)        <= (others => '0');
  failed_addr0(ADDR_WIDTH-1 downto 0)       <= address_mem_rdata;
  failed_addr1                              <= (others => '0');
end generate g_failed_addr_lessthan32;

g_failed_addr_32 : if ADDR_WIDTH=32 generate
  failed_addr0                              <= address_mem_rdata;
  failed_addr1                              <= (others => '0');
end generate g_failed_addr_32;

g_failed_addr_over32_lessthan64 : if ((ADDR_WIDTH > 32) and (ADDR_WIDTH < 64)) generate
  failed_addr0                              <= address_mem_rdata(31 downto 0);
  failed_addr1(31 downto (ADDR_WIDTH-32))   <= (others => '0');
  failed_addr1(((ADDR_WIDTH-32)-1) downto 0)<= address_mem_rdata(ADDR_WIDTH-1 downto 32); 
end generate g_failed_addr_over32_lessthan64;

g_failed_addr_64 : if ADDR_WIDTH=64 generate
  failed_addr0                              <= address_mem_rdata(31 downto 0);
  failed_addr1                              <= address_mem_rdata(63 downto 32);
end generate g_failed_addr_64;

g_burstof4 : if BURST_LENGTH=4 generate
  g_datawidth32 : if MEM_DATA_WIDTH=32 generate
    expected_data0_0 <= expected_mem_rdata(31 downto 0);
    expected_data0_1 <= (others => '0');
    expected_data0_2 <= (others => '0');
    expected_data1_0 <= expected_mem_rdata(63 downto 32);
    expected_data1_1 <= (others => '0');
    expected_data1_2 <= (others => '0');
    expected_data2_0 <= expected_mem_rdata(95 downto 64);
    expected_data2_1 <= (others => '0');
    expected_data2_2 <= (others => '0');
    expected_data3_0 <= expected_mem_rdata(127 downto 96);
    expected_data3_1 <= (others => '0');
    expected_data3_2 <= (others => '0');
    expected_data4_0 <= (others => '0');
    expected_data4_1 <= (others => '0');
    expected_data4_2 <= (others => '0');
    expected_data5_0 <= (others => '0');
    expected_data5_1 <= (others => '0');
    expected_data5_2 <= (others => '0');
    expected_data6_0 <= (others => '0');
    expected_data6_1 <= (others => '0');
    expected_data6_2 <= (others => '0');
    expected_data7_0 <= (others => '0');
    expected_data7_1 <= (others => '0');
    expected_data7_2 <= (others => '0');
    received_data0_0 <= received_mem_rdata(31 downto 0);
    received_data0_1 <= (others => '0');
    received_data0_2 <= (others => '0');
    received_data1_0 <= received_mem_rdata(63 downto 32);
    received_data1_1 <= (others => '0');
    received_data1_2 <= (others => '0');
    received_data2_0 <= received_mem_rdata(95 downto 64);
    received_data2_1 <= (others => '0');
    received_data2_2 <= (others => '0');
    received_data3_0 <= received_mem_rdata(127 downto 96);
    received_data3_1 <= (others => '0');
    received_data3_2 <= (others => '0');  
    received_data4_0 <= (others => '0');
    received_data4_1 <= (others => '0');
    received_data4_2 <= (others => '0');
    received_data5_0 <= (others => '0');
    received_data5_1 <= (others => '0');
    received_data5_2 <= (others => '0');
    received_data6_0 <= (others => '0');
    received_data6_1 <= (others => '0');
    received_data6_2 <= (others => '0');
    received_data7_0 <= (others => '0');
    received_data7_1 <= (others => '0');
    received_data7_2 <= (others => '0');
  end generate g_datawidth32;
  g_datawidth40 : if MEM_DATA_WIDTH=40 generate
    expected_data0_0 <= expected_mem_rdata(31 downto 0);
    expected_data0_1 <= x"000000" & expected_mem_rdata(39 downto 32);
    expected_data0_2 <= (others => '0');
    expected_data1_0 <= expected_mem_rdata(71 downto 40);
    expected_data1_1 <= x"000000" & expected_mem_rdata(79 downto 72);
    expected_data1_2 <= (others => '0');
    expected_data2_0 <= expected_mem_rdata(111 downto 80);
    expected_data2_1 <= x"000000" & expected_mem_rdata(119 downto 112);
    expected_data2_2 <= (others => '0');
    expected_data3_0 <= expected_mem_rdata(151 downto 120);
    expected_data3_1 <= x"000000" & expected_mem_rdata(159 downto 152);
    expected_data3_2 <= (others => '0');
    expected_data4_0 <= (others => '0');
    expected_data4_1 <= (others => '0');
    expected_data4_2 <= (others => '0');
    expected_data5_0 <= (others => '0');
    expected_data5_1 <= (others => '0');
    expected_data5_2 <= (others => '0');
    expected_data6_0 <= (others => '0');
    expected_data6_1 <= (others => '0');
    expected_data6_2 <= (others => '0');
    expected_data7_0 <= (others => '0');
    expected_data7_1 <= (others => '0');
    expected_data7_2 <= (others => '0');
    received_data0_0 <= received_mem_rdata(31 downto 0);
    received_data0_1 <= x"000000" & received_mem_rdata(39 downto 32);
    received_data0_2 <= (others => '0');
    received_data1_0 <= received_mem_rdata(71 downto 40);
    received_data1_1 <= x"000000" & received_mem_rdata(79 downto 72);
    received_data1_2 <= (others => '0');
    received_data2_0 <= received_mem_rdata(111 downto 80);
    received_data2_1 <= x"000000" & received_mem_rdata(119 downto 112);
    received_data2_2 <= (others => '0');
    received_data3_0 <= received_mem_rdata(151 downto 120);
    received_data3_1 <= x"000000" & received_mem_rdata(159 downto 152);
    received_data3_2 <= (others => '0');   
    received_data4_0 <= (others => '0');
    received_data4_1 <= (others => '0');
    received_data4_2 <= (others => '0');
    received_data5_0 <= (others => '0');
    received_data5_1 <= (others => '0');
    received_data5_2 <= (others => '0');
    received_data6_0 <= (others => '0');
    received_data6_1 <= (others => '0');
    received_data6_2 <= (others => '0');
    received_data7_0 <= (others => '0');
    received_data7_1 <= (others => '0');
    received_data7_2 <= (others => '0');
  end generate g_datawidth40;
  g_datawidth64 : if MEM_DATA_WIDTH=64 generate
    expected_data0_0 <= expected_mem_rdata(31 downto 0);
    expected_data0_1 <= expected_mem_rdata(63 downto 32);
    expected_data0_2 <= (others => '0');
    expected_data1_0 <= expected_mem_rdata(95 downto 64);
    expected_data1_1 <= expected_mem_rdata(127 downto 96);
    expected_data1_2 <= (others => '0');
    expected_data2_0 <= expected_mem_rdata(159 downto 128);
    expected_data2_1 <= expected_mem_rdata(191 downto 160);
    expected_data2_2 <= (others => '0');
    expected_data3_0 <= expected_mem_rdata(223 downto 192);
    expected_data3_1 <= expected_mem_rdata(255 downto 224);
    expected_data3_2 <= (others => '0');
    expected_data3_2 <= (others => '0');
    expected_data4_0 <= (others => '0');
    expected_data4_1 <= (others => '0');
    expected_data4_2 <= (others => '0');
    expected_data5_0 <= (others => '0');
    expected_data5_1 <= (others => '0');
    expected_data5_2 <= (others => '0');
    expected_data6_0 <= (others => '0');
    expected_data6_1 <= (others => '0');
    expected_data6_2 <= (others => '0');
    expected_data7_0 <= (others => '0');
    expected_data7_1 <= (others => '0');
    expected_data7_2 <= (others => '0');
    received_data0_0 <= received_mem_rdata(31 downto 0);
    received_data0_1 <= received_mem_rdata(63 downto 32);
    received_data0_2 <= (others => '0');
    received_data1_0 <= received_mem_rdata(95 downto 64);
    received_data1_1 <= received_mem_rdata(127 downto 96);
    received_data1_2 <= (others => '0');
    received_data2_0 <= received_mem_rdata(159 downto 128);
    received_data2_1 <= received_mem_rdata(191 downto 160);
    received_data2_2 <= (others => '0');
    received_data3_0 <= received_mem_rdata(223 downto 192);
    received_data3_1 <= received_mem_rdata(255 downto 224);
    received_data3_2 <= (others => '0');
    received_data4_0 <= (others => '0');
    received_data4_1 <= (others => '0');
    received_data4_2 <= (others => '0');
    received_data5_0 <= (others => '0');
    received_data5_1 <= (others => '0');
    received_data5_2 <= (others => '0');
    received_data6_0 <= (others => '0');
    received_data6_1 <= (others => '0');
    received_data6_2 <= (others => '0');
    received_data7_0 <= (others => '0');
    received_data7_1 <= (others => '0');
    received_data7_2 <= (others => '0');    
  end generate g_datawidth64;
  g_datawidth72 : if MEM_DATA_WIDTH=72 generate
    expected_data0_0 <= expected_mem_rdata(31 downto 0);
    expected_data0_1 <= expected_mem_rdata(63 downto 32);
    expected_data0_2 <= x"000000" & expected_mem_rdata(71 downto 64);
    expected_data1_0 <= expected_mem_rdata(103 downto 72);
    expected_data1_1 <= expected_mem_rdata(135 downto 104);
    expected_data1_2 <= x"000000" & expected_mem_rdata(143 downto 136);
    expected_data2_0 <= expected_mem_rdata(175 downto 144);
    expected_data2_1 <= expected_mem_rdata(207 downto 176);
    expected_data2_2 <= x"000000" & expected_mem_rdata(215 downto 208);
    expected_data3_0 <= expected_mem_rdata(247 downto 216);
    expected_data3_1 <= expected_mem_rdata(279 downto 248);
    expected_data3_2 <= x"000000" & expected_mem_rdata(287 downto 280);
    expected_data4_0 <= (others => '0');
    expected_data4_1 <= (others => '0');
    expected_data4_2 <= (others => '0');
    expected_data5_0 <= (others => '0');
    expected_data5_1 <= (others => '0');
    expected_data5_2 <= (others => '0');
    expected_data6_0 <= (others => '0');
    expected_data6_1 <= (others => '0');
    expected_data6_2 <= (others => '0');
    expected_data7_0 <= (others => '0');
    expected_data7_1 <= (others => '0');
    expected_data7_2 <= (others => '0');
    received_data0_0 <= received_mem_rdata(31 downto 0);
    received_data0_1 <= received_mem_rdata(63 downto 32);
    received_data0_2 <= x"000000" & received_mem_rdata(71 downto 64);
    received_data1_0 <= received_mem_rdata(103 downto 72);
    received_data1_1 <= received_mem_rdata(135 downto 104);
    received_data1_2 <= x"000000" & received_mem_rdata(143 downto 136);
    received_data2_0 <= received_mem_rdata(175 downto 144);
    received_data2_1 <= received_mem_rdata(207 downto 176);
    received_data2_2 <= x"000000" & received_mem_rdata(215 downto 208);
    received_data3_0 <= received_mem_rdata(247 downto 216);
    received_data3_1 <= received_mem_rdata(279 downto 248);
    received_data3_2 <= x"000000" & received_mem_rdata(287 downto 280);   
    received_data4_0 <= (others => '0');
    received_data4_1 <= (others => '0');
    received_data4_2 <= (others => '0');
    received_data5_0 <= (others => '0');
    received_data5_1 <= (others => '0');
    received_data5_2 <= (others => '0');
    received_data6_0 <= (others => '0');
    received_data6_1 <= (others => '0');
    received_data6_2 <= (others => '0');
    received_data7_0 <= (others => '0');
    received_data7_1 <= (others => '0');
    received_data7_2 <= (others => '0');  
  end generate g_datawidth72;
end generate g_burstof4;
g_burstof8 : if BURST_LENGTH=8 generate
  g_datawidth32 : if MEM_DATA_WIDTH=32 generate
    expected_data0_0 <= expected_mem_rdata(31 downto 0);
    expected_data0_1 <= (others => '0');
    expected_data0_2 <= (others => '0');
    expected_data1_0 <= expected_mem_rdata(63 downto 32);
    expected_data1_1 <= (others => '0');
    expected_data1_2 <= (others => '0');
    expected_data2_0 <= expected_mem_rdata(95 downto 64);
    expected_data2_1 <= (others => '0');
    expected_data2_2 <= (others => '0');
    expected_data3_0 <= expected_mem_rdata(127 downto 96);
    expected_data3_1 <= (others => '0');
    expected_data3_2 <= (others => '0');
    expected_data4_0 <= expected_mem_rdata(159 downto 128);
    expected_data4_1 <= (others => '0');
    expected_data4_2 <= (others => '0');
    expected_data5_0 <= expected_mem_rdata(191 downto 160);
    expected_data5_1 <= (others => '0');
    expected_data5_2 <= (others => '0');
    expected_data6_0 <= expected_mem_rdata(223 downto 192);
    expected_data6_1 <= (others => '0');
    expected_data6_2 <= (others => '0');
    expected_data7_0 <= expected_mem_rdata(255 downto 224);
    expected_data7_1 <= (others => '0');
    expected_data7_2 <= (others => '0');
    received_data0_0 <= received_mem_rdata(31 downto 0);
    received_data0_1 <= (others => '0');
    received_data0_2 <= (others => '0');
    received_data1_0 <= received_mem_rdata(63 downto 32);
    received_data1_1 <= (others => '0');
    received_data1_2 <= (others => '0');
    received_data2_0 <= received_mem_rdata(95 downto 64);
    received_data2_1 <= (others => '0');
    received_data2_2 <= (others => '0');
    received_data3_0 <= received_mem_rdata(127 downto 96);
    received_data3_1 <= (others => '0');
    received_data3_2 <= (others => '0');  
    received_data4_0 <= received_mem_rdata(159 downto 128);
    received_data4_1 <= (others => '0');
    received_data4_2 <= (others => '0');
    received_data5_0 <= received_mem_rdata(191 downto 160);
    received_data5_1 <= (others => '0');
    received_data5_2 <= (others => '0');
    received_data6_0 <= received_mem_rdata(223 downto 192);
    received_data6_1 <= (others => '0');
    received_data6_2 <= (others => '0');
    received_data7_0 <= received_mem_rdata(255 downto 224);
    received_data7_1 <= (others => '0');
    received_data7_2 <= (others => '0');
  end generate g_datawidth32;
  g_datawidth40 : if MEM_DATA_WIDTH=40 generate
    expected_data0_0 <= expected_mem_rdata(31 downto 0);
    expected_data0_1 <= x"000000" & expected_mem_rdata(39 downto 32);
    expected_data0_2 <= (others => '0');
    expected_data1_0 <= expected_mem_rdata(71 downto 40);
    expected_data1_1 <= x"000000" & expected_mem_rdata(79 downto 72);
    expected_data1_2 <= (others => '0');
    expected_data2_0 <= expected_mem_rdata(111 downto 80);
    expected_data2_1 <= x"000000" & expected_mem_rdata(119 downto 112);
    expected_data2_2 <= (others => '0');
    expected_data3_0 <= expected_mem_rdata(151 downto 120);
    expected_data3_1 <= x"000000" & expected_mem_rdata(159 downto 152);
    expected_data3_2 <= (others => '0');
    expected_data4_0 <= expected_mem_rdata(191 downto 160);
    expected_data4_1 <= x"000000" & expected_mem_rdata(199 downto 192);
    expected_data4_2 <= (others => '0');
    expected_data5_0 <= expected_mem_rdata(231 downto 200);
    expected_data5_1 <= x"000000" & expected_mem_rdata(239 downto 232);
    expected_data5_2 <= (others => '0');
    expected_data6_0 <= expected_mem_rdata(271 downto 240);
    expected_data6_1 <= x"000000" & expected_mem_rdata(279 downto 272);
    expected_data6_2 <= (others => '0');
    expected_data7_0 <= expected_mem_rdata(311 downto 280);
    expected_data7_1 <= x"000000" & expected_mem_rdata(319 downto 312);
    expected_data7_2 <= (others => '0');
    received_data0_0 <= received_mem_rdata(31 downto 0);
    received_data0_1 <= x"000000" & received_mem_rdata(39 downto 32);
    received_data0_2 <= (others => '0');
    received_data1_0 <= received_mem_rdata(71 downto 40);
    received_data1_1 <= x"000000" & received_mem_rdata(79 downto 72);
    received_data1_2 <= (others => '0');
    received_data2_0 <= received_mem_rdata(111 downto 80);
    received_data2_1 <= x"000000" & received_mem_rdata(119 downto 112);
    received_data2_2 <= (others => '0');
    received_data3_0 <= received_mem_rdata(151 downto 120);
    received_data3_1 <= x"000000" & received_mem_rdata(159 downto 152);
    received_data3_2 <= (others => '0');   
    received_data4_0 <= received_mem_rdata(191 downto 160);
    received_data4_1 <= x"000000" & received_mem_rdata(199 downto 192);
    received_data4_2 <= (others => '0');
    received_data5_0 <= received_mem_rdata(231 downto 200);
    received_data5_1 <= x"000000" & received_mem_rdata(239 downto 232);
    received_data5_2 <= (others => '0');
    received_data6_0 <= received_mem_rdata(271 downto 240);
    received_data6_1 <= x"000000" & received_mem_rdata(279 downto 272);
    received_data6_2 <= (others => '0');
    received_data7_0 <= received_mem_rdata(311 downto 280);
    received_data7_1 <= x"000000" & received_mem_rdata(319 downto 312);
    received_data7_2 <= (others => '0');
  end generate g_datawidth40;
  g_datawidth64 : if MEM_DATA_WIDTH=64 generate
    expected_data0_0 <= expected_mem_rdata(31 downto 0);
    expected_data0_1 <= expected_mem_rdata(63 downto 32);
    expected_data0_2 <= (others => '0');
    expected_data1_0 <= expected_mem_rdata(95 downto 64);
    expected_data1_1 <= expected_mem_rdata(127 downto 96);
    expected_data1_2 <= (others => '0');
    expected_data2_0 <= expected_mem_rdata(159 downto 128);
    expected_data2_1 <= expected_mem_rdata(191 downto 160);
    expected_data2_2 <= (others => '0');
    expected_data3_0 <= expected_mem_rdata(223 downto 192);
    expected_data3_1 <= expected_mem_rdata(255 downto 224);
    expected_data3_2 <= (others => '0');
    expected_data4_0 <= expected_mem_rdata(287 downto 256);
    expected_data4_1 <= expected_mem_rdata(319 downto 288);
    expected_data4_2 <= (others => '0');
    expected_data5_0 <= expected_mem_rdata(351 downto 320);
    expected_data5_1 <= expected_mem_rdata(383 downto 352);
    expected_data5_2 <= (others => '0');
    expected_data6_0 <= expected_mem_rdata(415 downto 384);
    expected_data6_1 <= expected_mem_rdata(447 downto 416);
    expected_data6_2 <= (others => '0');
    expected_data7_0 <= expected_mem_rdata(479 downto 448);
    expected_data7_1 <= expected_mem_rdata(511 downto 480);
    expected_data7_2 <= (others => '0');
    received_data0_0 <= received_mem_rdata(31 downto 0);
    received_data0_1 <= received_mem_rdata(63 downto 32);
    received_data0_2 <= (others => '0');
    received_data1_0 <= received_mem_rdata(95 downto 64);
    received_data1_1 <= received_mem_rdata(127 downto 96);
    received_data1_2 <= (others => '0');
    received_data2_0 <= received_mem_rdata(159 downto 128);
    received_data2_1 <= received_mem_rdata(191 downto 160);
    received_data2_2 <= (others => '0');
    received_data3_0 <= received_mem_rdata(223 downto 192);
    received_data3_1 <= received_mem_rdata(255 downto 224);
    received_data3_2 <= (others => '0');
    received_data4_0 <= received_mem_rdata(287 downto 256);
    received_data4_1 <= received_mem_rdata(319 downto 288);
    received_data4_2 <= (others => '0');
    received_data5_0 <= received_mem_rdata(351 downto 320);
    received_data5_1 <= received_mem_rdata(383 downto 352);
    received_data5_2 <= (others => '0');
    received_data6_0 <= received_mem_rdata(415 downto 384);
    received_data6_1 <= received_mem_rdata(447 downto 416);
    received_data6_2 <= (others => '0');
    received_data7_0 <= received_mem_rdata(479 downto 448);
    received_data7_1 <= received_mem_rdata(511 downto 480);
    received_data7_2 <= (others => '0');    
  end generate g_datawidth64;
  g_datawidth72 : if MEM_DATA_WIDTH=72 generate
    expected_data0_0 <= expected_mem_rdata(31 downto 0);
    expected_data0_1 <= expected_mem_rdata(63 downto 32);
    expected_data0_2 <= x"000000" & expected_mem_rdata(71 downto 64);
    expected_data1_0 <= expected_mem_rdata(103 downto 72);
    expected_data1_1 <= expected_mem_rdata(135 downto 104);
    expected_data1_2 <= x"000000" & expected_mem_rdata(143 downto 136);
    expected_data2_0 <= expected_mem_rdata(175 downto 144);
    expected_data2_1 <= expected_mem_rdata(207 downto 176);
    expected_data2_2 <= x"000000" & expected_mem_rdata(215 downto 208);
    expected_data3_0 <= expected_mem_rdata(247 downto 216);
    expected_data3_1 <= expected_mem_rdata(279 downto 248);
    expected_data3_2 <= x"000000" & expected_mem_rdata(287 downto 280);
    expected_data4_0 <= expected_mem_rdata(319 downto 288);
    expected_data4_1 <= expected_mem_rdata(351 downto 320);
    expected_data4_2 <= x"000000" & expected_mem_rdata(359 downto 352);
    expected_data5_0 <= expected_mem_rdata(391 downto 360);
    expected_data5_1 <= expected_mem_rdata(423 downto 392);
    expected_data5_2 <= x"000000" & expected_mem_rdata(431 downto 424);
    expected_data6_0 <= expected_mem_rdata(463 downto 432);
    expected_data6_1 <= expected_mem_rdata(495 downto 464);
    expected_data6_2 <= x"000000" & expected_mem_rdata(503 downto 496);
    expected_data7_0 <= expected_mem_rdata(535 downto 504);
    expected_data7_1 <= expected_mem_rdata(567 downto 536);
    expected_data7_2 <= x"000000" & expected_mem_rdata(575 downto 568);
    received_data0_0 <= received_mem_rdata(31 downto 0);
    received_data0_1 <= received_mem_rdata(63 downto 32);
    received_data0_2 <= x"000000" & received_mem_rdata(71 downto 64);
    received_data1_0 <= received_mem_rdata(103 downto 72);
    received_data1_1 <= received_mem_rdata(135 downto 104);
    received_data1_2 <= x"000000" & received_mem_rdata(143 downto 136);
    received_data2_0 <= received_mem_rdata(175 downto 144);
    received_data2_1 <= received_mem_rdata(207 downto 176);
    received_data2_2 <= x"000000" & received_mem_rdata(215 downto 208);
    received_data3_0 <= received_mem_rdata(247 downto 216);
    received_data3_1 <= received_mem_rdata(279 downto 248);
    received_data3_2 <= x"000000" & received_mem_rdata(287 downto 280);   
    received_data4_0 <= received_mem_rdata(319 downto 288);
    received_data4_1 <= received_mem_rdata(351 downto 320);
    received_data4_2 <= x"000000" & received_mem_rdata(359 downto 352);
    received_data5_0 <= received_mem_rdata(391 downto 360);
    received_data5_1 <= received_mem_rdata(423 downto 392);
    received_data5_2 <= x"000000" & received_mem_rdata(431 downto 424);
    received_data6_0 <= received_mem_rdata(463 downto 432);
    received_data6_1 <= received_mem_rdata(495 downto 464);
    received_data6_2 <= x"000000" & received_mem_rdata(503 downto 496);
    received_data7_0 <= received_mem_rdata(535 downto 504);
    received_data7_1 <= received_mem_rdata(567 downto 536);
    received_data7_2 <= x"000000" & received_mem_rdata(575 downto 568);  
  end generate g_datawidth72;
end generate g_burstof8;

rresp <= (others => '0');
bresp <= (others => '0');

-- Read Handshake
process (aclk)
begin
  if rising_edge(aclk) then
    if areset='1' then
      arready_i      <= '0';
      rvalid_i       <= '0';
      rstate         <= RS_ADDR;
    else
      case rstate is 
        when RS_ADDR =>
          if arvalid='1' and arready_i='1' then
            arready_i <= '0';
            rvalid_i  <= '0';
            rstate    <= RS_DATA;
          else
            arready_i <= '1';
            rvalid_i  <= '0';
          end if;
        when RS_DATA =>
          if rready='1' and rvalid_i='1' then
            arready_i <= '0';
            rvalid_i  <= '0';
            rstate    <= RS_ADDR;
          else
            arready_i <= '0';
            rvalid_i  <= '1';
          end if;
        when others =>
          arready_i   <= '0';
          rvalid_i    <= '0';
          rstate      <= RS_ADDR;
      end case;
    end if;
  end if;
end process;
												        
arready <= arready_i;										         
rvalid  <= rvalid_i;										       
												     
-- Read Decode (need to determine registers and how I map them in in a controlled manner)	         
process (aclk)											         
begin												         
  if rising_edge(aclk) then									         
    if areset='1' then								       
      rdata_i                        <= (others => '0');			       
    else									       
      if arvalid='1' and arready_i='1' then					       
        case araddr is								       
          when ERROR_LOG_ADDR =>        
            rdata_i                  <= x"0000" & words_stored;
          when FAILED_ADDR0_ADDR =>   
            rdata_i                  <= failed_addr0;          
          when FAILED_ADDR1_ADDR =>              
            rdata_i                  <= failed_addr1;                            
          when EXPECTED_DATA0_0_ADDR =>
            rdata_i                  <= expected_data0_0;          
          when EXPECTED_DATA0_1_ADDR =>
            rdata_i                  <= expected_data0_1;          
          when EXPECTED_DATA0_2_ADDR =>
            rdata_i                  <= expected_data0_2;          
          when EXPECTED_DATA1_0_ADDR =>
            rdata_i                  <= expected_data1_0;          
          when EXPECTED_DATA1_1_ADDR =>
            rdata_i                  <= expected_data1_1;          
          when EXPECTED_DATA1_2_ADDR =>
            rdata_i                  <= expected_data1_2;          
          when EXPECTED_DATA2_0_ADDR =>
            rdata_i                  <= expected_data2_0;          
          when EXPECTED_DATA2_1_ADDR =>
            rdata_i                  <= expected_data2_1;          
          when EXPECTED_DATA2_2_ADDR =>
            rdata_i                  <= expected_data2_2;          
          when EXPECTED_DATA3_0_ADDR =>
            rdata_i                  <= expected_data3_0;          
          when EXPECTED_DATA3_1_ADDR =>
            rdata_i                  <= expected_data3_1;          
          when EXPECTED_DATA3_2_ADDR =>
            rdata_i                  <= expected_data3_2;          
          when EXPECTED_DATA4_0_ADDR =>
            rdata_i                  <= expected_data4_0;          
          when EXPECTED_DATA4_1_ADDR =>
            rdata_i                  <= expected_data4_1;          
          when EXPECTED_DATA4_2_ADDR =>
            rdata_i                  <= expected_data4_2;          
          when EXPECTED_DATA5_0_ADDR =>
            rdata_i                  <= expected_data5_0;          
          when EXPECTED_DATA5_1_ADDR =>
            rdata_i                  <= expected_data5_1;          
          when EXPECTED_DATA5_2_ADDR =>
            rdata_i                  <= expected_data5_2;          
          when EXPECTED_DATA6_0_ADDR =>
            rdata_i                  <= expected_data6_0;          
          when EXPECTED_DATA6_1_ADDR =>
            rdata_i                  <= expected_data6_1;          
          when EXPECTED_DATA6_2_ADDR =>
            rdata_i                  <= expected_data6_2;          
          when EXPECTED_DATA7_0_ADDR =>
            rdata_i                  <= expected_data7_0;          
          when EXPECTED_DATA7_1_ADDR =>
            rdata_i                  <= expected_data7_1;          
          when EXPECTED_DATA7_2_ADDR =>
            rdata_i                  <= expected_data7_2;          
          when RECEIVED_DATA0_0_ADDR =>
            rdata_i                  <= received_data0_0;                
          when RECEIVED_DATA0_1_ADDR =>
            rdata_i                  <= received_data0_1;          
          when RECEIVED_DATA0_2_ADDR =>
            rdata_i                  <= received_data0_2;          
          when RECEIVED_DATA1_0_ADDR =>
            rdata_i                  <= received_data1_0;          
          when RECEIVED_DATA1_1_ADDR =>
            rdata_i                  <= received_data1_1;          
          when RECEIVED_DATA1_2_ADDR =>
            rdata_i                  <= received_data1_2;          
          when RECEIVED_DATA2_0_ADDR =>
            rdata_i                  <= received_data2_0;          
          when RECEIVED_DATA2_1_ADDR =>
            rdata_i                  <= received_data2_1;          
          when RECEIVED_DATA2_2_ADDR =>
            rdata_i                  <= received_data2_2;          
          when RECEIVED_DATA3_0_ADDR =>
            rdata_i                  <= received_data3_0;          
          when RECEIVED_DATA3_1_ADDR =>
            rdata_i                  <= received_data3_1;          
          when RECEIVED_DATA3_2_ADDR =>
            rdata_i                  <= received_data3_2;          
          when RECEIVED_DATA4_0_ADDR =>
            rdata_i                  <= received_data4_0;          
          when RECEIVED_DATA4_1_ADDR =>
            rdata_i                  <= received_data4_1;          
          when RECEIVED_DATA4_2_ADDR =>
            rdata_i                  <= received_data4_2;          
          when RECEIVED_DATA5_0_ADDR =>
            rdata_i                  <= received_data5_0;          
          when RECEIVED_DATA5_1_ADDR =>
            rdata_i                  <= received_data5_1;          
          when RECEIVED_DATA5_2_ADDR =>
            rdata_i                  <= received_data5_2;          
          when RECEIVED_DATA6_0_ADDR =>
            rdata_i                  <= received_data6_0;          
          when RECEIVED_DATA6_1_ADDR =>
            rdata_i                  <= received_data6_1;          
          when RECEIVED_DATA6_2_ADDR =>
            rdata_i                  <= received_data6_2;          
          when RECEIVED_DATA7_0_ADDR =>
            rdata_i                  <= received_data7_0;          
          when RECEIVED_DATA7_1_ADDR =>
            rdata_i                  <= received_data7_1;          
          when RECEIVED_DATA7_2_ADDR =>
            rdata_i                  <= received_data7_2;          
          when others =>
            rdata_i                  <= x"DEADBEEF";
        end case;								       
      end if;									       
    end if;
  end if;
end process;

rdata  <= rdata_i;

process (aclk)
begin
  if rising_edge(aclk) then
    if areset='1' then
      awready_i        <= '0';
      bvalid_i         <= '0';
      wready_i         <= '0';
      wstate           <= WS_ADDR;
    else
      case wstate is
        when WS_ADDR =>
          if awvalid='1' then
            wstate     <= WS_DATA;
            awready_i  <= '0';
            wready_i   <= '1';
            bvalid_i   <= '0';
          else
            awready_i  <= '1';
            wready_i   <= '0';
            bvalid_i   <= '0';
          end if;
        when WS_DATA =>
          if wvalid='1' then
            wstate     <= WS_RESP;
            awready_i  <= '0';
            wready_i   <= '0';
            bvalid_i   <= '1';
          else
            awready_i  <= '0';
            wready_i   <= '1';
            bvalid_i   <= '0';
          end if;
        when WS_RESP =>
          if bready='1' then
            wstate     <= WS_ADDR;
            awready_i  <= '1';
            wready_i   <= '0';
            bvalid_i   <= '0';
          else
            awready_i  <= '0';
            wready_i   <= '0';
            bvalid_i   <= '1';
          end if;
        when others =>
          wstate       <= WS_ADDR;
          awready_i    <= '0';
          bvalid_i     <= '0';
          wready_i     <= '0';
      end case;
    end if;
  end if;
end process;

awready  <= awready_i;
bvalid   <= bvalid_i;
wready   <= wready_i;
       
process (aclk)
begin
  if rising_edge(aclk) then
    if areset='1' then
      waddr       <= (others => '0');
    else
      if awready_i='1' and awvalid='1' then
        waddr     <= awaddr;
      end if;
    end if;
  end if;
end process;

process (aclk)
begin
  if rising_edge(aclk) then
    if areset='1' then
      error_log_address                     <= (others => '0');
    else				               
      if wready_i='1' and wvalid='1' then             
        case waddr is			              
         when ERROR_LOG_ADDR =>
           if wstrb(0)='1' then
             error_log_address(7 downto 0)  <= wdata(7 downto 0);
           end if;
           if wstrb(1)='1' then
             error_log_address(9 downto 8)  <= wdata(9 downto 8);
           end if;
         when others =>
           null;
        end case;
      end if;
    end if;
  end if;
end process;

end rtl;