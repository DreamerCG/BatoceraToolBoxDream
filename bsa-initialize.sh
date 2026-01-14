#!/usr/bin/env bash 
# BATOCERA - SWITCH ADD-ON : INITIALLIZE STRUCTURES

# SOURCE GUARD TO PREVENT REDUNDANCY
[ -n "$SOURCED_INITIALIZE" ] && return
SOURCED_INITIALIZE=true


# ADD EMULATOR TO ES SYSTEMS CONFIG FILE
add_emulator_to_es_systems() {
	local emu="$1"
	local xml_node="<emulator name=\"$emu\"><cores><core default=\"true\">$emu</core></cores></emulator>"
	xml_file_inject_node \
		"$system_configs_dir/emulationstation/es_systems_switch.cfg" \
		"//system[name='switch']/emulators" \
		"emulator[@name='$emu']" \
		"$xml_node"
}


purge_old_switch_install() {

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

    rm -f \
        /userdata/system/configs/{eden,citron,sudachi} \
        /userdata/system/.configs/{eden,citron,sudachi}

    echo "[PURGE] Done" >>"$LOG"
}




# SETUP COMMON STRUCTURES
initialize_common() {
	# SOURCE GUARD TO PREVENT REDUNDANCY
	[ -n "$RAN_INITIALIZE_COMMON" ] && return

	message "log" "$addon_log" "<<< [ INITIALLIZE COMMON STRUCTURES ]>>>"

	# CREATE SWITCH SYSTEM DIRECTORY
	message "log" "$addon_log" "Creating Switch System Directory."
	mkdir -p "$switch_system_dir" 2>>"$stderr_log"

	# CREATE SWITCH LOGS DIRECTORY
	message "log" "$addon_log" "Creating Switch System Logs Directory."
	mkdir -p "$switch_logs_dir" 2>>"$stderr_log"

	# SETUP BIOS DIRECTORY (STORES FIRMWARE, KEYS, AMIIBO)
	message "log" "$addon_log" "Creating Switch BIOS Directory"
	mkdir -p "$switch_bios_dir" 2>>"$stderr_log"
	# GENERATE _INFO.TXT IN BIOS DIRECTORY
	message "log" "$addon_log" "Generating _info.txt for Switch BIOS Directory."
	generate_file "$switch_bios_dir/_info.txt" \
		"-= Firmware, Keys, Amiibo, etc. for Switch =-" \
		"" \
		"***NOTE: Yuzu also refers to Forks (Eden, Citron) as well." \
		"" \
		"Directory Structure for the BSA (Batocera Switch Add-On}" \
		"" \
		"	./amiibo" \
		"		... AMIIBO files" \
		"	./firmware_ryujinx" \
		"		... Firmware for Ryujinx (can be different from Yuzu)" \
		"	./firmware_yuzu" \
		"		... Firmware for Yuzu (can be different from Ryujinx)" \
		"	./keys_ryujinx" \
		"		... Keys for Ryujinx (must match the Firmware for Ryujinx)" \
		"	./keys_yuzu" \
		"		... Keys for Yuzu (must match the Firmware for Yuzu)" \
		""

	# SETUP AMIIBO DIRECTORY
	message "log" "$addon_log" "Creating Switch Amiibo Directory."
	mkdir -p "$switch_amiibo_dir" 2>>"$stderr_log"

	# CREATE ROMS DIRECTORY
	message "log" "$addon_log" "Creating Switch ROMs Directory."
	mkdir -p "$switch_roms_dir" 2>>"$stderr_log"
	# GENERATE _INFO.TXT IN ROMS DIRECTORY
	message "log" "$addon_log" "Generating _info.txt for Switch ROMs Directory."
	generate_file "$switch_roms_dir/_info.txt" \
		"## SYSTEM NINTENDO SWITCH ##" \
		"-------------------------------------------------------------------------------" \
		"ROM files extensions accepted: \".xci, .XCI, .nsp, .NSP, .nsz, .NSZ\"" \
		"-------------------------------------------------------------------------------" \
		"Extensions des fichiers ROMs permises: \".xci, .XCI, .nsp, .NSP, .nsz, .NSZ\""

	# SETUP SYSTEM CONFIGS
	rename_file	"$system_configs_dir/emulationstation/es_systems_switch.cfg" "$system_configs_dir/emulationstation/es_systems_switch.old" "yes"
	message "log" "$addon_log" "Setup Switch System Configs. (EmulationStation, evmapy, etc.)"
	cp -rfT "$switch_install_configs_dir" "$system_configs_dir" 2>>"$stderr_log"
	rename_file	"$system_configs_dir/emulationstation/es_systems_switch.old" "$system_configs_dir/emulationstation/es_systems_switch.cfg" "yes"

	# SETUP SYSTEM CONFIG GENERATORS
	message "log" "$addon_log" "Setup Switch Config Generators."
	cp -rfT "$switch_install_configgen_dir" "$switch_configgen_dir" 2>>"$stderr_log"

	# SETUP LOCAL DIRECTORIES
	message "log" "$addon_log" "Setup Local Applications & Icons Directories"
	mkdir -p "$local_applications_dir" 2>>"$stderr_log"
	mkdir -p "$local_icons_dir" 2>>"$stderr_log"

	# CREATE SWITCH BIN DIRECTORY
	message "log" "$addon_log" "Creating Switch BIN Directory."
	mkdir -p "$switch_bin_dir" 2>>"$stderr_log"

	# CREATE SWITCH LIB DIRECTORY
	message "log" "$addon_log" "Creating Switch LIB Directory."
	mkdir -p "$switch_lib_dir" 2>>"$stderr_log"

	# SOURCE GUARD TO PREVENT REDUNDANCY
	RAN_INITIALIZE_COMMON=true
}


