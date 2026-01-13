#!/bin/bash
# Common Pre-Settings
source /userdata/system/switch/bsa-pre-common.sh

batocera-mouse show

/userdata/system/switch/bin/bsa-mousemove.sh

# SETUP LOGS
mkdir -p /userdata/system/switch/logs 2>/dev/null 
log1=/userdata/system/switch/logs/citron-out.txt 2>/dev/null 
log2=/userdata/system/switch/logs/citron-err.txt 2>/dev/null 
rm $log1 2>/dev/null && rm $log2 2>/dev/null 

# LAUNCH ROM
ulimit -H -n 819200; ulimit -S -n 819200; ulimit -S -n 819200 citron;
ulimit -H -n 819200; ulimit -S -n 819200; ulimit -S -n 819200 citron.AppImage;
rom="$(echo "$@" | sed 's,-f -g ,,g')"
if [[ "$rom" = "" ]]; then
	# if no rom then launch emulator
	/userdata/system/switch/emulateur/citron.AppImage -f -g > >(tee "$log1") 2> >(tee "$log2" >&2)
else
	# Convert ROM as needed
    echo "$rom" > /tmp/switchromname 2>/dev/null
	/userdata/system/switch/bin/bsa-nsz-converter.sh
	rom="$(cat /tmp/switchromname)"
	# Run ROM
	/userdata/system/switch/emulateur/citron.AppImage -f -g "$rom" 1>"$log1" 2>"$log2"
fi

batocera-mouse hide
