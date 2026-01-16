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

    rm -rf \
        /userdata/bios/switch/firmware_ryujinx \
        /userdata/bios/switch/firmware_yuzu \
        /userdata/bios/switch/keys_yuzu \
        /userdata/bios/switch/keys_ryujinx \
        >>"$LOG" 2>&1

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
        "/userdata/roms/ports/Suyu Qlauncher.sh.keys"

    rm -f \
        /userdata/system/configs/emulationstation/es_systems_switch.cfg \
        /userdata/system/configs/emulationstation/es_features_switch.cfg \
        /userdata/system/configs/evmapy/switch.keys

    rm -f /userdata/roms/ports/update*yuzu*.sh
    rm -f /userdata/roms/ports/updateryujinx*.sh

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

	rm -rf /userdata/system/cache/{eden,citron,sudachi,yuzu} >>"$LOG" 2>&1
	rm -rf /userdata/system/.cache/{eden,citron,sudachi,yuzu} >>"$LOG" 2>&1
	rm -rf /userdata/cache/{eden,citron,sudachi,yuzu} >>"$LOG" 2>&1
	rm -rf /userdata/.cache/{eden,citron,sudachi,yuzu} >>"$LOG" 2>&1

    rm -f \
        /userdata/system/configs/{eden,citron,sudachi,yuzu} \
        /userdata/system/.configs/{eden,citron,sudachi,yuzu}

    echo "[PURGE] Done" >>"$LOG"
}


# UNINSTALL BATOCERA SWITCH ADD-ON
uninstall_BSA() {

	purge_old_switch_install
	
	message "log" "$addon_log" "<<< [ UNINSTALL BATOCERA SWITCH ADD-ON ]>>>"
	# DELETE SWITCH SYSTEM DIRECTORY
	message "log" "$addon_log" "DELETE SWITCH SYSTEM DIRECTORY"
	delete_recursive "$switch_system_dir" "SWITCH SYSTEM DIRECTORY" "log"

	# DELETE DESKTOP LAUNCHERS & ICONS
	message "log" "$addon_log" "DELETE DESKTOP LAUNCHERS & ICONS"
	delete_recursive "$local_applications_dir/ryujinx.desktop" "Ryujinx Deskop Launcher" "log"
	delete_recursive "$local_icons_dir/ryujinx.png" "Ryujinx Desktop Icon" "log"
	delete_recursive "$local_applications_dir/yuzu.desktop" "Yuzu Deskop Launcher" "log"
	delete_recursive "$local_icons_dir/yuzu.png" "Yuzu Desktop Icon" "log"
	delete_recursive "$local_applications_dir/eden.desktop" "Eden Deskop Launcher" "log"
	delete_recursive "$local_icons_dir/eden.png" "Eden Desktop Icon" "log"
	delete_recursive "$local_applications_dir/citron.desktop" "Citron Deskop Launcher" "log"
	delete_recursive "$local_icons_dir/citron.png" "Citron Desktop Icon" "log"


	# DELETE CONFIGS
	message "log" "$addon_log" "DELETE CONFIGS"
	delete_recursive "$system_hidden_config_dir/Ryujinx" "Ryujinx Config (Symbolic Link)" "log"
	delete_recursive "$local_share_dir/Ryujinx" "Ryujinx Config (Symbolic Link)" "log"
	delete_recursive "$system_configs_dir/Ryujinx" "Ryujinx Config" "log"
	delete_recursive "$system_hidden_config_dir/yuzu" "Yuzu Config (Symbolic Link)" "log"
	delete_recursive "$local_share_dir/yuzu" "Yuzu Config (Symbolic Link)" "log"
	delete_recursive "$system_configs_dir/yuzu" "Yuzu Config" "log"
	delete_recursive "$system_hidden_config_dir/eden" "Eden Config (Symbolic Link)" "log"
	delete_recursive "$local_share_dir/eden" "Eden Config (Symbolic Link)" "log"
	delete_recursive "$system_configs_dir/eden" "Eden Config" "log"
	delete_recursive "$system_hidden_config_dir/citron" "Citron Config (Symbolic Link)" "log"
	delete_recursive "$local_share_dir/citron" "Citron Config (Symbolic Link)" "log"
	delete_recursive "$system_configs_dir/citron" "Citron Config" "log"


	# REMOVE EMULATIONSTATION CONFIG FILES
	message "log" "$addon_log" "DELETE EMULATIONSTATION CONFIGS"
	delete_recursive "$system_configs_emulationstation_dir/es_features_switch.cfg" "EmulationStation Switch Features Config" "log"
	delete_recursive "$system_configs_emulationstation_dir/es_systems_switch.cfg" "EmulationStation Switch Systems Config" "log"

	# REMOVE EVMAPY CONFIG
	message "log" "$addon_log" "DELETE EVENT MAPPER CONFIGS"
	delete_recursive "$system_configs_evmapy_dir/switch.keys" "Event Mapper Config" "log"
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