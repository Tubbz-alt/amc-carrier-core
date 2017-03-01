-------------------------------------------------------------------------------
-- File       : RtmRfInterlock.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-06-17
-- Last update: 2017-02-27
-------------------------------------------------------------------------------
-- Description: https://confluence.slac.stanford.edu/display/AIRTRACK/PC_379_396_19_C01    
------------------------------------------------------------------------------
-- This file is part of 'LCLS2 LLRF Development'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'LCLS2 LLRF Development', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

library unisim;
use unisim.vcomponents.all;

entity RtmRfInterlock is
   generic (
      TPD_G            : time             := 1 ns;
      AXIL_BASE_ADDR_G : slv(31 downto 0) := (others => '0');
      AXI_ERROR_RESP_G : slv(1 downto 0)  := AXI_RESP_SLVERR_C);
   port (
      -- Recovered EVR clock
      recClk          : in    sl;
      recRst          : in    sl;
      -- Timing triggers
      stndbyTrig      : in    sl;
      accelTrig       : in    sl;
      dataTrig        : in    sl;
      -- AXI-Lite
      axilClk         : in    sl;
      axilRst         : in    sl;
      axilReadMaster  : in    AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
      axilReadSlave   : out   AxiLiteReadSlaveType;
      axilWriteMaster : in    AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
      axilWriteSlave  : out   AxiLiteWriteSlaveType;
      -----------------------
      -- Application Ports --
      -----------------------      
      -- RTM's Low Speed Ports
      rtmLsP          : inout slv(53 downto 0);
      rtmLsN          : inout slv(53 downto 0);
      --  RTM's Clock Reference
      genClkP         : in    sl;
      genClkN         : in    sl);
end RtmRfInterlock;

architecture mapping of RtmRfInterlock is

   -- High speed ADC status data (data rate is 6x recClk DDR)
   signal hsAdcBeamIP    : sl;
   signal hsAdcBeamIN    : sl;
   signal hsAdcBeamVP    : sl;
   signal hsAdcBeamVN    : sl;
   signal hsAdcFwdPwrP   : sl;
   signal hsAdcFwdPwrN   : sl;
   signal hsAdcReflPwrP  : sl;
   signal hsAdcReflPwrN  : sl;
   signal hsAdcFrameClkP : sl;
   signal hsAdcFrameClkN : sl;
   signal hsAdcDataClkP  : sl;
   signal hsAdcDataClkN  : sl;
   signal hsAdcClkP      : sl;
   signal hsAdcClkN      : sl;
   signal hsAdcTest      : sl;
   -- Thresholds SPI
   signal klyThrCs       : sl;
   signal modThrCs       : sl;
   signal potSck         : sl;
   signal potSdi         : sl;
   -- Low Speed ADC SPI
   signal adcCnv         : sl;
   signal adcSck         : sl;
   signal adcSdi         : sl;
   signal adcSdo         : sl;
   -- CPLD SPI
   signal cpldCsb        : sl;
   signal cpldSck        : sl;
   signal cpldSdi        : sl;
   signal cpldSdo        : sl;
   -- SLED and MODE
   signal detuneSled     : sl;
   signal tuneSled       : sl;
   signal mode           : sl;
   signal bypassMode     : sl;
   signal rfOff          : sl;
   signal fault          : sl;
   signal faultClear     : sl;

