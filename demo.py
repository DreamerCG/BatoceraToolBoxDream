PYSDL2_DLL_PATH=/usr/lib python3 - <<'EOF'
import sdl2, sys
print("SDL version:", sdl2.SDL_GetRevision().decode())
print("Joystick count:", sdl2.SDL_NumJoysticks())
for i in range(sdl2.SDL_NumJoysticks()):
    print(i, sdl2.SDL_JoystickNameForIndex(i))
EOF