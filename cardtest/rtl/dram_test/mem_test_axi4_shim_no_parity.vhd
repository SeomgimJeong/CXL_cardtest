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
-- Title       : AXI4 Shim for the Memory Test
-- Project     : Memory Test
--------------------------------------------------------------------------------
-- Description : Converts the native memory map interface of the Memory Test
--               to AXI4.
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

entity mem_test_axi4_shim_no_parity is 
generic (
  ADDR_WIDTH             :       integer := 10;
  DATA_WIDTH             :       integer := 512;
  USER_WIDTH             :       integer := 64;
  BURST_LENGTH           :       integer := 256;
  MEM_BURST              :       integer := 8;
  MEM_DATA_WIDTH         :       integer := 64
  );
port (
  -- AXI4 Interface
  axi4_aclk              : in    std_logic;
  axi4_areset            : in    std_logic;
  axi4_awready           : in    std_logic;
  axi4_awvalid           : out   std_logic;
  axi4_awid              : out   std_logic_vector(6 downto 0);
  axi4_awaddr            : out   std_logic_vector(ADDR_WIDTH-1 downto 0);
  axi4_awlen             : out   std_logic_vector(7 downto 0);
  axi4_awsize            : out   std_logic_vector(2 downto 0);
  axi4_awburst           : out   std_logic_vector(1 downto 0);
  axi4_awlock            : out   std_logic_vector(0 downto 0);
  axi4_awprot            : out   std_logic_vector(2 downto 0);
  axi4_awqos             : out   std_logic_vector(3 downto 0);
  axi4_awuser            : out   std_logic_vector(10 downto 0);
  axi4_arready           : in    std_logic;
  axi4_arvalid           : out   std_logic;
  axi4_arid              : out   std_logic_vector(6 downto 0);
  axi4_araddr            : out   std_logic_vector(ADDR_WIDTH-1 downto 0);
  axi4_arlen             : out   std_logic_vector(7 downto 0);
  axi4_arsize            : out   std_logic_vector(2 downto 0);
  axi4_arburst           : out   std_logic_vector(1 downto 0);
  axi4_arlock            : out   std_logic_vector(0 downto 0);
  axi4_arprot            : out   std_logic_vector(2 downto 0);
  axi4_arqos             : out   std_logic_vector(3 downto 0);
  axi4_aruser            : out   std_logic_vector(10 downto 0);
  axi4_wready            : in    std_logic;
  axi4_wvalid            : out   std_logic;
  axi4_wdata             : out   std_logic_vector((DATA_WIDTH-1) downto 0);
  axi4_wuser             : out   std_logic_vector((USER_WIDTH-1) downto 0);
  axi4_wstrb             : out   std_logic_vector(((DATA_WIDTH/8)-1) downto 0);
  axi4_wlast             : out   std_logic;
  axi4_bready            : out   std_logic;
  axi4_bvalid            : in    std_logic;
  axi4_bid               : in    std_logic_vector(6 downto 0);
  axi4_bresp             : in    std_logic_vector(1 downto 0);
  axi4_rready            : out   std_logic;
  axi4_rvalid            : in    std_logic;
  axi4_rid               : in    std_logic_vector(6 downto 0);
  axi4_rdata             : in    std_logic_vector((DATA_WIDTH-1) downto 0);
  axi4_ruser             : in    std_logic_vector((USER_WIDTH-1) downto 0);
  axi4_rresp             : in    std_logic_vector(1 downto 0);
  axi4_rlast             : in    std_logic;
  -- Error Counters
  bresp_error_count      : out   std_logic_vector(31 downto 0);
  rresp_error_count      : out   std_logic_vector(31 downto 0);
  write_timeout          : out   std_logic;
  read_timeout           : out   std_logic;
  -- Bandwidth Measurement
  sample_pulse           : in    std_logic;
  write_bandwidth        : out   std_logic_vector(31 downto 0);
  read_bandwidth         : out   std_logic_vector(31 downto 0);
  -- Memory Test Interface  
  mem_clk                : in    std_logic;
  mem_reset              : in    std_logic;
  mem_waddr              : in    std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_wdata              : in    std_logic_vector(DATA_WIDTH-1 downto 0);
  mem_wbyte_en           : in    std_logic_vector(((DATA_WIDTH/8)-1) downto 0);
  mem_wvalid             : in    std_logic;
  mem_wready             : out   std_logic;
  mem_raddr              : in    std_logic_vector(ADDR_WIDTH-1 downto 0);
  mem_rvalid             : in    std_logic;
  mem_rready             : out   std_logic;
  mem_rdata              : out   std_logic_vector(DATA_WIDTH-1 downto 0);
  mem_rdatavalid         : out   std_logic
  );
