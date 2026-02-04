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
-- Title       : Memory Test Control Registers
-- Project     : Memory Test 
--------------------------------------------------------------------------------
-- Description : This is the AXI4-LITE interface that provides control to
--               the memory test + general test status.
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

entity mem_test_control_regs is
generic (
  MEM_DATA_WIDTH                  :      integer := 64;
  TEST_CTRL_CLK_PERIOD            :      integer := 10
  );
port (
  -- Clock and Reset
  aclk                            : in   std_logic;
  areset                          : in   std_logic;
  -- Write Address Interface      
  awaddr                          : in   std_logic_vector(5 downto 0);
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
  araddr                          : in   std_logic_vector(5 downto 0);						
  arvalid                         : in   std_logic;								
  arready                         : out  std_logic;								
  arprot                          : in   std_logic_vector(2 downto 0);
  -- Read Response Interface     										
  rdata                           : out  std_logic_vector(31 downto 0);				
  rresp                           : out  std_logic_vector(1 downto 0);				
  rvalid                          : out  std_logic;							
  rready                          : in   std_logic;							
  -- Memory Reset & Calibration 
  mem_reset                       : out  std_logic;
  mem_reset_status                : in   std_logic;
  calibration_success             : in   std_logic;
  calibration_fail                : in   std_logic;
  cattrip                         : in   std_logic;
  temp                            : in   std_logic_vector(2 downto 0);
  -- Memory Test Control
  test_reset                      : out  std_logic;
  test_enable                     : out  std_logic;
  test_pattern_sel                : out  std_logic_vector(5 downto 0);
  test_write_once                 : out  std_logic;
  -- Memory Test Status
  test_running                    : in   std_logic;
  test_fail                       : in   std_logic;
  test_complete_count             : in   std_logic_vector(31 downto 0);
  test_error_count                : in   std_logic_vector(31 downto 0);
  test_error_bits                 : in   std_logic_vector(MEM_DATA_WIDTH-1 downto 0);
  -- AXI Error Counts
  axi_bresp_error_count           : in   std_logic_vector(31 downto 0);
  axi_rresp_error_count           : in   std_logic_vector(31 downto 0);
  -- AXI Timeouts 
  write_timeout                   : in   std_logic;
  read_timeout                    : in   std_logic;
  -- Write & Read Bandwidths
  sample_toggle                   : out  std_logic;
  write_bandwidth                 : in   std_logic_vector(31 downto 0);
  read_bandwidth                  : in   std_logic_vector(31 downto 0)
  );
end entity mem_test_control_regs;

architecture rtl of mem_test_control_regs is

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

signal waddr                               : std_logic_vector(5 downto 0);

-- Address Constants
constant TEST_CONTROL_ADDR                 : std_logic_vector(5 downto 0) := "000000"; -- 0x00
constant TEST_STATUS_ADDR                  : std_logic_vector(5 downto 0) := "000100"; -- 0x04
constant MEMORY_STATUS_ADDR                : std_logic_vector(5 downto 0) := "001000"; -- 0x08
constant TESTS_COMPLETED_ADDR              : std_logic_vector(5 downto 0) := "001100"; -- 0x0C
constant ERROR_COUNT_ADDR                  : std_logic_vector(5 downto 0) := "010000"; -- 0x10
constant ERROR_BITS0_ADDR                  : std_logic_vector(5 downto 0) := "010100"; -- 0x14
constant ERROR_BITS1_ADDR                  : std_logic_vector(5 downto 0) := "011000"; -- 0x18
constant ERROR_BITS2_ADDR                  : std_logic_vector(5 downto 0) := "011100"; -- 0x1C
constant WRITE_BW_ADDR                     : std_logic_vector(5 downto 0) := "100000"; -- 0x20
constant READ_BW_ADDR                      : std_logic_vector(5 downto 0) := "100100"; -- 0x24
constant BRESP_ERROR_COUNT_ADDR            : std_logic_vector(5 downto 0) := "101000"; -- 0x28
constant RRESP_ERROR_COUNT_ADDR            : std_logic_vector(5 downto 0) := "101100"; -- 0x2C
constant CALIBRATION_TIMER_ADDR            : std_logic_vector(5 downto 0) := "110000"; -- 0x30

