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

purge_old_switch_install() {

# find /   -type d   \( -iname "*citron*"   -o -iname "*eden*"   -o -iname "*ryujinx*"   -o -iname "*yuzu*"   -o -iname "*sudachi*"   -o -iname "switch" \)   2>/dev/null

    LOG="/userdata/system/logs/bsa.log"

    echo "[PURGE] Starting old Switch cleanup" >>"$LOG"

    rm -rf /userdata/system/switch >>"$LOG" 2>&1
	message "both" "$addon_log" "- Supression du dossier switch system"

    rm -rf \
        /userdata/bios/switch/firmware_ryujinx \
        /userdata/bios/switch/firmware_yuzu \
        /userdata/bios/switch/keys_yuzu \
        /userdata/bios/switch/keys_ryujinx \
        >>"$LOG" 2>&1

	message "both" "$addon_log" "- Supression des anciens  dossier firmware et keys"

    rm -f \
        "/userdata/roms/ports/Sudachi Qlauncher.sh" \
        "/userdata/roms/ports/Sudachi Qlauncher.sh.keys" \
        "/userdata/roms/ports/Switch Updater40.sh" \
        "/userdata/roms/ports/Switch Updater40.sh.keys" \
        "/userdata/roms/ports/ryujinx_config.sh" \
        "/userdata/roms/ports/ryujinx_config.sh.keys" \
        "/userdata/roms/ports/yuzu_config.sh" \
        "/userdata/roms/ports/yuzu_config.sh.keys" \
        "/userdata/roms/ports/Suyu Qlauncher.sh" \
        "/userdata/roms/ports/Suyu Qlauncher.sh.keys" \
        "/userdata/roms/ports/update*yuzu*.sh" \
        "/userdata/roms/ports/updateryujinx*.sh" 

	message "both" "$addon_log" "- Supression des differents scripts de lancement"

    rm -f \
        /userdata/system/configs/emulationstation/es_systems_switch.cfg \
        /userdata/system/configs/emulationstation/es_features_switch.cfg \
        /userdata/system/configs/evmapy/switch.keys

	message "both" "$addon_log" "- Supression et nettoyage des fichiers de configuration"

    rm -f /userdata/system/.local/share/applications/*yuzu*
    rm -f /userdata/system/.local/share/applications/*ryujinx*
    rm -f /userdata/system/.local/share/applications/*eden*
    rm -f /userdata/system/.local/share/applications/*citron*
    rm -f /userdata/system/.local/share/applications/*sudachi*

    rm -f /usr/share/applications/*yuzu*
    rm -f /usr/share/applications/*ryujinx*
    rm -f /usr/share/applications/*eden*
    rm -f /usr/share/applications/*citron*
    rm -f /usr/share/applications/*sudachi*

	message "both" "$addon_log" "- Supression des icones et lanceurs du bureau"

	rm -rf /userdata/system/cache/{eden,citron,sudachi,yuzu} >>"$LOG" 2>&1
	rm -rf /userdata/system/.cache/{eden,citron,sudachi,yuzu} >>"$LOG" 2>&1
	rm -rf /userdata/cache/{eden,citron,sudachi,yuzu} >>"$LOG" 2>&1
	rm -rf /userdata/.cache/{eden,citron,sudachi,yuzu} >>"$LOG" 2>&1

    rm -rf \
        /userdata/system/configs/{eden,citron,sudachi,yuzu} \
        /userdata/system/.configs/{eden,citron,sudachi,yuzu}

	message "both" "$addon_log" "- Supression des caches et configurations"
}

# UNINSTALL BATOCERA SWITCH ADD-ON
uninstall_BSA() {

	# Backup Yuzu Saves & mods
	backup_saves_ryujinx
	message "both" "$addon_log" "Preventif : Sauvegardes des saves & Mods Ryujinx effectuée dans /userdata/saves/switch/"

	# Backup Yuzu Saves & Mods
	backup_saves_yuzu
	message "both" "$addon_log" "Preventif : Sauvegardes des saves & Mods Yuzu effectuée dans /userdata/saves/switch/"

	# Deplacement des mods Citron/Eden/Sudachi en temporaire
	move_mods_yuzu
	message "both" "$addon_log" "Preventif : Deplacement des mods Citron/Eden/Sudachi effectuée dans /userdata/saves/switch/backup_mod_yuzu"

	# Deplacement des mods Ryujinx
	move_mods_ryujinx
	message "both" "$addon_log" "Preventif : Deplacement des mods Ryujinx effectuée dans /userdata/saves/switch/backup_mod_ryujinx"

	purge_old_switch_install

	gamelist_file="/userdata/roms/ports/gamelist.xml"
	xmlstarlet ed -L -d "/gameList/game[path='./ryujinx_config.sh']" "$gamelist_file"
	xmlstarlet ed -L -d "/gameList/game[path='./yuzu_config.sh']" "$gamelist_file"
	xmlstarlet ed -L -d "/gameList/game[path='./Sudachi Qlauncher.sh']" "$gamelist_file"
	message "both" "$addon_log" "- Nettoyage de la Gamelist PORTS terminé $gamelist_file"

	message "both" "$addon_log" "##### Desinstallation SWITCH ADD-ON terminée #####"
	
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