end entity mem_test_axi4_shim_no_parity;

architecture rtl of mem_test_axi4_shim_no_parity is

component general_fifo
generic (
  DWIDTH                    : integer := 32;              -- FIFO data width (bits)
  AWIDTH                    : integer := 9;               -- FIFO address width (bits)
  ALMOST_FULL_THOLD         : integer := 500;             -- Almost Full Flag (<<2^AWIDTH)
  RAMTYPE                   : string  := "block";         -- RAM type (block or distributed)
  FIRST_WORD_FALL_THRU      : boolean := FALSE            -- FIFO behaviour
  );
port (
  write_clock               : in  std_logic;
  read_clock                : in  std_logic;
  fifo_flush                : in  std_logic;
  write_enable              : in  std_logic;
  write_data                : in  std_logic_vector(DWIDTH-1 downto 0);
  read_enable               : in  std_logic;
  read_data                 : out std_logic_vector(DWIDTH-1 downto 0);
  almost_full               : out std_logic;
  depth                     : out std_logic_vector(AWIDTH-1 downto 0);
  empty                     : out std_logic
  );
end component;

constant BYTE_WIDTH            : integer range 1 to 128       := DATA_WIDTH/8;
constant TOTAL_BYTE_WIDTH      : integer range 1 to 256       := BYTE_WIDTH;
constant MEM_DBYTE_WIDTH       : integer range 1 to 128       := MEM_DATA_WIDTH/8;
constant FIFO_DATA_READY       : std_logic_vector(9 downto 0) := conv_std_logic_vector(BURST_LENGTH, 10);
constant BURST_LENGTH_VECTOR   : std_logic_vector(7 downto 0) := conv_std_logic_vector((BURST_LENGTH-1), 8);
constant BURST_COUNT_INIT      : integer range 0 to 255      := BURST_LENGTH-1;

constant WDATA_FIFO_WIDTH      : integer                      := (DATA_WIDTH+(DATA_WIDTH/8));
constant RDATA_FIFO_WIDTH      : integer                      := DATA_WIDTH;

type WRITE_STATES is (IDLE, START_TRANSFER, TRANSFER_BURST);
type WRITE_RESPONSE_STATES is (IDLE, BURST_RESPONSE);
type READ_STATES is (IDLE, START_TRANSFER, TRANSFER_BURST);

signal axi4_write_fsm          : WRITE_STATES;
signal axi4_write_resp_fsm     : WRITE_RESPONSE_STATES;
signal axi4_read_fsm           : READ_STATES;

signal aw_accept               : std_logic;
signal ar_accept               : std_logic;
signal w_accept                : std_logic;
signal w_accept_last           : std_logic;
signal r_accept                : std_logic;
signal r_accept_last           : std_logic;
signal b_accept                : std_logic;

signal awsize                  : std_logic_vector(2 downto 0);
signal awburst                 : std_logic_vector(1 downto 0);
signal awvalid                 : std_logic;
signal awid                    : std_logic_vector(6 downto 0);
signal arsize                  : std_logic_vector(2 downto 0);
signal arburst                 : std_logic_vector(1 downto 0);
signal arvalid                 : std_logic;
signal wvalid                  : std_logic;
signal wlast                   : std_logic;
signal bready                  : std_logic;
signal rready                  : std_logic;

signal write_addr_countdown    : integer range 0 to 255;
signal read_addr_countdown     : integer range 0 to 255;

signal write_data_to_fifo      : std_logic_vector(DATA_WIDTH-1 downto 0);
signal write_byteen_to_fifo    : std_logic_vector(BYTE_WIDTH-1 downto 0);

signal read_data_from_fifo     : std_logic_vector(DATA_WIDTH-1 downto 0);

signal waddr_fifo_wr           : std_logic;
signal waddr_fifo_wdata        : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal waddr_fifo_rd           : std_logic;
signal waddr_fifo_rdata        : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal waddr_fifo_empty        : std_logic;
signal waddr_fifo_afull        : std_logic;
signal waddr_fifo_wordcount    : std_logic_vector(9 downto 0);

signal wdata_fifo_wr           : std_logic;
signal wdata_fifo_wdata        : std_logic_vector((WDATA_FIFO_WIDTH-1) downto 0);
signal wdata_fifo_rd           : std_logic;
signal wdata_fifo_rdata        : std_logic_vector((WDATA_FIFO_WIDTH-1) downto 0);
signal wdata_fifo_empty        : std_logic;
signal wdata_fifo_afull        : std_logic;
signal wdata_fifo_wordcount    : std_logic_vector(9 downto 0);

