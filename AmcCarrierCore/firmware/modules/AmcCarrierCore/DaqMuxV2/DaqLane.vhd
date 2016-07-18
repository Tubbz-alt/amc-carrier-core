-------------------------------------------------------------------------------
-- Title      : Single lane data acquisition control V2
-------------------------------------------------------------------------------
-- File       : DaqLane.vhd
-- Author     : Uros Legat  <ulegat@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2014-04-02
-- Last update: 2015-11-02
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:   This module sends sample data to a single Lane.
--                In non-continuous mode
--                - When data is requested by trig_i = '1' (Has to be 1 c-c).
--                - the module sends data a packet at the time to AXI stream FIFO.
--                Note: Tx pause must indicate that the AXI stream FIFO can hold the whole data packet.
--                Note: The data transmission is enabled only if JESD data is valid dataReady_i='1'.
--                
--                In continuous mode:
--                - has to be triggered to start
--                - continuously sends 4k frames
--                - the packetSize_i, does not have any function
--                - the freeze_i inserts User bit that freezes the circular buffer 
--
--                More info: https://confluence.slac.stanford.edu/display/ppareg/AmcAxisDaqV2+Requirements
--
--                HeaderWord 0: timeStamp_i(63:32)
--                HeaderWord 1: timeStamp_i(31:0)
--                HeaderWord 2: packetSize_i
--                HeaderWord 3: header_i & dec16or32_i & averaging_i & test_i & '0' & axiNum_i & rateDiv_i
-------------------------------------------------------------------------------
-- This file is part of 'LCLS2 Common Carrier Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'LCLS2 Common Carrier Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;

use work.Jesd204bPkg.all;

entity DaqLane is
   generic (
      -- General Configurations
      TPD_G                : time            := 1 ns;
      AXI_ERROR_RESP_G     : slv(1 downto 0) := AXI_RESP_SLVERR_C;
      FRAME_BWIDTH_G       : positive        := 10; -- Dafault 10: 4096 byte frames
      FREZE_BUFFER_TUSER_G : integer         := 2   
   );  
   port (
      enable_i : in sl;
      test_i   : in sl;
      
      -- JESD devClk
      devClk_i : in sl;
      devRst_i : in sl;

      -- Lane number AXI number to be inserted into AXI stream
      axiNum_i  : integer range 0 to 15;

      -- DAQ
      packetSize_i : in slv(31 downto 0); -- Min 4
      rateDiv_i    : in slv(15 downto 0); -- If averaging enabled then only powers of 2 should be used
      trig_i       : in sl:='0';          -- Must be 1 c-c pulse
      freeze_i     : in sl:='0';          -- Must be 1 c-c pulse
      averaging_i  : in sl:='0';          -- Enable decination averaging
      dec16or32_i  : in sl:='0';          -- Data format
      timeStamp_i  : in slv(63 downto 0); 
      headerEn_i   : in sl:='0';          -- Additional/external header byte
      header_i     : in slv(7 downto 0):=x"00";
      
      -- Mode of DAQ - '0'  - until packet size and needs trigger (used in new interface)
      --             - '1'  - sends the 4k frames continuously no trigger(used in new interface)
      mode_i       : in sl:='0';
     
      -- Axi Stream
      rxAxisCtrl_i      : in  AxiStreamCtrlType := AXI_STREAM_CTRL_UNUSED_C;
      rxAxisSlave_i     : in  AxiStreamSlaveType:= AXI_STREAM_SLAVE_FORCE_C;
      rxAxisMaster_o    : out AxiStreamMasterType;
      error_o           : out sl; -- Error if tReady drops
      busy_o            : out sl; -- Busy inhibits trigger in mode_i = '0'
      pctCnt_o          : out slv(25 downto 0); -- Number of 4096 byte frames 

      sampleData_i : in slv((GT_WORD_SIZE_C*8)-1 downto 0);
      dataReady_i  : in sl
      );
end DaqLane;

