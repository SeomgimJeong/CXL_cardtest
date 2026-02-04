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
-- Title       : Data Generation & Verification
-- Project     : Memory Test
--------------------------------------------------------------------------------
-- Description : A memory BIST that provides a generic memory map interface.
--               This component generates the test data to be written to
--               memory and also verifies any data read from memory.
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

entity mem_test_data_check is 
generic (
  ADDR_WIDTH                 : integer := 10;
  MEM_DATA_WIDTH             : integer range 1 to 128  := 64;  
  EMIF_DATA_WIDTH            : integer range 1 to 1024 := 512   
  );			     
port (			     
  -- Memory Interface	     
  mem_clk                    : in    std_logic;
  mem_reset                  : in    std_logic;
  mem_waddr                  : out   std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_wdata                  : out   std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
  mem_wbyte_en               : out   std_logic_vector(((EMIF_DATA_WIDTH/8)-1) downto 0);
  mem_wvalid                 : out   std_logic;
  mem_wready                 : in    std_logic;
  mem_raddr                  : out   std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_rvalid                 : out   std_logic;
  mem_rready                 : in    std_logic;
  mem_rdata                  : in    std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
  mem_rdatavalid             : in    std_logic;
  -- Memory Status	     
  mem_cal_complete           : in    std_logic;
  -- Test Controls	     
  mem_test_reset             : in    std_logic;
  mem_test_enable            : in    std_logic;
  mem_test_pattern           : in    std_logic_vector(5 downto 0);
  mem_test_write_once        : in    std_logic;
  mem_test_start_addr        : in    std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_test_end_addr          : in    std_logic_vector(ADDR_WIDTH-1 downto 0);
  -- Test Status	     
  mem_test_running           : out   std_logic;
  mem_test_fail              : out   std_logic;
  mem_test_completed_cnt     : out   std_logic_vector(31 downto 0);
  mem_test_error_cnt         : out   std_logic_vector(31 downto 0);
  mem_test_error_bits        : out   std_logic_vector((MEM_DATA_WIDTH-1) downto 0);
  -- Results RAM	     
  words_stored               : out   std_logic_vector(15 downto 0);
  address_mem_wr             : out   std_logic;
  address_mem_addr           : out   std_logic_vector(9 downto 0);
  address_mem_data           : out   std_logic_vector(ADDR_WIDTH-1 downto 0);
  expected_mem_wr            : out   std_logic;
  expected_mem_addr          : out   std_logic_vector(9 downto 0);
  expected_mem_data          : out   std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
  received_mem_wr            : out   std_logic;
  received_mem_addr          : out   std_logic_vector(9 downto 0);
  received_mem_data          : out   std_logic_vector((EMIF_DATA_WIDTH-1) downto 0)
  );
end entity mem_test_data_check;

architecture rtl of mem_test_data_check is

-- A function to calculate the parity (if there are parity bits)
function get_parity (data_width : integer) return integer is

  variable remainder : integer;
  
begin

  if data_width < 64 then
    remainder := data_width-32;
  elsif data_width < 128 then
    remainder := data_width-64;
  elsif data_width < 256 then
    remainder := data_width-128;
  elsif data_width < 512 then
    remainder := data_width-256;
  else
    remainder := data_width-512;
  end if;
  
  return remainder;
  
end get_parity;

-- Component Declarations
component wide_prbs_gen
generic (
  width            :     integer := 11;   
  data_width       :     integer := 128  
  );
port (
  clock            : in  std_logic;
  sync_reset       : in  std_logic;
  enable           : in  std_logic;
  load             : in  std_logic;
  prbs_context_in  : in  std_logic_vector(data_width-1 downto 0);
  prbs_context_out : out std_logic_vector(data_width-1 downto 0);
  data             : out std_logic_vector(data_width-1 downto 0)
  );
end component;