# INITIALLIZE RYUJINX STRUCTURES
initialize_ryujinx() {

	# Backup Yuzu Saves
	backup_saves_ryujinx

	# SETUP COMMON STRUCTURES
	initialize_common

	message "log" "$addon_log" "<<< [ INITIALLIZE RYUJINX STRUCTURES ]>>>"

	# SETUP FIRMWARE DIRECTORY
	message "log" "$addon_log" "Creating Ryujinx Firmware Directories."
	mkdir -p "$switch_ryujinx_firmware_dir" 2>>"$stderr_log"

	# SETUP KEYS DIRECTORY
	message "log" "$addon_log" "Creating Ryujinx Keys Directories."
	mkdir -p "$switch_ryujinx_keys_dir" 2>>"$stderr_log"

	# CREATE & LINK ORIGINAL CONFIG DIRECTORIES TO NEW CONFIG DIRECTORIES (MORE CENTRALIZED)
	message "log" "$addon_log" "Linking Original Configuration Directories to New (Centralized) Configuration Directories."
	create_slink_directory "$ryujinx_config_dir" "$ryujinx_og_config_dir"
	create_slink_directory "$ryujinx_config_dir" "$ryujinx_og_local_config_dir"

	# ******************************************************************************
	# START USING NEW CONFIG DIRECTORIES FROM HERE ON OUT AS LINKS CREATE
	# ******************************************************************************

	# LINK FIRMWARE/NAND DIRECTORY
	message "log" "$addon_log" "Linking Ryujinx Firmware Directory." "Firmware may need to be manually installed from the GUI for Ryujinx."
	create_slink_directory "$switch_ryujinx_firmware_dir" "$ryujinx_config_firmware_dir"

	# LINK KEYS DIRECTORY
	message "log" "$addon_log" "Linking Keys Directory."
	create_slink_directory "$switch_ryujinx_keys_dir" "$ryujinx_config_keys_dir"

	# LINK SAVES DIRECTORIES
	message "log" "$addon_log" "Linking Saves Directories."
	create_slink_directory "$ryujinx_system_saves_dir" "$ryujinx_config_system_saves_dir"
	create_slink_directory "$ryujinx_user_saves_dir" "$ryujinx_config_user_saves_dir"
	create_slink_directory "$ryujinx_user_saves_meta_dir" "$ryujinx_config_user_saves_meta_dir"

	# LINK AMIIBO DIRECTORY
	message "log" "$addon_log" "Ryujinx Does Not Have an Amiibo Directory to Link."
	create_slink_directory "$switch_amiibo_dir" "$ryujinx_config_amiibo_dir"

	# .DESKTOP FOR F1-APPLICATIONS MENU 
	message "log" "$addon_log" "Generating .desktop for F1-Applications Menu."
	generate_desktop_file "$local_applications_dir" "$local_icons_dir" "ryujinx" "Ryujinx-Config"

	# COPY LAUNCHER SCRIPTS
	message "log" "$addon_log" "Installing EmulationStation & Desktop Launcher Scripts"
	copy_make_executable "ryujinx-config.sh" "$switch_install_scripts_dir" "$switch_system_dir"
	copy_make_executable "ryujinx-launch.sh" "$switch_install_scripts_dir" "$switch_system_dir"

	# CREATE EMULATOR DIRECTORY
	message "log" "$addon_log" "Ryujinx Emulator Directory Created."
	mkdir -p "$ryujinx_emu_dir" 2>>"$stderr_log"

	# ADD EMULATOR TO ES SYSTEMS CONFIG FILE
	add_emulator_to_es_systems "ryujinx-emu"
}

