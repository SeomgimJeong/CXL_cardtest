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
-- Title       : BMC SPI Telemetry Test
-- Project     : Multi
--------------------------------------------------------------------------------
-- Description : This is the AXI4-LITE interface that allows the host to read
--               back telemetry data from the BMC.
--               It also allows the host to set QSFPDD controls (to be 
--               transmitted to the BMC via the telemetry interface).
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

entity telemetry_test is
generic (
  QSFPDD_NUM                      :      integer range 1 to 3 := 1
  );
port (
  -- Clock and Reset
  aclk                            : in   std_logic;
  areset                          : in   std_logic;
  -- Write Address Interface      
  awaddr                          : in   std_logic_vector(11 downto 0);
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
  araddr                          : in   std_logic_vector(11 downto 0);						
  arvalid                         : in   std_logic;								
  arready                         : out  std_logic;								
  arprot                          : in   std_logic_vector(2 downto 0);
  -- Read Response Interface     										
  rdata                           : out  std_logic_vector(31 downto 0);				
  rresp                           : out  std_logic_vector(1 downto 0);				
  rvalid                          : out  std_logic;							
  rready                          : in   std_logic;							
  -- QSFPDD0 Sidebands
  qsfpdd0_rst_n                   : out  std_logic;
  qsfpdd0_lpmode                  : out  std_logic;
  qsfpdd0_int_n                   : in   std_logic;
  qsfpdd0_present_n               : in   std_logic;
  -- QSFPDD1 Sidebands
  qsfpdd1_rst_n                   : out  std_logic;
  qsfpdd1_lpmode                  : out  std_logic;
  qsfpdd1_int_n                   : in   std_logic;
  qsfpdd1_present_n               : in   std_logic;
  -- QSFPDD2 Sidebands
  qsfpdd2_rst_n                   : out  std_logic;
  qsfpdd2_lpmode                  : out  std_logic;
  qsfpdd2_int_n                   : in   std_logic;
  qsfpdd2_present_n               : in   std_logic;  
  -- EEPROM Data
  eeprom_data                     : in   std_logic_vector(2047 downto 0)  
  );
end entity telemetry_test;

architecture rtl of telemetry_test is

constant VERSION_MINOR                     : std_logic_vector(11 downto 0) := x"001";
constant VERSION_MAJOR                     : std_logic_vector(11 downto 0) := x"000";
constant QSFPDD_NUMBER                     : std_logic_vector(7 downto 0)  := conv_std_logic_vector(QSFPDD_NUM, 8);

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

signal waddr                               : std_logic_vector(11 downto 0);

signal qsfpdd0_in_axiclk                   : std_logic_vector(1 downto 0);
signal qsfpdd0_out_axiclk                  : std_logic_vector(1 downto 0);
signal qsfpdd1_in_axiclk                   : std_logic_vector(1 downto 0);
signal qsfpdd1_out_axiclk                  : std_logic_vector(1 downto 0);
signal qsfpdd2_in_axiclk                   : std_logic_vector(1 downto 0);
signal qsfpdd2_out_axiclk                  : std_logic_vector(1 downto 0);
signal eeprom_axiclk                       : std_logic_vector(2047 downto 0);

begin

qsfpdd0_in_axiclk      <= qsfpdd0_present_n & qsfpdd0_int_n;
qsfpdd0_rst_n          <= qsfpdd0_out_axiclk(0);
qsfpdd0_lpmode         <= qsfpdd0_out_axiclk(1);

qsfpdd1_in_axiclk      <= qsfpdd1_present_n & qsfpdd1_int_n;
qsfpdd1_rst_n          <= qsfpdd1_out_axiclk(0);
qsfpdd1_lpmode         <= qsfpdd1_out_axiclk(1);

qsfpdd2_in_axiclk      <= qsfpdd2_present_n & qsfpdd2_int_n;
qsfpdd2_rst_n          <= qsfpdd2_out_axiclk(0);
qsfpdd2_lpmode         <= qsfpdd2_out_axiclk(1);