architecture rtl of DaqLane is

   constant SSI_CONFIG_C      : AxiStreamConfigType := ssiAxiStreamConfig(GT_WORD_SIZE_C, TKEEP_FIXED_C, TUSER_FIRST_LAST_C, 4, 3);
   constant TSTRB_C           : slv(15 downto 0)    := (15 downto GT_WORD_SIZE_C => '0') & (GT_WORD_SIZE_C-1 downto 0 => '1');
   constant KEEP_C            : slv(15 downto 0)    := (15 downto GT_WORD_SIZE_C => '0') & (GT_WORD_SIZE_C-1 downto 0 => '1');

   type StateType is (
      IDLE_S,
      HEADER_0_S,
      HEADER_1_S,
      HEADER_2_S,
      HEADER_3_S,
      SOF_S,
      DATA_S
      );  

   type RegType is record
      dataCnt      : slv(packetSize_i'range);
      txAxisMaster : AxiStreamMasterType;
      error        : sl;
      freeze       : sl;
      busy         : sl;      
      pctCnt       : slv(pctCnt_o'range);
      trig         : sl;  
      state        : StateType;
   end record;
   
   constant REG_INIT_C : RegType := (
      dataCnt      => (others => '0'),
      txAxisMaster => AXI_STREAM_MASTER_INIT_C,
      error        => '0',
      freeze       => '0',
      busy         => '0',
      pctCnt       => (others => '0'),
      trig         => '0',
      state        => IDLE_S
      );

   signal r                : RegType := REG_INIT_C;
   signal rin              : RegType;
   signal s_rateClk        : sl;
   signal s_trigDecimator  : sl;
   signal s_decSampData    : slv((GT_WORD_SIZE_C*8)-1 downto 0);

begin
   -- Do not trigger decimator when busy
   -- because it will zero s_rateClk and data will be missed
   s_trigDecimator <= trig_i and not r.busy;
   
   -- Rate divider module
   Decimator_INST : entity work.DaqDecimator
      generic map (
         TPD_G => TPD_G
         )
      port map (
         clk           => devClk_i,
         rst           => devRst_i,
         test_i        => test_i,
         sampleData_i  => sampleData_i,
         decSampData_o => s_decSampData,
         dec16or32_i   => dec16or32_i,
         rateDiv_i     => rateDiv_i,
         trig_i        => s_trigDecimator,
         averaging_i   => averaging_i,
         rateClk_o     => s_rateClk);


   comb : process (r, axiNum_i, dataReady_i, devRst_i, enable_i, packetSize_i, mode_i, freeze_i, 
                   rxAxisCtrl_i, rxAxisSlave_i, s_decSampData, s_rateClk, trig_i, headerEn_i, timeStamp_i, header_i) is
      variable v             : RegType;
      variable axilStatus    : AxiLiteStatusType;
      variable axilWriteResp : slv(1 downto 0);
      variable axilReadResp  : slv(1 downto 0);
   begin
      -- Latch the current value
      v := r;
      
      -- Register trigger
      v.trig := trig_i;
      
      -- Reset strobing signals
      ssiResetFlags(v.txAxisMaster);
      v.txAxisMaster.tData := (others => '0');

      -- Latch the configuration
      v.txAxisMaster.tKeep := KEEP_C;
      v.txAxisMaster.tStrb := TSTRB_C;

      -- State Machine
      case (r.state) is
         ----------------------------------------------------------------------
         when IDLE_S =>

            -- Put packet data count to zero 
            v.dataCnt := (others => '0');
            v.error   := r.error;
            v.freeze  := '0';
            v.busy    := '0';
            v.pctCnt  := r.pctCnt;
              

            -- No data sent 
            v.txAxisMaster.tvalid := '0';
            v.txAxisMaster.tData  := (others => '0');
            v.txAxisMaster.tLast  := '0';
            v.txAxisMaster.tDest  := toSlv(axiNum_i, 8);

            -- Check if fifo and JESD is ready
            if (rxAxisCtrl_i.pause = '0' and enable_i = '1' and rxAxisSlave_i.tReady = '1' and dataReady_i = '1' and r.trig = '1') then
               
               -- Clear error at the beginning of transmission
               v.error  := '0';
               v.pctCnt := (others => '0');

               -- 
               if (mode_i = '0') then 
                  v.state  := HEADER_0_S; -- Next State when in triggered mode
               else   
                  v.state  := SOF_S;      -- Next State when in continuous mode
               end if;              
            end if;
         ----------------------------------------------------------------------
         when HEADER_0_S =>
             
            v.busy   := '1';          
            v.pctCnt := (others => '0');
            v.freeze  := '0';
            
            -- Increment the counter
            -- and sample data on s_rateClk rate
            if s_rateClk = '1' then
               v.dataCnt             := r.dataCnt + 1;
               v.txAxisMaster.tvalid := '1';
            else
               v.dataCnt             := r.dataCnt;
               v.txAxisMaster.tvalid := '0';
            end if;

            -- Error if tReady or dataReady drops 
            if (rxAxisSlave_i.tReady = '0' or dataReady_i = '0') then
               v.error := '1';
            else
               v.error := r.error;
            end if;

            -- Insert time-stamp MSW at the first header word
            if (headerEn_i = '1') then
               v.txAxisMaster.tData((GT_WORD_SIZE_C*8)-1 downto 0) := timeStamp_i(63 downto 32);            
            else
               v.txAxisMaster.tData((GT_WORD_SIZE_C*8)-1 downto 0) := s_decSampData;
            end if;
            
            v.txAxisMaster.tLast := '0';
            v.txAxisMaster.tDest := toSlv(axiNum_i, 8);

            -- Set the SOF bit
            ssiSetUserSof(SSI_CONFIG_C, v.txAxisMaster, '1');

            -- Go further after next data
            if s_rateClk = '1' then
               v.state := HEADER_1_S;
            end if;
         ----------------------------------------------------------------------
         when HEADER_1_S =>
             
            v.busy   := '1';          
            v.pctCnt := (others => '0');
            v.freeze  := '0';
            
            -- Increment the counter
            -- and sample data on s_rateClk rate
            if s_rateClk = '1' then
               v.dataCnt             := r.dataCnt + 1;
               v.txAxisMaster.tvalid := '1';
            else
               v.dataCnt             := r.dataCnt;
               v.txAxisMaster.tvalid := '0';
            end if;

            -- Error if tReady or dataReady drops 
            if (rxAxisSlave_i.tReady = '0' or dataReady_i = '0') then
               v.error := '1';
            else
               v.error := r.error;
            end if;

            -- Insert time-stamp LSW at the second header word
            if (headerEn_i = '1') then
               v.txAxisMaster.tData((GT_WORD_SIZE_C*8)-1 downto 0) := timeStamp_i(31 downto 0);            
            else
               v.txAxisMaster.tData((GT_WORD_SIZE_C*8)-1 downto 0) := s_decSampData;
            end if;
            
            v.txAxisMaster.tLast := '0';
            v.txAxisMaster.tDest := toSlv(axiNum_i, 8);

            -- Go further after next data
            if s_rateClk = '1' then
               v.state := HEADER_2_S;
            end if;
         ----------------------------------------------------------------------
         when HEADER_2_S =>
             
            v.busy   := '1';          
            v.pctCnt := (others => '0');
            v.freeze  := '0';
            
            -- Increment the counter
            -- and sample data on s_rateClk rate
            if s_rateClk = '1' then
               v.dataCnt             := r.dataCnt + 1;
               v.txAxisMaster.tvalid := '1';
            else
               v.dataCnt             := r.dataCnt;
               v.txAxisMaster.tvalid := '0';
            end if;

            -- Error if tReady or dataReady drops 
            if (rxAxisSlave_i.tReady = '0' or dataReady_i = '0') then
               v.error := '1';
            else
               v.error := r.error;
            end if;

            -- Insert packet size at the third header word
            if (headerEn_i = '1') then
               v.txAxisMaster.tData((GT_WORD_SIZE_C*8)-1 downto 0) := packetSize_i;            
            else
               v.txAxisMaster.tData((GT_WORD_SIZE_C*8)-1 downto 0) := s_decSampData;
            end if;
            
            v.txAxisMaster.tLast := '0';
            v.txAxisMaster.tDest := toSlv(axiNum_i, 8);

            -- Go further after next data
            if s_rateClk = '1' then
               v.state := HEADER_3_S;
            end if;
         ----------------------------------------------------------------------
         when HEADER_3_S =>
             
            v.busy   := '1';          
            v.pctCnt := (others => '0');
            v.freeze  := '0';
            
            -- Increment the counter
            -- and sample data on s_rateClk rate
            if s_rateClk = '1' then
               v.dataCnt             := r.dataCnt + 1;
               v.txAxisMaster.tvalid := '1';
            else
               v.dataCnt             := r.dataCnt;
               v.txAxisMaster.tvalid := '0';
            end if;

            -- Error if tReady or dataReady drops 
            if (rxAxisSlave_i.tReady = '0' or dataReady_i = '0') then
               v.error := '1';
            else
               v.error := r.error;
            end if;

            -- Insert header at the fourth header word
            if (headerEn_i = '1') then
               v.txAxisMaster.tData((GT_WORD_SIZE_C*8)-1 downto 0) := header_i & dec16or32_i & averaging_i & test_i & '0' & toSlv(axiNum_i, 4) & rateDiv_i ;            
            else                                                      
               v.txAxisMaster.tData((GT_WORD_SIZE_C*8)-1 downto 0) := s_decSampData;
            end if;
            
            v.txAxisMaster.tLast := '0';
            v.txAxisMaster.tDest := toSlv(axiNum_i, 8);
            
            -- Insert tLast and EOFE if packetSize_i less or equal to 4 
            if (packetSize_i <= 4) then
                        -- Set the EOF(tlast) bit       
               v.txAxisMaster.tLast := '1';
               -- Set the EOFE bit in tUser if error occurred during packet transmission
               ssiSetUserEofe(SSI_CONFIG_C, v.txAxisMaster, r.error);
            end if;

            -- Go further after next data
            if (s_rateClk = '1') then
               if (packetSize_i <= 4) then
                  v.pctCnt  := r.pctCnt+1;
                  v.state := IDLE_S;     -- End packet
               else
                  v.state := DATA_S;               
               end if;
            end if;            
         when SOF_S =>
         
            -- Busy only if in trigger mode        
            v.busy := '1'; 
            
            -- Increment the counter
            -- and sample data on s_rateClk rate
            if s_rateClk = '1' then
               v.dataCnt             := r.dataCnt + 1;
               v.txAxisMaster.tvalid := '1';
            else
               v.dataCnt             := r.dataCnt;
               v.txAxisMaster.tvalid := '0';
            end if;

            -- Error if tReady or dataReady drops 
            if (rxAxisSlave_i.tReady = '0' or dataReady_i = '0') then
               v.error := '1';
            else
               v.error := r.error;
            end if;

            -- Freeze buffers if triggered in continuous mode
            if (freeze_i = '1') then
               v.freeze  := '1';
            else
               v.freeze := r.freeze;
            end if;

            v.pctCnt := r.pctCnt;

            -- Send the JESD data
            v.txAxisMaster.tData((GT_WORD_SIZE_C*8)-1 downto 0) := s_decSampData;
            v.txAxisMaster.tLast                                := '0';

            v.txAxisMaster.tDest := toSlv(axiNum_i, 8);

            -- Set the SOF bit
            ssiSetUserSof(SSI_CONFIG_C, v.txAxisMaster, '1');
            
            -- Set the tLast bit            
            if (r.dataCnt >= (packetSize_i-1) and mode_i = '0') then
               v.txAxisMaster.tLast := '1';
               -- Set the EOFE bit in tUser if error occurred during packet transmission
               ssiSetUserEofe(SSI_CONFIG_C, v.txAxisMaster, r.error);
               -- Set the freeze buffer tUser bit 
               -- if the trigger occurred during the packet the EOF will contain freeze buffer bit 
               axiStreamSetUserBit(SSI_CONFIG_C, v.txAxisMaster, FREZE_BUFFER_TUSER_G, r.freeze);
            end if;

            -- Go further after next data
            if (s_rateClk = '1') then
               if (r.dataCnt >= (packetSize_i-1) and mode_i = '0') then
                  v.pctCnt := r.pctCnt+1;
                  v.state := IDLE_S;
               else
                  v.state := DATA_S;
               end if;
            end if;
         ----------------------------------------------------------------------
         when DATA_S =>
         
            -- Busy only if in trigger mode        
            v.busy := '1'; 
            
            -- Increment the counter
            -- and sample data on s_rateClk rate
            if s_rateClk = '1' then
               v.dataCnt             := r.dataCnt + 1;
               v.txAxisMaster.tvalid := '1';
            else
               v.dataCnt             := r.dataCnt;
               v.txAxisMaster.tvalid := '0';
            end if;

            -- Error if tReady or dataReady drops 
            if (rxAxisSlave_i.tReady = '0' or dataReady_i = '0') then
               v.error := '1';
            else
               v.error := r.error;
            end if;

            -- Freeze buffers if triggered in continuous mode
            if (freeze_i = '1') then
               v.freeze  := '1';
            else
               v.freeze := r.freeze;
            end if;

            v.pctCnt := r.pctCnt;

            -- Send the JESD data 
            v.txAxisMaster.tData((GT_WORD_SIZE_C*8)-1 downto 0) := s_decSampData;
            
            v.txAxisMaster.tDest := toSlv(axiNum_i, 8);            
            v.txAxisMaster.tLast := '0';
            
            -- Set the tLast bit            
            if ((r.dataCnt >= (packetSize_i-1) and mode_i = '0') or
                (r.dataCnt(FRAME_BWIDTH_G-1 downto 0) = (2**FRAME_BWIDTH_G-1)) or
                (r.error = '1')
            ) then
               v.txAxisMaster.tLast := '1';
               -- Set the EOFE bit in tUser if error occurred during packet transmission
               ssiSetUserEofe(SSI_CONFIG_C, v.txAxisMaster, r.error);
               -- Set the freeze buffer tUser bit 
               -- if the trigger occurred during the packet the EOF will contain freeze buffer bit 
               axiStreamSetUserBit(SSI_CONFIG_C, v.txAxisMaster, FREZE_BUFFER_TUSER_G, r.freeze);
            end if;

            -- Next state conditioning
            if (s_rateClk = '1') then
               if ((r.error = '1') or                               -- Immediately stop sending data if error occurs
                   (r.dataCnt >= (packetSize_i-1) and mode_i = '0') -- Stop sending data if packet size reached 
               ) then                                               -- Do not stop sending data if in continuous mode
                  v.pctCnt := r.pctCnt+1;
                  v.state := IDLE_S;                   
               elsif (r.dataCnt(FRAME_BWIDTH_G-1 downto 0) = (2**FRAME_BWIDTH_G-1)) then -- Finish a frame if frame size reached
                  if enable_i = '1' then
                     -- Clear freeze flag (but apply it if the freeze_i occurs at this very moment)
                     if (freeze_i = '1') then
                        v.freeze := '1';
                     else
                        v.freeze := '0';
                     end if;
                     v.pctCnt := r.pctCnt+1;
                     v.state := SOF_S;                              -- Go to next frame                 
                  else
                     v.pctCnt := r.pctCnt+1;
                     v.state := IDLE_S;                             -- End packet if disabled                             
                  end if;
               end if;
            end if;
         ----------------------------------------------------------------------
         when others => null;

      ----------------------------------------------------------------------
      end case;

      -- Reset
      if (devRst_i = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;
      
   end process comb;

   seq : process (devClk_i) is
   begin
      if rising_edge(devClk_i) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   -- Output assignment
   rxAxisMaster_o <= r.txAxisMaster;
   error_o        <= r.error;
   pctCnt_o       <= r.pctCnt;
   busy_o         <= r.busy and not mode_i;

end rtl;
