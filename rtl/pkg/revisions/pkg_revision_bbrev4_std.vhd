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
-- Title        : Package for the design revision
-- Project      : IA-860m
--------------------------------------------------------------------------------
-- Description  : This package controls all the fields of the Firmware Version
--                Register.
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package pkg_revision is

  -- Constants
  constant DESIGN_ID_MAJOR  : std_logic_vector(7 downto 0)     := x"09";
  constant DESIGN_ID_MINOR  : std_logic_vector(7 downto 0)     := x"00";
  constant VERSION_MAJOR    : std_logic_vector(7 downto 0)     := x"01";
  constant VERSION_MINOR    : std_logic_vector(7 downto 0)     := x"02";
  
  constant PB_INSTANCES     : natural                          := 1;
  constant PB_BRAM_NUM      : natural                          := 300;        -- Number of BRAM (Powerburner)         - Minimum value of 16*PB_INSTANCES
  constant PB_REG_NUM       : natural                          := 22272;      -- Number of x8 Registers (Powerburner) - Minimum value of 64*PB_INSTANCES
  constant PB_DSP_NUM       : natural                          := 320;        -- Number of DSPs (Powerburner)         - Minimum value of 8*PB_INSTANCES

end pkg_revision;


package body pkg_revision is
end pkg_revision;

