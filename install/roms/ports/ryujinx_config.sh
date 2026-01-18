#!/bin/bash

export XDG_MENU_PREFIX=batocera-
export XDG_CONFIG_DIRS=/etc/xdg
export XDG_CACHE_HOME=/tmp/xdg_cache
export XDG_DATA_HOME=/userdata/system/configs
export XDG_CONFIG_HOME=/userdata/system/configs
export XDG_CACHE_HOME=/userdata/system/configs
export QT_QPA_PLATFORM_PLUGIN_PATH=${QT_PLUGIN_PATH}
export QT_QPA_PLATFORM=xcb
export DRI_PRIME=1
export AMD_VULKAN_ICD=RADV
export DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1=1
export QT_XKB_CONFIG_ROOT=/usr/share/X11/xkb
export NO_AT_BRIDGE=1
export XDG_MENU_PREFIX=batocera-
export XDG_CONFIG_DIRS=/etc/xdg
export XDG_CURRENT_DESKTOP=XFCE
export DESKTOP_SESSION=XFCE
export QT_FONT_DPI=96
export QT_SCALE_FACTOR=1
export GDK_SCALE=1

export SDL_JOYSTICK_HIDAPI=1
export SDL_JOYSTICK_HIDAPI_XBOX=0
export SDL_JOYSTICK_HIDAPI_XBOX_ONE=0
export SDL_JOYSTICK_HIDAPI_SWITCH=0
export SDL_JOYSTICK_HIDAPI_STEAMDECK=0

batocera-mouse show

# Lancement du script de préparation Ryujinx
PY_SCRIPT="/userdata/system/switch/configgen/generators/RyujinxFirmwareLoad.py"

if [ -x "$PY_SCRIPT" ]; then
    echo "[INFO] Préparation Ryujinx (keys + NCA)..."
    python3 "$PY_SCRIPT" || {
        echo "[ERROR] Échec du script Python, abandon du lancement Ryujinx"
        exit 1
    }
else
    echo "[WARN] Script Python introuvable ou non exécutable : $PY_SCRIPT"
fi

cd /userdata/system/switch/appimages/
chmod +x /userdata/system/switch/appimages/*.AppImage 2>/dev/null
./ryujinx-emu.AppImage
batocera-mouse hide




