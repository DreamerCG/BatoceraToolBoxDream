#!/usr/bin/python
# -*- coding: utf-8 -*-
import re
import sys
import os

from importlib import import_module

# Fichiers à vérifier
paths_to_check = ["/usr/lib/libSDL3.so", "/usr/lib/libSDL3.so.0"]
target_lib = "/userdata/system/switch/lib/libSDL3.so.0.2.26"

for path in paths_to_check:
    if not os.path.exists(path):
        # Supprime le symlink si il existe mais est cassé
        if os.path.islink(path):
            os.unlink(path)
        # Création du symlink
        os.symlink(target_lib, path)
        print(f"Symlink créé : {path} -> {target_lib}")
    else:
        print(f"{path} existe déjà.")


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