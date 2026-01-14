#!/bin/bash
if test -z "${DISPLAY}"
then
    export DISPLAY=:0.0
fi

if [[ ":$PATH:" != *":/userdata/system/switch/bin:"* ]]; then
	export PATH="/userdata/system/switch/bin:$PATH"
fi
if [[ ":$LD_LIBRARY_PATH:" != *":/userdata/system/switch/lib:"* ]]; then
	export LD_LIBRARY_PATH="/userdata/system/switch/lib:$LD_LIBRARY_PATH"
fi

export XDG_CONFIG_HOME="/userdata/system/configs"
export XDG_DATA_HOME="/userdata/system/configs"
export XDG_CACHE_HOME="/userdata/system/cache"
export XDG_MENU_PREFIX=batocera-
export XDG_CONFIG_DIRS=/etc/xdg
export XDG_CURRENT_DESKTOP=XFCE
export DESKTOP_SESSION=XFCE
export QT_QPA_PLATFORM="xcb"
