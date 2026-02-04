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
-- Title       : LED Control
-- Project     : Multi
--------------------------------------------------------------------------------
-- Description : Simple LED control (controlling a LED flash)
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

entity led_control is
generic (
  LED_NUMBER                      :      integer range 1 to 32
  );
port (
  -- Clock and Reset
  aclk                            : in   std_logic;
  areset                          : in   std_logic;
  -- Write Address Interface      
  awaddr                          : in   std_logic_vector(3 downto 0);
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
  araddr                          : in   std_logic_vector(3 downto 0);						
  arvalid                         : in   std_logic;								
  arready                         : out  std_logic;								
  arprot                          : in   std_logic_vector(2 downto 0);
  -- Read Response Interface     										
  rdata                           : out  std_logic_vector(31 downto 0);				
  rresp                           : out  std_logic_vector(1 downto 0);				
  rvalid                          : out  std_logic;							
  rready                          : in   std_logic;							
  -- LED Outputs
  led_r                           : out  std_logic_vector(LED_NUMBER-1 downto 0);
  led_g                           : out  std_logic_vector(LED_NUMBER-1 downto 0)  
  );
end entity led_control;

architecture rtl of led_control is

component heartbeat_50m
port (
  clk             : in  std_logic;
  hrt_beat        : out std_logic_vector(4 downto 0)
  );
end component;

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

signal waddr                               : std_logic_vector(3 downto 0);

signal led_number_vector                   : std_logic_vector(31 downto 0);
signal led_control                         : std_logic_vector(1 downto 0);
signal heartbeat                           : std_logic_vector(4 downto 0);

signal led_r_i                             : std_logic_vector(LED_NUMBER-1 downto 0);
signal led_g_i                             : std_logic_vector(LED_NUMBER-1 downto 0);

begin

led_number_vector    <= conv_std_logic_vector(LED_NUMBER, 32);

u0_heartbeat : heartbeat_50m
port map (
  clk             => aclk,
  hrt_beat        => heartbeat
  );

g1 : for i in 0 to LED_NUMBER-1 generate
led_r_i(i) <= '1' when led_control="10" else not(heartbeat(4));
led_g_i(i) <= '1' when led_control="01" else not(heartbeat(4));
end generate;

process (aclk)
begin
  if rising_edge(aclk) then
    if areset='1' then
      led_r         <= (others => '1');
      led_g         <= (others => '1');
    else
      led_r         <= led_r_i;
      led_g         <= led_g_i;
    end if;
  end if;
end process;

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
          when x"0" =>
            rdata_i                  <= led_number_vector;
          when x"4" =>
            rdata_i                  <= x"0000000" & "00" & led_control; 
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
      led_control                                   <= "11";
    else				              
      if wready_i='1' and wvalid='1' then             
        case waddr is			              
          when x"4" =>		              
            if wstrb(0)='1' then	              
              led_control                           <= wdata(1 downto 0);
            end if;
          when others =>
            null;
        end case;
      end if;
    end if;
  end if;
end process;


end rtl;