signal raddr_fifo_wr           : std_logic;
signal raddr_fifo_wdata        : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal raddr_fifo_rd           : std_logic;
signal raddr_fifo_rdata        : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal raddr_fifo_empty        : std_logic;
signal raddr_fifo_afull        : std_logic;
signal raddr_fifo_wordcount    : std_logic_vector(9 downto 0);

signal rdata_fifo_wr           : std_logic;
signal rdata_fifo_wdata        : std_logic_vector((RDATA_FIFO_WIDTH-1) downto 0);
signal rdata_fifo_rd           : std_logic;
signal rdata_fifo_rdata        : std_logic_vector((RDATA_FIFO_WIDTH-1) downto 0);
signal rdata_fifo_empty        : std_logic;
signal rdata_fifo_afull        : std_logic;
signal rdata_fifo_wordcount    : std_logic_vector(9 downto 0);

signal mem_wready_i            : std_logic;
signal mem_rready_i            : std_logic;

signal wburstcount             : integer;
signal reset_wburstcount       : std_logic;
signal dec_wburstcount         : std_logic;

signal bresp_error             : std_logic;
signal bresp_error_count_i     : std_logic_vector(31 downto 0);
signal rresp_error             : std_logic;
signal rresp_error_count_i     : std_logic_vector(31 downto 0);

signal write_bw_count          : std_logic_vector(47 downto 0);
signal new_write_bw            : std_logic_vector(30 downto 0);
signal av_write_bw             : std_logic_vector(30 downto 0);
signal combo_write_bw          : std_logic_vector(31 downto 0);
signal first_wr_bw             : std_logic;

signal read_bw_count           : std_logic_vector(47 downto 0);
signal new_read_bw             : std_logic_vector(30 downto 0);
signal av_read_bw              : std_logic_vector(30 downto 0);
signal combo_read_bw           : std_logic_vector(31 downto 0);
signal first_rd_bw             : std_logic;

signal sample_pulse_d1         : std_logic;
signal sample_pulse_d2         : std_logic;
signal sample_pulse_d3         : std_logic;

signal outstanding_bresp       : std_logic_vector(15 downto 0);

signal write_timeout_count     : std_logic_vector(23 downto 0);
signal read_timeout_count      : std_logic_vector(23 downto 0);

constant TIMEOUT_MAX           : std_logic_vector(23 downto 0) := x"FFFFFF";

begin

-- Memory Test Interface		    

-- Ready signal asserted when appropriate FIFOs are not full.
mem_wready_i           <= '1' when waddr_fifo_afull='0' and wdata_fifo_afull='0' else '0';
mem_rready_i           <= '1' when raddr_fifo_afull='0' else '0';
		    
mem_wready             <= mem_wready_i;
mem_rready             <= mem_rready_i; 

-- As AXI burst transfers only require one address per burst (at the start of the burst), we'll only
-- write one address into the FIFO (per burst) and throw away the rest.
process (mem_clk)
begin
  if rising_edge(mem_clk) then
    if mem_reset='1' then
      write_addr_countdown             <= 0;
    else
      if mem_wvalid='1' and mem_wready_i='1' then
        if write_addr_countdown=0 then
          write_addr_countdown         <= BURST_COUNT_INIT;
        else
          write_addr_countdown         <= write_addr_countdown-1;
        end if;
      end if;
    end if;
  end if;
end process;

-- Write single address to FIFO (per burst).  Always the first address in the burst.
waddr_fifo_wr          <= '1' when ((mem_wvalid='1' and mem_wready_i='1') and write_addr_countdown=0) else '0';
waddr_fifo_wdata       <= mem_waddr; 

write_data_to_fifo     <= mem_wdata;
write_byteen_to_fifo   <= mem_wbyte_en;

-- Unlike the address, every instance of write data is written into the FIFO.  
wdata_fifo_wr          <= '1' when mem_wvalid='1' and mem_wready_i='1' else '0';
-- Write FIFO data is (from LSB to MSB) Data/ByteEn.  
wdata_fifo_wdata       <= write_byteen_to_fifo & write_data_to_fifo;

-- Similar to the Write Address, only one Read Address is required for each read burst.
process (mem_clk)
begin
  if rising_edge(mem_clk) then
    if mem_reset='1' then
      read_addr_countdown              <= 0;
    else
      if mem_rvalid='1' and mem_rready_i='1' then
        if read_addr_countdown=0 then
          read_addr_countdown          <= BURST_COUNT_INIT;
        else
          read_addr_countdown          <= read_addr_countdown-1;
        end if;
      end if;
    end if;
  end if;
