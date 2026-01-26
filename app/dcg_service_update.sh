#!/usr/bin/env bash
# BATOCERA - SWITCH ADD-ON

LOG_DIR="/userdata/DreamerCGToolBox/logs"
LOG="$LOG_DIR/update_toolbox.log"

VERSION_FILE="/userdata/DreamerCGToolBox/configgen-version.txt"
VERSION_URL="https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/main/configgen-version.txt"

echo "[$(date)] Batocera Version   : $VERSION_URL"

# Récupération de la version principale de Batocera
batocera_version=$(batocera-es-swissknife --version | grep -oE '^[0-9]+')

set -u
unset folder_update_version || true

case "$batocera_version" in
	41)
		folder_update_version=41
		;;
	4[2-3])
		folder_update_version=42
		;;
	*)
		echo "Unsupported Batocera version: $batocera_version" >&2
		exit 1
		;;
esac


# Sécurité : création du dossier de logs AVANT toute redirection
mkdir -p "$LOG_DIR"

# Duplication sortie écran + log
exec > >(tee -a "$LOG") 2>&1

echo "[$(date)] ===== START TOOLBOX UPDATE ====="

# Version locale
if [ -f "$VERSION_FILE" ]; then
    toolbox_version_local="$(tr -d '\r\n' < "$VERSION_FILE")"
else
    toolbox_version_local="none"
fi

# Version distante
toolbox_download_version="$(curl -L "$VERSION_URL" | tr -d '\r\n')"

echo "[$(date)] Batocera Version   : $folder_update_version"
echo "[$(date)] Local Version   : $toolbox_version_local"
echo "[$(date)] Distant Version : $toolbox_download_version"

# Vérification et lecture de la version locale
if [ -f "$VERSION_FILE" ]; then
    toolbox_version_local=$(<"$VERSION_FILE")
else
    toolbox_version_local=""
fi

# Sécurité : si curl échoue
if [ -z "$toolbox_download_version" ]; then
    echo "[$(date)] ERREUR : impossible de récupérer la version distante"
    exit 1
fi

# Installation ou mise à jour
if [ "$toolbox_version_local" != "$toolbox_download_version" ]; then
    if [ -z "$toolbox_version_local" ]; then
        echo "[$(date)] Aucune version détectée, installation des configgens…"
    else
        echo "[$(date)] Mise à jour détectée ($toolbox_version_local → $toolbox_download_version)"
    fi
    echo "[$(date)] Lancement par précautions du téléchargement des configgen…"
    
    # Configuration des dossiers pour updates
    DIR_TOOLBOX="/userdata/DreamerCGToolBox/"
    DIR_EMULATIONSTATION="/userdata/system/configs/emulationstation"
    DIR_ROM_SWITCH="/userdata/roms/switch"
    DIR_ROM_PORT="/userdata/roms/ports"
    DIR_CONFIGGEN="/userdata/system/switch/configgen"
    DIR_GENERATOR="/userdata/system/switch/configgen/generators"

    # echo "[$(date)] DEBUG folder_version=$folder_update_version"

    URL_BASE="https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/main/install/$folder_update_version/system/switch/configgen/"
	URL_ROM_INSTALL="https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/main/install/roms/switch"
    URL_ROM_IMAGE_INSTALL="https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/main/install/roms/switch/images"


    mkdir -p "$DIR_TOOLBOX"
    mkdir -p "$DIR_CONFIGGEN"
    mkdir -p "$DIR_GENERATOR"

	echo "[$(date)] Configgen Local Dir   : $DIR_CONFIGGEN"
	echo "[$(date)] Generator Local Dir  : $DIR_GENERATOR"
	echo "[$(date)] Distant URL          : $URL_BASE"
    
    # Téléchargement des nouveaux fichiers
    curl -L "$URL_BASE/switchlauncher.py" -o "$DIR_CONFIGGEN/switchlauncher.py"
    echo "[$(date)] Mise à jour de switchlauncher"
    curl -L "$URL_BASE/generators/edenGenerator.py" -o "$DIR_GENERATOR/edenGenerator.py"
    echo "[$(date)] Mise à jour de EdenGenerator"
    curl -L "$URL_BASE/generators/ryujinxGenerator.py" -o "$DIR_GENERATOR/ryujinxGenerator.py"
    echo "[$(date)] Mise à jour de ryujinxGenerator"
    curl -L "https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/main/install/gamecontroller_ryujinx.txt" -o "$DIR_GENERATOR/gamecontroller_ryujinx.txt"
    echo "[$(date)] Mise à jour de Game Controller DB SDL"
    curl -L "https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/main/install/gamecontrollerdb.txt" -o "$DIR_CONFIGGEN/gamecontroller_ryujinx.txt"
    echo "[$(date)] Mise à jour de gamecontroller_ryujinx"
    curl -L "$URL_BASE/generators/ryujinxloadfirmware.sh" -o "$DIR_GENERATOR/ryujinxloadfirmware.sh"
    echo "[$(date)] Mise à jour de ryujinxloadfirmware"
    curl -L "$VERSION_URL" -o "$DIR_TOOLBOX/configgen-version.txt"
    echo "[$(date)] Mise à jour de configgen-version.txt"

    # Mise à jour du Switch Features
    curl -fL \
    "https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/main/install/$folder_update_version/system/configs/emulationstation/es_features_switch.cfg" \
    -o "$DIR_EMULATIONSTATION/es_features_switch.cfg"

    echo "[$(date)] Mise à jour de es_features_switch"

    # Mise à jour du Switch System
    curl -fL \
    "https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/main/install/$folder_update_version/system/configs/emulationstation/es_systems_switch.cfg" \
    -o "$DIR_EMULATIONSTATION/es_systems_switch.cfg"

    echo "[$(date)] Mise à jour de es_systems_switch"

    chmod a+x "$DIR_CONFIGGEN/switchlauncher.py"
    chmod a+x "$DIR_GENERATOR/edenGenerator.py"
    chmod a+x "$DIR_GENERATOR/ryujinxGenerator.py"
    chmod a+x "$DIR_GENERATOR/ryujinxloadfirmware.sh"

    #On Verifie si les roms suivants existe dans /userdata/roms/switch/


	gamelist_file="/userdata/roms/switch/gamelist.xml"
	# Ensure the gamelist.xml exists
	if [ ! -f "$gamelist_file" ]; then
		echo '<?xml version="1.0" encoding="UTF-8"?><gameList></gameList>' > "$gamelist_file"
	fi

    FILES=(
        "citron_config.xci_config"
        "eden_config.xci_config"
        "ryujinx_config.xci_config"
        "eden_qlaunch.xci_config"
    )


    # Noms personnalisés
    declare -A NOMS_PERSONNALISES
    NOMS_PERSONNALISES=(
        ["citron_config.xci_config"]="Configuration de Citron Toolbox"
        ["eden_config.xci_config"]="Configuration de Eden Toolbox"
        ["ryujinx_config.xci_config"]="Configuration de Ryujinx Toolbox"
        ["eden_qlaunch.xci_config"]="Eden QLauncher"
    )

