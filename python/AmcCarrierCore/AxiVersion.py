#!/usr/bin/env python
#-----------------------------------------------------------------------------
# Title      : PyRogue AXI Version Module
#-----------------------------------------------------------------------------
# File       : AxiVersion.py
# Author     : Jesus Vasquez, jvasquez@slac.stanford.edu
# Created    : 2017-02-24
# Last update: 2017-02-24
#-----------------------------------------------------------------------------
# Description:
# PyRogue AXI Version Module
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

class AxiVersion(pr.Device):
    def __init__(self, name="AxiVersion", memBase=None, offset=0, hidden=False):
        super(self.__class__, self).__init__(name, "Axi-Lite based commonn version block", memBase, offset, hidden)

        ##############################
        # Variables
        ##############################

        self.add(pr.Variable(   name         = 'fpgaVersion',
                                description  = 'FPGA Firmware Version Number',
                                offset       = 0x000,
                                bitSize      = 32,
                                bitOffset    = 0,
                                base         = 'hex',
                                mode         = 'RO'
                            ))

        self.add(pr.Variable(   name         = 'scratchPad',
                                description  = 'Register to test read and writes',
                                offset       = 0x004,
                                bitSize      = 32,
                                bitOffset    = 0,
                                base         = 'hex',
                                mode         = 'RW'
                            ))

        self.add(pr.Variable(   name         = 'upTimeCnt',
                                description  = 'Number of seconds since reset',
                                offset       = 0x008,
                                bitSize      = 32,
                                bitOffset    = 0,
                                base         = 'uint',
                                mode         = 'RO',
                                pollInterval = 1,
                                units        = "seconds"
                            ))

        self.add(pr.Variable(   name         = 'fpgaReloadHalt',
                                description  = 'Used to halt automatic reloads via AxiVersion',
                                offset       = 0x100,
                                bitSize      = 1,
                                bitOffset    = 0,
                                base         = 'bool',
                                mode         = 'RW'
                            ))

        self.add(pr.Variable(   name         = 'fpgaReloadVar',
                                description  = 'Optional reload the FPGA from the attached PROM',
                                offset       = 0x104,
                                bitSize      = 1,
                                bitOffset    = 0,
                                base         = 'bool',
                                mode         = 'SL',
                                hidden       = True
                            ))

        self.add(pr.Variable(   name         = 'fpgaReloadAddress',
                                description  = 'Reload start address',
                                offset       = 0x108,
                                bitSize      = 32,
                                bitOffset    = 0,
                                base         = 'hex',
                                mode         = 'RW'
                            ))

        self.add(pr.Variable(   name         = 'masterResetVar',
                                description  = 'Optional User Reset',
                                offset       = 0x10C,
                                bitSize      = 1,
                                bitOffset    = 0,
                                base         = 'bool',
                                mode         = 'SL',
                                hidden       = True
                            ))

        self.add(pr.Variable(   name         = 'fdValue',
                                description  = 'Board ID value read from DS2411 chip',
                                offset       = 0x300,
                                bitSize      = 64,
                                bitOffset    = 0,
                                base         = 'hex',
                                mode         = 'RO'
                            ))  

        self.add(pr.Variable(   name         = 'deviceId',
                                description  = 'Device identification',
                                offset       = 0x500,
                                bitSize      = 32,
                                bitOffset    = 0,
                                base         = 'hex',
                                mode         = 'RO'
                            ))
        
        self.add(pr.Variable(   name         = 'gitHash',
                                description  = 'GIT SHA-1 Hash',
                                offset       = 0x600,
                                bitSize      = 160,
                                bitOffset    = 0,
                                base         = 'hex',
                                mode         = 'RO'
                            ))

        self.add(pr.Variable(   name         = 'deviceDna',
                                description  = 'Xilinx Device DNA value burned into FPGA',
                                offset       = 0x700,
                                bitSize      = 128,
                                bitOffset    = 0,
                                base         = 'hex',
                                mode         = 'RO'
                            ))
        
        self.add(pr.Variable(   name         = 'buildStamp',
                                description  = 'Firmware build string',
                                offset       = 0x800,
                                bitSize      = 256*8,
                                bitOffset    = 0,
                                base         = 'string',
                                mode         = 'RO'
                            ))

        ##############################
        # Commands
        ##############################

        self.add(pr.Command(    name         = 'masterReset',
                                description  = 'Master Reset',
                                function     = 'self.parent.masterResetVar.post(1)'
                            ))

        self.add(pr.Command(    name         = 'fpgaReload',
                                description  = 'Reload FPGA',
                                function     = 'self.fpgaReloadVar.post(1)'
                            ))
