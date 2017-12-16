##############################################################################
## This file is part of 'LCLS2 Common Carrier Core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'LCLS2 Common Carrier Core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property BITSTREAM.CONFIG.CONFIGRATE 51.0 [current_design] 

set_property CFGBVS         {GND} [current_design]
set_property CONFIG_VOLTAGE {1.8} [current_design]

set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets {U_Core/U_AppMps/U_Clk/mpsClk}] 

#######################
## Common Core Ports ##
#######################

# Common fabrication clock
set_property PACKAGE_PIN T6 [get_ports {fabClkP}]
set_property PACKAGE_PIN T5 [get_ports {fabClkN}]

# ETH Ports
set_property PACKAGE_PIN V6  [get_ports {ethClkP}]
set_property PACKAGE_PIN V5  [get_ports {ethClkN}]

# LCLS Timing Ports
set_property -dict { PACKAGE_PIN U34  IOSTANDARD LVDS     } [get_ports {timingRecClkOutP}]
set_property -dict { PACKAGE_PIN V34  IOSTANDARD LVDS     } [get_ports {timingRecClkOutN}]
set_property -dict { PACKAGE_PIN AP13 IOSTANDARD LVCMOS25 } [get_ports {timingClkSel}]

set_property PACKAGE_PIN AK6  [get_ports {timingTxP}]
set_property PACKAGE_PIN AK5  [get_ports {timingTxN}]
set_property PACKAGE_PIN AJ4  [get_ports {timingRxP}]
set_property PACKAGE_PIN AJ3  [get_ports {timingRxN}]
set_property PACKAGE_PIN Y6   [get_ports {timingRefClkInP}]
set_property PACKAGE_PIN Y5   [get_ports {timingRefClkInN}]

# Secondary AMC Auxiliary Power Enable Port
set_property -dict { PACKAGE_PIN AN13 IOSTANDARD LVCMOS25 } [get_ports {enAuxPwrL}] 

# DDR3L SO-DIMM Ports
set_property PACKAGE_PIN      P26         [get_ports {ddrClkP}] 
set_property PACKAGE_PIN      N26         [get_ports {ddrClkN}] 
set_property IOSTANDARD       DIFF_HSTL_I [get_ports {ddrClkP ddrClkN}]
set_property IBUF_LOW_PWR     FALSE       [get_ports {ddrClkP ddrClkN}]
set_property PULLTYPE         KEEPER      [get_ports {ddrClkP ddrClkN}]

set_property PACKAGE_PIN AN18 [get_ports {ddrDqsP[0]}] 
set_property PACKAGE_PIN AN17 [get_ports {ddrDqsN[0]}] 
set_property PACKAGE_PIN AL18 [get_ports {ddrDqsP[1]}] 
set_property PACKAGE_PIN AL17 [get_ports {ddrDqsN[1]}] 
set_property PACKAGE_PIN AJ15 [get_ports {ddrDqsP[2]}] 
set_property PACKAGE_PIN AJ14 [get_ports {ddrDqsN[2]}] 
set_property PACKAGE_PIN AE16 [get_ports {ddrDqsP[3]}] 
set_property PACKAGE_PIN AE15 [get_ports {ddrDqsN[3]}] 
set_property PACKAGE_PIN B10  [get_ports {ddrDqsP[4]}] 
set_property PACKAGE_PIN A10  [get_ports {ddrDqsN[4]}] 
set_property PACKAGE_PIN K10  [get_ports {ddrDqsP[5]}] 
set_property PACKAGE_PIN J10  [get_ports {ddrDqsN[5]}] 
set_property PACKAGE_PIN L13  [get_ports {ddrDqsP[6]}] 
set_property PACKAGE_PIN K13  [get_ports {ddrDqsN[6]}] 
set_property PACKAGE_PIN F13  [get_ports {ddrDqsP[7]}] 
set_property PACKAGE_PIN E13  [get_ports {ddrDqsN[7]}] 
set_property IOSTANDARD DIFF_SSTL15_DCI   [get_ports {ddrDqsP[*] ddrDqsN[*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrDqsP[*] ddrDqsN[*]}]
set_property SLEW          FAST           [get_ports {ddrDqsP[*] ddrDqsN[*]}]
set_property IBUF_LOW_PWR  FALSE          [get_ports {ddrDqsP[*] ddrDqsN[*]}]
set_property ODT           RTT_40         [get_ports {ddrDqsP[*] ddrDqsN[*]}]

set_property PACKAGE_PIN AN14 [get_ports {ddrDm[0]}] 
set_property PACKAGE_PIN AL14 [get_ports {ddrDm[1]}] 
set_property PACKAGE_PIN AH18 [get_ports {ddrDm[2]}] 
set_property PACKAGE_PIN AD19 [get_ports {ddrDm[3]}] 
set_property PACKAGE_PIN F8   [get_ports {ddrDm[4]}] 
set_property PACKAGE_PIN L8   [get_ports {ddrDm[5]}] 
set_property PACKAGE_PIN H11  [get_ports {ddrDm[6]}] 
set_property PACKAGE_PIN E11  [get_ports {ddrDm[7]}] 
set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrDm[*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrDm[*]}]
set_property SLEW FAST                    [get_ports {ddrDm[*]}]

