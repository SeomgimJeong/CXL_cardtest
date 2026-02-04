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
-- Project     : Multi
--------------------------------------------------------------------------------
-- Description : A clocks test wrapper which includes the following sub-components
--               - axi_clocks_test (main clocks test)
--               - clocks_test_cap_rom (clocks test capability rom)
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

entity clock_test is
generic (
  VERSION_MINOR                               : integer          := 1;
  VERSION_MAJOR                               : integer          := 0;
  CLOCK0_TYPE                                 : integer          := 1;
  CLOCK0_EN                                   : boolean          := false;
  CLOCK0_FREQ                                 : integer          := 0;
  CLOCK0_NAME                                 : string           := "";
  CLOCK1_TYPE                                 : integer          := 1;
  CLOCK1_EN                                   : boolean          := false;
  CLOCK1_FREQ                                 : integer          := 0;
  CLOCK1_NAME                                 : string           := "";
  CLOCK2_TYPE                                 : integer          := 1;
  CLOCK2_EN                                   : boolean          := false;
  CLOCK2_FREQ                                 : integer          := 0;
  CLOCK2_NAME                                 : string           := "";
  CLOCK3_TYPE                                 : integer          := 1;
  CLOCK3_EN                                   : boolean          := false;
  CLOCK3_FREQ                                 : integer          := 0;
  CLOCK3_NAME                                 : string           := "";
  CLOCK4_TYPE                                 : integer          := 1;
  CLOCK4_EN                                   : boolean          := false;
  CLOCK4_FREQ                                 : integer          := 0;
  CLOCK4_NAME                                 : string           := "";
  CLOCK5_TYPE                                 : integer          := 1;
  CLOCK5_EN                                   : boolean          := false;
  CLOCK5_FREQ                                 : integer          := 0;
  CLOCK5_NAME                                 : string           := "";
  CLOCK6_TYPE                                 : integer          := 1;
  CLOCK6_EN                                   : boolean          := false;
  CLOCK6_FREQ                                 : integer          := 0;
  CLOCK6_NAME                                 : string           := "";
  CLOCK7_TYPE                                 : integer          := 1;
  CLOCK7_EN                                   : boolean          := false;
  CLOCK7_FREQ                                 : integer          := 0;
  CLOCK7_NAME                                 : string           := "";
  CLOCK8_TYPE                                 : integer          := 1;
  CLOCK8_EN                                   : boolean          := false;
  CLOCK8_FREQ                                 : integer          := 0;
  CLOCK8_NAME                                 : string           := "";
  CLOCK9_TYPE                                 : integer          := 1;
  CLOCK9_EN                                   : boolean          := false;
  CLOCK9_FREQ                                 : integer          := 0;
  CLOCK9_NAME                                 : string           := "";
  CLOCK10_TYPE                                : integer          := 1;
  CLOCK10_EN                                  : boolean          := false;
  CLOCK10_FREQ                                : integer          := 0;
  CLOCK10_NAME                                : string           := "";
  CLOCK11_TYPE                                : integer          := 1;
  CLOCK11_EN                                  : boolean          := false;
  CLOCK11_FREQ                                : integer          := 0;
  CLOCK11_NAME                                : string           := "";
  CLOCK12_TYPE                                : integer          := 1;
  CLOCK12_EN                                  : boolean          := false;
  CLOCK12_FREQ                                : integer          := 0;
  CLOCK12_NAME                                : string           := "";
  CLOCK13_TYPE                                : integer          := 1;
  CLOCK13_EN                                  : boolean          := false;
  CLOCK13_FREQ                                : integer          := 0;
  CLOCK13_NAME                                : string           := "";
  CLOCK14_TYPE                                : integer          := 1;
  CLOCK14_EN                                  : boolean          := false;
  CLOCK14_FREQ                                : integer          := 0;
  CLOCK14_NAME                                : string           := "";
  CLOCK15_TYPE                                : integer          := 1;
  CLOCK15_EN                                  : boolean          := false;
  CLOCK15_FREQ                                : integer          := 0;
  CLOCK15_NAME                                : string           := "";
  CLOCK16_TYPE                                : integer          := 1;
  CLOCK16_EN                                  : boolean          := false;
  CLOCK16_FREQ                                : integer          := 0;
  CLOCK16_NAME                                : string           := "";
  CLOCK17_TYPE                                : integer          := 1;
  CLOCK17_EN                                  : boolean          := false;
  CLOCK17_FREQ                                : integer          := 0;
  CLOCK17_NAME                                : string           := "";
  CLOCK18_TYPE                                : integer          := 1;
  CLOCK18_EN                                  : boolean          := false;
  CLOCK18_FREQ                                : integer          := 0;
  CLOCK18_NAME                                : string           := "";
  CLOCK19_TYPE                                : integer          := 1;
  CLOCK19_EN                                  : boolean          := false;
  CLOCK19_FREQ                                : integer          := 0;
  CLOCK19_NAME                                : string           := ""
  );  
