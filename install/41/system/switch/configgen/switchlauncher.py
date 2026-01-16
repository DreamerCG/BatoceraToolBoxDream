#!/usr/bin/python
# -*- coding: utf-8 -*-
import re
import sys
from importlib import import_module

import configgen
from configgen.emulatorlauncher import launch

def _new_get_generator(emulator: str):
    
    yuzuemu = {}
    yuzuemu['eden-emu'] = 1
    yuzuemu['citron-emu'] = 1
    yuzuemu['eden-pgo'] = 1

    if emulator in yuzuemu:
        from generators.edenGenerator import EdenGenerator
        return EdenGenerator()

    if emulator == 'ryujinx-emu':
        from generators.ryujinxGenerator import RyujinxGenerator
        return RyujinxGenerator()

    #fallback to batocera generators
    return get_generator(emulator)

#configgen.Emulator._load_system_config = _new_load_system_config
configgen.emulatorlauncher.get_generator = _new_get_generator

if __name__ == "__main__":
    sys.argv[0] = re.sub(r"(-script\.pyw|\.exe)?$", "", sys.argv[0])
    sys.exit(launch())