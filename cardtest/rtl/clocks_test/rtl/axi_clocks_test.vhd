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
-- Title       : Clock Test AXI4-LITE
-- Project     : Multi
--------------------------------------------------------------------------------
-- Description : A bank of fifteen identical 32-bit counters that are used for
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
--    CLK_STATUS    21  2  RO 0x0000     Clock Status. 1 Bit per clock '1' is locked/ready.
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity axi_clock_test is
  port (
	--AXI Clock and Reset
  aclk      					  : in  std_logic;
  areset    					  : in  std_logic;
	--Write Address Interface
  awaddr						  : in  std_logic_vector(7 downto 0); --replaces avmm_address
  awvalid 					  	  : in  std_logic;
  awready 					  	  : out std_logic; 					--replaces avmm_write
  awprot						  : in  std_logic_vector(2 downto 0);
	--Write Data Interface
  wdata						  	  : in  std_logic_vector(31 downto 0); --replaces avmm_writedata
  wstrb							  : in  std_logic_vector(3 downto 0);  --replaces avmm_byteenable
  wvalid						  : in  std_logic;
  wready						  : out std_logic;
	--Write Response Interface     
  bresp                           : out  std_logic_vector(1 downto 0);						
  bvalid                          : out  std_logic;									
  bready                          : in   std_logic;									
	--Read Address Interface     											
  araddr                          : in   std_logic_vector(7 downto 0);						
  arvalid                         : in   std_logic;								
  arready                         : out  std_logic;								
  arprot                          : in   std_logic_vector(2 downto 0);
	--Read Response Interface     										
  rdata                           : out  std_logic_vector(31 downto 0);				
  rresp                           : out  std_logic_vector(1 downto 0);				
  rvalid                          : out  std_logic;							
  rready                          : in   std_logic;				
  --Test Clocks
  test_clock                      : in   std_logic_vector(19 downto 0);
  test_clock_stat                 : in   std_logic_vector(19 downto 0)
  );
end axi_clock_test;


architecture rtl of axi_clock_test is


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

  component counter32
    port (
      clock  : in  std_logic;
      reset  : in  std_logic;
      enable : in  std_logic;
      abort  : out std_logic;
      count  : out std_logic_vector(31 downto 0)
      );
  end component;


---------
--Types
---------
type READ_STATES is (RS_ADDR, RS_DATA);
signal rstate       : READ_STATES;

type WRITE_STATES is (WS_ADDR, WS_DATA, WS_RESP);
signal wstate       : WRITE_STATES;

type T_count_out is array (0 to 19) of std_logic_vector(31 downto 0);
-----------
--Signals
-----------
signal count_ctrl   : std_logic_vector(1 downto 0) := (others => '0');
signal count_reset  : std_logic_vector(19 downto 0);
signal count_enable : std_logic_vector(19 downto 0);
signal count_out    : T_count_out;
	
-----------
--AXI internal signals added
-----------
signal arready_i    : std_logic;
signal rvalid_i	    : std_logic;
signal rdata_i	    : std_logic_vector(31 downto 0);
signal awready_i    : std_logic;
signal wready_i	    : std_logic;
signal bvalid_i     : std_logic;

signal waddr        : std_logic_vector(7 downto 0);
signal csr_reg      : std_logic_vector(31 downto 0);

signal count_abort  : std_logic_vector(19 downto 0);
signal reg_abort    : std_logic_vector(19 downto 0);

constant DONT_ABORT : std_logic_vector(19 downto 0) := (others => '0');

begin
  --------------------
  --Read Handshake
  --------------------
process (aclk)
begin
  if rising_edge(aclk) then
    if areset='1' then
      arready_i      <= '0'; --resetting
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

  --------------------
	--Read Decode
  --------------------
process(aclk)
begin
	if rising_edge(aclk) then
	if areset='1' then
	rdata_i <= (others => '0');
	else
		if arvalid='1' and arready_i='1' then
		  case araddr is
		    when x"00" =>
		      rdata_i <= "0000000000" & test_clock_stat & csr_reg(1 downto 0); 
		    when x"04" =>
		      rdata_i <= count_out(0);
		    when x"08" =>
		      rdata_i <= count_out(1);
		    when x"0C" =>
		      rdata_i <= count_out(2);
		    when x"10" =>
		      rdata_i <= count_out(3);
		    when x"14" =>
		      rdata_i <= count_out(4);
		    when x"18" =>
		      rdata_i <= count_out(5);
		    when x"1C" =>
		      rdata_i <= count_out(6);
		    when x"20" =>
		      rdata_i <= count_out(7);
		    when x"24" =>
		      rdata_i <= count_out(8);
		    when x"28" =>
		      rdata_i <= count_out(9);
		    when x"2C" =>
		      rdata_i <= count_out(10);
		    when x"30" =>
		      rdata_i <= count_out(11);
		    when x"34" =>
		      rdata_i <= count_out(12);
		    when x"38" =>
		      rdata_i <= count_out(13);
		    when x"3C" =>
		      rdata_i <= count_out(14);
		    when x"40" =>
		      rdata_i <= count_out(15);
		    when x"44" =>
		      rdata_i <= count_out(16);
		    when x"48" =>
		      rdata_i <= count_out(17);			
		    when x"4C" =>
		      rdata_i <= count_out(18);
		    when x"50" =>
		      rdata_i <= count_out(19);
            when others =>
              rdata_i <= x"DEADBEEF";
		  end case;
		end if;
	 end if;
  end if;
end process;

rdata <= rdata_i; --pulling from the input		

  --------------------
	--Write address
  --------------------
process (aclk)
begin
  if rising_edge(aclk) then
    if areset ='1' then
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

  ---------------------
	--Write data
  ---------------------
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

  ---------------------
	--Write Response
	---------------------

process (aclk)
begin
  if rising_edge(aclk) then
    if areset='1' then
      csr_reg <= (others => '0');
    else
      if wready_i='1' and wvalid='1' then
        case waddr is
          when x"00" =>
            if wstrb(0)='1' then
              csr_reg(1 downto 0) <= wdata(1 downto 0);
            end if;
          when others =>
            null;
        end case;
      end if;
      if reg_abort /= DONT_ABORT then
        csr_reg(1) <= '0';
      end if;
    end if;
  end if;
end process;

count_ctrl <= csr_reg(1 downto 0);

  ---------------------
  --Generate Counters
  ---------------------
  gen_counters : for i in 0 to 19 generate

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
        count  => count_out(i)
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

  end generate;
 

end rtl;