port (
  -- Clocks Test
  --AXI Clock and Reset
  clocks_test_aclk      					  : in  std_logic;
  clocks_test_areset    					  : in  std_logic;
  --Write Address Interface
  clocks_test_awaddr						  : in  std_logic_vector(7 downto 0); 
  clocks_test_awvalid 					  	  : in  std_logic;
  clocks_test_awready 					  	  : out std_logic; 					
  clocks_test_awprot						  : in  std_logic_vector(2 downto 0);
  --Write Data Interface
  clocks_test_wdata						  	  : in  std_logic_vector(31 downto 0); 
  clocks_test_wstrb							  : in  std_logic_vector(3 downto 0);  
  clocks_test_wvalid						  : in  std_logic;
  clocks_test_wready						  : out std_logic;
  --Write Response Interface     
  clocks_test_bresp                           : out  std_logic_vector(1 downto 0);						
  clocks_test_bvalid                          : out  std_logic;									
  clocks_test_bready                          : in   std_logic;									
  --Read Address Interface     											
  clocks_test_araddr                          : in   std_logic_vector(7 downto 0);						
  clocks_test_arvalid                         : in   std_logic;								
  clocks_test_arready                         : out  std_logic;								
  clocks_test_arprot                          : in   std_logic_vector(2 downto 0);
  --Read Response Interface     										
  clocks_test_rdata                           : out  std_logic_vector(31 downto 0);				
  clocks_test_rresp                           : out  std_logic_vector(1 downto 0);				
  clocks_test_rvalid                          : out  std_logic;							
  clocks_test_rready                          : in   std_logic;				
  --Test Clocks
  clocks_test_test_clock                      : in   std_logic_vector(19 downto 0);
  clocks_test_test_clock_stat                 : in   std_logic_vector(19 downto 0);
  -- Clocks Capability ROM
  -- Clock and Reset
  clocks_cap_aclk                             : in   std_logic;
  clocks_cap_areset                           : in   std_logic;
  -- Write Address Interface                
  clocks_cap_awaddr                           : in   std_logic_vector(12 downto 0);
  clocks_cap_awvalid                          : in   std_logic;
  clocks_cap_awready                          : out  std_logic;
  clocks_cap_awprot                           : in   std_logic_vector(2 downto 0);
  -- Write Data Interface                   
  clocks_cap_wdata                            : in   std_logic_vector(31 downto 0);
  clocks_cap_wstrb                            : in   std_logic_vector(3 downto 0);
  clocks_cap_wvalid                           : in   std_logic;
  clocks_cap_wready                           : out  std_logic;
  -- Write Response Interface               
  clocks_cap_bresp                            : out  std_logic_vector(1 downto 0);						
  clocks_cap_bvalid                           : out  std_logic;									
  clocks_cap_bready                           : in   std_logic;									
  -- Read Address Interface     			 								
  clocks_cap_araddr                           : in   std_logic_vector(12 downto 0);						
  clocks_cap_arvalid                          : in   std_logic;								
  clocks_cap_arready                          : out  std_logic;								
  clocks_cap_arprot                           : in   std_logic_vector(2 downto 0);
  -- Read Response Interface     			 							
  clocks_cap_rdata                            : out  std_logic_vector(31 downto 0);				
  clocks_cap_rresp                            : out  std_logic_vector(1 downto 0);				
  clocks_cap_rvalid                           : out  std_logic;							
  clocks_cap_rready                           : in   std_logic   
  );