set_property PACKAGE_PIN AN19 [get_ports {ddrDq[0]}] 
set_property PACKAGE_PIN AP18 [get_ports {ddrDq[1]}] 
set_property PACKAGE_PIN AM17 [get_ports {ddrDq[2]}] 
set_property PACKAGE_PIN AN16 [get_ports {ddrDq[3]}] 
set_property PACKAGE_PIN AM16 [get_ports {ddrDq[4]}] 
set_property PACKAGE_PIN AM15 [get_ports {ddrDq[5]}] 
set_property PACKAGE_PIN AP16 [get_ports {ddrDq[6]}] 
set_property PACKAGE_PIN AP15 [get_ports {ddrDq[7]}] 
set_property PACKAGE_PIN AL19 [get_ports {ddrDq[8]}] 
set_property PACKAGE_PIN AM19 [get_ports {ddrDq[9]}] 
set_property PACKAGE_PIN AK15 [get_ports {ddrDq[10]}] 
set_property PACKAGE_PIN AL15 [get_ports {ddrDq[11]}] 
set_property PACKAGE_PIN AJ18 [get_ports {ddrDq[12]}] 
set_property PACKAGE_PIN AK18 [get_ports {ddrDq[13]}] 
set_property PACKAGE_PIN AK17 [get_ports {ddrDq[14]}] 
set_property PACKAGE_PIN AK16 [get_ports {ddrDq[15]}] 
set_property PACKAGE_PIN AH16 [get_ports {ddrDq[16]}] 
set_property PACKAGE_PIN AJ16 [get_ports {ddrDq[17]}] 
set_property PACKAGE_PIN AG17 [get_ports {ddrDq[18]}] 
set_property PACKAGE_PIN AG16 [get_ports {ddrDq[19]}] 
set_property PACKAGE_PIN AG19 [get_ports {ddrDq[20]}] 
set_property PACKAGE_PIN AH19 [get_ports {ddrDq[21]}] 
set_property PACKAGE_PIN AG15 [get_ports {ddrDq[22]}] 
set_property PACKAGE_PIN AG14 [get_ports {ddrDq[23]}] 
set_property PACKAGE_PIN AF15 [get_ports {ddrDq[24]}] 
set_property PACKAGE_PIN AF14 [get_ports {ddrDq[25]}] 
set_property PACKAGE_PIN AE18 [get_ports {ddrDq[26]}] 
set_property PACKAGE_PIN AF18 [get_ports {ddrDq[27]}] 
set_property PACKAGE_PIN AE17 [get_ports {ddrDq[28]}] 
set_property PACKAGE_PIN AF17 [get_ports {ddrDq[29]}] 
set_property PACKAGE_PIN AD16 [get_ports {ddrDq[30]}] 
set_property PACKAGE_PIN AD15 [get_ports {ddrDq[31]}] 
set_property PACKAGE_PIN B9   [get_ports {ddrDq[32]}] 
set_property PACKAGE_PIN A9   [get_ports {ddrDq[33]}] 
set_property PACKAGE_PIN D8   [get_ports {ddrDq[34]}] 
set_property PACKAGE_PIN C8   [get_ports {ddrDq[35]}] 
set_property PACKAGE_PIN D9   [get_ports {ddrDq[36]}] 
set_property PACKAGE_PIN C9   [get_ports {ddrDq[37]}] 
set_property PACKAGE_PIN E10  [get_ports {ddrDq[38]}] 
set_property PACKAGE_PIN D10  [get_ports {ddrDq[39]}] 
set_property PACKAGE_PIN J9   [get_ports {ddrDq[40]}] 
set_property PACKAGE_PIN H9   [get_ports {ddrDq[41]}] 
set_property PACKAGE_PIN J8   [get_ports {ddrDq[42]}] 
set_property PACKAGE_PIN H8   [get_ports {ddrDq[43]}] 
set_property PACKAGE_PIN G9   [get_ports {ddrDq[44]}] 
set_property PACKAGE_PIN F9   [get_ports {ddrDq[45]}] 
set_property PACKAGE_PIN G10  [get_ports {ddrDq[46]}] 
set_property PACKAGE_PIN F10  [get_ports {ddrDq[47]}] 
set_property PACKAGE_PIN H12  [get_ports {ddrDq[48]}] 
set_property PACKAGE_PIN G12  [get_ports {ddrDq[49]}] 
set_property PACKAGE_PIN K11  [get_ports {ddrDq[50]}] 
set_property PACKAGE_PIN J11  [get_ports {ddrDq[51]}] 
set_property PACKAGE_PIN L12  [get_ports {ddrDq[52]}] 
set_property PACKAGE_PIN K12  [get_ports {ddrDq[53]}] 
set_property PACKAGE_PIN J13  [get_ports {ddrDq[54]}] 
set_property PACKAGE_PIN H13  [get_ports {ddrDq[55]}] 
set_property PACKAGE_PIN C12  [get_ports {ddrDq[56]}] 
set_property PACKAGE_PIN B12  [get_ports {ddrDq[57]}] 
set_property PACKAGE_PIN C11  [get_ports {ddrDq[58]}] 
set_property PACKAGE_PIN B11  [get_ports {ddrDq[59]}] 
set_property PACKAGE_PIN A13  [get_ports {ddrDq[60]}] 
set_property PACKAGE_PIN A12  [get_ports {ddrDq[61]}] 
set_property PACKAGE_PIN D13  [get_ports {ddrDq[62]}] 
set_property PACKAGE_PIN C13  [get_ports {ddrDq[63]}] 
set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrDq[*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrDq[*]}]
set_property SLEW          FAST           [get_ports {ddrDq[*]}]
set_property IBUF_LOW_PWR  FALSE          [get_ports {ddrDq[*]}]
set_property ODT           RTT_40         [get_ports {ddrDq[*]}]

