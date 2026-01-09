#!/usr/bin/env bash
# BATOCERA - SWITCH ADD-ON
TERM=xterm clear > /dev/tty 2>/dev/null || printf "\033c" > /dev/tty

set -e
trap 'rm -f "$temp_file"' EXIT

echo "BATOCERA - SWITCH ADD-ON"
echo ""
echo "Attempting to Install BSA ..."

# Récupération de la version principale de Batocera
version=$(batocera-es-swissknife --version | grep -oE '^[0-9]+')

echo "Detected Batocera version: $version"


# Vérification que la version est bien un nombre
if [[ -z "$version" ]]; then
    dialog --msgbox "Impossible de détecter une version valide de Batocera. Installation annulée." 8 60
    clear
    exit 1
fi