end clock_test;

architecture rtl of clock_test is

component axi_clock_test
  port (
  aclk      					  : in  std_logic;
  areset    					  : in  std_logic;
  awaddr						  : in  std_logic_vector(7 downto 0); 
  awvalid 					  	  : in  std_logic;
  awready 					  	  : out std_logic; 					
  awprot						  : in  std_logic_vector(2 downto 0);
  wdata						  	  : in  std_logic_vector(31 downto 0); 
  wstrb							  : in  std_logic_vector(3 downto 0);  
  wvalid						  : in  std_logic;
  wready						  : out std_logic;
  bresp                           : out  std_logic_vector(1 downto 0);						
  bvalid                          : out  std_logic;									
  bready                          : in   std_logic;									
  araddr                          : in   std_logic_vector(7 downto 0);						
  arvalid                         : in   std_logic;								
  arready                         : out  std_logic;								
  arprot                          : in   std_logic_vector(2 downto 0);
  rdata                           : out  std_logic_vector(31 downto 0);				
  rresp                           : out  std_logic_vector(1 downto 0);				
  rvalid                          : out  std_logic;							
  rready                          : in   std_logic;				
  test_clock                      : in   std_logic_vector(19 downto 0);
  test_clock_stat                 : in   std_logic_vector(19 downto 0)
  );
end component;

