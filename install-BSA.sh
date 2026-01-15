#!/usr/bin/env bash
# BATOCERA - SWITCH ADD-ON
TERM=xterm clear > /dev/tty 2>/dev/null || printf "\033c" > /dev/tty


trap 'rm -f "$temp_file"' EXIT

echo "BATOCERA - SWITCH ADD-ON"
echo ""
echo "Attempting to Install BSA ..."

# Récupération de la version principale de Batocera
version=$(batocera-es-swissknife --version | grep -oE '^[0-9]+')

# Vérification que la version est bien détectée
if [[ -z "$version" ]]; then
    echo "ERROR: Impossible de détecter une version valide de Batocera."
    echo "Installation annulée."
    exit 1
fi

# Vérification stricte : uniquement Batocera 43 autorisée
[[ "$version" =~ ^(41|42|43)$ ]] || {
    echo "ERROR: Batocera non supportée (détectée: $version)"
    echo "Versions supportées : 41, 42, 43"
    exit 1
}

echo "Batocera $version détectée — poursuite de l'installation."

set -e

# Download and Install BSA
(
	url="https://github.com/DreamerCG/BatoceraToolBoxDream/archive/refs/heads/main.tar.gz"

	BSA_path="/userdata/DreamerCGToolBox"

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
curl -L https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/refs/heads/main/install/roms/ports/bsa-switch-tools.sh -o /userdata/roms/ports/DreamerCGToolBox.sh

# Add bsa-switch-tools.keys to "ports"
curl -L  https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/refs/heads/main/install/roms/ports/bsa-switch-tools.sh.keys -o /userdata/roms/ports/DreamerCGToolBox.sh.keys

# Set execute permissions for the downloaded scripts
chmod +x /userdata/roms/ports/DreamerCGToolBox.sh

# Refresh the Ports menu
echo "Refreshing Ports menu..."
curl http://127.0.0.1:1234/reloadgames

# Add an entry to gamelist.xml#################################xmledit#########################################################
ports_dir="/userdata/roms/ports"
mkdir -p "$ports_dir"
echo "Ajout toolbox dans le gamelist.xml..."
gamelist_file="$ports_dir/gamelist.xml"
screenshot_url="https://github.com/DreamerCG/BatoceraToolBoxDream/raw/main/install/roms/ports/images/toolbox-image.png"
screenshot_path="$ports_dir/images/toolbox-image.png"
logo_url="https://github.com/DreamerCG/BatoceraToolBoxDream/raw/main/install/roms/ports/images/toolbox-logo.png"
logo_path="$ports_dir/images/toolbox-logo.png"
box_url="https://github.com/DreamerCG/BatoceraToolBoxDream/raw/main/install/roms/ports/images/toolbox-box.png"
box_path="$ports_dir/images/toolbox-box.png"
box_url="https://github.com/DreamerCG/BatoceraToolBoxDream/raw/main/install/roms/ports/images/yuzu_config.png"
box_path="$ports_dir/images/yuzu_config.png"
box_url="https://github.com/DreamerCG/BatoceraToolBoxDream/raw/main/install/roms/ports/images/ryujinx_config.png"
box_path="$ports_dir/images/ryujinx_config.png"

# Ensure the logo directory exists and download the logo
mkdir -p "$(dirname "$logo_path")"
curl -L -o "$logo_path" "$logo_url"
mkdir -p "$(dirname "$screenshot_path")"
curl -L -o "$screenshot_path" "$screenshot_url"
mkdir -p "$(dirname "$box_path")"
curl -L -o "$box_path" "$box_url"

# Ensure the gamelist.xml exists
if [ ! -f "$gamelist_file" ]; then
    echo '<?xml version="1.0" encoding="UTF-8"?><gameList></gameList>' > "$gamelist_file"
fi

# Installation de xmlstarlet si absent.
XMLSTARLET_DIR="/userdata/system/pro/extra"
XMLSTARLET_BIN="$XMLSTARLET_DIR/xmlstarlet"
XMLSTARLET_URL="https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/main/app/xmlstarlet"
XMLSTARLET_SYMLINK="/usr/bin/xmlstarlet"
CUSTOM_SH="/userdata/system/custom.sh"

if [ -f "$XMLSTARLET_BIN" ]; then
    echo -e "\e[1;34mXMLStarlet est déjà installé, passage à la suite...\e[1;37m"
else
    echo -e "\e[1;34mInstallation de XMLStarlet (pour l'édition du gamelist)...\e[1;37m"
    mkdir -p "$XMLSTARLET_DIR"

    echo "Téléchargement de XMLStarlet..."
    curl -# -L "$XMLSTARLET_URL" -o "$XMLSTARLET_BIN"

    echo "Rendre XMLStarlet exécutable..."
    chmod +x "$XMLSTARLET_BIN"

    echo "Création du lien symbolique dans /usr/bin/xmlstarlet pour un usage immédiat..."
    ln -sf "$XMLSTARLET_BIN" "$XMLSTARLET_SYMLINK"
    
    # Assure-toi que le fichier custom.sh existe
    if [ ! -f "$CUSTOM_SH" ]; then
        echo "#!/bin/bash" > "$CUSTOM_SH"
        chmod +x "$CUSTOM_SH"
    fi

    # Ajoute la création du lien symbolique au démarrage (si non déjà présent)
    if ! grep -q "ln -sf $XMLSTARLET_BIN $XMLSTARLET_SYMLINK" "$CUSTOM_SH"; then
        echo "ln -sf $XMLSTARLET_BIN $XMLSTARLET_SYMLINK" >> "$CUSTOM_SH"
    fi
fi

xmlstarlet ed -L \
    -s "/gameList" -t elem -n "game" -v "" \
    -s "/gameList/game[last()]" -t elem -n "path" -v "./DreamerCGToolBox.sh" \
    -s "/gameList/game[last()]" -t elem -n "name" -v "A Toolbox Switch" \
    -s "/gameList/game[last()]" -t elem -n "desc" -v "Boite à outils de DreamerCG permettant l'installation de la Switch " \
    -s "/gameList/game[last()]" -t elem -n "developer" -v "DreamerCG" \
    -s "/gameList/game[last()]" -t elem -n "publisher" -v "DreamerCG" \
    -s "/gameList/game[last()]" -t elem -n "genre" -v "Toolbox" \
    -s "/gameList/game[last()]" -t elem -n "rating" -v "1.00" \
    -s "/gameList/game[last()]" -t elem -n "region" -v "eu" \
    -s "/gameList/game[last()]" -t elem -n "lang" -v "fr" \
    -s "/gameList/game[last()]" -t elem -n "image" -v "./images/toolbox-image.png" \
    -s "/gameList/game[last()]" -t elem -n "marquee" -v "./images/toolbox-logo.png" \
    -s "/gameList/game[last()]" -t elem -n "thumbnail" -v "./images/toolbox-box.png" \
    "$gamelist_file"
# Add an entry to gamelist.xml#################################xmledit#########################################################


xmlstarlet ed -L \
    -s "/gameList" -t elem -n "game" -v "" \
    -s "/gameList/game[last()]" -t elem -n "path" -v "./yuzu_config.sh" \
    -s "/gameList/game[last()]" -t elem -n "name" -v "Configuration de Yuzu/Eden/Citron" \
    -s "/gameList/game[last()]" -t elem -n "desc" -v "Configuration de Yuzu/Eden/Citron" \
    -s "/gameList/game[last()]" -t elem -n "developer" -v "Yuzu" \
    -s "/gameList/game[last()]" -t elem -n "publisher" -v "Yuzu" \
    -s "/gameList/game[last()]" -t elem -n "genre" -v "Toolbox" \
    -s "/gameList/game[last()]" -t elem -n "rating" -v "1.00" \
    -s "/gameList/game[last()]" -t elem -n "region" -v "eu" \
    -s "/gameList/game[last()]" -t elem -n "lang" -v "fr" \
    -s "/gameList/game[last()]" -t elem -n "image" -v "./images/toolbox-image.png" \
    -s "/gameList/game[last()]" -t elem -n "marquee" -v "./images/toolbox-logo.png" \
    -s "/gameList/game[last()]" -t elem -n "thumbnail" -v "./images/yuzu_config.png" \
    "$gamelist_file"

# Refresh the Ports menu
echo "Refreshing Ports menu..."
curl http://127.0.0.1:1234/reloadgames

killall -9 emulationstation

sleep 1

echo "ToolBox Installed!"
echo "Launch DreamerCG ToolBox from the Ports menu."
echo ""