# INITIALLIZE YUZU STRUCTURES
initialize_yuzu() {

	# Backup Yuzu Saves
	backup_saves_yuzu

	# SETUP COMMON STRUCTURES
	initialize_common

	message "log" "$addon_log" "<<< [ INITIALLIZE YUZU STRUCTURES ]>>>"

	# SETUP FIRMWARE DIRECTORY
	if [ ! -d "$switch_yuzu_firmware_dir" ]; then
		message "log" "$addon_log" "Creating Firmware Directory."
		mkdir -p "$switch_yuzu_firmware_dir" 2>>"$stderr_log"
	fi

	# SETUP KEYS DIRECTORY
	if [ ! -d "$switch_yuzu_keys_dir" ]; then
		message "log" "$addon_log" "Creating Keys Directory."
		mkdir -p "$switch_yuzu_keys_dir" 2>>"$stderr_log"
	fi

	# CREATE & LINK ORIGINAL CONFIG DIRECTORIES TO NEW CONFIG DIRECTORIES (MORE CENTRALIZED)
	message "log" "$addon_log" "Linking Original Configuration Directories to New (Centralized) Configuration Directories."
	create_slink_directory "$yuzu_config_dir" "$yuzu_og_config_dir"
	create_slink_directory "$yuzu_config_dir" "$yuzu_og_local_config_dir"

	# ******************************************************************************
	# START USING NEW CONFIG DIRECTORIES FROM HERE ON OUT AS LINKS CREATE
	# ******************************************************************************

	# LINK FIRMWARE/NAND DIRECTORY
	message "log" "$addon_log" "Linking Firmware Directory."
	create_slink_directory "$switch_yuzu_firmware_dir" "$yuzu_config_firmware_dir"

	# LINK KEYS DIRECTORY
	message "log" "$addon_log" "Linking Keys Directory."
	create_slink_directory "$switch_yuzu_keys_dir" "$yuzu_config_keys_dir"

	# LINK SAVES DIRECTORIES
	message "log" "$addon_log" "Linking Saves Directories."
	create_slink_directory "$yuzu_system_saves_dir" "$yuzu_config_system_saves_dir"
	create_slink_directory "$yuzu_user_saves_dir" "$yuzu_config_user_saves_dir"

	# LINK AMIIBO DIRECTORY
	message "log" "$addon_log" "Linking Amiibo Directory."
	create_slink_directory "$switch_amiibo_dir" "$yuzu_config_amiibo_dir"

	# .DESKTOP FOR F1-APPLICATIONS MENU 
	message "log" "$addon_log" "Generating .desktop for F1-Applications Menu."
	generate_desktop_file "$local_applications_dir" "$local_icons_dir" "yuzu" "Yuzu-Config"

	# COPY LAUNCHER SCRIPTS
	message "log" "$addon_log" "Installing EmulationStation & Desktop Launcher Scripts"
	copy_make_executable "yuzu-config.sh" "$switch_install_scripts_dir" "$switch_system_dir"
	copy_make_executable "yuzu-launch.sh" "$switch_install_scripts_dir" "$switch_system_dir"

	# CREATE EMULATOR DIRECTORY
	message "log" "$addon_log" "Yuzu Emulator Directory Created."
	mkdir -p "$yuzu_emu_dir" 2>>"$stderr_log"

	# ADD EMULATOR TO ES SYSTEMS CONFIG FILE
	add_emulator_to_es_systems "yuzu-emu"
}


