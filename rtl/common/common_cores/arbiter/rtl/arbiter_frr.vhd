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
---------------------------------------------------------------------------
-- Title       : arbiter_frr
-- Project     : Common Gateware
---------------------------------------------------------------------------
-- Description :
--
--   Fast Round-Robin Arbiter
--   ------------------------
--
-- This arbiter checks a group of request inputs and issues grant outputs
-- in response to a particular request, on a round-robin basis. When no 
-- requests are asserted, a grant is given to the first request. If more than
-- one request is asserted on the same clock edge, the least significant
-- request (LSB of the request input vector) is granted. From then on the
-- grant is passed to the next lowest asserted bit in the input request vector.
-- The number of request/grant pairs is set by the width parameter.
--
--
---------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pkg_global.all;

entity arbiter_frr is
  generic(
    width   :     natural := 5);        -- must be > 1
  port (
    clock   : in  std_logic;
    reset   : in  std_logic;
    request : in  std_logic_vector(width-1 downto 0);
    grant   : out std_logic_vector(width-1 downto 0)
    );
end arbiter_frr;

architecture rtl of arbiter_frr is

  signal next_grant       : std_logic_vector(width-1 downto 0);
  signal next_grant_state : std_logic_vector(width-1 downto 0);
  signal grant_state      : std_logic_vector(width-1 downto 0);
  

begin


  -- Work out who is to be granted next. If there are no active grants, then
  -- the lowest request number wins. If a grant is active, when the
  -- corresponding request is deasserted the grant is given to the next active
  -- request (relative to the current one). This ensures (round robin) fairness.
  process(request, grant_state)
    variable preceding        : integer;
    variable req_term         : std_logic;
    variable priority         : std_logic;
    variable next_grant_state : std_logic_vector(width-1 downto 0);
  begin
    for n in 0 to width-1 loop

      -- work out if the current request is the highest priority
      priority     := request(n);
      if (n > 0) then
        for i in n-1 downto 0 loop
          priority := priority and not request(i);
        end loop;
      end if;

      -- no one granted, and current grant is highest priority (lowest active request),
      -- or currently granted and still requesting.
      next_grant_state(n) := (and_reduce(not grant_state) and priority) or (grant_state(n) and request(n));

      req_term := request(n);

      for i in 0 to width-1 loop
        preceding := (n-i-1+width) mod width;

        req_term := req_term and not request(preceding);

        next_grant_state(n) := next_grant_state(n) or (grant_state(preceding) and req_term);
      end loop;
    end loop;

    next_grant <= next_grant_state;

  end process;


  -- sequential section
  process(clock)
  begin
    if rising_edge(clock) then
      if reset = '1' then
        grant_state <= (others => '0');
      else 
        grant_state <= next_grant;
      end if;
    end if;
  end process;

  grant <= grant_state;


end rtl;




