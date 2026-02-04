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
-- Title       : Altera Dual-Port RAM
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : This component infers dual port RAM with asynchronous
--               write and read access through each port.
--
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity dprw_ram is
  generic
    (
    AWIDTH   : natural := 9;
    DWIDTH   : natural := 32
      );
  port(
    clka     : in  std_logic;
    clkb     : in  std_logic;
    wea      : in  std_logic;
    web      : in  std_logic;
    addra    : in  std_logic_vector(AWIDTH-1 downto 0);
    addrb    : in  std_logic_vector(AWIDTH-1 downto 0);
    dia      : in  std_logic_vector(DWIDTH-1 downto 0);
    dib      : in  std_logic_vector(DWIDTH-1 downto 0);
    doa      : out std_logic_vector(DWIDTH-1 downto 0);
    dob      : out std_logic_vector(DWIDTH-1 downto 0)
    );
end dprw_ram;

architecture syn of dprw_ram is
  type T_mem is array (0 to (2**AWIDTH)-1) of std_logic_vector(DWIDTH-1 downto 0);
  shared variable RAM_shared : T_mem    := (others => (others => '0'));

begin

  process (clka)
  begin
    if rising_edge(clka) then
      if wea = '1' then
        RAM_shared(conv_integer(addra)) := dia;
      end if;

      doa <= RAM_shared(conv_integer(addra));

    end if;
  end process;


  process (clkb)
  begin
    if rising_edge(clkb) then
      if web = '1' then
        RAM_shared(conv_integer(addrb)) := dib;
      end if;

      dob <= RAM_shared(conv_integer(addrb));

    end if;
  end process;


end syn;

