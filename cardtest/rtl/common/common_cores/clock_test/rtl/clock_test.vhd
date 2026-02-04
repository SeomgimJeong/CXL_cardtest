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
-- Title       : Clock Test
-- Project     : 520R-MX
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

use work.pkg_user_registers.all;
use work.clocks_test.all;

entity clock_test is
  generic (
    NUM_CLKS        :     integer := 16
    );
  port (
    config_clk      : in  std_logic;
    config_rstn     : in  std_logic;
    -- Host Interface
    avmm_writedata  : in  std_logic_vector(31 downto 0);
    avmm_address    : in  std_logic_vector(11 downto 0);
    avmm_write      : in  std_logic;
    avmm_byteenable : in  std_logic_vector(3 downto 0);
    -- Test Clocks
    test_clock      : in  std_logic_vector(NUM_CLKS-1 downto 0);
    test_clock_stat : in  std_logic_vector(NUM_CLKS-1 downto 0);
    count_stcl      : out std_logic_vector(31 downto 0);
    count           : out T_count_out
    );
end clock_test;


architecture rtl of clock_test is

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
-- Types
---------


-----------
-- Signals
-----------
  signal count_ctrl   : std_logic_vector(1 downto 0) := (others => '0');
  signal count_reset  : std_logic_vector(NUM_CLKS-1 downto 0);
  signal count_enable : std_logic_vector(NUM_CLKS-1 downto 0);
  signal count_out    : T_count_out;
  signal count_abort  : std_logic_vector(NUM_CLKS-1 downto 0);
  signal reg_abort    : std_logic_vector(NUM_CLKS-1 downto 0);

  constant DONT_ABORT : std_logic_vector(NUM_CLKS-1 downto 0) := (others => '0');

begin
  --------------------
  -- Control Register
  --------------------
  process(config_clk)
  begin
    if rising_edge(config_clk) then
      if config_rstn = '0' then
        count_ctrl                      <= (others => '0');
      else
        if avmm_write = '1' then
          if (avmm_address = STCL_REG(11 downto 0)) then
            if avmm_byteenable(0) = '1' then
              count_ctrl                <= avmm_writedata(1 downto 0);          
            end if;
          end if;
        end if;
        if reg_abort /= DONT_ABORT then
          count_ctrl(1)                 <= '0';
        end if;
      end if;
    end if;
  end process;

  ---------------------
  -- Generate Counters
  ---------------------
  gen_counters : for i in 0 to NUM_CLKS-1 generate

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
        clock => config_clk,
        d     => count_abort(i),
        q     => reg_abort(i)
        );

  end generate;
  
  -------------------
  -- Connect outputs
  -------------------
  count_stcl <= ext( test_clock_stat & count_ctrl, count_stcl'length);
  count      <= count_out;

end rtl;
