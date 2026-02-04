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
-- Title       : General FIFO
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : This is a general asynchronous FIFO. The 'depth' output and
--               the 'empty' flag are output synchronous to the 'read_clock',
--               while the 'almost_full' flag is output synchronous to the
--               'write_clock'. All outputs are registered.
--
--               FIFO Flush
--               ----------
--               This is an input in the 'read_clock' domain and causes
--               the FIFO to flush (synchronous reset). It does not stop
--               new 'write_data' being written into the FIFO.
--
--               Flow Control
--               ------------
--               The FIFO can be used for passing data between two
--               asynchronous clock domains. In this case 'read_data' can be
--               read out as soon as the FIFO is not empty ('empty' = '0') and
--               the 'almost_full' output can be used for holding off the
--               writing of 'write_data'.
--
--               Note: The 'almost_full' output is derived from the FIFO
--               'depth', so it has a long latency (8 clock cycles when
--               measured with 'write_clock' = 'read_clock'). To use the
--               'almost_full' output for flow control the 'ALMOST_FULL_THOLD'
--               should be set to around 3/4 of the maximum FIFO 'depth'.
--
--               Latency
--               -------
--               Test conditions:
--                 1/  Synchronous (i.e. 'write_clock' = 'read_clock').
--                 2/  Measured from 'write_enable' going high to 'empty'
--                     going low.
--
--                 Standard Mode =                5 clock cycles
--                 First Word Fall Thru Mode =    6 clock cycles
--            
--                 Note: In First Word Fall Thru Mode the first word of
--                 'read_data' is available immediately 'empty' goes low.
--
--               Synthesis
--               ---------
--               For Virtex-6 and Virtex-7 it is recommended that for FIFO
--               address widths of 6-bits or less distributed RAM (LUTs) should
--               be used, while for FIFO address widths of greater than 6-bits
--               block RAM should be used.
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


entity general_fifo is
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
end general_fifo;


architecture rtl of general_fifo is
  ---------
  -- Types
  ---------
  type T_ram is array (0 to (2**AWIDTH)-1) of std_logic_vector(DWIDTH-1 downto 0);

  -----------
  -- Signals
  -----------
  signal ram                  : T_ram                                 := (others => (others => '0'));
  signal write_addr           : std_logic_vector(AWIDTH-1 downto 0)   := (others => '0');
  signal read_addr            : std_logic_vector(AWIDTH-1 downto 0)   := (others => '0');
  signal read_addr_fwft       : std_logic_vector(AWIDTH-1 downto 0)   := (others => '0');
  signal write_addr_gray      : std_logic_vector(AWIDTH-1 downto 0)   := (others => '0');
  signal write_addr_gray_r1   : std_logic_vector(AWIDTH-1 downto 0)   := (others => '0');
  signal write_addr_gray_r2   : std_logic_vector(AWIDTH-1 downto 0)   := (others => '0');
  signal write_addr_dec       : std_logic_vector(AWIDTH-1 downto 0)   := (others => '0');
  signal depth_i              : std_logic_vector(AWIDTH-1 downto 0)   := (others => '0');
  signal almost_full_i        : std_logic                             := '0';
  signal almost_full_r1       : std_logic                             := '0';
  signal almost_full_r2       : std_logic                             := '0';
  signal empty_i              : std_logic                             := '1';
  signal empty_d1             : std_logic                             := '1';
  signal empty_fwft           : std_logic                             := '1';

  attribute ram_style: string;
  attribute ram_style of ram : signal is RAMTYPE;


begin
  ----------------------
  -- Write Clock Domain
  ----------------------
  process(write_clock)
  begin
    if rising_edge(write_clock) then
      -- Write data into RAM.
      if write_enable = '1' then
        ram(conv_integer(write_addr)) <= write_data;
      end if;

      -- Write Pointer Control.
      if write_enable = '1' then
        write_addr <= write_addr + 1;
      end if;

      -- Convert the Write Pointer to gray code.
      write_addr_gray(AWIDTH-1) <= write_addr(AWIDTH-1);
      for i in 0 to (AWIDTH-2) loop
        write_addr_gray(i) <= write_addr(i) xor write_addr(i+1);
      end loop;

      -- Double register almost_full_i as it enters the write_clock domain.
      almost_full_r1 <= almost_full_i;
      almost_full_r2 <= almost_full_r1;

    end if;
  end process;

  ---------------------
  -- Read Clock Domain
  ---------------------
  process(read_clock)

  variable xor_reduce_v  : std_logic;

  begin
    if rising_edge(read_clock) then
      -- Read data from RAM.
      if FIRST_WORD_FALL_THRU then
        if ((empty_i = '0') and (empty_d1 = '1')) or (read_enable = '1') then
          read_data <= ram(conv_integer(read_addr_fwft));
        end if;
      else
        if read_enable = '1' then
          read_data <= ram(conv_integer(read_addr));
        end if;
      end if;

      -- Read Pointer Control.
      if (empty_i = '0') and (empty_d1 = '1') then
        read_addr_fwft <= read_addr + 1;
      elsif empty_i = '1' then
        read_addr_fwft <= read_addr;
      elsif read_enable = '1' then
        read_addr_fwft <= read_addr_fwft + 1;
      end if;

      if fifo_flush = '1' then
        read_addr <= write_addr_dec;
      elsif read_enable = '1' then
        read_addr <= read_addr + 1;
      end if;

      -- Double register write_addr_gray as it enters the read_clock domain.
      write_addr_gray_r1 <= write_addr_gray;
      write_addr_gray_r2 <= write_addr_gray_r1;

      -- Convert gray coded write address back to decimal.
      for i in 0 to (AWIDTH-1) loop
        xor_reduce_v := '0';
        for j in i to (AWIDTH-1) loop
          xor_reduce_v := xor_reduce_v xor write_addr_gray_r2(j);
        end loop;
        write_addr_dec(i) <= xor_reduce_v;
      end loop;

      -- Create a registered FIFO Empty flag.
      if fifo_flush = '1' then
        empty_i <= '1';
      elsif (write_addr_dec = read_addr) or
            ((write_addr_dec = read_addr + 1) and (read_enable = '1')) then
        empty_i <= '1';
      else
        empty_i <= '0';
      end if;

      -- Delay FIFO Empty flag for first word fall thru.
      if fifo_flush = '1' then
        empty_d1 <= '1';
      else
        empty_d1 <= empty_i;
      end if;

      -- Create a registered FIFO Empty flag for first word fall thru.
      if fifo_flush = '1' then
        empty_fwft <= '1';
      elsif (write_addr_dec = read_addr) or (empty_i = '1') or
            ((write_addr_dec = read_addr + 1) and (read_enable = '1')) then
        empty_fwft <= '1';
      else
        empty_fwft <= '0';
      end if;

      -- Calculate FIFO Depth.
      if fifo_flush = '1' then
        depth_i <= (others => '0');
      else
        if read_enable = '1' then
          depth_i <= write_addr_dec - (read_addr + 1);
        else
          depth_i <= write_addr_dec - read_addr;
        end if;
      end if;

      -- Determine when FIFO Almost Full.
      if conv_integer(depth_i) >= ALMOST_FULL_THOLD then
        almost_full_i <= '1';
      else
        almost_full_i <= '0';
      end if;

    end if;
  end process;


  -- Connect up outputs.
  empty       <= empty_fwft when FIRST_WORD_FALL_THRU else empty_i;
  depth       <= depth_i;
  almost_full <= almost_full_r2;


end rtl;

