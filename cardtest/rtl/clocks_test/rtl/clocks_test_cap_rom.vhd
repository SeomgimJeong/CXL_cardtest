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
-- Title       : Clocks Test Capability ROM
-- Project     : Clocks Test
--------------------------------------------------------------------------------
-- Description : This ROM provides the host with the details for the
--               clocks which have been connected to the clocks test.
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

use work.pkg_clks_cap_rom_functions.all;

entity clocks_test_cap_rom is
generic (
  VERSION_MINOR                   : integer          := 1;
  VERSION_MAJOR                   : integer          := 0;
  CLOCK0_TYPE                     : integer          := 1;
  CLOCK0_EN                       : boolean          := false;
  CLOCK0_FREQ                     : integer          := 0;
  CLOCK0_NAME                     : string           := "";
  CLOCK1_TYPE                     : integer          := 1;
  CLOCK1_EN                       : boolean          := false;
  CLOCK1_FREQ                     : integer          := 0;
  CLOCK1_NAME                     : string           := "";
  CLOCK2_TYPE                     : integer          := 1;
  CLOCK2_EN                       : boolean          := false;
  CLOCK2_FREQ                     : integer          := 0;
  CLOCK2_NAME                     : string           := "";
  CLOCK3_TYPE                     : integer          := 1;
  CLOCK3_EN                       : boolean          := false;
  CLOCK3_FREQ                     : integer          := 0;
  CLOCK3_NAME                     : string           := "";
  CLOCK4_TYPE                     : integer          := 1;
  CLOCK4_EN                       : boolean          := false;
  CLOCK4_FREQ                     : integer          := 0;
  CLOCK4_NAME                     : string           := "";
  CLOCK5_TYPE                     : integer          := 1;
  CLOCK5_EN                       : boolean          := false;
  CLOCK5_FREQ                     : integer          := 0;
  CLOCK5_NAME                     : string           := "";
  CLOCK6_TYPE                     : integer          := 1;
  CLOCK6_EN                       : boolean          := false;
  CLOCK6_FREQ                     : integer          := 0;
  CLOCK6_NAME                     : string           := "";
  CLOCK7_TYPE                     : integer          := 1;
  CLOCK7_EN                       : boolean          := false;
  CLOCK7_FREQ                     : integer          := 0;
  CLOCK7_NAME                     : string           := "";
  CLOCK8_TYPE                     : integer          := 1;
  CLOCK8_EN                       : boolean          := false;
  CLOCK8_FREQ                     : integer          := 0;
  CLOCK8_NAME                     : string           := "";
  CLOCK9_TYPE                     : integer          := 1;
  CLOCK9_EN                       : boolean          := false;
  CLOCK9_FREQ                     : integer          := 0;
  CLOCK9_NAME                     : string           := "";
  CLOCK10_TYPE                    : integer          := 1;
  CLOCK10_EN                      : boolean          := false;
  CLOCK10_FREQ                    : integer          := 0;
  CLOCK10_NAME                    : string           := "";
  CLOCK11_TYPE                    : integer          := 1;
  CLOCK11_EN                      : boolean          := false;
  CLOCK11_FREQ                    : integer          := 0;
  CLOCK11_NAME                    : string           := "";
  CLOCK12_TYPE                    : integer          := 1;
  CLOCK12_EN                      : boolean          := false;
  CLOCK12_FREQ                    : integer          := 0;
  CLOCK12_NAME                    : string           := "";
  CLOCK13_TYPE                    : integer          := 1;
  CLOCK13_EN                      : boolean          := false;
  CLOCK13_FREQ                    : integer          := 0;
  CLOCK13_NAME                    : string           := "";
  CLOCK14_TYPE                    : integer          := 1;
  CLOCK14_EN                      : boolean          := false;
  CLOCK14_FREQ                    : integer          := 0;
  CLOCK14_NAME                    : string           := "";
  CLOCK15_TYPE                    : integer          := 1;
  CLOCK15_EN                      : boolean          := false;
  CLOCK15_FREQ                    : integer          := 0;
  CLOCK15_NAME                    : string           := "";
  CLOCK16_TYPE                    : integer          := 1;
  CLOCK16_EN                      : boolean          := false;
  CLOCK16_FREQ                    : integer          := 0;
  CLOCK16_NAME                    : string           := "";
  CLOCK17_TYPE                    : integer          := 1;
  CLOCK17_EN                      : boolean          := false;
  CLOCK17_FREQ                    : integer          := 0;
  CLOCK17_NAME                    : string           := "";
  CLOCK18_TYPE                    : integer          := 1;
  CLOCK18_EN                      : boolean          := false;
  CLOCK18_FREQ                    : integer          := 0;
  CLOCK18_NAME                    : string           := "";
  CLOCK19_TYPE                    : integer          := 1;
  CLOCK19_EN                      : boolean          := false;
  CLOCK19_FREQ                    : integer          := 0;
  CLOCK19_NAME                    : string           := ""
  );
