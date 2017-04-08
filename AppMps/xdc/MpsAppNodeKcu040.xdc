##############################################################################
## This file is part of 'LCLS2 Common Carrier Core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'LCLS2 Common Carrier Core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

################################
## Area/Placement Constraints ##
################################

set_property LOC MMCME3_ADV_X1Y0 [get_cells {U_Core/U_AppMps/U_Clk/U_ClkManagerMps/MmcmGen.U_Mmcm}]

set_property LOC BUFGCE_X1Y20 [get_cells {U_Core/U_AppMps/U_Clk/U_ClkManagerMps/ClkOutGen[0].U_Bufg}]
set_property LOC BUFGCE_X1Y6  [get_cells {U_Core/U_AppMps/U_Clk/U_ClkManagerMps/ClkOutGen[1].U_Bufg}]
set_property LOC BUFGCE_X1Y4  [get_cells {U_Core/U_AppMps/U_Clk/U_ClkManagerMps/ClkOutGen[2].U_Bufg}]
set_property LOC BUFGCE_X1Y14 [get_cells {U_Core/U_AppMps/U_Clk/U_ClkManagerMps/FbBufgGen.U_Bufg}]
set_property LOC BUFGCE_X1Y0  [get_cells {U_Core/U_AppMps/U_Clk/U_ClkManagerMps/InputBufgGen.U_Bufg}]

set_property LOC HRIODIFFOUTBUF_X0Y0 [get_cells {U_Core/U_AppMps/U_Salt/APP_SLOT.U_SaltUltraScale/TX_ONLY.U_SaltUltraScaleCore/U0/lvds_transceiver_mw/serdes_10_to_1_ser8_i/io_data_out}]
set_property LOC BITSLICE_RX_TX_X1Y0 [get_cells {U_Core/U_AppMps/U_Salt/APP_SLOT.U_SaltUltraScale/TX_ONLY.U_SaltUltraScaleCore/U0/lvds_transceiver_mw/serdes_10_to_1_ser8_i/oserdes_m}]

##########################
## Misc. Configurations ##
##########################