eeprom_axiclk          <= eeprom_data;

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
          -- Version and QSFPDD Number
          when x"000" =>
            rdata_i                  <= QSFPDD_NUMBER & VERSION_MAJOR & VERSION_MINOR;
          -- QSFPDD0 Sideband Ports
          when x"004" =>  
            rdata_i                  <= x"0000000" & qsfpdd0_out_axiclk & qsfpdd0_in_axiclk;
          -- QSFPDD1 Sideband Ports
          when x"008" =>  
            rdata_i                  <= x"0000000" & qsfpdd1_out_axiclk & qsfpdd1_in_axiclk;
          -- QSFPDD1 Sideband Ports
          when x"00C" =>  
            rdata_i                  <= x"0000000" & qsfpdd2_out_axiclk & qsfpdd2_in_axiclk;
          -- EEPROM Data
          when x"100" => 
            rdata_i                  <= eeprom_axiclk(31 downto 0);
          when x"104" => 
            rdata_i                  <= eeprom_axiclk(63 downto 32);
          when x"108" => 
            rdata_i                  <= eeprom_axiclk(95 downto 64);
          when x"10C" => 
            rdata_i                  <= eeprom_axiclk(127 downto 96);            
          when x"110" => 
            rdata_i                  <= eeprom_axiclk(159 downto 128);
          when x"114" => 
            rdata_i                  <= eeprom_axiclk(191 downto 160);
          when x"118" => 
            rdata_i                  <= eeprom_axiclk(223 downto 192);
          when x"11C" => 
            rdata_i                  <= eeprom_axiclk(255 downto 224);   
          when x"120" => 
            rdata_i                  <= eeprom_axiclk(287 downto 256);
          when x"124" => 
            rdata_i                  <= eeprom_axiclk(319 downto 288);
          when x"128" => 
            rdata_i                  <= eeprom_axiclk(351 downto 320);
          when x"12C" => 
            rdata_i                  <= eeprom_axiclk(383 downto 352);            
          when x"130" => 
            rdata_i                  <= eeprom_axiclk(415 downto 384);
          when x"134" => 
            rdata_i                  <= eeprom_axiclk(447 downto 416);
          when x"138" => 
            rdata_i                  <= eeprom_axiclk(479 downto 448);
          when x"13C" => 
            rdata_i                  <= eeprom_axiclk(511 downto 480);  
          when x"140" => 
            rdata_i                  <= eeprom_axiclk(543 downto 512);
          when x"144" => 
            rdata_i                  <= eeprom_axiclk(575 downto 544);
          when x"148" => 
            rdata_i                  <= eeprom_axiclk(607 downto 576);
          when x"14C" => 
            rdata_i                  <= eeprom_axiclk(639 downto 608);            
          when x"150" => 
            rdata_i                  <= eeprom_axiclk(671 downto 640);
          when x"154" => 
            rdata_i                  <= eeprom_axiclk(703 downto 672);
          when x"158" => 
            rdata_i                  <= eeprom_axiclk(735 downto 704);
          when x"15C" => 
            rdata_i                  <= eeprom_axiclk(767 downto 736);   
          when x"160" => 
            rdata_i                  <= eeprom_axiclk(799 downto 768);
          when x"164" => 
            rdata_i                  <= eeprom_axiclk(831 downto 800);
          when x"168" => 
            rdata_i                  <= eeprom_axiclk(863 downto 832);
          when x"16C" => 
            rdata_i                  <= eeprom_axiclk(895 downto 864);            
          when x"170" => 
            rdata_i                  <= eeprom_axiclk(927 downto 896);
          when x"174" => 
            rdata_i                  <= eeprom_axiclk(959 downto 928);
          when x"178" => 
            rdata_i                  <= eeprom_axiclk(991 downto 960);
          when x"17C" => 
            rdata_i                  <= eeprom_axiclk(1023 downto 992); 
          when x"180" => 
            rdata_i                  <= eeprom_axiclk(1055 downto 1024);
          when x"184" => 
            rdata_i                  <= eeprom_axiclk(1087 downto 1056);
          when x"188" => 
            rdata_i                  <= eeprom_axiclk(1119 downto 1088);
          when x"18C" => 
            rdata_i                  <= eeprom_axiclk(1151 downto 1120);            
          when x"190" => 
            rdata_i                  <= eeprom_axiclk(1183 downto 1152);
          when x"194" => 
            rdata_i                  <= eeprom_axiclk(1215 downto 1184);
          when x"198" => 
            rdata_i                  <= eeprom_axiclk(1247 downto 1216);
          when x"19C" => 
            rdata_i                  <= eeprom_axiclk(1279 downto 1248);   
          when x"1A0" => 
            rdata_i                  <= eeprom_axiclk(1311 downto 1280);
          when x"1A4" => 
            rdata_i                  <= eeprom_axiclk(1343 downto 1312);
          when x"1A8" => 
            rdata_i                  <= eeprom_axiclk(1375 downto 1344);
          when x"1AC" => 
            rdata_i                  <= eeprom_axiclk(1407 downto 1376);            
          when x"1B0" => 
            rdata_i                  <= eeprom_axiclk(1439 downto 1408);
          when x"1B4" => 
            rdata_i                  <= eeprom_axiclk(1471 downto 1440);
          when x"1B8" => 
            rdata_i                  <= eeprom_axiclk(1503 downto 1472);
          when x"1BC" => 
            rdata_i                  <= eeprom_axiclk(1535 downto 1504);  
          when x"1C0" => 
            rdata_i                  <= eeprom_axiclk(1567 downto 1536);
          when x"1C4" => 
            rdata_i                  <= eeprom_axiclk(1599 downto 1568);
          when x"1C8" => 
            rdata_i                  <= eeprom_axiclk(1631 downto 1600);
          when x"1CC" => 
            rdata_i                  <= eeprom_axiclk(1663 downto 1632);            
          when x"1D0" => 
            rdata_i                  <= eeprom_axiclk(1695 downto 1664);
          when x"1D4" => 
            rdata_i                  <= eeprom_axiclk(1727 downto 1696);
          when x"1D8" => 
            rdata_i                  <= eeprom_axiclk(1759 downto 1728);
          when x"1DC" => 
            rdata_i                  <= eeprom_axiclk(1791 downto 1760);   
          when x"1E0" => 
            rdata_i                  <= eeprom_axiclk(1823 downto 1792);
          when x"1E4" => 
            rdata_i                  <= eeprom_axiclk(1855 downto 1824);
          when x"1E8" => 
            rdata_i                  <= eeprom_axiclk(1887 downto 1856);
          when x"1EC" => 
            rdata_i                  <= eeprom_axiclk(1919 downto 1888);            
          when x"1F0" => 
            rdata_i                  <= eeprom_axiclk(1951 downto 1920);
          when x"1F4" => 
            rdata_i                  <= eeprom_axiclk(1983 downto 1952);
          when x"1F8" => 
            rdata_i                  <= eeprom_axiclk(2015 downto 1984);
          when x"1FC" => 
            rdata_i                  <= eeprom_axiclk(2047 downto 2016); 
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
      qsfpdd0_out_axiclk                            <= "01";
      qsfpdd1_out_axiclk                            <= "01";
      qsfpdd2_out_axiclk                            <= "01";
    else				              
      if wready_i='1' and wvalid='1' then             
        case waddr is			              
          -- QSFPDD0 Control
          when x"004" =>		              
            if wstrb(0)='1' then	              
              qsfpdd0_out_axiclk                    <= wdata(3 downto 2);
            end if;
          -- QSFPDD1 Control
          when x"008" =>		              
            if wstrb(0)='1' then	              
              qsfpdd1_out_axiclk                    <= wdata(3 downto 2);
            end if;
          -- QSFPDD2 Control
          when x"00C" =>		              
            if wstrb(0)='1' then	              
              qsfpdd2_out_axiclk                    <= wdata(3 downto 2);
            end if;
          when others =>
            null;
        end case;
      end if;
    end if;
  end if;
end process;


end rtl;