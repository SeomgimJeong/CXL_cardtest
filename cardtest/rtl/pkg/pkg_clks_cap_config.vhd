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
-- Title       : Clocks Configuration for Clocks Test Capability ROM
-- Project     : Clocks Test Capability ROM
--------------------------------------------------------------------------------
-- Description : Constants used to define the clocks being tested in the 
--               clocks test (to be used to auto-generate the Clocks Test
--               Capability ROM).
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

package pkg_clks_cap_rom_config is

constant CLK_CAP_VERSION_MINOR             : integer          := 1;
constant CLK_CAP_VERSION_MAJOR             : integer          := 0;

constant CLK_TEST_CLOCK0_TYPE              : integer          := 1;
constant CLK_TEST_CLOCK0_EN                : boolean          := true;
constant CLK_TEST_CLOCK0_FREQ              : integer          := 50000000;
constant CLK_TEST_CLOCK0_NAME              : string           := "System Clock";

constant CLK_TEST_CLOCK1_TYPE              : integer          := 2;
constant CLK_TEST_CLOCK1_EN                : boolean          := true;
constant CLK_TEST_CLOCK1_FREQ              : integer          := 400000000;
constant CLK_TEST_CLOCK1_NAME              : string           := "PCIe User Clock";

constant CLK_TEST_CLOCK2_TYPE              : integer          := 3;
constant CLK_TEST_CLOCK2_EN                : boolean          := true;
constant CLK_TEST_CLOCK2_FREQ              : integer          := 156250000;
constant CLK_TEST_CLOCK2_NAME              : string           := "QSFPDD0 Reference Clock";

constant CLK_TEST_CLOCK3_TYPE              : integer          := 3;
constant CLK_TEST_CLOCK3_EN                : boolean          := true;
constant CLK_TEST_CLOCK3_FREQ              : integer          := 156250000;
constant CLK_TEST_CLOCK3_NAME              : string           := "QSFPDD1 Reference Clock";

constant CLK_TEST_CLOCK4_TYPE              : integer          := 3;
constant CLK_TEST_CLOCK4_EN                : boolean          := true;
constant CLK_TEST_CLOCK4_FREQ              : integer          := 156250000;
constant CLK_TEST_CLOCK4_NAME              : string           := "QSFPDD2 Reference Clock";

constant CLK_TEST_CLOCK5_TYPE              : integer          := 3;
constant CLK_TEST_CLOCK5_EN                : boolean          := true;
constant CLK_TEST_CLOCK5_FREQ              : integer          := 100000000;
constant CLK_TEST_CLOCK5_NAME              : string           := "MCIO Reference Clock";

constant CLK_TEST_CLOCK6_TYPE              : integer          := 3;
constant CLK_TEST_CLOCK6_EN                : boolean          := true;
constant CLK_TEST_CLOCK6_FREQ              : integer          := 100000000;
constant CLK_TEST_CLOCK6_NAME              : string           := "M.2 SSD Reference Clock";

constant CLK_TEST_CLOCK7_TYPE              : integer          := 2;
constant CLK_TEST_CLOCK7_EN                : boolean          := true;
constant CLK_TEST_CLOCK7_FREQ              : integer          := 315000000;
constant CLK_TEST_CLOCK7_NAME              : string           := "HBM2e Test Clock 0";

constant CLK_TEST_CLOCK8_TYPE              : integer          := 2;
constant CLK_TEST_CLOCK8_EN                : boolean          := true;
constant CLK_TEST_CLOCK8_FREQ              : integer          := 315000000;
constant CLK_TEST_CLOCK8_NAME              : string           := "HBM2e Test Clock 1";

constant CLK_TEST_CLOCK9_TYPE              : integer          := 3;
constant CLK_TEST_CLOCK9_EN                : boolean          := true;
constant CLK_TEST_CLOCK9_FREQ              : integer          := 10000000;
constant CLK_TEST_CLOCK9_NAME              : string           := "External Reference Clock";

constant CLK_TEST_CLOCK10_TYPE              : integer         := 3;
constant CLK_TEST_CLOCK10_EN               : boolean          := true;
constant CLK_TEST_CLOCK10_FREQ             : integer          := 10000000;
constant CLK_TEST_CLOCK10_NAME             : string           := "1PPS Clock";

constant CLK_TEST_CLOCK11_TYPE              : integer         := 3;
constant CLK_TEST_CLOCK11_EN               : boolean          := true;
constant CLK_TEST_CLOCK11_FREQ             : integer          := 100000000;
constant CLK_TEST_CLOCK11_NAME             : string           := "User Clock 1";

constant CLK_TEST_CLOCK12_TYPE              : integer         := 0;
constant CLK_TEST_CLOCK12_EN               : boolean          := false;
constant CLK_TEST_CLOCK12_FREQ             : integer          := 0;
constant CLK_TEST_CLOCK12_NAME             : string           := "";

constant CLK_TEST_CLOCK13_TYPE              : integer         := 0;
constant CLK_TEST_CLOCK13_EN               : boolean          := false;
constant CLK_TEST_CLOCK13_FREQ             : integer          := 0;
constant CLK_TEST_CLOCK13_NAME             : string           := "";

constant CLK_TEST_CLOCK14_TYPE              : integer         := 0;
constant CLK_TEST_CLOCK14_EN               : boolean          := false;
constant CLK_TEST_CLOCK14_FREQ             : integer          := 0;
constant CLK_TEST_CLOCK14_NAME             : string           := "";

constant CLK_TEST_CLOCK15_TYPE              : integer         := 0;
constant CLK_TEST_CLOCK15_EN               : boolean          := false;
constant CLK_TEST_CLOCK15_FREQ             : integer          := 0;
constant CLK_TEST_CLOCK15_NAME             : string           := "";

constant CLK_TEST_CLOCK16_TYPE              : integer         := 0;
constant CLK_TEST_CLOCK16_EN               : boolean          := false;
constant CLK_TEST_CLOCK16_FREQ             : integer          := 0;
constant CLK_TEST_CLOCK16_NAME             : string           := "";

constant CLK_TEST_CLOCK17_TYPE              : integer         := 0;
constant CLK_TEST_CLOCK17_EN               : boolean          := false;
constant CLK_TEST_CLOCK17_FREQ             : integer          := 0;
constant CLK_TEST_CLOCK17_NAME             : string           := "";

constant CLK_TEST_CLOCK18_TYPE              : integer         := 0;
constant CLK_TEST_CLOCK18_EN               : boolean          := false;
constant CLK_TEST_CLOCK18_FREQ             : integer          := 0;
constant CLK_TEST_CLOCK18_NAME             : string           := "";

constant CLK_TEST_CLOCK19_TYPE             : integer          := 0;
constant CLK_TEST_CLOCK19_EN               : boolean          := false;
constant CLK_TEST_CLOCK19_FREQ             : integer          := 0;
constant CLK_TEST_CLOCK19_NAME             : string           := "";
                          
end pkg_clks_cap_rom_config;

package body pkg_clks_cap_rom_config is
end pkg_clks_cap_rom_config;

