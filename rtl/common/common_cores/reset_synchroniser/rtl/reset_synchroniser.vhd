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
-- Title       : Reset Synchroniser
-- Project     : Common Gateware
---------------------------------------------------------------------------
-- Description :
--
--   Reset Synchroniser
--   ------------------
--
-- In cases where a design requires a reset (a lot of designs don't) to be present
-- after configuration synchronous resets are recommended by Xilinx (WP248 and WP231)
-- principally because they can be collapsed in with control terms thereby in certain
-- cases saving a level of logic.
--
-- One of the potential issues with synchronous resets is that they require a
-- clock to be present in order to ensure the circuit they are resetting actually
-- sees the reset. The circuit below goes aynchronously into reset condition
-- and synchronously out. The clock needs to be present to clock the reset state
-- out so this will ensure that all downstream registers (on this clock) are covered.
--
-- Of course, this sync_reset register can become very high fanout and can place
-- a burden on the place and route tools in high frequesncy designs - for this reason
-- a max_fanout synthesis constraint is placed on it to ensure that is replicated
-- thereby aiding timing closure. Note buffer type is set to "none" to ensure
-- that this high fanout net is not routed on a clock buffer.
--
-- Note, ensure your synthesis settings are set to ensure that this register
-- replication is maintained.
--
--
--
---------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity reset_synchroniser is
  generic (
    depth       :     integer := 2);    -- depth of reset_synchroniser shift
                                        -- register (in clock
                                        -- cycles)
  port (
    clock       : in  std_logic;
    async_reset : in  std_logic;
    sync_reset  : out std_logic);

end reset_synchroniser;

architecture rtl of reset_synchroniser is

  signal sync_reset_r : std_logic_vector(depth-1 downto 0);

begin

  process (async_reset, clock) is

  begin
    if (async_reset = '1') then
      sync_reset_r <= (others => '1');
    elsif rising_edge(clock) then
      sync_reset_r <= sync_reset_r(depth-2 downto 0) & '0';
    end if;
  end process;

  sync_reset <= sync_reset_r(depth-1);

end rtl;