end process;

-- Again, only one address FIFO write per burst. 		    
raddr_fifo_wr          <= '1' when ((mem_rvalid='1' and mem_rready_i='1') and read_addr_countdown=0) else '0';
raddr_fifo_wdata       <= mem_raddr;
-- Always read the FIFO (when not empty).
rdata_fifo_rd          <= '1' when rdata_fifo_empty='0' else '0';

-- This has been simplified from parity version and could be simplified further to remove read_data_from_fifo stage.
read_data_from_fifo    <= rdata_fifo_rdata;
mem_rdata              <= read_data_from_fifo;

mem_rdatavalid         <= rdata_fifo_rd;

-- Intermediate FIFOs
awaddr_fifo : general_fifo
generic map (
  DWIDTH                    => ADDR_WIDTH,        
  AWIDTH                    => 10,        
  ALMOST_FULL_THOLD         => 1000,        
  RAMTYPE                   => "block",        
  FIRST_WORD_FALL_THRU      => true        
  )
port map (
  write_clock               => mem_clk,
  read_clock                => axi4_aclk,
  fifo_flush                => axi4_areset,
  write_enable              => waddr_fifo_wr,
  write_data                => waddr_fifo_wdata,
  read_enable               => waddr_fifo_rd,
  read_data                 => waddr_fifo_rdata,
  almost_full               => waddr_fifo_afull,
  depth                     => waddr_fifo_wordcount,
  empty                     => waddr_fifo_empty
  );
  
wdata_fifo : general_fifo
generic map (
  DWIDTH                    => WDATA_FIFO_WIDTH,        
  AWIDTH                    => 10,        
  ALMOST_FULL_THOLD         => 1000,        
  RAMTYPE                   => "block",        
  FIRST_WORD_FALL_THRU      => true        
  )
port map (
  write_clock               => mem_clk,
  read_clock                => axi4_aclk,
  fifo_flush                => axi4_areset,
  write_enable              => wdata_fifo_wr,
  write_data                => wdata_fifo_wdata,
  read_enable               => wdata_fifo_rd,
  read_data                 => wdata_fifo_rdata,
  almost_full               => wdata_fifo_afull,
  depth                     => wdata_fifo_wordcount,
  empty                     => wdata_fifo_empty
  );  

araddr_fifo : general_fifo
generic map (
  DWIDTH                    => ADDR_WIDTH,        
  AWIDTH                    => 10,        
  ALMOST_FULL_THOLD         => 1000,        
  RAMTYPE                   => "block",        
  FIRST_WORD_FALL_THRU      => true        
  )
port map (
  write_clock               => mem_clk,
  read_clock                => axi4_aclk,
  fifo_flush                => axi4_areset,
  write_enable              => raddr_fifo_wr,
  write_data                => raddr_fifo_wdata,
  read_enable               => raddr_fifo_rd,
  read_data                 => raddr_fifo_rdata,
  almost_full               => raddr_fifo_afull,
  depth                     => raddr_fifo_wordcount,
  empty                     => raddr_fifo_empty
  );
  
rdata_fifo : general_fifo
generic map (
  DWIDTH                    => RDATA_FIFO_WIDTH,        
  AWIDTH                    => 10,        
  ALMOST_FULL_THOLD         => 1000,        
  RAMTYPE                   => "block",        
  FIRST_WORD_FALL_THRU      => true        
  )
port map (
  write_clock               => axi4_aclk,
  read_clock                => mem_clk,
  fifo_flush                => mem_reset,
  write_enable              => rdata_fifo_wr,
  write_data                => rdata_fifo_wdata,
  read_enable               => rdata_fifo_rd,
  read_data                 => rdata_fifo_rdata,
  almost_full               => rdata_fifo_afull,
  depth                     => rdata_fifo_wordcount,
  empty                     => rdata_fifo_empty
  ); 
 
-- AXI4 Interface

