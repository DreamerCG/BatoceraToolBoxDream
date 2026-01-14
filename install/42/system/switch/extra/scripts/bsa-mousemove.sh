#!/bin/bash
# batocera-switch-mousemove.sh 
# modified for BSA
##################################################

# get screen resolution 
r=$(xrandr | grep "+" | awk '{print $1}' | tail -n1)
w=$(echo "$r" | cut -d "x" -f1)
h=$(echo "$r" | cut -d "x" -f2)


# prepare dependencies
if [[ ":$PATH:" != *":/userdata/system/switch/bin:"* ]]; then
	export PATH="/userdata/system/switch/bin:$PATH"
fi
if [[ ":$LD_LIBRARY_PATH:" != *":/userdata/system/switch/lib:"* ]]; then
	export LD_LIBRARY_PATH="/userdata/system/switch/lib:$LD_LIBRARY_PATH"
fi

 
# move mouse cursor to bottom right corner
if [[ "$w" =~ ^[1-9][0-9]{2,}$ ]] && [[ "$h" =~ ^[1-9][0-9]{2,}$ ]]; then
	xdotool mousemove --sync $w $h 2>/dev/null
else 
	xdotool mousemove --sync 0 0 2>/dev/null
fi
