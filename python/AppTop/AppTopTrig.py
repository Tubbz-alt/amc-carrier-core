#!/usr/bin/env python
#-----------------------------------------------------------------------------
# Title      : PyRogue Common Application Top Level Trigger Module
#-----------------------------------------------------------------------------
# File       : AppTopTrig.py
# Created    : 2017-04-04
#-----------------------------------------------------------------------------
# Description:
# PyRogue Common Application Top Level Trigger Module
#-----------------------------------------------------------------------------
# This file is part of the rogue software platform. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the rogue software platform, including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue as pr

from LclsTimingCore.LclsTriggerPulse import *
from LclsTimingCore.EvrV1Reg import *
from LclsTimingCore.EvrV1Isr import *

class AppTopTrig(pr.Device):
    def __init__(   self, 
                    name         = "AppTopTrig", 
                    description  = "Common Application Top Level Trigger Module", 
                    memBase      =  None, 
                    offset       =  0x0, 
                    hidden       =  False, 
                    numTrigPulse =  1,
                    expand      =  True,
                ):
        super(self.__class__, self).__init__(name, description, memBase, offset, hidden, expand=expand)

        ##############################
        # Variables
        ##############################

        digits = len(str(abs(numTrigPulse-1))) 
        for i in range(numTrigPulse):
            self.add(LclsTriggerPulse(
                                    name         = "LclsTriggerPulse_%.*i" % (digits, i),
                                    offset       =  0x00000000 + (i * 0x00001000),
                                ))

        self.add(EvrV1Reg(
                                offset       =  0x01000000,
                            ))

        self.add(EvrV1Isr(
                                offset       =  0x02000000,
                            ))