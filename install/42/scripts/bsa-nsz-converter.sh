#!/bin/bash
# batocera-switch nsz-converter
# ******************************************************************************
# MODIFIED FOR BSA
# ******************************************************************************


# ******************************************************************************
# CHECK IF NSZ CONVERTER IS INSTALLED, IF NOT INSTALL IT
# ******************************************************************************
if [[ "$(which nsz | head -n 1 | grep "not found")" != "" ]] || [[ "$(which nsz | head -n 1)" = "" ]]; then 
	echo -e "╔═════════════════════════════════════════════╗ "
	echo -e "║ PREPARING NSZ & XCZ CONVERTER . . .         ║ "
	echo -e "╚═════════════════════════════════════════════╝ "
	echo
	echo
	python -m ensurepip --default-pip 1>/dev/null 2>/dev/null 
	python -m pip install --upgrade pip 1>/dev/null 2>/dev/null 
	python -m pip install --upgrade --force-reinstall pycryptodome 1>/dev/null 2>/dev/null 
	python -m pip install --upgrade --force-reinstall nsz 1>/dev/null 2>/dev/null 
	wait
	sleep 0.1
fi


# ******************************************************************************
# GET ROM NAME FROM COOKIE FILE
# ******************************************************************************
rom="$(cat /tmp/switchromname)"
# Extract extension
ext="$(echo "$rom" | rev | cut -c 1-4 | rev)"
# Convert extension to lowercase
ext="${ext,,}"


# ******************************************************************************
# BASED ON EXTENSION :: CONVERT NSZ TO NSP OR XCZ TO XCI
# ******************************************************************************
if [[ "$ext" = ".nsz" || "$ext" = ".xcz" ]]; then 
	echo -e "╔═════════════════════════════════════════════╗ "
	if [[ "$ext" = ".nsz" ]]; then 
		echo -e "║ CONVERTING NSZ TO NSP . . .                 ║ "
	elif [[ "$ext" = ".xcz" ]]; then
		echo -e "║ CONVERTING XCZ TO XCI . . .                 ║ "
	fi
	echo -e "╚═════════════════════════════════════════════╝ "
	echo
	echo

	# fill dependencies 
	chmod a+x /userdata/system/switch/bin/nsz/lib-dynload/*.so 2>/dev/null

	# for python 3.11
	if [[ -d "/usr/lib/python3.11" ]]; then 
		cp -r /userdata/system/switch/bin/nsz/curses /usr/lib/python3.11/site-packages/ 2>/dev/null
		cp /userdata/system/switch/bin/nsz/lib-dynload/_curses.cpython-310-x86_64-linux-gnu.so /usr/lib/python3.11/lib-dynload/_curses.cpython-311-x86_64-linux-gnu.so
		cp /userdata/system/switch/bin/nsz/lib-dynload/_curses_panel.cpython-310-x86_64-linux-gnu.so /usr/lib/python3.11/lib-dynload/_curses_panel.cpython-311-x86_64-linux-gnu.so
	fi

	# for python 3.10
	if [[ -d "/usr/lib/python3.10" ]]; then 
		cp -r /userdata/system/switch/bin/nsz/curses /usr/lib/python3.10/site-packages/ 2>/dev/null
		cp /userdata/system/switch/bin/nsz/lib-dynload/_curses.cpython-310-x86_64-linux-gnu.so /usr/lib/python3.10/lib-dynload/_curses.cpython-310-x86_64-linux-gnu.so
		cp /userdata/system/switch/bin/nsz/lib-dynload/_curses_panel.cpython-310-x86_64-linux-gnu.so /usr/lib/python3.10/lib-dynload/_curses_panel.cpython-310-x86_64-linux-gnu.so
	fi

	# fill user keys 
	cp /userdata/bios/switch/prod.keys /usr/bin/keys.txt 2>/dev/null

	# run conversion  
	sleep 0.5 && nsz -D -w -t 4 -P "$rom" 
	wait
	echo -e "╔═════════════════════════════════════════════╗ "
	if [[ "$ext" = ".nsz" ]]; then 
		echo -e "║ FINISHED CONVERTING TO NSP                  ║ "
	elif [[ "$ext" = ".xcz" ]]; then
		echo -e "║ FINISHED CONVERTING TO XCZ                  ║ "
	fi
	echo -e "╚═════════════════════════════════════════════╝ "
	sleep 0.5 					

	# remove ROM file 
	#rm -rf "$rom" 2>/dev/null
	# reload games
	curl http://127.0.0.1:1234/reloadgames 

	# pass the ROM cookie for launcher & emulator 
	if [[ "$ext" = ".nsz" ]]; then 
		rompath="$(dirname "$rom")"
		romname="$(basename "$rom" ".nsz")"
		rom="$rompath/$romname.nsp"
	elif [[ "$ext" = ".xcz" ]]; then
		rompath="$(dirname "$rom")"
		romname="$(basename "$rom" ".xcz")"
		rom="$rompath/$romname.xci"
	fi
	echo "$rom" > /tmp/switchromname 

fi 

exit 0