set_property PACKAGE_PIN H27 [get_ports {ddrA[0]}] 
set_property PACKAGE_PIN G27 [get_ports {ddrA[1]}] 
set_property PACKAGE_PIN G25 [get_ports {ddrA[2]}] 
set_property PACKAGE_PIN G26 [get_ports {ddrA[3]}] 
set_property PACKAGE_PIN K26 [get_ports {ddrA[4]}] 
set_property PACKAGE_PIN K27 [get_ports {ddrA[5]}] 
set_property PACKAGE_PIN J26 [get_ports {ddrA[6]}] 
set_property PACKAGE_PIN H26 [get_ports {ddrA[7]}] 
set_property PACKAGE_PIN J23 [get_ports {ddrA[8]}] 
set_property PACKAGE_PIN H24 [get_ports {ddrA[9]}] 
set_property PACKAGE_PIN M27 [get_ports {ddrA[10]}] 
set_property PACKAGE_PIN L27 [get_ports {ddrA[11]}] 
set_property PACKAGE_PIN L23 [get_ports {ddrA[12]}] 
set_property PACKAGE_PIN L24 [get_ports {ddrA[13]}] 
set_property PACKAGE_PIN L25 [get_ports {ddrA[14]}] 
set_property PACKAGE_PIN K25 [get_ports {ddrA[15]}]
set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrA[*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrA[*]}]
set_property SLEW FAST                    [get_ports {ddrA[*]}]