component clocks_test_cap_rom
generic (
  VERSION_MINOR                   : integer          := 1;
  VERSION_MAJOR                   : integer          := 0;
  CLOCK0_TYPE                                 : integer          := 1;
  CLOCK0_EN                                   : boolean          := false;
  CLOCK0_FREQ                                 : integer          := 0;
  CLOCK0_NAME                                 : string           := "";
  CLOCK1_TYPE                                 : integer          := 1;
  CLOCK1_EN                                   : boolean          := false;
  CLOCK1_FREQ                                 : integer          := 0;
  CLOCK1_NAME                                 : string           := "";
  CLOCK2_TYPE                                 : integer          := 1;
  CLOCK2_EN                                   : boolean          := false;
  CLOCK2_FREQ                                 : integer          := 0;
  CLOCK2_NAME                                 : string           := "";
  CLOCK3_TYPE                                 : integer          := 1;
  CLOCK3_EN                                   : boolean          := false;
  CLOCK3_FREQ                                 : integer          := 0;
  CLOCK3_NAME                                 : string           := "";
  CLOCK4_TYPE                                 : integer          := 1;
  CLOCK4_EN                                   : boolean          := false;
  CLOCK4_FREQ                                 : integer          := 0;
  CLOCK4_NAME                                 : string           := "";
  CLOCK5_TYPE                                 : integer          := 1;
  CLOCK5_EN                                   : boolean          := false;
  CLOCK5_FREQ                                 : integer          := 0;
  CLOCK5_NAME                                 : string           := "";
  CLOCK6_TYPE                                 : integer          := 1;
  CLOCK6_EN                                   : boolean          := false;
  CLOCK6_FREQ                                 : integer          := 0;
  CLOCK6_NAME                                 : string           := "";
  CLOCK7_TYPE                                 : integer          := 1;
  CLOCK7_EN                                   : boolean          := false;
  CLOCK7_FREQ                                 : integer          := 0;
  CLOCK7_NAME                                 : string           := "";
  CLOCK8_TYPE                                 : integer          := 1;
  CLOCK8_EN                                   : boolean          := false;
  CLOCK8_FREQ                                 : integer          := 0;
  CLOCK8_NAME                                 : string           := "";
  CLOCK9_TYPE                                 : integer          := 1;
  CLOCK9_EN                                   : boolean          := false;
  CLOCK9_FREQ                                 : integer          := 0;
  CLOCK9_NAME                                 : string           := "";
  CLOCK10_TYPE                                : integer          := 1;
  CLOCK10_EN                                  : boolean          := false;
  CLOCK10_FREQ                                : integer          := 0;
  CLOCK10_NAME                                : string           := "";
  CLOCK11_TYPE                                : integer          := 1;
  CLOCK11_EN                                  : boolean          := false;
  CLOCK11_FREQ                                : integer          := 0;
  CLOCK11_NAME                                : string           := "";
  CLOCK12_TYPE                                : integer          := 1;
  CLOCK12_EN                                  : boolean          := false;
  CLOCK12_FREQ                                : integer          := 0;
  CLOCK12_NAME                                : string           := "";
  CLOCK13_TYPE                                : integer          := 1;
  CLOCK13_EN                                  : boolean          := false;
  CLOCK13_FREQ                                : integer          := 0;
  CLOCK13_NAME                                : string           := "";
  CLOCK14_TYPE                                : integer          := 1;
  CLOCK14_EN                                  : boolean          := false;
  CLOCK14_FREQ                                : integer          := 0;
  CLOCK14_NAME                                : string           := "";
  CLOCK15_TYPE                                : integer          := 1;
  CLOCK15_EN                                  : boolean          := false;
  CLOCK15_FREQ                                : integer          := 0;
  CLOCK15_NAME                                : string           := "";
  CLOCK16_TYPE                                : integer          := 1;
  CLOCK16_EN                                  : boolean          := false;
  CLOCK16_FREQ                                : integer          := 0;
  CLOCK16_NAME                                : string           := "";
  CLOCK17_TYPE                                : integer          := 1;
  CLOCK17_EN                                  : boolean          := false;
  CLOCK17_FREQ                                : integer          := 0;
  CLOCK17_NAME                                : string           := "";
  CLOCK18_TYPE                                : integer          := 1;
  CLOCK18_EN                                  : boolean          := false;
  CLOCK18_FREQ                                : integer          := 0;
  CLOCK18_NAME                                : string           := "";
  CLOCK19_TYPE                                : integer          := 1;
  CLOCK19_EN                                  : boolean          := false;
  CLOCK19_FREQ                                : integer          := 0;
  CLOCK19_NAME                                : string           := ""
  );
port (
  aclk                            : in   std_logic;
  areset                          : in   std_logic;
  awaddr                          : in   std_logic_vector(12 downto 0);
  awvalid                         : in   std_logic;
  awready                         : out  std_logic;
  awprot                          : in   std_logic_vector(2 downto 0);
  wdata                           : in   std_logic_vector(31 downto 0);
  wstrb                           : in   std_logic_vector(3 downto 0);
  wvalid                          : in   std_logic;
  wready                          : out  std_logic;
  bresp                           : out  std_logic_vector(1 downto 0);						
  bvalid                          : out  std_logic;									
  bready                          : in   std_logic;									
  araddr                          : in   std_logic_vector(12 downto 0);						
  arvalid                         : in   std_logic;								
  arready                         : out  std_logic;								
  arprot                          : in   std_logic_vector(2 downto 0);
  rdata                           : out  std_logic_vector(31 downto 0);				
  rresp                           : out  std_logic_vector(1 downto 0);				
  rvalid                          : out  std_logic;							
  rready                          : in   std_logic 
  );
end component;

begin

