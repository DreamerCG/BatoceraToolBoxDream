#!/usr/bin/env bash 
# BATOCERA - SWITCH ADD-ON : UNINSTALL

# SOURCE GUARD TO PREVENT REDUNDANCY
[ -n "$SOURCED_UNINSTALL" ] && return
SOURCED_UNINSTALL=true



# REMOVE EMULATOR TO ES SYSTEMS CONFIG FILE
remove_emulator_to_es_systems() {
	local emu="$1"
	xml_file_delete_node "$system_configs_dir/emulationstation/es_systems_switch.cfg" "//system[name='switch']/emulators/emulator[@name='$emu']"
}


	log_msg() {
		message "both" "$addon_log" "$1"
	}

	rm_logged() {
		rm -rf "$@" >>"$addon_log" 2>&1
	}


purge_old_switch_install() {

echo "[PURGE] Starting old Switch cleanup" >>"$addon_log"

# ===== Dossiers principaux =====
	rm_logged /userdata/system/switch
	log_msg "- Suppression du dossier switch system"


	if [ -d "/userdata/system/configs/yuzu" ]; then
		rm -rf /userdata/saves/switch
		log_msg "- suppression du dossier saves/switch"
	fi

	# ===== Firmwares & keys =====
	FIRMWARE_DIRS=(
		/userdata/bios/switch/firmware_ryujinx
		/userdata/bios/switch/firmware_yuzu
		/userdata/bios/switch/keys_yuzu
		/userdata/bios/switch/keys_ryujinx
	)

	rm_logged "${FIRMWARE_DIRS[@]}"
	log_msg "- Suppression des anciens dossiers firmware et keys"

	# ===== Scripts ports =====
	PORT_SCRIPTS=(
		"Sudachi Qlauncher.sh"
		"Sudachi Qlauncher.sh.keys"
		"Switch Updater40.sh"
		"Switch Updater40.sh.keys"
		"ryujinx_config.sh"
		"ryujinx_config.sh.keys"
		"yuzu_config.sh"
		"yuzu_config.sh.keys"
		"citron_config.sh"
		"citron_config.sh.keys"
		"Suyu Qlauncher.sh"
		"Suyu Qlauncher.sh.keys"
	)

	for script in "${PORT_SCRIPTS[@]}"; do
		rm -f "/userdata/roms/ports/$script"
	done

	rm -f /userdata/roms/ports/update*yuzu*.sh
	rm -f /userdata/roms/ports/updateryujinx*.sh

	log_msg "- Suppression des scripts de lancement"

	# ===== Config EmulationStation =====
	rm_logged \
		/userdata/system/configs/emulationstation/es_systems_switch.cfg \
		/userdata/system/configs/emulationstation/es_features_switch.cfg \
		/userdata/system/configs/evmapy/switch.keys

	log_msg "- Suppression et nettoyage des fichiers de configuration"

	# ===== Apps / émulateurs =====
	EMULATORS=(eden citron sudachi yuzu Ryujinx suyu)

	for emu in "${EMULATORS[@]}"; do
		rm -f /userdata/system/.local/share/applications/*"$emu"* >>"$addon_log" 2>&1
		rm -f /usr/share/applications/*"$emu"* >>"$addon_log" 2>&1
	done

	rm_logged /userdata/system/.local/share/{eden,citron,sudachi,yuzu,Ryujinx,yuzu-early-access}

	log_msg "- Suppression des icônes et lanceurs du bureau"

	# ===== Cache =====
	CACHE_BASES=(
		/userdata/system/cache
		/userdata/system/.cache
		/userdata/cache
		/userdata/.cache
	)

	for base in "${CACHE_BASES[@]}"; do
		rm_logged "$base"/{eden,citron,sudachi,yuzu,Ryujinx,suyu}
	done

	rm_logged \
		/userdata/system/cache/mesa_shader_cache \
		/userdata/system/.cache/mesa_shader_cache \
		/userdata/system/cache/radv_builtin_shaders \
		/userdata/system/.cache/radv_builtin_shaders

	log_msg "- Suppression des caches Vulkan et Mesa"

	# ===== Configs émulateurs =====
	rm_logged \
		/userdata/system/configs/{eden,citron,sudachi,yuzu,Ryujinx,suyu} \
		/userdata/system/.configs/{eden,citron,sudachi,yuzu,Ryujinx,suyu}

	# Nettoyage du batocera.conf (Switch) #Thanks Foclabroc
	BATOCERA_CONF="/userdata/system/batocera.conf"

	if [[ -f "$BATOCERA_CONF" ]]; then
		sed -i \
			-e '/^switch/d' \
			"$BATOCERA_CONF"
	fi

	message "both" "$addon_log" "- Nettoyage de Batocera CONF [SWITCH]."

    # Nettoyage du custom.sh
    CUSTOM="/userdata/system/custom.sh"
    if [[ -f "$CUSTOM" ]]; then
        sed -i '\|/userdata/system/switch/extra/batocera-switch-startup|d' "$CUSTOM"
    fi

		message "both" "$addon_log" "- Nettoyage de Custom SH [SWITCH]."

}

backup_saves_mods() {

    mkdir -p /userdata/DreamerCGToolBox/tmp/
    mkdir -p /userdata/DreamerCGToolBox/tmp/tmp_yuzu_mods
    mkdir -p /userdata/DreamerCGToolBox/tmp/tmp_yuzu_save_user
    mkdir -p /userdata/DreamerCGToolBox/tmp/tmp_yuzu_save_system
    mkdir -p /userdata/DreamerCGToolBox/tmp/tmp_ryujinx_save_user
    mkdir -p /userdata/DreamerCGToolBox/tmp/tmp_ryujinx_save_system
    mkdir -p /userdata/DreamerCGToolBox/tmp/tmp_ryujinx_mods

	# Activer le déplacement des fichiers cachés
	shopt -s dotglob

	[ -d "/userdata/system/configs/yuzu/load" ] && \
	[ "$(ls -A /userdata/system/configs/yuzu/load 2>/dev/null)" ] && \
	mv /userdata/system/configs/yuzu/load/* /userdata/DreamerCGToolBox/tmp/tmp_yuzu_mods/ 2>/dev/null
	message "both" "$addon_log" "- Deplacement de yuzu/Mods"

	[ -d "/userdata/system/configs/yuzu/nand/user/save" ] && \
	[ "$(ls -A /userdata/system/configs/yuzu/nand/user/save 2>/dev/null)" ] && \
	mv /userdata/system/configs/yuzu/nand/user/save/* /userdata/DreamerCGToolBox/tmp/tmp_yuzu_save_user/ 2>/dev/null
	message "both" "$addon_log" "- Deplacement de yuzu/Saves User"

	[ -d "/userdata/system/configs/yuzu/nand/system/save" ] && \
	[ "$(ls -A /userdata/system/configs/yuzu/nand/system/save 2>/dev/null)" ] && \
	mv /userdata/system/configs/yuzu/nand/system/save/* /userdata/DreamerCGToolBox/tmp/tmp_yuzu_save_system/ 2>/dev/null
	message "both" "$addon_log" "- Deplacement de yuzu/Saves System"

	[ -d "/userdata/system/configs/Ryujinx/bis/user" ] && \
	[ "$(ls -A /userdata/system/configs/Ryujinx/bis/user 2>/dev/null)" ] && \
	mv /userdata/system/configs/Ryujinx/bis/user/* /userdata/DreamerCGToolBox/tmp/tmp_ryujinx_save_user/ 2>/dev/null
	message "both" "$addon_log" "- Deplacement de Ryujinx/Saves User"


	[ -d "/userdata/system/configs/Ryujinx/bis/system/save" ] && \
	[ "$(ls -A /userdata/system/configs/Ryujinx/bis/system/save 2>/dev/null)" ] && \
	mv /userdata/system/configs/Ryujinx/bis/system/save/* /userdata/DreamerCGToolBox/tmp/tmp_ryujinx_save_system/ 2>/dev/null
	message "both" "$addon_log" "- Deplacement de Ryujinx/Saves System"

	[ -d "/userdata/system/configs/Ryujinx/mods" ] && \
	[ "$(ls -A /userdata/system/configs/Ryujinx/mods 2>/dev/null)" ] && \
	mv /userdata/system/configs/Ryujinx/mods/* /userdata/DreamerCGToolBox/tmp/tmp_ryujinx_mods/ 2>/dev/null
	message "both" "$addon_log" "- Deplacement de Ryujinx/Mods"
	# Désactiver après usage (important)
	shopt -u dotglob


}

restore_saves_mods_yuzu() {
	
    move_content() {
        SRC="$1"
        DEST="$2"

        if [[ -d "$SRC" ]]; then
            mkdir -p "$DEST"

            shopt -s dotglob nullglob
            mv "$SRC"/* "$DEST"/ 2>/dev/null
            shopt -u dotglob nullglob
        fi
    }

    move_content "/userdata/DreamerCGToolBox/tmp/tmp_yuzu_mods" "/userdata/saves/switch/eden_citron/mods"
    move_content "/userdata/DreamerCGToolBox/tmp/tmp_yuzu_save_user" "/userdata/saves/switch/eden_citron/save/save_user"
    move_content "/userdata/DreamerCGToolBox/tmp/tmp_yuzu_save_system" "/userdata/saves/switch/eden_citron/save/save_system"


}


restore_saves_mods_ryujinx() {
	
    move_content() {
        SRC="$1"
        DEST="$2"

        if [[ -d "$SRC" ]]; then
            mkdir -p "$DEST"

            shopt -s dotglob nullglob
            mv "$SRC"/* "$DEST"/ 2>/dev/null
            shopt -u dotglob nullglob
        fi
    }

    move_content "/userdata/DreamerCGToolBox/tmp/tmp_ryujinx_save_user" "/userdata/saves/switch/ryujinx/save/save_user"
    move_content "/userdata/DreamerCGToolBox/tmp/tmp_ryujinx_save_system" "/userdata/saves/switch/ryujinx/save/save_system"
    move_content "/userdata/DreamerCGToolBox/tmp/tmp_ryujinx_mods" "/userdata/saves/switch/ryujinx/mods"
}

# UNINSTALL BATOCERA SWITCH ADD-ON
uninstall_BSA() {

	message "both" "$addon_log" "- Sauvegarde préventive des saves & mods Yuzu & Ryujinx en cours..."
	backup_saves_mods
	message "both" "$addon_log" "- Sauvegarde préventive des saves & mods Yuzu & Ryujinx terminée."
	sleep 2
	
	message "both" "$addon_log" "Clean Install : suppression des anciennes configurations"
	purge_old_switch_install
	sleep 2
	
	gamelist_file="/userdata/roms/ports/gamelist.xml"
	xmlstarlet ed -L -d "/gameList/game[path='./ryujinx_config.sh']" "$gamelist_file"
	xmlstarlet ed -L -d "/gameList/game[path='./yuzu_config.sh']" "$gamelist_file"
	xmlstarlet ed -L -d "/gameList/game[path='./citron_config.sh']" "$gamelist_file"
	xmlstarlet ed -L -d "/gameList/game[path='./Sudachi Qlauncher.sh']" "$gamelist_file"
	message "both" "$addon_log" "- Nettoyage de la Gamelist PORTS terminé $gamelist_file"
    message "both" "$addon_log" "Clean terminé"

}


# UNINSTALL BIOS
uninstall_bios() {
	message "log" "$addon_log" "<<< [ REMOVE BIOS DIRECTORY ]>>>"
	delete_recursive "$switch_bios_dir" "Switch BIOS Directory" "log"
}


# UNINSTALL BIOS AS NEEDED
# If Firmware, Keys & Amiibo removed then remove BIOS directory
check_and_uninstall_bios() {
	local paths=(
		"$switch_ryujinx_firmware_dir"
		"$switch_yuzu_firmware_dir"
		"$switch_ryujinx_keys_dir"
		"$switch_yuzu_keys_dir"
		"$switch_amiibo_dir"
	)
	local all_not_dirs=true

	for path in "${paths[@]}"; do
		[[ -d "$path" ]] && all_not_dirs=false && break
	done

	$all_not_dirs && uninstall_bios
}


# UNINSTALL FIRMWARE
uninstall_firmware() {
	message "log" "$addon_log" "<<< [ UNINSTALL FIRMWARE ]>>>"
	delete_recursive "$switch_ryujinx_firmware_dir" "Ryujinx Firmware" "log"
	delete_recursive "$switch_yuzu_firmware_dir" "Yuzu Firmware" "log"
	check_and_uninstall_bios
}

# UNINSTALL KEYS
uninstall_keys() {
	message "log" "$addon_log" "<<< [ UNINSTALL KEYS ]>>>"
	delete_recursive "$switch_ryujinx_keys_dir" "Ryujinx Keys" "log"
	delete_recursive "$switch_yuzu_keys_dir" "Yuzu Keys" "log"
	check_and_uninstall_bios
}

# UNINSTALL AMIIBO
uninstall_amiibo() {
	message "log" "$addon_log" "<<< [ UNINSTALL AMIIBO ]>>>"
	delete_recursive "$switch_amiibo_dir" "Amiibo" "log"
	check_and_uninstall_bios
}

# UNINSTALL SAVES
uninstall_saves() {
	message "log" "$addon_log" "<<< [ UNINSTALL SAVES ]>>>"
	delete_recursive "$switch_saves_dir" "Switch Saves" "log"
}