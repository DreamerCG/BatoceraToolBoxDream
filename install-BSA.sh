#!/usr/bin/env bash
# BATOCERA - SWITCH ADD-ON
TERM=xterm clear > /dev/tty 2>/dev/null || printf "\033c" > /dev/tty

set -e
trap 'rm -f "$temp_file"' EXIT

echo "BATOCERA - SWITCH ADD-ON"
echo ""
echo "Attempting to Install BSA ..."

(
	url="https://github.com/DreamerCG/BatoceraToolBoxDream/archive/refs/tags/main.tar.gz"
	
	BSA_path="/userdata/BSA_BETA"

	# Retrieve and Extract BSA to /userdata/BSA (will overwrite)
	temp_file=$(mktemp) || { echo "ERROR: Failed to create temp file"; exit 1; }
	wget --quiet --show-progress --progress=bar:force:noscroll \
		--tries=10 --timeout=30 --waitretry=3 \
		--no-check-certificate --no-cache --no-cookies \
		-O "$temp_file" \
		"$url"
	[[ -n "$BSA_path" ]] && rm -rf "$BSA_path"
	mkdir -p "$BSA_path"
	tar -xzf "$temp_file" -C "$BSA_path" --strip-components=1
	rm -f "$temp_file"

	# Make BSA executable
	cd "$BSA_path" || { echo "ERROR: Extraction failed, $BSA_path directory not found"; exit 1; }
	dos2unix BSA.sh 
	chmod a+x BSA.sh
)

 
echo "Installation de BSA_TOOLBOX dans Ports..."
sleep 3
# Add bsa-switch-tools.sh to "ports"
curl -L https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/refs/heads/main/ports_install/bsa-switch-tools.sh -o /userdata/roms/ports/bsa-switch-tools_beta.sh

# Add bsa-switch-tools.keys to "ports"
curl -L  https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/refs/heads/main/ports_install/bsa-switch-tools.sh.keys -o /userdata/roms/ports/bsa-switch-tools_beta.sh.keys

# Set execute permissions for the downloaded scripts
chmod +x /userdata/roms/ports/bsa-switch-tools_beta.sh


echo "BSA Installed!"
echo ""
echo "*** Remember to place your files in the appropriate BSA folders before installing ***"
echo ""
echo "Usage:"
echo "	cd /userdata/BSA"
echo "	./BSA.sh"
echo ""