u0_clks_test : axi_clock_test
port map (
  aclk      					  => clocks_test_aclk,
  areset    					  => clocks_test_areset,
  awaddr						  => clocks_test_awaddr,
  awvalid 					  	  => clocks_test_awvalid,
  awready 					  	  => clocks_test_awready,
  awprot						  => clocks_test_awprot,
  wdata						  	  => clocks_test_wdata,
  wstrb							  => clocks_test_wstrb,
  wvalid						  => clocks_test_wvalid,
  wready						  => clocks_test_wready,
  bresp                           => clocks_test_bresp,					
  bvalid                          => clocks_test_bvalid,			
  bready                          => clocks_test_bready,			
  araddr                          => clocks_test_araddr,					
  arvalid                         => clocks_test_arvalid,	
  arready                         => clocks_test_arready,	
  arprot                          => clocks_test_arprot,
  rdata                           => clocks_test_rdata,			
  rresp                           => clocks_test_rresp,			
  rvalid                          => clocks_test_rvalid,
  rready                          => clocks_test_rready,
  test_clock                      => clocks_test_test_clock,
  test_clock_stat                 => clocks_test_test_clock_stat
  );

u1_clks_cap_rom : clocks_test_cap_rom
generic map (
  VERSION_MINOR                   => VERSION_MINOR,
  VERSION_MAJOR                   => VERSION_MAJOR,
  CLOCK0_TYPE                     => CLOCK0_TYPE,
  CLOCK0_EN                       => CLOCK0_EN,
  CLOCK0_FREQ                     => CLOCK0_FREQ,
  CLOCK0_NAME                     => CLOCK0_NAME,
  CLOCK1_TYPE                     => CLOCK1_TYPE,
  CLOCK1_EN                       => CLOCK1_EN,
  CLOCK1_FREQ                     => CLOCK1_FREQ,
  CLOCK1_NAME                     => CLOCK1_NAME,
  CLOCK2_TYPE                     => CLOCK2_TYPE,
  CLOCK2_EN                       => CLOCK2_EN,
  CLOCK2_FREQ                     => CLOCK2_FREQ,
  CLOCK2_NAME                     => CLOCK2_NAME,
  CLOCK3_TYPE                     => CLOCK3_TYPE,
  CLOCK3_EN                       => CLOCK3_EN,
  CLOCK3_FREQ                     => CLOCK3_FREQ,
  CLOCK3_NAME                     => CLOCK3_NAME,
  CLOCK4_TYPE                     => CLOCK4_TYPE,
  CLOCK4_EN                       => CLOCK4_EN,
  CLOCK4_FREQ                     => CLOCK4_FREQ,
  CLOCK4_NAME                     => CLOCK4_NAME,
  CLOCK5_TYPE                     => CLOCK5_TYPE,
  CLOCK5_EN                       => CLOCK5_EN,
  CLOCK5_FREQ                     => CLOCK5_FREQ,
  CLOCK5_NAME                     => CLOCK5_NAME,
  CLOCK6_TYPE                     => CLOCK6_TYPE,
  CLOCK6_EN                       => CLOCK6_EN,
  CLOCK6_FREQ                     => CLOCK6_FREQ,
  CLOCK6_NAME                     => CLOCK6_NAME,
  CLOCK7_TYPE                     => CLOCK7_TYPE,
  CLOCK7_EN                       => CLOCK7_EN,
  CLOCK7_FREQ                     => CLOCK7_FREQ,
  CLOCK7_NAME                     => CLOCK7_NAME,
  CLOCK8_TYPE                     => CLOCK8_TYPE,
  CLOCK8_EN                       => CLOCK8_EN,
  CLOCK8_FREQ                     => CLOCK8_FREQ,
  CLOCK8_NAME                     => CLOCK8_NAME,
  CLOCK9_TYPE                     => CLOCK9_TYPE,
  CLOCK9_EN                       => CLOCK9_EN,
  CLOCK9_FREQ                     => CLOCK9_FREQ,
  CLOCK9_NAME                     => CLOCK9_NAME,
  CLOCK10_TYPE                    => CLOCK10_TYPE,
  CLOCK10_EN                      => CLOCK10_EN,
  CLOCK10_FREQ                    => CLOCK10_FREQ,
  CLOCK10_NAME                    => CLOCK10_NAME,
  CLOCK11_TYPE                    => CLOCK11_TYPE,
  CLOCK11_EN                      => CLOCK11_EN,
  CLOCK11_FREQ                    => CLOCK11_FREQ,
  CLOCK11_NAME                    => CLOCK11_NAME,
  CLOCK12_TYPE                    => CLOCK12_TYPE,
  CLOCK12_EN                      => CLOCK12_EN,
  CLOCK12_FREQ                    => CLOCK12_FREQ,
  CLOCK12_NAME                    => CLOCK12_NAME,
  CLOCK13_TYPE                    => CLOCK13_TYPE,
  CLOCK13_EN                      => CLOCK13_EN,
  CLOCK13_FREQ                    => CLOCK13_FREQ,
  CLOCK13_NAME                    => CLOCK13_NAME,
  CLOCK14_TYPE                    => CLOCK14_TYPE,
  CLOCK14_EN                      => CLOCK14_EN,
  CLOCK14_FREQ                    => CLOCK14_FREQ,
  CLOCK14_NAME                    => CLOCK14_NAME,
  CLOCK15_TYPE                    => CLOCK15_TYPE,
  CLOCK15_EN                      => CLOCK15_EN,
  CLOCK15_FREQ                    => CLOCK15_FREQ,
  CLOCK15_NAME                    => CLOCK15_NAME,
  CLOCK16_TYPE                    => CLOCK16_TYPE,
  CLOCK16_EN                      => CLOCK16_EN,
  CLOCK16_FREQ                    => CLOCK16_FREQ,
  CLOCK16_NAME                    => CLOCK16_NAME,
  CLOCK17_TYPE                    => CLOCK17_TYPE,
  CLOCK17_EN                      => CLOCK17_EN,
  CLOCK17_FREQ                    => CLOCK17_FREQ,
  CLOCK17_NAME                    => CLOCK17_NAME,
  CLOCK18_TYPE                    => CLOCK18_TYPE,
  CLOCK18_EN                      => CLOCK18_EN,
  CLOCK18_FREQ                    => CLOCK18_FREQ,
  CLOCK18_NAME                    => CLOCK18_NAME,
  CLOCK19_TYPE                    => CLOCK19_TYPE,
  CLOCK19_EN                      => CLOCK19_EN,
  CLOCK19_FREQ                    => CLOCK19_FREQ,
  CLOCK19_NAME                    => CLOCK19_NAME
  )
port map (
  aclk                            => clocks_cap_aclk,
  areset                          => clocks_cap_areset,
  awaddr                          => clocks_cap_awaddr,
  awvalid                         => clocks_cap_awvalid,
  awready                         => clocks_cap_awready,
  awprot                          => clocks_cap_awprot,
  wdata                           => clocks_cap_wdata,
  wstrb                           => clocks_cap_wstrb,
  wvalid                          => clocks_cap_wvalid,
  wready                          => clocks_cap_wready,
  bresp                           => clocks_cap_bresp,				
  bvalid                          => clocks_cap_bvalid,		
  bready                          => clocks_cap_bready,		
  araddr                          => clocks_cap_araddr,				
  arvalid                         => clocks_cap_arvalid,	
  arready                         => clocks_cap_arready,	
  arprot                          => clocks_cap_arprot,
  rdata                           => clocks_cap_rdata,		
  rresp                           => clocks_cap_rresp,		
  rvalid                          => clocks_cap_rvalid,
  rready                          => clocks_cap_rready
  );

end rtl;

