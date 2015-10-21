-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : BsaAccumulator.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-09-29
-- Last update: 2015-10-15
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2015 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;

entity BsaAccumulator is

   generic (
      TPD_G : time := 1 ns;
      BSA_NUMBER_G : integer range 0 to 64 := 0;
      FRAME_SIZE_BYTES_G : integer range 128 to 4096 := 2048;
      AXIS_CONFIG_G : AxiStreamConfigType := ssiAxiStreamConfig(4));

   port (
      clk : in sl;
      rst : in sl;

      bsaInit        : in  sl;
      bsaActive      : in  sl;
      bsaAvgDone     : in  sl;
      diagnosticData : in  slv(31 downto 0);
      accumulateEn   : in  sl;
      axisMaster     : out AxiStreamMasterType;
      axisSlave      : in  AxiStreamSlaveType);

end entity BsaAccumulator;

architecture rtl of BsaAccumulator is

   constant MAX_COUNT_G : integer := FRAME_SIZE_BYTES_G/4-1;

   type RegType is record
      count : integer range 0 to MAX_COUNT_G-1;
      accumulations : Slv32Array(31 downto 0);
   end record RegType;


   signal r   : RegType;
   signal rin : RegType;

   -- Outputs from FB adder array
   signal adderEn    : sl;
   signal adderInA   : slv(31 downto 0);
   signal adderInB   : slv(31 downto 0);
   signal adderOut   : slv(31 downto 0);
   signal adderValid : sl;

   signal shiftEn : sl;
   signal shiftIn : slv(31 downto 0);

   signal sAxisMaster : AxiStreamMasterType;
   signal sAxisSlave : AxiStreamSlaveType;

   component BsaAddFpCore is
      port (
         aclk                 : in  sl;
         s_axis_a_tvalid      : in  sl;
         s_axis_a_tdata       : in  slv(31 downto 0);
         s_axis_b_tvalid      : in  sl;
         s_axis_b_tdata       : in  slv(31 downto 0);
         m_axis_result_tvalid : out sl;
         m_axis_result_tdata  : out slv(31 downto 0));
   end component BsaAddFpCore;
   
   constant INT_AXI_STREAM_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 4,
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 0,
      TKEEP_MODE_C  => TKEEP_NONE_C,
      TUSER_BITS_C  => 0,
      TUSER_MODE_C  => TUSER_NONE_C);

--    attribute srl_style : string;
--    attribute srl_style of r.accumulations : signal is "srl";
   
begin

   BSA_ADD_FP_CORE : BsaAddFpCore
      port map (
         aclk                 => clk,
         s_axis_a_tvalid      => adderEn,
         s_axis_a_tdata       => adderInA,
         s_axis_b_tvalid      => adderEn,
         s_axis_b_tdata       => adderInB,
         m_axis_result_tvalid => adderValid,
         m_axis_result_tdata  => adderOut);

   adderInA <= diagnosticData     when bsaActive = '1' else X"00000000";
   adderInB <= r.accumulations(0) when bsaInit = '0'   else X"00000000";
   adderEn  <= accumulateEn;

   shiftEn <= accumulateEn or adderValid;
   shiftIn <= adderOut when bsaAvgDone = '0' else X"00000000";

   sAxisMaster.tdata(31 downto 0) <= adderOut;
   sAxisMaster.tvalid             <= adderValid and bsaAvgDone;
   sAxisMaster.tdest <= toSlv(BSA_NUMBER_G, 8);
   sAxisMaster.tlast <= toSl(r.count = MAX_COUNT_G);
   sAxisMaster.tkeep <= (others => '1');
   sAxisMaster.tStrb <= (others => '1');
   sAxisMaster.tUser <= (others => '0');
   sAxisMaster.tId <= (others => '0');

   U_AxiStreamFifo_1 : entity work.AxiStreamFifo
      generic map (
         TPD_G               => TPD_G,
         PIPE_STAGES_G       => 0,
         SLAVE_READY_EN_G    => false,
         VALID_THOLD_G       => 0,
         BRAM_EN_G           => true,
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => true,
         CASCADE_SIZE_G      => 1,
         FIFO_ADDR_WIDTH_G   => 9,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 1,
         SLAVE_AXI_CONFIG_G  => INT_AXI_STREAM_CONFIG_C,
         MASTER_AXI_CONFIG_G => AXIS_CONFIG_G)
      port map (
         sAxisClk    => clk,            -- [in]
         sAxisRst    => rst,            -- [in]
         sAxisMaster => sAxisMaster,    -- [in]
         sAxisSlave  => sAxisSlave,           -- [out]
         sAxisCtrl   => open,           -- [out]
         mAxisClk    => clk,            -- [in]
         mAxisRst    => rst,            -- [in]
         mAxisMaster => axisMaster,     -- [out]
         mAxisSlave  => axisSlave,      -- [in]
         mTLastTUser => open);          -- [out]

   comb : process (r, rst, sAxisMaster, shiftEn, shiftIn) is
      variable v : RegType;

   begin
      v := r;

      if (shiftEn = '1') then
         v.accumulations(31)          := shiftIn;
         v.accumulations(30 downto 0) := r.accumulations(31 downto 1);
      end if;

      if (sAxisMaster.tvalid = '1' and sAxisSlave.tReady = '1') then
         v.count := r.count + 1;
         if (r.count = MAX_COUNT_G) then
            v.count := 0;
         end if;
      end if;

 
      ----------------------------------------------------------------------------------------------
      -- Reset and output assignment
      ----------------------------------------------------------------------------------------------
      if (rst = '1') then
         v.count := 0;
      end if;

      rin <= v;

   end process comb;

   seq : process (clk) is
   begin
      if (rising_edge(clk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end architecture rtl;