-- Derived Constants
constant BURST_WIDTH            : integer := EMIF_DATA_WIDTH/MEM_DATA_WIDTH;
constant MEM_BYTE_WIDTH         : integer := MEM_DATA_WIDTH/8;
constant EMIF_BYTE_WIDTH        : integer := EMIF_DATA_WIDTH/8;
constant EMIF_PARITY_WIDTH      : integer := get_parity(EMIF_DATA_WIDTH);
constant EMIF_NONPARITY_WIDTH   : integer := EMIF_DATA_WIDTH-EMIF_PARITY_WIDTH;
constant ADDR_INC               : integer := EMIF_NONPARITY_WIDTH/8;

constant TEMP_FIVES             : std_logic_vector(1023 downto 0) := x"5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555";
constant TEMP_AS                : std_logic_vector(1023 downto 0) := x"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
constant TEMP_ZEROS             : std_logic_vector(1023 downto 0) := x"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
constant TEMP_FS                : std_logic_vector(1023 downto 0) := x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";

constant ZERO_ERRORS            : std_logic_vector(BURST_WIDTH-1 downto 0)   := (others      => '0');
constant MAX_WORDS_STORED       : std_logic_vector(10 downto 0)              := "10000000000";
constant MAX_ERRORS             : std_logic_vector(31 downto 0)              := x"FFFFFFFF";
constant ZERO32                 : std_logic_vector(31 downto 0)              := (others      => '0');

-- AXI Signals (Internal)
signal mem_wvalid_i             : std_logic;
signal mem_rvalid_i             : std_logic;

-- AXI Shortcuts (transaction accepts)
signal w_accept                 : std_logic;
signal r_accept                 : std_logic;

-- Resets
signal test_fsm_reset           : std_logic;
signal error_store_reset        : std_logic;
signal load_data_reset          : std_logic;
signal check_data_reset         : std_logic;
signal addr_reset               : std_logic;

-- Test State Machine Signals
type test_states is (IDLE, WAIT_FOR_CALIBRATE, CHECK_MODE, WRITE_DATA, READ_DATA, CHANGE_MODE);
signal test_fsm                 : test_states;
signal pattern_written          : std_logic;
signal inc_pattern_type         : std_logic;
signal inc_test_count           : std_logic;
signal read_done                : std_logic;

signal active_pattern           : std_logic_vector(5 downto 0);
signal active_pattern_d1        : std_logic_vector(5 downto 0);
signal active_pattern_d2        : std_logic_vector(5 downto 0);
signal pattern_check            : std_logic_vector(5 downto 0);
signal pattern_valid            : std_logic;

signal tests_completed          : std_logic_vector(31 downto 0);

-- Test Data (Load and Check)
signal seq_data_load            : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
signal seq_data_check           : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
signal rolling_one_data_load    : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
signal rolling_one_data_check   : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
signal rolling_zero_data_load   : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
signal rolling_zero_data_check  : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
signal fives_as_data_load       : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
signal fives_as_data_check      : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
signal zeros_fs_data_load       : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
signal zeros_fs_data_check      : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
signal prbs_data_load           : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
signal prbs_data_check          : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);

signal prbs_load_data_enable    : std_logic;
signal prbs_check_data_enable   : std_logic;

signal null_data                : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0) := (others => '0');

signal write_addr               : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal read_addr                : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal read_count               : std_logic_vector(ADDR_WIDTH downto 0);
signal read_data_count          : std_logic_vector(ADDR_WIDTH downto 0);
signal end_address              : std_logic_vector(ADDR_WIDTH-1 downto 0);

signal check_data               : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
signal check_data_d1            : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);    
signal check_data_d2            : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);    
signal check_data_d3            : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);    

signal mem_rdatavalid_d1        : std_logic;
signal mem_rdatavalid_d2        : std_logic;
signal mem_rdatavalid_d3        : std_logic;

signal mem_rdata_d1             : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);      
signal mem_rdata_d2             : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);     
signal mem_rdata_d3             : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);     

signal test_running             : std_logic;
signal test_fail                : std_logic;       
signal data_error               : std_logic_vector(BURST_WIDTH-1 downto 0);      
signal error_data_bits          : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
signal error_count              : std_logic_vector(31 downto 0);     
signal error_temp               : std_logic;      
signal error_bits               : std_logic_vector((MEM_DATA_WIDTH-1) downto 0);