-- Transfer size (per word in burst) is determined by BYTE_WIDTH (which is derived from DATA_WIDTH).
process (axi4_aclk)
begin
  if rising_edge(axi4_aclk) then
    if BYTE_WIDTH = 1 then
      awsize          <= "000";
      arsize          <= "000";
    elsif BYTE_WIDTH = 2 then
      awsize          <= "001";
      arsize          <= "001";
    elsif BYTE_WIDTH = 4 then
      awsize          <= "010";
      arsize          <= "010";
    elsif BYTE_WIDTH = 8 then
      awsize          <= "011";
      arsize          <= "011";
    elsif BYTE_WIDTH = 16 then
      awsize          <= "100";
      arsize          <= "100";
    elsif BYTE_WIDTH = 32 then
      awsize          <= "101";
      arsize          <= "101";
    elsif BYTE_WIDTH = 64 then
      awsize          <= "110";
      arsize          <= "110";
    else
      awsize          <= "111";
      arsize          <= "111";
    end if;
  end if;
end process;

-- Some of this encoding might not be required but creating 'accept' signals for all
-- the combinations.
aw_accept           <= '1' when awvalid='1' and axi4_awready='1' else '0';
ar_accept           <= '1' when arvalid='1' and axi4_arready='1' else '0';
w_accept            <= '1' when wvalid='1' and axi4_wready='1' else '0';
w_accept_last       <= '1' when wvalid='1' and axi4_wready='1' and wlast='1' else '0';
r_accept            <= '1' when axi4_rvalid='1' and rready='1' else '0';
r_accept_last       <= '1' when axi4_rvalid='1' and rready='1' and axi4_rlast='1' else '0';
b_accept            <= '1' when axi4_bvalid='1' and bready='1' else '0';
		    
-- Wiring out any internally used output.
axi4_awvalid        <= awvalid;
axi4_arvalid        <= arvalid;
axi4_wvalid         <= wvalid;
axi4_wlast          <= wlast;
axi4_bready         <= bready;
axi4_rready         <= rready;
 
-- AXI4 Write State Machine.
-- Only flaw at the moment is that a burst of 1 would be inefficient as there is a dead cycle each time.  Might need to look into that.
-- However for HBM2e in BL8 mode, the minumum burst length is 2 so should be fine.
-- We have three states:
-- IDLE 
-- All interfaces nulled.
-- Waits for a word to appear in WADDR FIFO + Burst Length worth of data to appear in WDATA FIFO - then goes to START_TRANSFER.
-- START_TRANSFER
-- Get Address and first set of Data.
-- Initiate Address Write + Data Write
-- Go to TRANSFER_BURST.
-- TRANSFER_BURST
-- Close out the Address Write when accepted.
-- Keep transferring data until the burst ends (then close it out).
-- Check FIFOs.  If enough data for the next round, go to START_TRANSFER; otherwise go to IDLE.
process (axi4_aclk)
begin
  if rising_edge(axi4_aclk) then
    if axi4_areset='1' then
      axi4_write_fsm           <= IDLE;
      awvalid                  <= '0';
      axi4_awid                <= (others => '0');
      awid                     <= (others => '0');
      axi4_awaddr              <= (others => '0');
      axi4_awlen               <= (others => '0');   
      axi4_awsize              <= (others => '0');  
      axi4_awburst             <= (others => '0'); 
      axi4_awlock              <= (others => '0');  
      axi4_awprot              <= (others => '0');  
      axi4_awqos               <= (others => '0');  
      axi4_awuser              <= (others => '0');  
      wvalid                   <= '0';
      axi4_wdata               <= (others => '0'); 
      axi4_wuser               <= (others => '0');
      axi4_wstrb               <= (others => '0'); 
      wlast                    <= '0';  
    else
      case axi4_write_fsm is
        when IDLE =>
          awvalid              <= '0';
          axi4_awaddr          <= (others => '0');
          axi4_awlen           <= (others => '0');   
          axi4_awsize          <= (others => '0');  
          axi4_awburst         <= (others => '0'); 
          axi4_awlock          <= (others => '0');  
          axi4_awprot          <= (others => '0');  
          axi4_awqos           <= (others => '0');  
          axi4_awuser          <= (others => '0');  
          wvalid               <= '0';
          axi4_wdata           <= (others => '0');
          axi4_wuser           <= (others => '0');
          axi4_wstrb           <= (others => '0');
          wlast                <= '0';  
          if waddr_fifo_empty = '0' and wdata_fifo_wordcount >= FIFO_DATA_READY then
            axi4_write_fsm     <= START_TRANSFER;
          end if;          
        when START_TRANSFER =>
          axi4_write_fsm       <= TRANSFER_BURST;
          axi4_awid            <= awid;
          awvalid              <= '1';
          axi4_awaddr          <= waddr_fifo_rdata;
          axi4_awlen           <= BURST_LENGTH_VECTOR;
          axi4_awsize          <= awsize;
          axi4_awburst         <= "01";
          axi4_awlock          <= (others => '0');
          axi4_awprot          <= "010";
          axi4_awqos           <= (others => '0');
          axi4_awuser          <= (others => '0');
          wvalid               <= '1';
          axi4_wdata           <= wdata_fifo_rdata((DATA_WIDTH-1) downto 0); 
          axi4_wuser           <= (others => '0');
          axi4_wstrb           <= wdata_fifo_rdata(((DATA_WIDTH+(DATA_WIDTH/8))-1) downto DATA_WIDTH);
          if BURST_LENGTH=1 then
            wlast              <= '1';
          else 
            wlast              <= '0';
          end if;
        when TRANSFER_BURST =>
          if aw_accept='1' then
            awvalid            <= '0';
          end if;
          if w_accept_last='1' then
            wvalid             <= '0';
            awid               <= awid+1;
            if waddr_fifo_empty='0' and wdata_fifo_wordcount >= FIFO_DATA_READY then
              axi4_write_fsm   <= START_TRANSFER;
            else
              axi4_write_fsm   <= IDLE;
            end if;            
          elsif w_accept='1' then
            wvalid             <= '1';
            axi4_wdata         <= wdata_fifo_rdata((DATA_WIDTH-1) downto 0); 
            axi4_wuser         <= (others => '0');
            axi4_wstrb         <= wdata_fifo_rdata(((DATA_WIDTH+(DATA_WIDTH/8))-1) downto DATA_WIDTH);
            if wburstcount=1 then
              wlast            <= '1';
            else
              wlast            <= '0';
            end if;
          end if;            
        when others =>
          awvalid              <= '0';
          awid                 <= (others => '0');
          axi4_awaddr          <= (others => '0');
          axi4_awlen           <= (others => '0');   
          axi4_awsize          <= (others => '0');  
          axi4_awburst         <= (others => '0'); 
          axi4_awlock          <= (others => '0');  
          axi4_awprot          <= (others => '0');  
          axi4_awqos           <= (others => '0');  
          axi4_awuser          <= (others => '0');  
          wvalid               <= '0';
          axi4_wdata           <= (others => '0'); 
          axi4_wstrb           <= (others => '0');
          axi4_wuser           <= (others => '0');
          wlast                <= '0';  
          axi4_write_fsm       <= IDLE;
      end case;    
    end if;
  end if;
