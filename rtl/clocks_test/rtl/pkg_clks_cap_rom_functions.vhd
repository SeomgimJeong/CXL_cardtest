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
-- Title       : Clocks Test Capability ROM Functions
-- Project     : Clocks Test 
--------------------------------------------------------------------------------
-- Description : This package contains a number of functions required to 
--               create the contents of the Clocks Test Capability ROM
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

package pkg_clks_cap_rom_functions is

type CLKS_CAP_ROM_TYPE is array(0 to 2047) of std_logic_vector(31 downto 0); 

function clk_name_word_length_gen (clock_name              : string) return integer;

function cap_rom_clks_vector_gen (
                                  clock_type                 : integer;
                                  clock_index                : integer;
                                  clock_name                 : string;
                                  clock_name_length          : integer;
                                  clock_name_word_length     : integer;
                                  clock_frequency            : integer
                                  )
                                  return std_logic_vector;

function clks_cap_rom_contents (
                                version_minor              : integer;
                                version_major              : integer;
                                clock0_en                  : boolean;
                                clock0_vector              : std_logic_vector;
                                clock1_en                  : boolean;
                                clock1_vector              : std_logic_vector;
                                clock2_en                  : boolean;
                                clock2_vector              : std_logic_vector;
                                clock3_en                  : boolean;
                                clock3_vector              : std_logic_vector;								
                                clock4_en                  : boolean;
                                clock4_vector              : std_logic_vector;
                                clock5_en                  : boolean;
                                clock5_vector              : std_logic_vector;								
                                clock6_en                  : boolean;
                                clock6_vector              : std_logic_vector;
                                clock7_en                  : boolean;
                                clock7_vector              : std_logic_vector;								
                                clock8_en                  : boolean;
                                clock8_vector              : std_logic_vector;
                                clock9_en                  : boolean;
                                clock9_vector              : std_logic_vector;
                                clock10_en                 : boolean;
                                clock10_vector             : std_logic_vector;
                                clock11_en                 : boolean;
                                clock11_vector             : std_logic_vector;								
                                clock12_en                 : boolean;
                                clock12_vector             : std_logic_vector;
                                clock13_en                 : boolean;
                                clock13_vector             : std_logic_vector;								
                                clock14_en                 : boolean;
                                clock14_vector             : std_logic_vector;
                                clock15_en                 : boolean;
                                clock15_vector             : std_logic_vector;								
                                clock16_en                 : boolean;
                                clock16_vector             : std_logic_vector;
                                clock17_en                 : boolean;
                                clock17_vector             : std_logic_vector;
                                clock18_en                 : boolean;
                                clock18_vector             : std_logic_vector;
                                clock19_en                 : boolean;
                                clock19_vector             : std_logic_vector								
			                    )
                                return CLKS_CAP_ROM_TYPE;

end pkg_clks_cap_rom_functions;

package body pkg_clks_cap_rom_functions is

function clk_name_word_length_gen (clock_name              : string) return integer is

  variable clock_name_length      : integer;
  variable clock_name_word_length : integer;

begin

  clock_name_word_length  := 0;
  clock_name_length       := clock_name'length;
  
  while clock_name_length /= 0 loop
    if clock_name_length < 4 then
      clock_name_word_length   := clock_name_word_length+1;
      clock_name_length        := 0;
    else
      clock_name_word_length   := clock_name_word_length+1;
      clock_name_length        := clock_name_length-4;
    end if;
  end loop;
  
  return clock_name_word_length;  

end clk_name_word_length_gen;

function cap_rom_clks_vector_gen (
                                  clock_type                 : integer;
                                  clock_index                : integer;
                                  clock_name                 : string;
                                  clock_name_length          : integer;
                                  clock_name_word_length     : integer;
                                  clock_frequency            : integer
                                  )
                                  return std_logic_vector is
  

  variable clock_type_slv           : std_logic_vector(31 downto 0);
  variable clock_cap_length_int     : integer;
  variable clock_cap_length_slv     : std_logic_vector(31 downto 0);
  variable clock_index_slv          : std_logic_vector(31 downto 0);
  variable clock_frequency_slv      : std_logic_vector(31 downto 0);
  variable clock_description_tmp    : std_logic_vector((clock_name_word_length*32)-1 downto 0);
  variable clock_description_slv    : std_logic_vector((clock_name_word_length*32)-1 downto 0);
  
  variable cap_rom_clks_vector      : std_logic_vector((((4+clock_name_word_length)*32)-1) downto 0);
								
