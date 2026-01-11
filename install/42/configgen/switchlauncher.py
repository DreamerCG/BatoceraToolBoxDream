#!/usr/bin/python
# -*- coding: utf-8 -*-
import re
import sys
import yaml

from importlib import import_module
import configgen
from configgen.Emulator import Emulator, _dict_merge, _load_defaults
from configgen.emulatorlauncher import launch
from configgen.generators import get_generator
from typing import TYPE_CHECKING, Any
from pathlib import Path

def _new_get_generator(emulator: str):
    
    SwitchEmu = {}
    SwitchEmu['citron-emu'] = 1
    SwitchEmu['eden-emu'] = 1

    if emulator in SwitchEmu:
        from generators.yuzuMainlineGenerator import YuzuMainlineGenerator
        return YuzuMainlineGenerator()

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