end process;

-- Timeout count for writes
process (axi4_aclk)
begin
  if rising_edge(axi4_aclk) then
    if axi4_areset='1' then
      write_timeout            <= '0';
      write_timeout_count      <= (others => '0');
    else
      if w_accept='1' or axi4_write_fsm=IDLE then
        write_timeout_count    <= (others => '0');
      elsif axi4_write_fsm=START_TRANSFER or axi4_write_fsm=TRANSFER_BURST then
        if write_timeout_count < TIMEOUT_MAX then
          write_timeout_count  <= write_timeout_count+1;
        else
          write_timeout        <= '1';
        end if;
      end if;
    end if;
  end if;
end process;      

process (axi4_aclk)
begin
  if rising_edge(axi4_aclk) then
    if axi4_areset='1' then
      outstanding_bresp         <= (others => '0');
    else
      if w_accept_last='1' and b_accept='0' then
        outstanding_bresp       <= outstanding_bresp+1;
      elsif w_accept_last='0' and b_accept='1' then
        outstanding_bresp       <= outstanding_bresp-1;
      end if;
    end if;
  end if;
end process;

process (axi4_aclk) 
begin
  if rising_edge(axi4_aclk) then
    if axi4_areset='1' then
      bready                        <= '0';
      axi4_write_resp_fsm           <= IDLE;
    else
      case axi4_write_resp_fsm is
        when IDLE =>
          if outstanding_bresp > x"0000" then
            bready                  <= '1';
            axi4_write_resp_fsm     <= BURST_RESPONSE;
          end if;
        when BURST_RESPONSE =>
          if b_accept='1' then
            bready                  <= '0';
            axi4_write_resp_fsm     <= IDLE;
          end if;
        when others =>
          bready                    <= '0';
          axi4_write_resp_fsm       <= IDLE;
      end case;
    end if;
  end if;
end process;
            
-- Read the WADDR FIFO at the start of every transfer.
waddr_fifo_rd      <= '1' when axi4_write_fsm=START_TRANSFER else
                      '0';

-- Read the WDATA FIFO at the start of the transfer and at the start of every subsequent write (until burst completion).
wdata_fifo_rd      <= '1' when axi4_write_fsm=START_TRANSFER else
                      '1' when w_accept='1' and w_accept_last='0' else
                      '0';