signal address_mem_addr_i       : std_logic_vector(9 downto 0);
signal expected_mem_addr_i      : std_logic_vector(9 downto 0);
signal received_mem_addr_i      : std_logic_vector(9 downto 0);

signal address_mem_data_tmp     : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal address_mem_data_i       : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal expected_mem_data_i      : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);
signal received_mem_data_i      : std_logic_vector((EMIF_DATA_WIDTH-1) downto 0);

signal words_stored_i           : std_logic_vector(10 downto 0);

begin

-- Drive out any internal AXI signals.
mem_wvalid         <= mem_wvalid_i;
mem_rvalid         <= mem_rvalid_i;

-- Create signals to determine valid AXI interactions.
w_accept           <= '1' when mem_wvalid_i='1' and mem_wready='1' else '0';
r_accept           <= '1' when mem_rvalid_i='1' and mem_rready='1' else '0';

process (mem_clk)
begin
  if rising_edge(mem_clk) then
    if mem_reset='1' or mem_test_reset='1' then
      test_fsm_reset            <= '1';
      error_store_reset         <= '1';
    else
      test_fsm_reset            <= '0';
      error_store_reset         <= '0';
    end if;
  end if;
end process;

-- Create multiple resets (may need a KEEP attribute to ensure they all remain).
process (mem_clk)
begin
  if rising_edge(mem_clk) then
    if mem_reset='1' or mem_test_reset='1' or test_fsm=CHANGE_MODE then
      load_data_reset           <= '1';
      check_data_reset          <= '1';
      addr_reset                <= '1';
    else
      load_data_reset           <= '0';
      check_data_reset          <= '0';    
      addr_reset                <= '0';
    end if;
  end if;
end process;

-- Test State Machine 
-- Determines whether we are writing or reading and ensures that current active pattern
-- is a valid one selected by the control logic.
process (mem_clk)
begin
  if rising_edge(mem_clk) then
    if test_fsm_reset = '1' then
      test_fsm                  <= IDLE;
      inc_test_count            <= '0';
      pattern_written           <= '0';
      read_done                 <= '0';
      test_running              <= '0';
    else
      inc_test_count            <= '0';
      if mem_test_write_once = '0' then
        pattern_written         <= '0';
      end if;
      case test_fsm is
        -- Intial State
        when IDLE =>
          test_fsm            <= WAIT_FOR_CALIBRATE;
        -- When Calibration Complete, go to check for valid pattern selection
        when WAIT_FOR_CALIBRATE =>
          if mem_test_enable='1' then
            if mem_cal_complete = '1' then
              test_fsm          <= CHECK_MODE;
              test_running      <= '1';
            end if;
          end if;
        -- If current active pattern is not enabled, change active pattern.
        -- Otherwise, go to WRITE_DATA or READ_DATA.
        when CHECK_MODE =>
          if pattern_valid='1' then 
            if mem_test_write_once='1' and pattern_written='1' then
              test_fsm        <= READ_DATA;
              read_done       <= '0';
            else  
              test_fsm        <= WRITE_DATA;
            end if;
          else
            test_fsm          <= CHANGE_MODE;
          end if;
        -- Keep writing until last word written to last address.
        -- Then go to READ_DATA
        when WRITE_DATA =>
          if write_addr = end_address and w_accept='1' then
            if mem_test_enable='1' then 
              test_fsm          <= READ_DATA;
              read_done         <= '0';
              if mem_test_write_once = '1' then
                pattern_written <= '1';
              end if;
            else 
              test_fsm          <= WAIT_FOR_CALIBRATE;
              test_running      <= '0';
            end if;
          end if;
        -- Keep reading until last word read from last address
        -- Then change active pattern (CHANGE_MODE).
        when READ_DATA =>
          if read_done='1' then
            if read_data_count = read_count then
              if mem_test_enable='1' then
                test_fsm          <= CHANGE_MODE;
                inc_test_count    <= '1';
              else  
                test_fsm          <= WAIT_FOR_CALIBRATE;
                test_running      <= '0';
              end if;
            end if;
          elsif read_addr = end_address and r_accept='1' then
            read_done         <= '1';
          end if;
        -- Active Pattern change (see below)
        when CHANGE_MODE =>
          test_fsm            <= CHECK_MODE;
        when others =>
          test_fsm            <= IDLE;
      end case;
    end if;
  end if;