port (
  -- Clock and Reset
  aclk                            : in   std_logic;
  areset                          : in   std_logic;
  -- Write Address Interface      
  awaddr                          : in   std_logic_vector(12 downto 0);
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
  araddr                          : in   std_logic_vector(12 downto 0);						
  arvalid                         : in   std_logic;								
  arready                         : out  std_logic;								
  arprot                          : in   std_logic_vector(2 downto 0);
  -- Read Response Interface     										
  rdata                           : out  std_logic_vector(31 downto 0);				
  rresp                           : out  std_logic_vector(1 downto 0);				
  rvalid                          : out  std_logic;							
  rready                          : in   std_logic 
  );
end entity clocks_test_cap_rom;

architecture rtl of clocks_test_cap_rom is

-- Derived constants (from the above)
constant CLOCK0_NAME_WORD_LENGTH  : integer          := clk_name_word_length_gen(CLOCK0_NAME);
constant CLOCK1_NAME_WORD_LENGTH  : integer          := clk_name_word_length_gen(CLOCK1_NAME);
constant CLOCK2_NAME_WORD_LENGTH  : integer          := clk_name_word_length_gen(CLOCK2_NAME);
constant CLOCK3_NAME_WORD_LENGTH  : integer          := clk_name_word_length_gen(CLOCK3_NAME);
constant CLOCK4_NAME_WORD_LENGTH  : integer          := clk_name_word_length_gen(CLOCK4_NAME);
constant CLOCK5_NAME_WORD_LENGTH  : integer          := clk_name_word_length_gen(CLOCK5_NAME);
constant CLOCK6_NAME_WORD_LENGTH  : integer          := clk_name_word_length_gen(CLOCK6_NAME);
constant CLOCK7_NAME_WORD_LENGTH  : integer          := clk_name_word_length_gen(CLOCK7_NAME);
constant CLOCK8_NAME_WORD_LENGTH  : integer          := clk_name_word_length_gen(CLOCK8_NAME);
constant CLOCK9_NAME_WORD_LENGTH  : integer          := clk_name_word_length_gen(CLOCK9_NAME);
constant CLOCK10_NAME_WORD_LENGTH : integer          := clk_name_word_length_gen(CLOCK10_NAME);
constant CLOCK11_NAME_WORD_LENGTH : integer          := clk_name_word_length_gen(CLOCK11_NAME);
constant CLOCK12_NAME_WORD_LENGTH : integer          := clk_name_word_length_gen(CLOCK12_NAME);
constant CLOCK13_NAME_WORD_LENGTH : integer          := clk_name_word_length_gen(CLOCK13_NAME);
constant CLOCK14_NAME_WORD_LENGTH : integer          := clk_name_word_length_gen(CLOCK14_NAME);
constant CLOCK15_NAME_WORD_LENGTH : integer          := clk_name_word_length_gen(CLOCK15_NAME);
constant CLOCK16_NAME_WORD_LENGTH : integer          := clk_name_word_length_gen(CLOCK16_NAME);
constant CLOCK17_NAME_WORD_LENGTH : integer          := clk_name_word_length_gen(CLOCK17_NAME);
constant CLOCK18_NAME_WORD_LENGTH : integer          := clk_name_word_length_gen(CLOCK18_NAME);
constant CLOCK19_NAME_WORD_LENGTH : integer          := clk_name_word_length_gen(CLOCK19_NAME);