-- These control the burst counter (which sits outside the state machine)
reset_wburstcount  <= '1' when axi4_write_fsm=START_TRANSFER else '0';
dec_wburstcount    <= '1' when w_accept='1' and w_accept_last='0' else '0';

-- Write Burst Counter
process (axi4_aclk)
begin
  if rising_edge(axi4_aclk) then
    if axi4_areset='1' then
      wburstcount           <= 0;
    else
      if reset_wburstcount='1' then
        wburstcount         <= BURST_COUNT_INIT;
      elsif dec_wburstcount='1' then
        wburstcount         <= wburstcount-1;
      end if;
    end if;
  end if;
end process;

-- Create delay/extra stages for sample pulse
process (axi4_aclk) 
begin
  if rising_edge(axi4_aclk) then
    if axi4_areset='1' then
      sample_pulse_d1     <= '0';
      sample_pulse_d2     <= '0';
      sample_pulse_d3     <= '0';
    else
      sample_pulse_d1     <= sample_pulse;
      sample_pulse_d2     <= sample_pulse_d1;
      sample_pulse_d3     <= sample_pulse_d2;
    end if;
  end if;
end process;

-- Write Bandwidth Counter
process (axi4_aclk)
begin
  if rising_edge(axi4_aclk) then
    if axi4_areset='1' then
      write_bw_count         <= (others => '0');
      new_write_bw           <= (others => '0');
      av_write_bw            <= (others => '0');
      combo_write_bw         <= (others => '0');
      write_bandwidth        <= (others => '0');
      first_wr_bw            <= '0';
    else
      if sample_pulse='1' then
        new_write_bw         <= "000" & write_bw_count(47 downto 20);
        write_bw_count       <= (others => '0');
      else
        if w_accept='1' then
          write_bw_count     <= write_bw_count+BYTE_WIDTH;
        end if;
      end if;
      if sample_pulse_d1='1' then
        if first_wr_bw='1' then
          combo_write_bw     <= ("0" & av_write_bw)+("0" & new_write_bw);
        else
          combo_write_bw     <= new_write_bw & "0";
          first_wr_bw        <= '1';
        end if;
      end if;
      if sample_pulse_d2='1' then
        av_write_bw          <= combo_write_bw(31 downto 1);
      end if;
      if sample_pulse_d3='1' then
        write_bandwidth      <= "0" & av_write_bw;
      end if;
    end if;
  end if;
end process;

bresp_error         <= '1' when b_accept='1' and axi4_bresp /= "00" else '0';

-- Burst Response Error Count
process (axi4_aclk) 
begin  
  if rising_edge(axi4_aclk) then
    if axi4_areset='1' then
      bresp_error_count_i     <= (others => '0');
    else
      if bresp_error='1' and bresp_error_count_i < x"FFFFFFFF" then
        bresp_error_count_i   <= bresp_error_count_i+1;
      end if;
    end if;
  end if;
end process;

bresp_error_count <= bresp_error_count_i;

-- Always accept read data is the RDATA FIFO isn't 'almost full'.
rready             <= '1' when rdata_fifo_afull='0' else '0';

