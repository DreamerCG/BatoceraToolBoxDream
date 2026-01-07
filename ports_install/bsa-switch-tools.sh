#!/bin/bash

echo "Add script to temp then execute"

export DISPLAY=:0.0

xterm -hold \
  -bg black \
  -fa "DejaVuSansMono" \
  -fs 12 \
  -en UTF-8 \
  -e "cd /userdata/BSA && ./BSA.sh"