begin

   hsAdcBeamIP    <= rtmLsP(9);
   hsAdcBeamIN    <= rtmLsN(9);
   hsAdcBeamVP    <= rtmLsP(14);
   hsAdcBeamVN    <= rtmLsN(14);
   hsAdcFwdPwrP   <= '0';               -- Removed in revision C01 
   hsAdcFwdPwrN   <= '1';               -- Removed in revision C01   
   hsAdcReflPwrP  <= rtmLsP(19);
   hsAdcReflPwrN  <= rtmLsN(19);
   hsAdcFrameClkP <= rtmLsP(18);
   hsAdcFrameClkN <= rtmLsN(18);
   hsAdcDataClkP  <= rtmLsP(3);
   hsAdcDataClkN  <= rtmLsN(3);
   rtmLsP(8)      <= hsAdcClkP;
   rtmLsN(8)      <= hsAdcClkN;
   rtmLsP(12)     <= hsAdcTest;

   rtmLsN(0) <= potSdi;
   rtmLsP(0) <= potSck;

   rtmLsN(1) <= klyThrCs;
   rtmLsP(1) <= modThrCs;

   rtmLsP(15) <= adcSdi;
   adcSdo     <= rtmLsN(15);

   rtmLsN(4) <= adcSck;
   rtmLsP(4) <= adcCnv;

   cpldSdo    <= rtmLsN(10);
   rtmLsP(11) <= cpldSdi;

   rtmLsN(12) <= cpldSck;
   rtmLsN(11) <= cpldCsb;

   U_stndbyTrig : OBUFDS
      port map (
         I  => stndbyTrig,  -- C00's stndbyTrig = C01's MOD_TRIGGER (CPLD.M2)
         O  => rtmLsP(6),
         OB => rtmLsN(6));

   U_accelTrig : OBUFDS
      port map (
         I  => accelTrig,  -- C00's accelTrig  = C01's SSSB_TRIGGER (CPLD.L4)
         O  => rtmLsP(7),
         OB => rtmLsN(7));

   rtmLsP(5) <= detuneSled;
   rtmLsN(5) <= tuneSled;

   -- mode removed in revision C01  

   rfOff     <= rtmLsP(16);
   fault     <= rtmLsN(16);
   rtmLsN(2) <= faultClear;
   rtmLsP(2) <= bypassMode;

   -------
   -- Core
   -------
   U_CORE : entity work.RtmRfInterlockCore
      generic map (
         TPD_G            => TPD_G,
         AXIL_BASE_ADDR_G => AXIL_BASE_ADDR_G,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_G)
      port map (
         -- Recovered EVR clock
         recClk          => recClk,
         recRst          => recRst,
         -- Timing triggers
         dataTrig        => dataTrig,
         -- AXI-Lite
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         -- High speed ADC status data (data rate is 6x recClk DDR)
         hsAdcBeamIP     => hsAdcBeamIP,
         hsAdcBeamIN     => hsAdcBeamIN,
         hsAdcBeamVP     => hsAdcBeamVP,
         hsAdcBeamVN     => hsAdcBeamVN,
         hsAdcFwdPwrP    => hsAdcFwdPwrP,
         hsAdcFwdPwrN    => hsAdcFwdPwrN,
         hsAdcReflPwrP   => hsAdcReflPwrP,
         hsAdcReflPwrN   => hsAdcReflPwrN,
         hsAdcFrameClkP  => hsAdcFrameClkP,
         hsAdcFrameClkN  => hsAdcFrameClkN,
         hsAdcDataClkP   => hsAdcDataClkP,
         hsAdcDataClkN   => hsAdcDataClkN,
         hsAdcClkP       => hsAdcClkP,
         hsAdcClkN       => hsAdcClkN,
         hsAdcTest       => hsAdcTest,
         -- Thresholds SPI
         klyThrCs        => klyThrCs,
         modThrCs        => modThrCs,
         potSck          => potSck,
         potSdi          => potSdi,
         -- Low Speed ADC SPI
         adcCnv          => adcCnv,
         adcSck          => adcSck,
         adcSdi          => adcSdi,
         adcSdo          => adcSdo,
         -- CPLD SPI
         cpldCsb         => cpldCsb,
         cpldSck         => cpldSck,
         cpldSdi         => cpldSdi,
         cpldSdo         => cpldSdo,
         -- SLED and MODE
         detuneSled      => detuneSled,
         tuneSled        => tuneSled,
         mode            => mode,
         bypassMode      => bypassMode,
         rfOff           => rfOff,
         fault           => fault,
         faultClear      => faultClear);

end architecture mapping;