end process;

inc_pattern_type <= '1' when test_fsm=CHANGE_MODE else '0';

-- Determine Active Pattern.
process (mem_clk)
begin
  if rising_edge(mem_clk) then
    if test_fsm_reset='1' then
      active_pattern               <= "000001";
      active_pattern_d1            <= "000001";
      active_pattern_d2            <= "000001";
    else
      if inc_pattern_type='1' then
        active_pattern(0)          <= active_pattern(5);
        active_pattern(5 downto 1) <= active_pattern(4 downto 0);
      end if;
      active_pattern_d1            <= active_pattern;
      active_pattern_d2            <= active_pattern_d1;
    end if;
  end if;
end process;
pattern_check <= active_pattern and mem_test_pattern;
pattern_valid <= ((pattern_check(0) xor pattern_check(1)) xor (pattern_check(2) xor pattern_check(3))) xor (pattern_check(4) xor pattern_check(5)); 

-- Count tests completed.
process (mem_clk) 
begin
  if rising_edge(mem_clk) then
    if test_fsm_reset='1' then
      tests_completed        <= (others => '0');
      mem_test_completed_cnt <= (others => '0');
    else
      if inc_test_count='1' then
        tests_completed      <= tests_completed+1;
      end if;
      mem_test_completed_cnt <= tests_completed;
    end if;
  end if;
end process;

