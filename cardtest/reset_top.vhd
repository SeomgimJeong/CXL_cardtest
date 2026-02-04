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
-- Title       : IA Reset Logic
-- Project     : Intel Agilex
--------------------------------------------------------------------------------
-- Description : Top Level for system reset network
--               Generates a number of independent resets synchronous with the
--               system clock. Reset outputs are asserted until a period of time
--               (specified by NUM_SYS_CLK_CYCLES) after the FPGA fabric has
--               been configured and once all reset inputs are deasserted.
--
--               When an input reset is asserted then reset outputs are
--               de-asserted synchronously with sys_clk.
--
--               sys_clk:    System clock
--               pll_locked: Assert when the system clock is stable
--               ninit_done: Output from Intel reset release IP. Asserted until
--                           all the FPGA fabric has been configured.
--               bmc_reset:  Reset input, intended to be the inverted reset
--                           from the BMC
--               pcie_reset: Reset input, intended to be the inverted reset
--                           from the PCIe core. This reset is connected to
--                           a glitch filter within this module.
--
--               sys_reset:   System reset output(s) Active high
--               sys_reset_n: System reset output(s) Active low
--
--               SYS_CLK_RST_CYCLES
--                 The number of system clock cycles the reset it held once all
--                 reset inputs have been deasserted.
--                 The Power On Reset time is:
--                   Period of 'sys_clk' * NUM_SYS_CLK_CYCLES (32-bit)
--               RST_FAN_OUT
--                 The number of system resets generated
--
--               Includes:
--                 * reset_filter
--                 * glitch_filter
--                 * pwr_on_rst_init_dist
--                 * reset_synchroniser
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity reset_top is
  generic (
    NUM_SYS_CLK_CYCLES  : std_logic_vector(31 downto 0)         := x"00000100";
    RST_FAN_OUT         : integer := 16
    );
  port (
    sys_clk             : in  std_logic;
    pll_locked          : in  std_logic;
    ninit_done          : in  std_logic;
    bmc_reset           : in  std_logic;
    pcie_reset          : in  std_logic;
    sys_reset           : out std_logic_vector(RST_FAN_OUT-1 downto 0);
    sys_reset_n         : out std_logic_vector(RST_FAN_OUT-1 downto 0)
    );
end entity reset_top;


architecture rtl of reset_top is
  --------------
  -- Components
  --------------
  component reset_filter
  port (
    enable              : in  std_logic;
    rstn_raw            : in  std_logic;
    clk                 : in  std_logic;
    rstn_filtered       : out std_logic
    );
  end component;

  component pwr_on_rst_init_dist
  generic (
    NUMBER_OF_CYCLES    : std_logic_vector(31 downto 0)         := x"00000100";
    FAN_OUT             : integer := 16
    );
  port (
    clk                 : in  std_logic;
    init_done_n         : in  std_logic;
    por_n               : out std_logic_vector(FAN_OUT-1 downto 0)
    );
  end component;

  component reset_synchroniser
  generic (
    depth               : integer := 2
    );
  port (
    clock               : in  std_logic;
    async_reset         : in  std_logic;
    sync_reset          : out std_logic
    );
  end component;

  component glitch_filter
  generic (
    DEPTH :     integer := 2);
  port (
    reset : in  std_logic;
    clock : in  std_logic;
    d     : in  std_logic;
    q     : out std_logic);
  end component;

  -----------
  -- Signals
  -----------
  signal ninit_done_n               : std_logic;
  signal sys_init_done              : std_logic;
  signal sys_init_done_n            : std_logic;
  signal pcie_reset_sys             : std_logic;
  signal pcie_reset_sys_unfiltered  : std_logic;
  signal bmc_reset_sys              : std_logic;
  signal sys_reset_init             : std_logic_vector(RST_FAN_OUT-1 downto 0);
  signal sys_reset_init_n           : std_logic_vector(RST_FAN_OUT-1 downto 0);
  signal sys_reset_i                : std_logic_vector(RST_FAN_OUT-1 downto 0);


begin
  
  ninit_done_n <= not(ninit_done);
  
  u01 : reset_filter 
    port map (
      enable             => pll_locked,
      rstn_raw           => ninit_done_n,
      clk                => sys_clk,
      rstn_filtered      => sys_init_done
      );

  sys_init_done_n <= not(sys_init_done);

  u02 : pwr_on_rst_init_dist
    generic map  (
      NUMBER_OF_CYCLES    =>  NUM_SYS_CLK_CYCLES,
      FAN_OUT             =>  RST_FAN_OUT
      )
    port map (
      clk                 => sys_clk,
      init_done_n         => sys_init_done_n,
      por_n               => sys_reset_init_n
      );

  sys_reset_init <= not(sys_reset_init_n);

  -- Retime Reset from the BMC
  u03 : reset_synchroniser
    generic map (
      DEPTH               => 3
      )
    port map (
      clock               => sys_clk,
      async_reset         => bmc_reset,
      sync_reset          => bmc_reset_sys
      );

  -- Retime the reset from the PCIe core
  u04 : reset_synchroniser
    generic map (
      DEPTH               => 3
      )
    port map (
      clock               => sys_clk,
      async_reset         => pcie_reset,
      sync_reset          => pcie_reset_sys_unfiltered
      );

  -- Ensure any glitches are filtered out
  u05 : glitch_filter
    generic map (
      DEPTH               => 16
      )
    port map (
      reset               => sys_reset_init(0),
      clock               => sys_clk,
      d                   => pcie_reset_sys_unfiltered,
      q                   => pcie_reset_sys
      );

  -- Create the system resets from the POR and the input resets
  process (sys_clk)
  begin
    if rising_edge(sys_clk) then
      for i in 0 to RST_FAN_OUT-1 loop
        sys_reset_i(i) <= sys_reset_init(i) or (bmc_reset_sys or pcie_reset_sys);
      end loop;
    end if;
  end process;

  sys_reset   <= sys_reset_i;
  sys_reset_n <= not(sys_reset_i);

end rtl;