set_property PACKAGE_PIN L22 [get_ports {ddrBa[0]}] 
set_property PACKAGE_PIN K23 [get_ports {ddrBa[1]}] 
set_property PACKAGE_PIN M25 [get_ports {ddrBa[2]}] 
set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrBa[*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrBa[*]}]
set_property SLEW FAST                    [get_ports {ddrBa[*]}]

set_property PACKAGE_PIN M26 [get_ports {ddrCsL[0]}] 
set_property PACKAGE_PIN R21 [get_ports {ddrCsL[1]}] 
set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrCsL[*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrCsL[*]}]
set_property SLEW FAST                    [get_ports {ddrCsL[*]}]

set_property PACKAGE_PIN M24 [get_ports {ddrOdt[0]}] 
set_property PACKAGE_PIN R22 [get_ports {ddrOdt[1]}] 
set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrOdt[*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrOdt[*]}]
set_property SLEW FAST                    [get_ports {ddrOdt[*]}]

set_property PACKAGE_PIN N24 [get_ports {ddrCke[0]}] 
set_property PACKAGE_PIN P23 [get_ports {ddrCke[1]}] 
set_property IOSTANDARD SSTL15_DCI        [get_ports {ddrCke[*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrCke[*]}]
set_property SLEW FAST                    [get_ports {ddrCke[*]}]

set_property PACKAGE_PIN J24 [get_ports {ddrCkP[0]}] 
set_property PACKAGE_PIN J25 [get_ports {ddrCkN[0]}] 
set_property PACKAGE_PIN R25 [get_ports {ddrCkP[1]}] 
set_property PACKAGE_PIN R26 [get_ports {ddrCkN[1]}] 
set_property IOSTANDARD DIFF_SSTL15_DCI   [get_ports {ddrCkP[*] ddrCkN[*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40  [get_ports {ddrCkP[*] ddrCkN[*]}]
set_property SLEW FAST                    [get_ports {ddrCkP[*] ddrCkN[*]}]

set_property -dict { PACKAGE_PIN T24 IOSTANDARD SSTL15_DCI OUTPUT_IMPEDANCE RDRV_40_40 SLEW FAST } [get_ports {ddrRasL}] 
set_property -dict { PACKAGE_PIN T25 IOSTANDARD SSTL15_DCI OUTPUT_IMPEDANCE RDRV_40_40 SLEW FAST } [get_ports {ddrCasL}] 
set_property -dict { PACKAGE_PIN T27 IOSTANDARD SSTL15_DCI OUTPUT_IMPEDANCE RDRV_40_40 SLEW FAST } [get_ports {ddrWeL}] 

set_property -dict { PACKAGE_PIN N23 IOSTANDARD SSTL15     OUTPUT_IMPEDANCE RDRV_48_48 SLEW SLOW } [get_ports {ddrRstL}] 
set_property -dict { PACKAGE_PIN P21 IOSTANDARD LVCMOS15 } [get_ports {ddrPwrEnL}] 
set_property -dict { PACKAGE_PIN P20 IOSTANDARD LVCMOS15 } [get_ports {ddrAlertL}] 
set_property -dict { PACKAGE_PIN N22 IOSTANDARD LVCMOS15 } [get_ports {ddrPg}] 
