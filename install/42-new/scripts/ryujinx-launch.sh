#!/bin/bash
# Common Pre-Settings
source /userdata/system/switch/bsa-pre-common.sh

# Ryujinx specific fixes
/userdata/system/switch/bin/ryujinx-fixes.sh

batocera-mouse show

/userdata/system/switch/bin/bsa-mousemove.sh

# SETUP LOGS
mkdir -p /userdata/system/switch/logs 2>/dev/null 
log1=/userdata/system/switch/logs/Ryujinx-out.txt 2>/dev/null 
log2=/userdata/system/switch/logs/Ryujinx-err.txt 2>/dev/null 
rm $log1 2>/dev/null && rm $log2 2>/dev/null 

# LAUNCH ROM
ulimit -H -n 819200; ulimit -S -n 819200; ulimit -S -n 819200 Ryujinx;
ulimit -H -n 819200; ulimit -S -n 819200; ulimit -S -n 819200 Ryujinx.AppImage;
rom="$1"
if [[ "$rom" = "" ]]; then
	/userdata/system/switch/emulateur/Ryujinx.AppImage > >(tee "$log1") 2> >(tee "$log2" >&2)
else
	# Convert ROM as needed
    echo "$rom" > /tmp/switchromname 2>/dev/null
	/userdata/system/switch/bin/bsa-nsz-converter.sh
	rom="$(cat /tmp/switchromname)"
	# Run ROM
	/userdata/system/switch/emulateur/Ryujinx.AppImage "$rom" > >(tee "$log1") 2> >(tee "$log2" >&2) 
fi 

batocera-mouse hide
