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
-- Title       : Design ID & Version Registers + Scratchpad (Test) Registers
-- Project     : Multi
--------------------------------------------------------------------------------
-- Description : Simple 5-register AXI-Lite interface that reports the 
--               Design ID & Version.
--               The other three registers are test registers.
--               The first two are read/writeable.  The third reports the 
--               inverse of the first read/writeable test register.
--               Final register is Timestamp
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
-- Very much a work in progress
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.pkg_revision.all;
use work.pkg_timestamp.all;

entity version_plus_scratchpad is
port (
  -- Clock and Reset
  aclk                            : in   std_logic;
  areset                          : in   std_logic;
  -- Write Address Interface      
  awaddr                          : in   std_logic_vector(4 downto 0);
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
  araddr                          : in   std_logic_vector(4 downto 0);						
  arvalid                         : in   std_logic;								
  arready                         : out  std_logic;								
  arprot                          : in   std_logic_vector(2 downto 0);
  -- Read Response Interface     										
  rdata                           : out  std_logic_vector(31 downto 0);				
  rresp                           : out  std_logic_vector(1 downto 0);				
  rvalid                          : out  std_logic;							
  rready                          : in   std_logic						  
  );
end entity version_plus_scratchpad;

architecture rtl of version_plus_scratchpad is

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

signal waddr                               : std_logic_vector(4 downto 0);

signal test_reg0                           : std_logic_vector(31 downto 0);
signal test_reg1                           : std_logic_vector(31 downto 0);

constant VERSION_REG_ADDR                  : std_logic_vector(4 downto 0) := "00000";
constant TEST_REG0_ADDR                    : std_logic_vector(4 downto 0) := "00100";
constant TEST_REG1_ADDR                    : std_logic_vector(4 downto 0) := "01000";
constant TEST_REG2_ADDR                    : std_logic_vector(4 downto 0) := "01100";
constant TIMESTAMP_REG_ADDR                : std_logic_vector(4 downto 0) := "10000";

begin

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
          -- Design ID & Version
          when VERSION_REG_ADDR =>
            rdata_i                  <= DESIGN_ID_MAJOR & DESIGN_ID_MINOR & VERSION_MAJOR & VERSION_MINOR; 
          when TEST_REG0_ADDR =>
            rdata_i                  <= test_reg0; 
          when TEST_REG1_ADDR =>
            rdata_i                  <= test_reg1; 
          when TEST_REG2_ADDR =>
            rdata_i                  <= not(test_reg0); 			
          when TIMESTAMP_REG_ADDR =>
            rdata_i                  <= TIMESTAMP;
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
      test_reg0                                               <= (others => '0');
      test_reg1                                               <= (others => '0');
    else				              
      if wready_i='1' and wvalid='1' then             
        case waddr is			              
          when TEST_REG0_ADDR =>		              
            if wstrb(0)='1' then	              
              test_reg0(7 downto 0)                           <= wdata(7 downto 0);
            end if;
            if wstrb(1)='1' then	              
             test_reg0(15 downto 8)                           <= wdata(15 downto 8);
            end if;			
            if wstrb(2)='1' then	              
              test_reg0(23 downto 16)                         <= wdata(23 downto 16);
            end if;
            if wstrb(3)='1' then	              
              test_reg0(31 downto 24)                         <= wdata(31 downto 24);
            end if;	 
          when TEST_REG1_ADDR =>		              
            if wstrb(0)='1' then	              
              test_reg1(7 downto 0)                           <= wdata(7 downto 0);
            end if;
            if wstrb(1)='1' then	              
             test_reg1(15 downto 8)                           <= wdata(15 downto 8);
            end if;			
            if wstrb(2)='1' then	              
              test_reg1(23 downto 16)                         <= wdata(23 downto 16);
            end if;
            if wstrb(3)='1' then	              
              test_reg1(31 downto 24)                         <= wdata(31 downto 24);
            end if;	 
          when others =>
            null;
        end case;
      end if;
    end if;
  end if;
end process;


end rtl;