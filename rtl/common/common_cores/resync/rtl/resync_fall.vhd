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
-- Title       : Resync fall
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description :              
-- 
-- This module produces a single clock wide pulse when a falling 
-- edge is detected on the asynchronous input. 
--
-- The module uses the falling edge of the asynchronous input to load
-- latch and then metastability corrects the latch output to detect 
-- the rising edge in the new clock domain. The module can be used to
-- go between slow and fast domains and vice-versa.
--
-- The following timing diagram shows the operation of the module 
-- when the asynchronous input causes q2 to become metastable. Two 
-- cases are shown, in the first q2 resolves to a 1 resulting in an 
-- early sync_pulse and the second where q2 resolves to a 0 resulting 
-- in a late sync_pulse. Note that the asynchronous signal could be 
-- narrower or wider than the clk domain period, but the minimum 
-- seperation of edges for guaranteed independant detection is three 
-- clk pulses (since the q3 pulse asynchronously resets the q1 input 
-- stage).
-- 
--    async_sig ------._____________________________
-- or async_sig ------._,---------------------------
--          clk _,--.__,--.__,--.__,--.__,--.__,--._
-- 
--           q1 _______,-------.____________________ 
--      meta q2 ________xxxx--------._______________ 
--  early pulse ______________,-----._______________ 
-- 
--           q1 _______,-------------.______________
--      meta q2 ________xxxx__,-----------._________
--   late pulse ____________________,-----._________
-- 
---------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity resync_fall is
  port(
    clk            : in  std_logic;
    rst            : in  std_logic;
    async_sig      : in  std_logic;
    sync_pulse     : out std_logic
    );
end resync_fall;


architecture rtl of resync_fall is
  signal q1,q2, q3 : std_logic;
begin

  -------------------------------------------------------------------
  -- catch the falling edge of async_sig
  -------------------------------------------------------------------
  p_catch_async: process (async_sig,q3,rst)
  begin
    if (q3 = '1' or rst = '1') then
      q1 <= '0';
    elsif (async_sig'event and async_sig='0') then
      q1 <= '1';
    end if;     
  end process p_catch_async;

  ---------------------------------------------------------------
  -- create a 1-bit wide pulse from the latched falling edge
  -- of async_sig (use 2 d-types to avoid metastability)
  ---------------------------------------------------------------
  p_pulse: process (clk,rst)
  begin
    if (rst = '1') then
      q2 <= '0';
      q3 <= '0';
    elsif (clk'event and clk = '1') then
      if (q3 = '1') then
        q2  <= '0';
        q3  <= '0';
      else
        q2  <= q1;
        q3  <= q2;
      end if;
    end if;
  end process p_pulse;

  sync_pulse <= q3;
  
end rtl;