constant SAMPLE_TIME                       : integer := ((2000000000/TEST_CTRL_CLK_PERIOD)-1);

signal test_control_reg                    : std_logic_vector(31 downto 0);
signal test_status_reg                     : std_logic_vector(31 downto 0);
signal memory_status_reg                   : std_logic_vector(31 downto 0);
signal tests_completed_reg                 : std_logic_vector(31 downto 0);
signal error_count_reg                     : std_logic_vector(31 downto 0);
signal error_bits0_reg                     : std_logic_vector(31 downto 0);
signal error_bits1_reg                     : std_logic_vector(31 downto 0);
signal error_bits2_reg                     : std_logic_vector(31 downto 0);

signal test_reset_count                    : std_logic_vector(3 downto 0);
signal mem_reset_count                     : std_logic_vector(3 downto 0);

signal sample_toggle_i                     : std_logic;
signal sample_count                        : integer;

signal mem_reset_status_retime             : std_logic_vector(3 downto 0);
signal calibration_counter                 : std_logic_vector(31 downto 0);

begin

-- Wire up the Status Registers (there's only one control register)
test_status_reg          <= x"00" & x"00" & x"00" & x"0" & read_timeout & write_timeout & test_fail & test_running;
memory_status_reg        <= x"00" & x"00" & x"0" & temp & cattrip & x"0" & "0" & mem_reset_status & calibration_fail & calibration_success;
tests_completed_reg      <= test_complete_count;
error_count_reg          <= test_error_count;

-- As Test Error Bits is dependent on memory width, this will be handled via IF GENERATEs
error_bits_72 : if MEM_DATA_WIDTH=72 generate
  error_bits0_reg        <= test_error_bits(31 downto 0);
  error_bits1_reg        <= test_error_bits(63 downto 32);
  error_bits2_reg        <= x"00" & x"00" & x"00" & test_error_bits(71 downto 64);
end generate error_bits_72;

error_bits_64 : if MEM_DATA_WIDTH=64 generate
  error_bits0_reg        <= test_error_bits(31 downto 0);
  error_bits1_reg        <= test_error_bits(63 downto 32);
  error_bits2_reg        <= x"00" & x"00" & x"00" & x"00";
end generate error_bits_64;

error_bits_40 : if MEM_DATA_WIDTH=40 generate
  error_bits0_reg        <= test_error_bits(31 downto 0);
  error_bits1_reg        <= x"00" & x"00" & x"00" & test_error_bits(39 downto 32);
  error_bits2_reg        <= x"00" & x"00" & x"00" & x"00";
end generate error_bits_40;

error_bits_32 : if MEM_DATA_WIDTH=32 generate
  error_bits0_reg        <= test_error_bits(31 downto 0);
  error_bits1_reg        <= x"00" & x"00" & x"00" & x"00";
  error_bits2_reg        <= x"00" & x"00" & x"00" & x"00";
end generate error_bits_32;

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
          when TEST_CONTROL_ADDR =>
            rdata_i                  <= test_control_reg;          
          when TEST_STATUS_ADDR =>
            rdata_i                  <= test_status_reg;          
          when MEMORY_STATUS_ADDR =>
            rdata_i                  <= memory_status_reg;          
          when TESTS_COMPLETED_ADDR =>
            rdata_i                  <= tests_completed_reg;          
          when ERROR_COUNT_ADDR =>
            rdata_i                  <= error_count_reg;          
          when ERROR_BITS0_ADDR =>
            rdata_i                  <= error_bits0_reg;          
          when ERROR_BITS1_ADDR =>
            rdata_i                  <= error_bits1_reg;          
          when ERROR_BITS2_ADDR =>
            rdata_i                  <= error_bits2_reg;    
          when WRITE_BW_ADDR =>
            rdata_i                  <= "0" & write_bandwidth(31 downto 1);
          when READ_BW_ADDR =>
            rdata_i                  <= "0" & read_bandwidth(31 downto 1);
          when BRESP_ERROR_COUNT_ADDR =>
            rdata_i                  <= axi_bresp_error_count;
          when RRESP_ERROR_COUNT_ADDR =>
            rdata_i                  <= axi_rresp_error_count;   
          when CALIBRATION_TIMER_ADDR =>
            rdata_i                  <= calibration_counter;          
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
      test_control_reg                      <= (1 => '1', others => '0');
      test_reset_count                      <= (others => '1');
      mem_reset_count                       <= (others => '0');
    else				               
      if wready_i='1' and wvalid='1' then             
        case waddr is			              
         when TEST_CONTROL_ADDR =>
           if wstrb(0)='1' then
             test_control_reg(0)            <= wdata(0);
             test_control_reg(7 downto 2)   <= wdata(7 downto 2);
           end if;
           if wstrb(1)='1' then
             test_control_reg(8)            <= wdata(8);
             test_control_reg(15 downto 10) <= wdata(15 downto 10);
           end if;           
           if wstrb(2)='1' then
             test_control_reg(23 downto 16) <= wdata(23 downto 16);
           end if;           
           if wstrb(3)='1' then
             test_control_reg(31 downto 24) <= wdata(31 downto 24);
           end if; 
         when others =>
           null;
        end case;
      end if;
      -- Create 8-clock reset pulse for test reset
      if ((wready_i='1' and wvalid='1') and (waddr=TEST_CONTROL_ADDR and wstrb(0)='1')) and wdata(1)='1' then
        test_reset_count                    <= (others => '1');
        test_control_reg(1)                 <= '1';
      else
        if test_reset_count /= x"0" then
          test_reset_count                  <= test_reset_count-1;
        else
          test_control_reg(1)               <= '0';
        end if;
      end if;
      -- Create 8-clock reset pulse for memory reset
      if ((wready_i='1' and wvalid='1') and (waddr=TEST_CONTROL_ADDR and wstrb(1)='1')) and wdata(9)='1' then
        mem_reset_count                     <= (others => '1');
        test_control_reg(9)                 <= '1';
      else
        if mem_reset_count /= x"0" then
          mem_reset_count                   <= mem_reset_count-1;
        else
          test_control_reg(9)               <= '0';
        end if;
      end if;
    end if;
  end if;
end process;

mem_reset        <= test_control_reg(9);
test_reset       <= test_control_reg(1);
test_enable      <= test_control_reg(0);
test_pattern_sel <= test_control_reg(7 downto 2);
test_write_once  <= test_control_reg(8);

process (aclk)
begin 
  if rising_edge(aclk) then
    if areset='1' then
      mem_reset_status_retime      <= (others => '0');
      calibration_counter          <= (others => '0');
    else 
      mem_reset_status_retime      <= mem_reset_status_retime(2 downto 0) & mem_reset_status;
      if test_control_reg(9)='1' or (mem_reset_status_retime(3)='0' and mem_reset_status_retime(2)='1') then
        calibration_counter        <= (others => '0');
      else
        if calibration_success='0' and calibration_fail='0' then
          calibration_counter      <= calibration_counter+1;
        end if;
      end if;
    end if;
  end if;
end process;

process (aclk)
begin
  if rising_edge(aclk) then
    -- Reset when the test is reset
    if areset='1' or test_control_reg(1)='1' then
      sample_count           <= 0;
      sample_toggle_i        <= '0';
    else
      -- Start sampling once the test is enabled
      if test_control_reg(0)='1' then
        if sample_count = SAMPLE_TIME then
          sample_count       <= 0;
          sample_toggle_i    <= not (sample_toggle_i);
        else
          sample_count       <= sample_count+1;
        end if;
      end if;
    end if;
  end if;
end process;

sample_toggle <= sample_toggle_i;

end rtl;