constant CLOCK0_CAP_VECTOR        : std_logic_vector((((4+CLOCK0_NAME_WORD_LENGTH)*32)-1) downto 0)  := cap_rom_clks_vector_gen(CLOCK0_TYPE, 0, CLOCK0_NAME, CLOCK0_NAME'length, CLOCK0_NAME_WORD_LENGTH, CLOCK0_FREQ);
constant CLOCK1_CAP_VECTOR        : std_logic_vector((((4+CLOCK1_NAME_WORD_LENGTH)*32)-1) downto 0)  := cap_rom_clks_vector_gen(CLOCK1_TYPE, 1, CLOCK1_NAME, CLOCK1_NAME'length, CLOCK1_NAME_WORD_LENGTH, CLOCK1_FREQ);
constant CLOCK2_CAP_VECTOR        : std_logic_vector((((4+CLOCK2_NAME_WORD_LENGTH)*32)-1) downto 0)  := cap_rom_clks_vector_gen(CLOCK2_TYPE, 2, CLOCK2_NAME, CLOCK2_NAME'length, CLOCK2_NAME_WORD_LENGTH, CLOCK2_FREQ);
constant CLOCK3_CAP_VECTOR        : std_logic_vector((((4+CLOCK3_NAME_WORD_LENGTH)*32)-1) downto 0)  := cap_rom_clks_vector_gen(CLOCK3_TYPE, 3, CLOCK3_NAME, CLOCK3_NAME'length, CLOCK3_NAME_WORD_LENGTH, CLOCK3_FREQ);
constant CLOCK4_CAP_VECTOR        : std_logic_vector((((4+CLOCK4_NAME_WORD_LENGTH)*32)-1) downto 0)  := cap_rom_clks_vector_gen(CLOCK4_TYPE, 4, CLOCK4_NAME, CLOCK4_NAME'length, CLOCK4_NAME_WORD_LENGTH, CLOCK4_FREQ);
constant CLOCK5_CAP_VECTOR        : std_logic_vector((((4+CLOCK5_NAME_WORD_LENGTH)*32)-1) downto 0)  := cap_rom_clks_vector_gen(CLOCK5_TYPE, 5, CLOCK5_NAME, CLOCK5_NAME'length, CLOCK5_NAME_WORD_LENGTH, CLOCK5_FREQ);
constant CLOCK6_CAP_VECTOR        : std_logic_vector((((4+CLOCK6_NAME_WORD_LENGTH)*32)-1) downto 0)  := cap_rom_clks_vector_gen(CLOCK6_TYPE, 6, CLOCK6_NAME, CLOCK6_NAME'length, CLOCK6_NAME_WORD_LENGTH, CLOCK6_FREQ);
constant CLOCK7_CAP_VECTOR        : std_logic_vector((((4+CLOCK7_NAME_WORD_LENGTH)*32)-1) downto 0)  := cap_rom_clks_vector_gen(CLOCK7_TYPE, 7, CLOCK7_NAME, CLOCK7_NAME'length, CLOCK7_NAME_WORD_LENGTH, CLOCK7_FREQ);
constant CLOCK8_CAP_VECTOR        : std_logic_vector((((4+CLOCK8_NAME_WORD_LENGTH)*32)-1) downto 0)  := cap_rom_clks_vector_gen(CLOCK8_TYPE, 8, CLOCK8_NAME, CLOCK8_NAME'length, CLOCK8_NAME_WORD_LENGTH, CLOCK8_FREQ);
constant CLOCK9_CAP_VECTOR        : std_logic_vector((((4+CLOCK9_NAME_WORD_LENGTH)*32)-1) downto 0)  := cap_rom_clks_vector_gen(CLOCK9_TYPE, 9, CLOCK9_NAME, CLOCK9_NAME'length, CLOCK9_NAME_WORD_LENGTH, CLOCK9_FREQ);
constant CLOCK10_CAP_VECTOR       : std_logic_vector((((4+CLOCK10_NAME_WORD_LENGTH)*32)-1) downto 0) := cap_rom_clks_vector_gen(CLOCK10_TYPE, 10, CLOCK10_NAME, CLOCK10_NAME'length, CLOCK10_NAME_WORD_LENGTH, CLOCK10_FREQ);
constant CLOCK11_CAP_VECTOR       : std_logic_vector((((4+CLOCK11_NAME_WORD_LENGTH)*32)-1) downto 0) := cap_rom_clks_vector_gen(CLOCK11_TYPE, 11, CLOCK11_NAME, CLOCK11_NAME'length, CLOCK11_NAME_WORD_LENGTH, CLOCK11_FREQ);
constant CLOCK12_CAP_VECTOR       : std_logic_vector((((4+CLOCK12_NAME_WORD_LENGTH)*32)-1) downto 0) := cap_rom_clks_vector_gen(CLOCK12_TYPE, 12, CLOCK12_NAME, CLOCK12_NAME'length, CLOCK12_NAME_WORD_LENGTH, CLOCK12_FREQ);
constant CLOCK13_CAP_VECTOR       : std_logic_vector((((4+CLOCK13_NAME_WORD_LENGTH)*32)-1) downto 0) := cap_rom_clks_vector_gen(CLOCK13_TYPE, 13, CLOCK13_NAME, CLOCK13_NAME'length, CLOCK13_NAME_WORD_LENGTH, CLOCK13_FREQ);
constant CLOCK14_CAP_VECTOR       : std_logic_vector((((4+CLOCK14_NAME_WORD_LENGTH)*32)-1) downto 0) := cap_rom_clks_vector_gen(CLOCK14_TYPE, 14, CLOCK14_NAME, CLOCK14_NAME'length, CLOCK14_NAME_WORD_LENGTH, CLOCK14_FREQ);
constant CLOCK15_CAP_VECTOR       : std_logic_vector((((4+CLOCK15_NAME_WORD_LENGTH)*32)-1) downto 0) := cap_rom_clks_vector_gen(CLOCK15_TYPE, 15, CLOCK15_NAME, CLOCK15_NAME'length, CLOCK15_NAME_WORD_LENGTH, CLOCK15_FREQ);
constant CLOCK16_CAP_VECTOR       : std_logic_vector((((4+CLOCK16_NAME_WORD_LENGTH)*32)-1) downto 0) := cap_rom_clks_vector_gen(CLOCK16_TYPE, 16, CLOCK16_NAME, CLOCK16_NAME'length, CLOCK16_NAME_WORD_LENGTH, CLOCK16_FREQ);
constant CLOCK17_CAP_VECTOR       : std_logic_vector((((4+CLOCK17_NAME_WORD_LENGTH)*32)-1) downto 0) := cap_rom_clks_vector_gen(CLOCK17_TYPE, 17, CLOCK17_NAME, CLOCK17_NAME'length, CLOCK17_NAME_WORD_LENGTH, CLOCK17_FREQ);
constant CLOCK18_CAP_VECTOR       : std_logic_vector((((4+CLOCK18_NAME_WORD_LENGTH)*32)-1) downto 0) := cap_rom_clks_vector_gen(CLOCK18_TYPE, 18, CLOCK18_NAME, CLOCK18_NAME'length, CLOCK18_NAME_WORD_LENGTH, CLOCK18_FREQ);
constant CLOCK19_CAP_VECTOR       : std_logic_vector((((4+CLOCK19_NAME_WORD_LENGTH)*32)-1) downto 0) := cap_rom_clks_vector_gen(CLOCK19_TYPE, 19, CLOCK19_NAME, CLOCK19_NAME'length, CLOCK19_NAME_WORD_LENGTH, CLOCK19_FREQ);

-- Capability ROM
constant CLK_CAP_ROM_INIT         : CLKS_CAP_ROM_TYPE := clks_cap_rom_contents(
                                                                               VERSION_MINOR,
																			   VERSION_MAJOR,
																			   CLOCK0_EN, CLOCK0_CAP_VECTOR,
																			   CLOCK1_EN, CLOCK1_CAP_VECTOR,
																			   CLOCK2_EN, CLOCK2_CAP_VECTOR,
																			   CLOCK3_EN, CLOCK3_CAP_VECTOR,
																			   CLOCK4_EN, CLOCK4_CAP_VECTOR,
																			   CLOCK5_EN, CLOCK5_CAP_VECTOR,
																			   CLOCK6_EN, CLOCK6_CAP_VECTOR,
																			   CLOCK7_EN, CLOCK7_CAP_VECTOR,
																			   CLOCK8_EN, CLOCK8_CAP_VECTOR,
																			   CLOCK9_EN, CLOCK9_CAP_VECTOR,
																			   CLOCK10_EN, CLOCK10_CAP_VECTOR,
																			   CLOCK11_EN, CLOCK11_CAP_VECTOR,
																			   CLOCK12_EN, CLOCK12_CAP_VECTOR,
																			   CLOCK13_EN, CLOCK13_CAP_VECTOR,
																			   CLOCK14_EN, CLOCK14_CAP_VECTOR,
																			   CLOCK15_EN, CLOCK15_CAP_VECTOR,
																			   CLOCK16_EN, CLOCK16_CAP_VECTOR,
																			   CLOCK17_EN, CLOCK17_CAP_VECTOR,
																			   CLOCK18_EN, CLOCK18_CAP_VECTOR,
																			   CLOCK19_EN, CLOCK19_CAP_VECTOR
                                                                               );

signal clks_capability_rom                 : CLKS_CAP_ROM_TYPE := CLK_CAP_ROM_INIT;

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

signal waddr                               : std_logic_vector(12 downto 0);
signal raddr                               : integer;

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

raddr   <= conv_integer(araddr(12 downto 2));

-- Read Decode (need to determine registers and how I map them in in a controlled manner)
process (aclk)
begin
  if rising_edge(aclk) then
    if areset='1' then
      rdata_i                        <= (others => '0');
    else
      if arvalid='1' and arready_i='1' then
        rdata_i                      <= clks_capability_rom(raddr);
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

end rtl;