# INITIALLIZE EDEN STRUCTURES
initialize_eden() {

	# Backup Yuzu Saves
	backup_saves_yuzu

	# SETUP COMMON STRUCTURES
	initialize_common

	message "log" "$addon_log" "<<< [ INITIALLIZE EDEN STRUCTURES ]>>>"

	# SETUP FIRMWARE DIRECTORY
	if [ ! -d "$switch_yuzu_firmware_dir" ]; then
		message "log" "$addon_log" "Creating Firmware Directory."
		mkdir -p "$switch_yuzu_firmware_dir" 2>>"$stderr_log"
	fi

	# SETUP KEYS DIRECTORY
	if [ ! -d "$switch_yuzu_keys_dir" ]; then
		message "log" "$addon_log" "Creating Keys Directory."
		mkdir -p "$switch_yuzu_keys_dir" 2>>"$stderr_log"
	fi

	# CREATE & LINK ORIGINAL CONFIG DIRECTORIES TO NEW CONFIG DIRECTORIES (MORE CENTRALIZED)
	message "log" "$addon_log" "Linking Original Configuration Directories to New (Centralized) Configuration Directories."
	create_slink_directory "$eden_config_dir" "$eden_og_config_dir"
	create_slink_directory "$eden_config_dir" "$eden_og_local_config_dir"

	# ******************************************************************************
	# START USING NEW CONFIG DIRECTORIES FROM HERE ON OUT AS LINKS CREATE
	# ******************************************************************************

	# LINK FIRMWARE/NAND DIRECTORY
	message "log" "$addon_log" "Linking Firmware Directory. (Fork: Link Eden NAND -> Yuzu NAND)"
	create_slink_directory "$yuzu_config_dir/nand" "$eden_config_dir/nand"

	# LINK KEYS DIRECTORY
	message "log" "$addon_log" "Linking Keys Directory."
	create_slink_directory "$switch_yuzu_keys_dir" "$eden_config_keys_dir"

	# LINK SAVES DIRECTORY
	#	If Yuzu installed then taken care of by linking NAND to Yuzu NAND
	# 		But redo in case Yuzu was not installed
	message "log" "$addon_log" "Linking Saves Directories."
	create_slink_directory "$yuzu_system_saves_dir" "$yuzu_config_system_saves_dir"
	create_slink_directory "$yuzu_user_saves_dir" "$yuzu_config_user_saves_dir"

	# LINK AMIIBO DIRECTORY
	message "log" "$addon_log" "Linking Amiibo Directory."
	create_slink_directory "$switch_amiibo_dir" "$eden_config_amiibo_dir"

	# .DESKTOP FOR F1-APPLICATIONS MENU 
	message "log" "$addon_log" "Generating .desktop for F1-Applications Menu."
	generate_desktop_file "$local_applications_dir" "$local_icons_dir" "eden" "Eden-Config"

	# COPY LAUNCHER SCRIPTS
	copy_make_executable "eden-config.sh" "$switch_install_scripts_dir" "$switch_system_dir"
	copy_make_executable "eden-launch.sh" "$switch_install_scripts_dir" "$switch_system_dir"

	# CREATE EMULATOR DIRECTORY
	message "log" "$addon_log" "Eden Emulator Directory Created."
	mkdir -p "$eden_emu_dir" 2>>"$stderr_log"

	# ADD EMULATOR TO ES SYSTEMS CONFIG FILE
	add_emulator_to_es_systems "eden-emu"
}


