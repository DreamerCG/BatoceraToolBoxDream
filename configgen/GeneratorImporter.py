from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from generators.Generator import Generator

# not the nicest way, possibly one of the faster i think
# some naming rules may allow to modify this function to less than 10 lines

def get_generator(emulator: str) -> Generator:

    if emulator == 'eden':
        from generators.edenGenerator import EdenGenerator
        return EdenGenerator()
    
    if emulator == 'citron':
        from generators.citronGenerator import CitronGenerator
        return CitronGenerator()

    if emulator == 'sudachi':
        from generators.sudachiGenerator import SudachiGenerator
        return SudachiGenerator()

    if emulator == 'yuzu':
        from generators.yuzuGenerator import YuzuGenerator
        return YuzuGenerator()

    if emulator == 'ryujinx':
        from generators.ryujinxGenerator import RyujinxGenerator
        return RyujinxGenerator()

    raise Exception(f"no generator found for emulator {emulator}")