# Boucle sur chaque fichier
for FILE in "${FILES[@]}"; do
    FILEPATH="$DIR_ROM_SWITCH/$FILE"
    URL="$URL_ROM_INSTALL/$FILE"
    BASENAME="${FILE%.*}"
    # Si un nom personnalisé existe, on le prend, sinon fallback sur BASENAME
    NOM="${NOMS_PERSONNALISES[$FILE]:-$BASENAME}"

    if [ -f "$FILEPATH" ]; then
        echo "[$(date)] Le fichier '$FILE' existe déjà, téléchargement ignoré."
    else
        echo "Téléchargement de '$FILE'..."
        curl -fsL "$URL" -o "$FILEPATH"
        if [ $? -eq 0 ]; then
            echo "[$(date)] Téléchargement de '$FILE' terminé avec succès."

            xmlstarlet ed -L \
                -d "/gameList/game[path='./$FILE']" \
                -s "/gameList" -t elem -n "game" -v "" \
                -s "/gameList/game[last()]" -t elem -n "path" -v "./$FILE" \
                -s "/gameList/game[last()]" -t elem -n "name" -v "$NOM" \
                -s "/gameList/game[last()]" -t elem -n "desc" -v "$NOM" \
                -s "/gameList/game[last()]" -t elem -n "developer" -v "$NOM" \
                -s "/gameList/game[last()]" -t elem -n "publisher" -v "$NOM" \
                -s "/gameList/game[last()]" -t elem -n "genre" -v "Toolbox" \
                -s "/gameList/game[last()]" -t elem -n "rating" -v "1.00" \
                -s "/gameList/game[last()]" -t elem -n "region" -v "eu" \
                -s "/gameList/game[last()]" -t elem -n "lang" -v "fr" \
                -s "/gameList/game[last()]" -t elem -n "image" -v "./images/$BASENAME-image.png" \
                -s "/gameList/game[last()]" -t elem -n "marquee" -v "./images/$BASENAME-logo.png" \
                -s "/gameList/game[last()]" -t elem -n "thumbnail" -v "./images/$BASENAME.png" \
                "$gamelist_file"

            echo "[$(date)] - Ajout de $NOM dans la game list $gamelist_file"
        else
            echo "[$(date)] Erreur lors du téléchargement de '$FILE' !"
        fi
    fi
done

# Ajout des images
    FILES_IMAGES=(
        "citron_config.png"
        "citron_config-logo.png"
        "citron_config-image.png"
        "eden_config.png"
        "eden_config-logo.png"
        "eden_config-image.png"
        "eden_qlaunch.png"
        "eden_qlaunch-logo.png"
        "eden_qlaunch-image.png"        
        "ryujinx_config.png"
        "ryujinx_config-logo.png"
        "ryujinx_config-image.png"
    )

    # Boucle sur chaque fichier
    for FILE in "${FILES_IMAGES[@]}"; do
        FILEPATH="$DIR_ROM_SWITCH/images/$FILE"
        URL="$URL_ROM_IMAGE_INSTALL/$FILE"

        if [ -f "$FILEPATH" ]; then
            echo "[$(date)]Le fichier '$FILE' existe déjà, téléchargement ignoré."
        else
            echo "[$(date)] Téléchargement de '$FILE'..."
            curl -fsL "$URL" -o "$FILEPATH"
            if [ $? -eq 0 ]; then
                echo "[$(date)] Téléchargement de '$FILE' terminé avec succès."
            else
                echo "[$(date)] Erreur lors du téléchargement de '$FILE' à partir de $URL  !"
            fi
        fi
    done

    # Suppression des anciens Ports Configs
    FILES_CONFIG_SH=(
        "ryujinx_config.sh"
        "ryujinx_config.sh.keys"
        "citron_config.sh"
        "citron_config.sh.keys"
        "yuzu_config.sh"
        "yuzu_config.sh.keys"
    )

    # Boucle sur chaque fichier
    for FILE in "${FILES_CONFIG_SH[@]}"; do
        FILEPATH="$DIR_ROM_PORT/$FILE"

        if [ -f "$FILEPATH" ]; then
             echo "[$(date)] Suppression de $FILE"
             rm $FILEPATH
            
        fi
    done

else
    echo "[$(date)] Toolbox déjà à jour (version $toolbox_version_local)"
fi

echo "[$(date)] ===== END TOOLBOX UPDATE ====="