# INITIALLIZE CITRON STRUCTURES
initialize_citron() {

	# Backup Yuzu Saves
	backup_saves_yuzu

	# SETUP COMMON STRUCTURES
	initialize_common

	message "log" "$addon_log" "<<< [ INITIALLIZE CITRON STRUCTURES ]>>>"

	# SETUP FIRMWARE DIRECTORY
	if [ ! -d "$switch_yuzu_firmware_dir" ]; then
		message "log" "$addon_log" "Creating Firmware Directory."
		mkdir -p "$switch_yuzu_firmware_dir" 2>>"$stderr_log"
	fi

	# SETUP KEYS DIRECTORY
	if [ ! -d "$switch_yuzu_keys_dir" ]; then
		message "log" "$addon_log" "Creating Keys Directory."
		mkdir -p "$switch_yuzu_keys_dir" 2>>"$stderr_log"
	fi

	# CREATE & LINK ORIGINAL CONFIG DIRECTORIES TO NEW CONFIG DIRECTORIES (MORE CENTRALIZED)
	message "log" "$addon_log" "Linking Original Configuration Directories to New (Centralized) Configuration Directories."
	create_slink_directory "$citron_config_dir" "$citron_og_config_dir"
	create_slink_directory "$citron_config_dir" "$citron_og_local_config_dir"

	# ******************************************************************************
	# START USING NEW CONFIG DIRECTORIES FROM HERE ON OUT AS LINKS CREATE
	# ******************************************************************************

	# LINK FIRMWARE/NAND DIRECTORY
	message "log" "$addon_log" "Linking Firmware Directory. (Fork: Link Citron NAND -> Yuzu NAND)"
	create_slink_directory "$yuzu_config_dir/nand" "$citron_config_dir/nand"

	# LINK KEYS DIRECTORY
	message "log" "$addon_log" "Linking Keys Directory."
	create_slink_directory "$switch_yuzu_keys_dir" "$citron_config_keys_dir"

	# LINK SAVES DIRECTORY
	#	If Yuzu installed then taken care of by linking NAND to Yuzu NAND
	# 		But redo in case Yuzu was not installed
	message "log" "$addon_log" "Linking Saves Directories."
	create_slink_directory "$yuzu_system_saves_dir" "$yuzu_config_system_saves_dir"
	create_slink_directory "$yuzu_user_saves_dir" "$yuzu_config_user_saves_dir"

	# LINK AMIIBO DIRECTORY
	message "log" "$addon_log" "Linking Amiibo Directory."
	create_slink_directory "$switch_amiibo_dir" "$citron_config_amiibo_dir"

	# .DESKTOP FOR F1-APPLICATIONS MENU 
	message "log" "$addon_log" "Generating .desktop for F1-Applications Menu."
	generate_desktop_file "$local_applications_dir" "$local_icons_dir" "citron" "Citron-Config"

	# COPY LAUNCHER SCRIPTS
	copy_make_executable "citron-config.sh" "$switch_install_scripts_dir" "$switch_system_dir"
	copy_make_executable "citron-launch.sh" "$switch_install_scripts_dir" "$switch_system_dir"

	# CREATE EMULATOR DIRECTORY
	message "log" "$addon_log" "Citron Emulator Directory Created."
	mkdir -p "$citron_emu_dir" 2>>"$stderr_log"

	# ADD EMULATOR TO ES SYSTEMS CONFIG FILE
	add_emulator_to_es_systems "citron-emu"
}