-- Load Data
process (mem_clk)
begin
  if rising_edge(mem_clk) then
    -- (32-bit) Data alternates between all 5's and all A's
    -- (32-bit) Data alternates between all 0's and all F's
    for i in 0 to ((BURST_WIDTH/2)-1) loop
      for j in 0 to MEM_BYTE_WIDTH-1 loop
        fives_as_data_load((((i*2)*MEM_DATA_WIDTH)+((j*8)+7)) downto (((i*2)*MEM_DATA_WIDTH)+(j*8)))                                  <= TEMP_FIVES(7 downto 0);
        fives_as_data_load((((i*2)*MEM_DATA_WIDTH)+((j*8)+MEM_DATA_WIDTH+7)) downto (((i*2)*MEM_DATA_WIDTH)+((j*8)+MEM_DATA_WIDTH)))  <= TEMP_AS(7 downto 0);
        zeros_fs_data_load((((i*2)*MEM_DATA_WIDTH)+((j*8)+7)) downto (((i*2)*MEM_DATA_WIDTH)+(j*8)))                                  <= TEMP_ZEROS(7 downto 0);
        zeros_fs_data_load((((i*2)*MEM_DATA_WIDTH)+((j*8)+MEM_DATA_WIDTH+7)) downto (((i*2)*MEM_DATA_WIDTH)+((j*8)+MEM_DATA_WIDTH)))  <= TEMP_FS(7 downto 0);
      end loop;
    end loop;  
    if load_data_reset='1' then
      -- Initialize Sequential Data
      for i in 0 to (BURST_WIDTH-1) loop
        for j in 0 to (MEM_BYTE_WIDTH-1) loop
          seq_data_load(((i*MEM_DATA_WIDTH)+((j*8)+7)) downto ((i*MEM_DATA_WIDTH)+(j*8)))                                             <= conv_std_logic_vector(i, 8);
        end loop;													              
      end loop;														              
      -- Initialize Rolling '1' and Rolling '0' Data
      for i in 0 to (BURST_WIDTH-1) loop										              
        rolling_one_data_load(((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-1) downto (i*MEM_DATA_WIDTH))                                        <= (others => '0');
        rolling_one_data_load((i*MEM_DATA_WIDTH)+i)                                                                                   <= '1';
        rolling_zero_data_load(((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-1) downto (i*MEM_DATA_WIDTH))                                       <= (others => '1');
        rolling_zero_data_load((i*MEM_DATA_WIDTH)+i)                                                                                  <= '0';
      end loop;      
    else
      if test_fsm=WRITE_DATA and w_accept='1' then
        -- Sequential Data
        -- Increment each byte separately
        -- Each sample written to memory will increment from the one before.
        for i in 0 to (BURST_WIDTH-1) loop
          for j in 0 to (MEM_BYTE_WIDTH-1) loop
            seq_data_load(((i*MEM_DATA_WIDTH)+((j*8)+7)) downto ((i*MEM_DATA_WIDTH)+(j*8)))                                           <= seq_data_load(((i*MEM_DATA_WIDTH)+((j*8)+7)) downto ((i*MEM_DATA_WIDTH)+(j*8)))+BURST_WIDTH;
          end loop;
        end loop;
        -- Rolling One Data
        -- Each word written to memory has a different start point
        -- Each word written will shift by the burst count
        -- This ensures that the '1' rolls to the next bit (for each word written to memory)
         for i in 0 to (BURST_WIDTH-1) loop
          rolling_one_data_load(((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-1) downto ((i*MEM_DATA_WIDTH)+BURST_WIDTH))                        <= rolling_one_data_load((((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-BURST_WIDTH)-1) downto (i*MEM_DATA_WIDTH));
          rolling_one_data_load((((i*MEM_DATA_WIDTH)+BURST_WIDTH)-1) downto (i*MEM_DATA_WIDTH))                                       <= rolling_one_data_load(((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-1) downto ((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-BURST_WIDTH));
        end loop; 
        -- Rolling Zero Data
        -- Similar to Rolling One Data (with data inversed)
        for i in 0 to (BURST_WIDTH-1) loop
          rolling_zero_data_load(((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-1) downto ((i*MEM_DATA_WIDTH)+BURST_WIDTH))                       <= rolling_zero_data_load((((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-BURST_WIDTH)-1) downto (i*MEM_DATA_WIDTH));
          rolling_zero_data_load((((i*MEM_DATA_WIDTH)+BURST_WIDTH)-1) downto (i*MEM_DATA_WIDTH))                                      <= rolling_zero_data_load(((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-1) downto ((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-BURST_WIDTH));
        end loop;   
      end if;
    end if;
  end if;
end process;

-- PRBS Data Load
prbs_load_data_enable <= '1' when active_pattern_d1(5)='1' and test_fsm = WRITE_DATA and w_accept='1' else '0';
      
random_test_pattern : wide_prbs_gen
generic map (
  width            => 31,
  data_width       => EMIF_DATA_WIDTH
  )
port map (
  clock            => mem_clk,
  sync_reset       => load_data_reset,
  enable           => prbs_load_data_enable,
  load             => '0',
  prbs_context_in  => null_data,
  prbs_context_out => open,
  data             => prbs_data_load
  );

-- Check Data
process (mem_clk)
begin
  if rising_edge(mem_clk) then
    -- All 5's, all A's
    -- All 0's. all F's
    -- See Test Data Pattern for further information
    for i in 0 to ((BURST_WIDTH/2)-1) loop
      for j in 0 to MEM_BYTE_WIDTH-1 loop
        fives_as_data_check((((i*2)*MEM_DATA_WIDTH)+((j*8)+7)) downto (((i*2)*MEM_DATA_WIDTH)+(j*8)))                                 <= TEMP_FIVES(7 downto 0);
        fives_as_data_check((((i*2)*MEM_DATA_WIDTH)+((j*8)+MEM_DATA_WIDTH+7)) downto (((i*2)*MEM_DATA_WIDTH)+((j*8)+MEM_DATA_WIDTH))) <= TEMP_AS(7 downto 0);
        zeros_fs_data_check((((i*2)*MEM_DATA_WIDTH)+((j*8)+7)) downto (((i*2)*MEM_DATA_WIDTH)+(j*8)))                                 <= TEMP_ZEROS(7 downto 0);
        zeros_fs_data_check((((i*2)*MEM_DATA_WIDTH)+((j*8)+MEM_DATA_WIDTH+7)) downto (((i*2)*MEM_DATA_WIDTH)+((j*8)+MEM_DATA_WIDTH))) <= TEMP_FS(7 downto 0);
      end loop;
    end loop;
    if check_data_reset='1' then
      for i in 0 to (BURST_WIDTH-1) loop
        for j in 0 to (MEM_BYTE_WIDTH-1) loop
          seq_data_check((((i*8)*MEM_BYTE_WIDTH)+((j*8)+7)) downto (((i*8)*MEM_BYTE_WIDTH)+(j*8)))                                    <= conv_std_logic_vector(i, 8);
        end loop;
      end loop;
      for i in 0 to (BURST_WIDTH-1) loop
        rolling_one_data_check(((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-1) downto (i*MEM_DATA_WIDTH))                                       <= (others => '0');
        rolling_one_data_check((i*MEM_DATA_WIDTH)+i)                                                                                  <= '1';
        rolling_zero_data_check(((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-1) downto (i*MEM_DATA_WIDTH))                                      <= (others => '1');
        rolling_zero_data_check((i*MEM_DATA_WIDTH)+i)                                                                                 <= '0';
      end loop;
    else
      if test_fsm=READ_DATA and mem_rdatavalid='1' then
        -- Sequential Data
        -- See Test Data Pattern for further information
        for i in 0 to (BURST_WIDTH-1) loop
          for j in 0 to (MEM_BYTE_WIDTH-1) loop
            seq_data_check(((i*MEM_DATA_WIDTH)+((j*8)+7)) downto ((i*MEM_DATA_WIDTH)+(j*8)))                                          <= seq_data_check(((i*MEM_DATA_WIDTH)+((j*8)+7)) downto ((i*MEM_DATA_WIDTH)+(j*8)))+BURST_WIDTH;
          end loop;
        end loop;
        -- Rolling One Data
        -- See Test Data Pattern for further information
        for i in 0 to (BURST_WIDTH-1) loop
          rolling_one_data_check(((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-1) downto ((i*MEM_DATA_WIDTH)+BURST_WIDTH))                       <= rolling_one_data_check((((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-BURST_WIDTH)-1) downto (i*MEM_DATA_WIDTH));
          rolling_one_data_check((((i*MEM_DATA_WIDTH)+BURST_WIDTH)-1) downto (i*MEM_DATA_WIDTH))                                      <= rolling_one_data_check(((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-1) downto ((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-BURST_WIDTH));
        end loop;
        -- Rolling Zero Data
        -- See Test Data Pattern for further information
        for i in 0 to (BURST_WIDTH-1) loop
          rolling_zero_data_check(((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-1) downto ((i*MEM_DATA_WIDTH)+BURST_WIDTH))                      <= rolling_zero_data_check((((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-BURST_WIDTH)-1) downto (i*MEM_DATA_WIDTH));
          rolling_zero_data_check((((i*MEM_DATA_WIDTH)+BURST_WIDTH)-1) downto (i*MEM_DATA_WIDTH))                                     <= rolling_zero_data_check(((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-1) downto ((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-BURST_WIDTH));
        end loop;    
      end if;
    end if;
  end if;
end process;
    
prbs_check_data_enable <= '1' when active_pattern_d2(5)='1' and test_fsm=READ_DATA and mem_rdatavalid='1' else '0';
        
random_chk_pattern : wide_prbs_gen
generic map (
  width            => 31,
  data_width       => EMIF_DATA_WIDTH
  )
port map (
  clock            => mem_clk,
  sync_reset       => check_data_reset,
  enable           => prbs_check_data_enable,
  load             => '0',
  prbs_context_in  => null_data,
  prbs_context_out => open,
  data             => prbs_data_check
  );
           
-- Address Counters
process (mem_clk)
begin
  if rising_edge(mem_clk) then
    if addr_reset='1' then
      write_addr           <= mem_test_start_addr;
      read_addr            <= mem_test_start_addr;
      read_count           <= (others => '0');
      read_data_count      <= (others => '0');
    else
      end_address          <= mem_test_end_addr;
      if test_fsm=WRITE_DATA and w_accept='1' then
        write_addr         <= write_addr+ADDR_INC;
      end if;
      if test_fsm=READ_DATA and r_accept='1' then
        read_addr          <= read_addr+ADDR_INC;
        read_count         <= read_count+1;    
      end if;
      if test_fsm=READ_DATA and mem_rdatavalid='1' then
        read_data_count    <= read_data_count+1;
      end if;
    end if;
  end if;
end process;

-- Write Signals
mem_waddr      <= write_addr;
mem_wvalid_i   <= '1' when test_fsm=WRITE_DATA else '0';

mem_wdata <= seq_data_load when active_pattern_d1(0)='1' else
             rolling_one_data_load when active_pattern_d1(1)='1' else
             rolling_zero_data_load when active_pattern_d1(2)='1' else
             fives_as_data_load when active_pattern_d1(3)='1' else
             zeros_fs_data_load when active_pattern_d1(4)='1' else
             prbs_data_load;
             
mem_wbyte_en <= (others => '1');

-- Read Signals
mem_raddr      <= read_addr;
mem_rvalid_i   <= '1' when (test_fsm=READ_DATA and read_done='0') else '0';

check_data <= seq_data_check when active_pattern_d2(0)='1' else
              rolling_one_data_check when active_pattern_d2(1)='1' else
              rolling_zero_data_check when active_pattern_d2(2)='1' else
              fives_as_data_check when active_pattern_d2(3)='1' else
              zeros_fs_data_check when active_pattern_d2(4)='1' else
              prbs_data_check;
         
-- Pipeline the incoming read data/valid + check data for easier processing.         
process (mem_clk)
begin
  if rising_edge(mem_clk) then
    check_data_d1       <= check_data;
    check_data_d2       <= check_data_d1;
    check_data_d3       <= check_data_d2;
    mem_rdatavalid_d1   <= mem_rdatavalid;
    mem_rdatavalid_d2   <= mem_rdatavalid_d1;
    mem_rdatavalid_d3   <= mem_rdatavalid_d2;
    mem_rdata_d1        <= mem_rdata;
    mem_rdata_d2        <= mem_rdata_d1;
    mem_rdata_d3        <= mem_rdata_d2;
  end if;
end process;

-- Test Running
process (mem_clk)
begin
  if rising_edge(mem_clk) then
    if test_fsm_reset='1' then
      mem_test_running             <= '0';
    else
      mem_test_running             <= test_running;
    end if;
  end if;
end process;     

-- Data Verification
process (mem_clk)
begin 
  if rising_edge(mem_clk) then
    if test_fsm_reset='1' then
      mem_test_fail                      <= '0';
      test_fail                          <= '0';
      data_error                         <= (others => '0');
      error_data_bits                    <= (others => '0');
      mem_test_error_cnt                 <= (others => '0');
      error_count                        <= (others => '0');
      error_temp                         <= '0';
    else
      mem_test_fail                      <= test_fail;
      mem_test_error_cnt                 <= error_count;
      if test_running='1' then
        if (data_error /= ZERO_ERRORS) then
          test_fail                      <= '1';
          error_temp                     <= '1';
        else
          error_temp                     <= '0';
        end if;
        if mem_rdatavalid_d2='1' then
          for i in 0 to BURST_WIDTH-1 loop
            if mem_rdata_d2(((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-1) downto (i*MEM_DATA_WIDTH)) /= check_data_d2(((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-1) downto (i*MEM_DATA_WIDTH)) then
              data_error(i)              <= '1';
            else
              data_error(i)              <= '0';
            end if;
          end loop;
          if (data_error /= ZERO_ERRORS) then
            if error_count /= MAX_ERRORS then
              error_count                <= error_count+1;
            end if;
          end if;
          for i in 0 to (EMIF_DATA_WIDTH-1) loop
            if mem_rdata_d2(i) /= check_data_d2(i) then
              error_data_bits(i)         <= '1';
            end if;
          end loop;
        end if;
      end if;
    end if;
  end if;
end process;

-- Determine Error Bits
process (mem_clk) 
  variable tmp_data_error_v              : std_logic_vector((MEM_DATA_WIDTH-1) downto 0);
begin
  if rising_edge(mem_clk) then
    if test_fsm_reset='1' then
      mem_test_error_bits    <= (others => '0');
      error_bits             <= (others => '0');
      tmp_data_error_v       := (others => '0');
    else
      mem_test_error_bits    <= error_bits;
      tmp_data_error_v       := (others => '0');
      for i in 0 to BURST_WIDTH-1 loop
        tmp_data_error_v     := tmp_data_error_v or error_data_bits(((i*MEM_DATA_WIDTH)+MEM_DATA_WIDTH-1) downto (i*MEM_DATA_WIDTH));
      end loop;
      error_bits             <= tmp_data_error_v;
    end if;
  end if;
end process;

-- Error Logging (3 processes)
process (mem_clk)
begin
  if rising_edge(mem_clk) then
    if error_store_reset = '1' then
      address_mem_data_tmp   <= mem_test_start_addr;
    else
      if mem_rdatavalid_d2 = '1' then
        address_mem_data_tmp <= address_mem_data_tmp+ADDR_INC;
      end if;
    end if;
    address_mem_data_i       <= address_mem_data_tmp;
    expected_mem_data_i      <= check_data_d2;
    received_mem_data_i      <= mem_rdata_d2;
 end if;
end process;

-- Error Logging continued
process (mem_clk)
begin
  if rising_edge(mem_clk) then
    if error_store_reset = '1' then
      address_mem_addr_i            <= (others => '0');
      expected_mem_addr_i           <= (others => '0');
      received_mem_addr_i           <= (others => '0');
      words_stored_i                <= (others => '0');
      words_stored                  <= (others => '0');
    else
      case BURST_WIDTH is
        when 1                                 =>
          words_stored(11 downto 1) <= words_stored_i;
        when 2                                 =>
          words_stored(12 downto 2) <= words_stored_i;
        when 4                                 =>
          words_stored(13 downto 3) <= words_stored_i;
        when 8                                 =>
          words_stored(14 downto 4) <= words_stored_i;
        when others                            =>
          words_stored(10 downto 0) <= words_stored_i;
      end case;
      if (data_error /= ZERO_ERRORS) and mem_rdatavalid_d3='1' then
        address_mem_addr_i          <= address_mem_addr_i+1;
        expected_mem_addr_i         <= expected_mem_addr_i+1;
        received_mem_addr_i         <= received_mem_addr_i+1;
        if words_stored_i < MAX_WORDS_STORED then
          words_stored_i            <= words_stored_i+1;
        end if;
      end if;
    end if;
  end if;
end process;

-- Error Logging (final process)
process (mem_clk)
begin
  if rising_edge(mem_clk) then
    if error_store_reset = '1' then
      address_mem_data        <= (others => '0');
      expected_mem_data       <= (others => '0');
      received_mem_data       <= (others => '0');
      address_mem_addr        <= (others => '0');
      expected_mem_addr       <= (others => '0');
      received_mem_addr       <= (others => '0');
      address_mem_wr          <= '0';
      expected_mem_wr         <= '0';
      received_mem_wr         <= '0';
    else
      address_mem_addr        <= address_mem_addr_i;
      expected_mem_addr       <= expected_mem_addr_i;
      received_mem_addr       <= received_mem_addr_i;
      if (data_error /= ZERO_ERRORS) and (mem_rdatavalid_d3='1' and words_stored_i /= MAX_WORDS_STORED) then
        address_mem_wr        <= '1';
        expected_mem_wr       <= '1';
        received_mem_wr       <= '1';
        address_mem_data      <= address_mem_data_i;
        expected_mem_data     <= expected_mem_data_i;
        received_mem_data     <= received_mem_data_i;
      else
        address_mem_wr        <= '0';
        expected_mem_wr       <= '0';
        received_mem_wr       <= '0';
      end if;
    end if;
  end if;
end process;
           
end rtl;
  
  
  
 