begin
   
  if clock_type=0 then
    clock_type_slv                  := (others => '0');
  elsif clock_type > 3 then
    clock_type_slv                  := (others => '0');
  else
    clock_type_slv                  := conv_std_logic_vector(clock_type, 32);
  end if;
  
  clock_cap_length_int              := 2 + clock_name_word_length;
  clock_cap_length_slv              := conv_std_logic_vector(clock_cap_length_int, 32);
  clock_index_slv                   := conv_std_logic_vector(clock_index, 32);
  clock_frequency_slv               := conv_std_logic_vector(clock_frequency, 32);
 
  clock_description_tmp             := (others => '0');
  clock_description_slv             := (others => '0');
 
  for i in 1 to clock_name_length loop
    clock_description_tmp((((i-1)*8)+7) downto ((i-1)*8))             := conv_std_logic_vector(character'pos(clock_name(i)), 8);
  end loop;  

  for j in 0 to clock_name_word_length-1 loop
    for k in 0 to 3 loop
      clock_description_slv((((j*32)+(k*8))+7) downto ((j*32)+(k*8))) := clock_description_tmp((((j*32)+((3-k)*8))+7) downto ((j*32)+((3-k)*8)));
    end loop;
  end loop;

  cap_rom_clks_vector               := clock_description_slv & clock_frequency_slv & clock_index_slv & clock_cap_length_slv & clock_type_slv;
  
  return cap_rom_clks_vector;

end cap_rom_clks_vector_gen;

function clks_cap_rom_contents (
                                version_minor              : integer;
                                version_major              : integer;
                                clock0_en                  : boolean;
                                clock0_vector              : std_logic_vector;
                                clock1_en                  : boolean;
                                clock1_vector              : std_logic_vector;
                                clock2_en                  : boolean;
                                clock2_vector              : std_logic_vector;
                                clock3_en                  : boolean;
                                clock3_vector              : std_logic_vector;								
                                clock4_en                  : boolean;
                                clock4_vector              : std_logic_vector;
                                clock5_en                  : boolean;
                                clock5_vector              : std_logic_vector;								
                                clock6_en                  : boolean;
                                clock6_vector              : std_logic_vector;
                                clock7_en                  : boolean;
                                clock7_vector              : std_logic_vector;								
                                clock8_en                  : boolean;
                                clock8_vector              : std_logic_vector;
                                clock9_en                  : boolean;
                                clock9_vector              : std_logic_vector;
                                clock10_en                 : boolean;
                                clock10_vector             : std_logic_vector;
                                clock11_en                 : boolean;
                                clock11_vector             : std_logic_vector;								
                                clock12_en                 : boolean;
                                clock12_vector             : std_logic_vector;
                                clock13_en                 : boolean;
                                clock13_vector             : std_logic_vector;								
                                clock14_en                 : boolean;
                                clock14_vector             : std_logic_vector;
                                clock15_en                 : boolean;
                                clock15_vector             : std_logic_vector;								
                                clock16_en                 : boolean;
                                clock16_vector             : std_logic_vector;
                                clock17_en                 : boolean;
                                clock17_vector             : std_logic_vector;
                                clock18_en                 : boolean;
                                clock18_vector             : std_logic_vector;
                                clock19_en                 : boolean;
                                clock19_vector             : std_logic_vector
                                ) 
                                return CLKS_CAP_ROM_TYPE is

  variable clock0_vector_tmp              : std_logic_vector(clock0_vector'length-1 downto 0);
  variable clock1_vector_tmp              : std_logic_vector(clock1_vector'length-1 downto 0);
  variable clock2_vector_tmp              : std_logic_vector(clock2_vector'length-1 downto 0);
  variable clock3_vector_tmp              : std_logic_vector(clock3_vector'length-1 downto 0);
  variable clock4_vector_tmp              : std_logic_vector(clock4_vector'length-1 downto 0);
  variable clock5_vector_tmp              : std_logic_vector(clock5_vector'length-1 downto 0);
  variable clock6_vector_tmp              : std_logic_vector(clock6_vector'length-1 downto 0);
  variable clock7_vector_tmp              : std_logic_vector(clock7_vector'length-1 downto 0);
  variable clock8_vector_tmp              : std_logic_vector(clock8_vector'length-1 downto 0);
  variable clock9_vector_tmp              : std_logic_vector(clock9_vector'length-1 downto 0);
  variable clock10_vector_tmp             : std_logic_vector(clock10_vector'length-1 downto 0);
  variable clock11_vector_tmp             : std_logic_vector(clock11_vector'length-1 downto 0);
  variable clock12_vector_tmp             : std_logic_vector(clock12_vector'length-1 downto 0);
  variable clock13_vector_tmp             : std_logic_vector(clock13_vector'length-1 downto 0);
  variable clock14_vector_tmp             : std_logic_vector(clock14_vector'length-1 downto 0);
  variable clock15_vector_tmp             : std_logic_vector(clock15_vector'length-1 downto 0);
  variable clock16_vector_tmp             : std_logic_vector(clock16_vector'length-1 downto 0);
  variable clock17_vector_tmp             : std_logic_vector(clock17_vector'length-1 downto 0);
  variable clock18_vector_tmp             : std_logic_vector(clock18_vector'length-1 downto 0);
  variable clock19_vector_tmp             : std_logic_vector(clock19_vector'length-1 downto 0);

  variable cap_version_minor              : std_logic_vector(7 downto 0);
  variable cap_version_major              : std_logic_vector(7 downto 0);
  variable cap_version                    : std_logic_vector(31 downto 0);

  variable cap_mem_end_int                : integer;
  variable cap_mem_end_slv                : std_logic_vector(31 downto 0);  
  
  variable ram_contents                   : CLKS_CAP_ROM_TYPE := (others => (others => '0'));
  
  variable ram_addr                       : integer := 0;

	
begin

  clock0_vector_tmp               := clock0_vector;
  clock1_vector_tmp               := clock1_vector;
  clock2_vector_tmp               := clock2_vector;
  clock3_vector_tmp               := clock3_vector;
  clock4_vector_tmp               := clock4_vector;
  clock5_vector_tmp               := clock5_vector;
  clock6_vector_tmp               := clock6_vector;
  clock7_vector_tmp               := clock7_vector;
  clock8_vector_tmp               := clock8_vector;
  clock9_vector_tmp               := clock9_vector;
  clock10_vector_tmp              := clock10_vector;
  clock11_vector_tmp              := clock11_vector;
  clock12_vector_tmp              := clock12_vector;
  clock13_vector_tmp              := clock13_vector;
  clock14_vector_tmp              := clock14_vector;
  clock15_vector_tmp              := clock15_vector;
  clock16_vector_tmp              := clock16_vector;
  clock17_vector_tmp              := clock17_vector;
  clock18_vector_tmp              := clock18_vector;
  clock19_vector_tmp              := clock19_vector;
  
  cap_version_minor               := conv_std_logic_vector(version_minor, 8);
  cap_version_major               := conv_std_logic_vector(version_major, 8);
  cap_version                     := x"0000" & cap_version_major & cap_version_minor;
  
  ram_addr                        := 2;
  
  -- Load each active clock's details into ROM
  if clock0_en then
    for i in 0 to ((clock0_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock0_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;
  if clock1_en then
    for i in 0 to ((clock1_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock1_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;  
  if clock2_en then
    for i in 0 to ((clock2_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock2_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;
  if clock3_en then
    for i in 0 to ((clock3_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock3_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;  
  if clock4_en then
    for i in 0 to ((clock4_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock4_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;
  if clock5_en then
    for i in 0 to ((clock5_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock5_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;  
  if clock6_en then
    for i in 0 to ((clock6_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock6_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;
  if clock7_en then
    for i in 0 to ((clock7_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock7_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;  
  if clock8_en then
    for i in 0 to ((clock8_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock8_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;
  if clock9_en then
    for i in 0 to ((clock9_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock9_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;  
  if clock10_en then
    for i in 0 to ((clock10_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock10_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;
  if clock11_en then
    for i in 0 to ((clock11_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock11_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;  
  if clock12_en then
    for i in 0 to ((clock12_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock12_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;
  if clock13_en then
    for i in 0 to ((clock13_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock13_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;  
  if clock14_en then
    for i in 0 to ((clock14_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock14_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;
  if clock15_en then
    for i in 0 to ((clock15_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock15_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if; 
  if clock16_en then
    for i in 0 to ((clock16_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock16_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;
  if clock17_en then
    for i in 0 to ((clock17_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock17_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;  
  if clock18_en then
    for i in 0 to ((clock18_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock18_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;
  if clock19_en then
    for i in 0 to ((clock19_vector'length)/32)-1 loop
      ram_contents(ram_addr)      := clock19_vector(((i*32)+31) downto (i*32));
      ram_addr                    := ram_addr+1;
    end loop;
  end if;  

  cap_mem_end_int                 := ram_addr-1;
  cap_mem_end_int                 := cap_mem_end_int*4;
  cap_mem_end_slv                 := conv_std_logic_vector(cap_mem_end_int, 32);

  ram_contents(0)                 := cap_version;
  ram_contents(1)                 := cap_mem_end_slv;

  return ram_contents;  

end clks_cap_rom_contents;

end pkg_clks_cap_rom_functions;

