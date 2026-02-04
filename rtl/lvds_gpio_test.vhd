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
-- Title       : LVDS Test
-- Project     : IA-860m
--------------------------------------------------------------------------------
-- Description : The LVDS clock (from the GPIO connector) will receive a 125MHz 
--               clock.
--               The one output to LVDS GPIO will drive out a 62.5MHz clock 
--               (LVDS clock/2).
--               The two inputs from LVDS GPIO will receive a 62.5MHz clock each.
--
--               The test will replicate the clocks test using the memory map 
--               clock as a point of reference.
--
--               A bank of four identical 32-bit counters that are used for
--               clock frequency measurement. It is assumed that each counter
--               is clocked by a different (and un-related) clock. All the
--               counters share a common synchronous reset and enable control.
--               The counters reset to 0x00000000 and count up (when enabled)
--               to a maximum of 0xFFFFFFFF, they do not roll over.
--
--               Typically a reliable reference clock is used to clock counter
--               'count_0' while the clocks to be measured are used to clock
--               the remaining counters. All the counters are initailly
--               disabled and reset (count_control = "01"). Next the counters
--               are enabled (count_control = "10") for an appropriate period
--               of time and then disabled (count_control = "00"). The counter
--               values are then read via the host interface and this allows
--               the frequency of each clock to be determined by calculating
--               the ratio:
--
--                 Clk 'n' Freq = Ref Clk Freq * (count_n/count_0)
--
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

entity lvds_gpio_test is
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
  rready                          : in   std_logic;				
  -- Test Clocks
  lvds_clock                      : in  std_logic;
  lvds_out                        : out std_logic;
  lvds_in                         : in  std_logic_vector(1 downto 0)
  );
end lvds_gpio_test;

architecture rtl of lvds_gpio_test is

component bretime_async_rst
generic (
  DEPTH :     integer
  );
port (
  clock : in  std_logic;
  d     : in  std_logic;
  q     : out std_logic
  );
end component;

component retime
generic (
  DEPTH  :     integer;
  WIDTH  :     integer
  );
port (
 reset  : in  std_logic;
 clock  : in  std_logic;
 d      : in  std_logic_vector(WIDTH-1 downto 0);
 q      : out std_logic_vector(WIDTH-1 downto 0)
 );
end component;

component counter32
port (
  clock  : in  std_logic;
  reset  : in  std_logic;
  enable : in  std_logic;
  abort  : out std_logic;
  count  : out std_logic_vector(31 downto 0)
  );
end component;

component lvds_clk_pll
port (
  rst        : in  std_logic;
  refclk     : in  std_logic;
  locked     : out std_logic;
  outclk_0   : out std_logic;
  outclk_1   : out std_logic
  );
end component;

type LVDS_COUNT_ARRAY is array (0 to 3) of std_logic_vector(31 downto 0);

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
  
signal test_clock                          : std_logic_vector(3 downto 0);
signal test_clock_stat                     : std_logic_vector(3 downto 0);
                                           
signal count_ctrl                          : std_logic_vector(1 downto 0) := (others => '0');
signal count_reset                         : std_logic_vector(3 downto 0);
signal count_enable                        : std_logic_vector(3 downto 0);
signal count_int                           : LVDS_COUNT_ARRAY;
signal count_out                           : LVDS_COUNT_ARRAY;
                                           signal count_abort                         : std_logic_vector(3 downto 0);
signal reg_abort                           : std_logic_vector(3 downto 0);
                                           
signal pll_reset                           : std_logic;
signal pll_locked                          : std_logic;
signal clk_125mhz                          : std_logic;
signal clk_62p5mhz                         : std_logic;
                                           
signal pll_rst_cnt_rst                     : std_logic;
signal pll_rst_cnt                         : std_logic_vector(3 downto 0);
                                           
constant DONT_ABORT                        : std_logic_vector(3 downto 0) := (others => '0');
                                           
constant CTRL_STAT_REG                     : std_logic_vector(4 downto 0) := "00000";
constant CLK_COUNT0                        : std_logic_vector(4 downto 0) := "00100";
constant CLK_COUNT1                        : std_logic_vector(4 downto 0) := "01000";
constant CLK_COUNT2                        : std_logic_vector(4 downto 0) := "01100";
constant CLK_COUNT3                        : std_logic_vector(4 downto 0) := "10000";

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
          when CTRL_STAT_REG =>
            rdata_i                  <= x"000000" & test_clock_stat & pll_locked & pll_reset & count_ctrl;
          when CLK_COUNT0 =>
            rdata_i                  <= count_out(0); 
          when CLK_COUNT1 =>
            rdata_i                  <= count_out(1);
          when CLK_COUNT2 =>
            rdata_i                  <= count_out(2);
          when CLK_COUNT3 =>
            rdata_i                  <= count_out(3);
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
      count_ctrl                                    <= "00";
      pll_rst_cnt_rst                               <= '1';
      pll_rst_cnt                                   <= (others => '1');
      pll_reset                                     <= '1';
    else				              
      pll_rst_cnt_rst                               <= '0';
      if wready_i='1' and wvalid='1' then             
        case waddr is			              
          when CTRL_STAT_REG =>		              
            if wstrb(0)='1' then	              
              count_ctrl                            <= wdata(1 downto 0);
              pll_rst_cnt_rst                       <= wdata(2);
            end if;
          when others =>
            null;
        end case;
      end if;
      if pll_rst_cnt_rst='1' then
        pll_rst_cnt                                 <= (others => '1');
        pll_reset                                   <= '1';
      elsif pll_rst_cnt /= "0000" then
        pll_rst_cnt                                 <= pll_rst_cnt-1;
        pll_reset                                   <= '1';
      else
        pll_reset                                   <= '0';
      end if;
      if reg_abort /= DONT_ABORT then
        count_ctrl(1)                               <= '0';
      end if;
    end if;
  end if;
end process;

lvds_tst_pll : lvds_clk_pll
port map (
  rst         => pll_reset,
  refclk      => lvds_clock,
  locked      => pll_locked,
  outclk_0    => clk_125mhz,
  outclk_1    => clk_62p5mhz
  );  

lvds_out        <= clk_62p5mhz;

test_clock      <= lvds_in & clk_125mhz & aclk;
test_clock_stat <= pll_locked & pll_locked & pll_locked & not(areset);  

---------------------
-- Generate Counters
---------------------
gen_counters : for i in 0 to 3 generate

  retime_reset : bretime_async_rst
    generic map (
      DEPTH => 2
      )
    port map (
      clock => test_clock(i),
      d     => count_ctrl(0),
      q     => count_reset(i)
      );

  retime_enable : bretime_async_rst
    generic map (
      DEPTH => 2
      )
    port map (
      clock => test_clock(i),
      d     => count_ctrl(1),
      q     => count_enable(i)
      );

  clk_counter : counter32
    port map (
      clock  => test_clock(i),
      reset  => count_reset(i),
      enable => count_enable(i),
      abort  => count_abort(i),
      count  => count_int(i)
      );

  retime_abort : bretime_async_rst
    generic map (
      DEPTH => 2
      )
    port map (
      clock => aclk,
      d     => count_abort(i),
      q     => reg_abort(i)
      );

  retime_counts : retime
    generic map (
      WIDTH => 32,
      DEPTH => 2
      )
    port map (
      reset => areset,
      clock => aclk,
      d     => count_int(i),
      q     => count_out(i)
      );

end generate;

end rtl;
