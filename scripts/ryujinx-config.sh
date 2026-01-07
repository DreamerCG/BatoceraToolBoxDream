#!/bin/bash
# Common Pre-Settings
source /userdata/system/switch/bsa-pre-common.sh

# Ryujinx specific fixes
/userdata/system/switch/bin/ryujinx-fixes.sh

# Run Ryujinx
/userdata/system/switch/ryujinx/Ryujinx.AppImage
