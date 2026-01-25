#!/usr/bin/env bash
# BATOCERA - SWITCH ADD-ON

LOG_DIR="/userdata/DreamerCGToolBox/logs"
LOG="$LOG_DIR/update_toolbox.log"

VERSION_FILE="/userdata/DreamerCGToolBox/configgen-version.txt"
VERSION_URL="https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/main/configgen-version.txt"

echo "[$(date)] Batocera Version   : $VERSION_URL"

# Récupération de la version principale de Batocera
batocera_version=$(batocera-es-swissknife --version | grep -oE '^[0-9]+')

case "$batocera_version" in
	41)
		folder_version=41
		;;
	4[2-3])
		folder_version=42
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
toolbox_download_version="$(curl -sL "$VERSION_URL" | tr -d '\r\n')"

echo "[$(date)] Batocera Version   : $batocera_version"
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
    DIR_CONFIGGEN="/userdata/system/switch/configgen"
    DIR_GENERATOR="/userdata/system/switch/configgen/generators"
    URL_BASE="https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/main/install/$folder_version/system/switch/configgen/"
	URL_ROM_INSTALL="https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/main/install/roms/switch/"


    mkdir -p "$DIR_TOOLBOX"
    mkdir -p "$DIR_CONFIGGEN"
    mkdir -p "$DIR_GENERATOR"

	echo "[$(date)] Configgen Local Dir   : $DIR_CONFIGGEN"
	echo "[$(date)] Generator Local Dir  : $DIR_GENERATOR"
	echo "[$(date)] Distant URL          : $URL_BASE"
    
    # Téléchargement des nouveaux fichiers
    curl -sL "$URL_BASE/switchlauncher.py" -o "$DIR_CONFIGGEN/switchlauncher.py"
    echo "[$(date)] Mise à jour de switchlauncher"
    curl -sL "$URL_BASE/generators/edenGenerator.py" -o "$DIR_GENERATOR/edenGenerator.py"
    echo "[$(date)] Mise à jour de EdenGenerator"
    curl -sL "$URL_BASE/generators/ryujinxGenerator.py" -o "$DIR_GENERATOR/ryujinxGenerator.py"
    echo "[$(date)] Mise à jour de ryujinxGenerator"
    curl -sL "https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/main/install/gamecontroller_ryujinx.txt" -o "$DIR_GENERATOR/gamecontroller_ryujinx.txt"
    echo "[$(date)] Mise à jour de gamecontroller_ryujinx"
    curl -sL "$URL_BASE/generators/ryujinxloadfirmware.sh" -o "$DIR_GENERATOR/ryujinxloadfirmware.sh"
    echo "[$(date)] Mise à jour de ryujinxloadfirmware"
    curl -sL "$VERSION_URL" -o "$DIR_TOOLBOX/configgen-version.txt"
    echo "[$(date)] Mise à jour de configgen-version.txt"

    # Mise à jour du Switch Features
    curl -sfL \
    "https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/main/install/$folder_version/system/configs/emulationstation/es_features_switch.cfg" \
    -o "$DIR_EMULATIONSTATION/es_features_switch.cfg"

    echo "[$(date)] Mise à jour de es_features_switch"

    # Mise à jour du Switch System
    curl -sfL \
    "https://raw.githubusercontent.com/DreamerCG/BatoceraToolBoxDream/main/install/$folder_version/system/configs/emulationstation/es_systems_switch.cfg" \
    -o "$DIR_EMULATIONSTATION/es_systems_switch.cfg"

    echo "[$(date)] Mise à jour de es_systems_switch"

    chmod a+x "$DIR_CONFIGGEN/switchlauncher.py"
    chmod a+x "$DIR_GENERATOR/edenGenerator.py"
    chmod a+x "$DIR_GENERATOR/ryujinxGenerator.py"
    chmod a+x "$DIR_GENERATOR/ryujinxloadfirmware.sh"

    #On Verifie si les roms suivants existe dans /userdata/roms/switch/

    # FILES=(
    #     "citron_config.xci_config"
    #     "eden_config.xci_config"
    #     "ryujinx_config.xci_config"
    #     "eden_qlaunch.xci_config"
    # )

    # # Boucle sur chaque fichier
    # for FILE in "${FILES[@]}"; do
    #     FILEPATH="$DIR_ROM_SWITCH/$FILE"
    #     URL="$URL_ROM_INSTALL/$FILE"

    #     if [ -f "$FILEPATH" ]; then
    #         echo "Le fichier '$FILE' existe déjà, téléchargement ignoré."
    #     else
    #         echo "Téléchargement de '$FILE'..."
    #         curl -fSL "$URL" -o "$FILEPATH"
    #         if [ $? -eq 0 ]; then
    #             echo "Téléchargement de '$FILE' terminé avec succès."
    #         else
    #             echo "Erreur lors du téléchargement de '$FILE' !"
    #         fi
    #     fi
    # done


    FILES_IMAGES=(
        "citron_config.png"
        "citron_config-logo.png"
        "yuzu_config-logo.png"
        "yuzu_config-logo.png"
        "yuzu_config-image.png"
        "ryujinx_config.png"
        "ryujinx_config-logo.png"
        "ryujinx_config-image.png"
    )

    # Boucle sur chaque fichier
    for FILE in "${FILES_IMAGES[@]}"; do
        FILEPATH="$DIR_ROM_SWITCH/images/$FILE"
        URL="$URL_ROM_INSTALL/images/$FILE"

        if [ -f "$FILEPATH" ]; then
            echo "Le fichier '$FILE' existe déjà, téléchargement ignoré."
        else
            echo "Téléchargement de '$FILE'..."
            curl -fSL "$URL" -o "$FILEPATH"
            if [ $? -eq 0 ]; then
                echo "Téléchargement de '$FILE' terminé avec succès."
            else
                echo "Erreur lors du téléchargement de '$FILE' !"
            fi
        fi
    done



else
    echo "[$(date)] Toolbox déjà à jour (version $toolbox_version_local)"
fi

echo "[$(date)] ===== END TOOLBOX UPDATE ====="