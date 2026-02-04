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
-- Title        : Package for the QSFPDD data rates
-- Project      : IA-860m
--------------------------------------------------------------------------------
-- Description  : This package controls the line rates that the QSFPDD tests 
--                will run.
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package pkg_xcvr_rate is

  -- Constants
  constant QSFPDD0_RATE    : integer := 1;
  constant QSFPDD1_RATE    : integer := 1;
  constant QSFPDD2_RATE    : integer := 1;

  constant XCVR_MODE       : string  := "NRZ";

end pkg_xcvr_rate;


package body pkg_xcvr_rate is
end pkg_xcvr_rate;