-- The AXI4 Read State Machine has the same three states as the AXI4 Write State Machine (though I should rename BURST_TRANSFER in this one).
-- The state machine is largely similar except in BURST TRANSFER, the state machine goes straight to either IDLE or START_TRANSFER after 
-- the read address is accepted.  The return data is handled separately.
-- In theory, we can keep sending read requests before data has been sent back.
process (axi4_aclk)
begin
  if rising_edge(axi4_aclk) then
    if axi4_areset='1' then
      axi4_read_fsm              <= IDLE;
      arvalid                    <= '0';
      axi4_arid                  <= (others => '0');    
      axi4_araddr                <= (others => '0');  
      axi4_arlen                 <= (others => '0');   
      axi4_arsize                <= (others => '0');  
      axi4_arburst               <= (others => '0'); 
      axi4_arlock                <= (others => '0');  
      axi4_arprot                <= (others => '0');  
      axi4_arqos                 <= (others => '0');
      axi4_aruser                <= (others => '0');  
    else
      case axi4_read_fsm is
        when IDLE =>
          arvalid                <= '0';
          axi4_arid              <= (others => '0');    
          axi4_araddr            <= (others => '0');  
          axi4_arlen             <= (others => '0');   
          axi4_arsize            <= (others => '0');  
          axi4_arburst           <= (others => '0'); 
          axi4_arlock            <= (others => '0');  
          axi4_arprot            <= (others => '0');  
          axi4_arqos             <= (others => '0');
          axi4_aruser            <= (others => '0');          
          if raddr_fifo_empty = '0' then
            axi4_read_fsm        <= START_TRANSFER;
          end if;    
        when START_TRANSFER =>
          arvalid                <= '1';
          axi4_arid              <= (others => '0');
          axi4_araddr            <= raddr_fifo_rdata;
          axi4_arlen             <= BURST_LENGTH_VECTOR;
          axi4_arsize            <= arsize;
          axi4_arburst           <= "01";
          axi4_arlock            <= (others => '0');
          axi4_arprot            <= "010";
          axi4_arqos             <= (others => '0');
          axi4_aruser            <= (others => '0');
          axi4_read_fsm          <= TRANSFER_BURST;
        when TRANSFER_BURST =>
          if ar_accept='1' then
            arvalid              <= '0';
            if raddr_fifo_empty='0' then 
              axi4_read_fsm      <= START_TRANSFER;
            else
              axi4_read_fsm      <= IDLE;
            end if;
          end if;
        when others =>
          axi4_read_fsm          <= IDLE;
          arvalid                <= '0';
          axi4_arid              <= (others => '0');    
          axi4_araddr            <= (others => '0');  
          axi4_arlen             <= (others => '0');   
          axi4_arsize            <= (others => '0');  
          axi4_arburst           <= (others => '0'); 
          axi4_arlock            <= (others => '0');  
          axi4_arprot            <= (others => '0');  
          axi4_arqos             <= (others => '0');
          axi4_aruser            <= (others => '0');          
      end case;
    end if;
  end if;
end process;

-- Only read the RADDR FIFO at the start of each transfer.
raddr_fifo_rd       <= '1' when axi4_read_fsm=START_TRANSFER else
                       '0';

-- Write to the RDATA FIFO with each accepted read response.
rdata_fifo_wr       <= '1' when r_accept='1' else '0';
rdata_fifo_wdata    <= axi4_rdata;

rresp_error         <= '1' when r_accept='1' and axi4_rresp /= "00" else '0';

-- Read Response Error Count
process (axi4_aclk)
begin 
  if rising_edge(axi4_aclk) then
    if axi4_areset='1' then 
      rresp_error_count_i         <= (others => '0');
    else 
      if rresp_error='1' and rresp_error_count_i < x"FFFFFFFF" then
        rresp_error_count_i       <= rresp_error_count_i+1;
      end if;
    end if;
  end if;
end process;

rresp_error_count <= rresp_error_count_i;

-- Timeout count for reads
process (axi4_aclk)
begin
  if rising_edge(axi4_aclk) then
    if axi4_areset='1' then
      read_timeout             <= '0';
      read_timeout_count       <= (others => '0');
    else
      if ar_accept='1' or axi4_read_fsm=IDLE then
        read_timeout_count     <= (others => '0');
      elsif axi4_read_fsm=START_TRANSFER or axi4_read_fsm=TRANSFER_BURST then
        if read_timeout_count < TIMEOUT_MAX then
          read_timeout_count   <= read_timeout_count+1;
        else
          read_timeout         <= '1';
        end if;
      end if;
    end if;
  end if;
end process;    

-- Read Bandwidth Counter
process (axi4_aclk)
begin
  if rising_edge(axi4_aclk) then
    if axi4_areset='1' then
      read_bw_count         <= (others => '0');
      new_read_bw           <= (others => '0');
      av_read_bw            <= (others => '0');
      combo_read_bw         <= (others => '0'); 
      read_bandwidth        <= (others => '0');
      first_rd_bw           <= '0';
    else
      if sample_pulse='1' then
        new_read_bw         <= "000" & read_bw_count(47 downto 20);
        read_bw_count       <= (others => '0');
      else
        if r_accept='1' then
          read_bw_count     <= read_bw_count+BYTE_WIDTH;
        end if;
      end if;
      if sample_pulse_d1='1' then
        if first_rd_bw='1' then
          combo_read_bw      <= ("0" & av_read_bw)+("0" & new_read_bw);
        else
          combo_read_bw      <= new_read_bw & "0";
          first_rd_bw        <= '1';
        end if;
      end if;
      if sample_pulse_d2='1' then
        av_read_bw           <= combo_read_bw(31 downto 1);
      end if;
      if sample_pulse_d3='1' then
        read_bandwidth       <= "0" & av_read_bw;
      end if;      
    end if;
  end if;
end process;

end rtl;
  
  
  
 