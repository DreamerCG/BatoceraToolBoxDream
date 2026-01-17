#!/usr/bin/env bash 
# BATOCERA - SWITCH ADD-ON: INSTALL
export DISPLAY=:0.0
reset
clear

# THIS SCRIPT
this_script_file="${0##*/}"
this_script_file_name="${this_script_file%.*}"
this_script_file_ext="${this_script_file##*.}"


# MAKES EXECUTABLE
dos2unix *.sh 2>>/dev/null
chmod a+x *.sh 2>>/dev/null
dos2unix *.py 2>>/dev/null
chmod a+x *.py 2>>/dev/null

# GLOBAL VARIABLES
source bsa-variables.sh

# GLOBAL FUNCTIONS
source bsa-functions.sh

# ******************************************************************************
# CHECK SYSTEM BEFORE PROCEEDING
# ******************************************************************************
if [[ "$(uname -a | grep "x86_64")" = "" ]]; then
	message "both" "$addon_log" "ERROR :: SYSTEM NOT SUPPORTED :: INSTALLATION ABORTED!" ""
	exit 0
fi


# PURGE INSTALLATION LOG FILE
purge_install_log() {
	rm "$addon_log" 2>>"$stderr_log"
	message "log" "$addon_log" "-=[ BATOCERA :: SWITCH // ADD-ON :: LOG }]=-\n"
	message "log" "$addon_log" " -------------------" "[$(date +"%Y/%m/%d %H:%M:%S")]" " -------------------"
}


# ******************************************************************************
# INTERNET CONNECTION SETUP
# ******************************************************************************
sysctl -w net.ipv6.conf.default.disable_ipv6=1 1>/dev/null 2>>"$stderr_log"
sysctl -w net.ipv6.conf.all.disable_ipv6=1 1>/dev/null 2>>"$stderr_log"


# ******************************************************************************
# INSTALLATION FUNCTIONS
# ******************************************************************************
# INITIALLIZATION FUNCTIONS (SETUP COMMON & EMULATOR SPECEFIC STRUCTURES [PRE-INSTALL])
source bsa-initialize.sh

# INSTALL EMULATORS FUNCTIONS
source bsa-emulators.sh

# UNPACK PACKAGES FUNCTIONS
source bsa-packages.sh

# POST INSTALL FUNCTIONS
source bsa-post.sh

# UNINSTALL FUNCTIONS
source bsa-uninstall.sh

# FULL INSTALL EMULATOR
full_install() {
	local emu="${1,,}";
	"initialize_${emu}"			# Setup directory structures
	"install_emulator_${emu}"	# Install Emulator (AppImage)
	"unpack_packages_${emu}"	# Install Required Libraries 
	"post_install_${emu}"		# Post Installation Processes
}

# UPDATE APPIMAGE
update_emulator() {
	local emu="${1,,}"
	local update_type="${2:-local}"
	update_type="${update_type,,}"
	local -n emu_file="${emu}_install_file"

	message "log" "$addon_log" "<<< [ UPDATE ${emu^^} ]>>>"
	# if remote update and AppImage in BSA then rename it
	if [ "$update_type" = "remote" ]; then
		local backup_file="$(rename_file_with_timestamp "$switch_install_emus_dir/$emu_file")"
		if [ "$backup_file" != "" ]; then
			message "log" "$addon_log" "${emu^^} APPIAMGE BACKED UP TO: $backup_file"
		fi
	fi

	# Re-install the emulator
	"initialize_${emu}"
	"install_emulator_${emu}"
	
}

# ******************************************************************************
# FUNCTIONS FOR SAVES BACKUP
# ******************************************************************************

	# BACKUP RYUJINX SAVES
	backup_saves_ryujinx() {
		local save_file="$switch_saves_dir/saves-ryujinx_$(date +"%Y%m%d_%H%M%S").zip"
		message "both" "$addon_log" "<<< [ BACKUP RYUJINX SAVES ]>>>"
		zip_it "$ryujinx_config_nand_dir" "$save_file"
		message "both" "$addon_log" "Backup Ryujinx Saves completed: $save_file"
		message "both" "$addon_log" " from $ryujinx_config_nand_dir"
	}

	# BACKUP YUZU SAVES
	backup_saves_yuzu() {
		local save_file="$switch_saves_dir/saves-yuzu_$(date +"%Y%m%d_%H%M%S").zip"
		message "both" "$addon_log" "<<< [ BACKUP YUZU SAVES ]>>>"
		zip_it "$yuzu_config_nand_dir" "$save_file"
		message "both" "$addon_log" "Backup Yuzu Saves completed: $save_file from $yuzu_config_nand_dir"	
		message "both" "$addon_log" "from $yuzu_config_nand_dir"	
	}
	
	# Backup des mods dans yuzu_mods_backup_dir 
	backup_mods_yuzu() {
		local save_mod_file="$switch_saves_dir/mods-yuzu_$(date +"%Y%m%d_%H%M%S").zip"
		message "both" "$addon_log" "<<< [ BACKUP YUZU MODS/CITRON/EDEN/SUDACHI ]>>>"
		mkdir -p "$yuzu_mods_temp_dir"
		zip_it "$yuzu_mods_dir" "$save_mod_file"
		# cp -r "$yuzu_mods_dir"/* "$yuzu_mods_temp_dir"/ 2>>"$stderr_log"
		message "both" "$addon_log" "Mods Citron/Eden/Sudachi/Yuzu moved to: $yuzu_mods_temp_dir"
	}

	# Backup des mods dans yuzu_mods_backup_dir 
	backup_mods_ryujinx() {
		local save_mod_file="$switch_saves_dir/mods-ryujinx_$(date +"%Y%m%d_%H%M%S").zip"
		message "both" "$addon_log" "<<< [ BACKUP RYUJINX MODS ]>>>"
		mkdir -p "$ryujinx_mods_temp_dir"
		zip_it "$ryujinx_mods_dir" "$save_mod_file"		
		# cp -r "$ryujinx_mods_dir"/* "$ryujinx_mods_temp_dir"/ 2>>"$stderr_log"
		message "both" "$addon_log" "Mods Ryujinx moved to: $ryujinx_mods_temp_dir"
	}


	# Backup des mods dans yuzu_mods_backup_dir 
	move_mods_yuzu() {
		mkdir -p "$yuzu_mods_temp_dir"
		cp -r "$yuzu_mods_dir"/* "$yuzu_mods_temp_dir"/ 2>>"$stderr_log"
		message "both" "$addon_log" "Mods Citron/Eden/Sudachi/Yuzu moved to: $yuzu_mods_temp_dir"
	}

	# Backup des mods dans yuzu_mods_backup_dir 
	move_mods_ryujinx() {
		mkdir -p "$ryujinx_mods_temp_dir"
		cp -r "$ryujinx_mods_dir"/* "$ryujinx_mods_temp_dir"/ 2>>"$stderr_log"
		message "both" "$addon_log" "Mods Ryujinx moved to: $ryujinx_mods_temp_dir"
	}


# ******************************************************************************
# MENUS
# ******************************************************************************
menu_title="Toolbox Switch -  Batocera : V$batocera_version"
menu_width=65
menu_height=20
menu_list_height=12

# DISPLAY INSTALL LOG
display_install_log() {
	create_dialog_textbox "$menu_title :: INSTALL LOG" "$menu_height" "$menu_width" "DONE" "$addon_log"
}


# Install Menu
install_menu() {
	local menu_items=(
		"Eden|Installation : Eden|off|fn|full_install "eden""
		"Citron|Installation : Citron|off|fn|full_install "citron""
		"Ryujinx|Installation : Ryujinx|off|fn|full_install "ryujinx""
	)
	unset RAN_POST_INSTALL_COMMON
	unset RAN_POST_INSTALL_COMMON_YUZU
	create_dialog_checkbox_menu \
		"$menu_title :: Install" "$menu_height" "$menu_width" "$menu_list_height" \
		"Lancer" "Annuler" "on" \
		"Choix des emulateurs" \
		"Confirmer l'installation" "Install?" \
		"TOOLBOX :: Installation" "" \
		"Installation" "Installation terminer" \
		"${menu_items[@]}"
}

# Updates Menu
updates_menu() {
	local menu_items=(
		"Eden Local|Mise à jour Eden Local|off|fn|update_emulator "eden" "local""
		"Eden Remote|Mise à jour Eden Remote|off|fn|update_emulator "eden" "remote""
		"Citron Local|Mise à jour Citron Local|off|fn|update_emulator "citron" "local""
		"Citron Remote|Mise à jour Citron Remote|off|fn|update_emulator "citron" "remote""
		"Ryujinx Local|Mise à jour Ryujinx Local|off|fn|update_emulator "ryujinx" "local""
		"Ryujinx Remote|Mise à jour Ryujinx Remote|off|fn|update_emulator "ryujinx" "remote""
	)
	create_dialog_checkbox_menu \
		"$menu_title :: Update" "$menu_height" "$menu_width" "$menu_list_height" \
		"MISE A JOUR" "Annuler" "on" \
		"Choix des emulateurs à mettre à jour" \
		"Confirmer la mise à jour" "Update?" \
		"TOOLBOX :: UPDATING" "" \
		"UPDATING" "UPDATED" \
		"${menu_items[@]}"
}


# Saves Menu
saves_menu() {
	local menu_items=(
		"BACKUP RYUJINX|Backup Ryujinx Saves|on|fn|backup_saves_ryujinx"
		"BACKUP Mods RYUJINX|Backup Ryujinx Mods|on|fn|backup_mods_ryujinx"
		"BACKUP Eden/Citron/YUZU|Backup Yuzu Saves|on|fn|backup_saves_yuzu"
		"BACKUP Mods Eden/Citron/YUZU|Backup Yuzu Mods|on|fn|backup_mods_yuzu"
	)
	create_dialog_checkbox_menu \
		"$menu_title :: Saves" "$menu_height" "$menu_width" "$menu_list_height" \
		"Sauvegarder!" "Annuler" "on" \
		"Select Options for Saves" \
		"Confirm Saves Options" "Save it?" \
		"BSA :: SAVES" "" \
		"SAVES OPTION" "COMPLETE" \
		"${menu_items[@]}"
}

# Uninstall Menu
uninstall_menu() {
	local menu_items=(
		"Emulateur|Supprimer les emulateurs|off|fn|uninstall_BSA"
		"Firmware|Supprimer les Firmware|off|fn|uninstall_firmware"
		"Keys|Supprimer les Keys|off|fn|uninstall_keys"
		"Amiibo|Supprimer les Amiibo|off|fn|uninstall_amiibo"
		# "Saves|Supprimer Saves|off|fn|uninstall_saves"
	)
	create_dialog_checkbox_menu \
		"$menu_title :: Uninstall" "$menu_height" "$menu_width" "$menu_list_height" \
		"Desinstaller" "Annuler" "on" \
		"Choix des packages à désinstaller" \
		"Confirmer la désinstallation" "Desinstaller?" \
		":: Desinstallation" "" \
		"Desinstallation" "Desinstallation" \
		"${menu_items[@]}"
}

confirm_purge_install_log() {
	if create_dialog_confirm "$menu_title :: Purge Install Log" $height $width "PURGE INSTALL LOG?"; then
		purge_install_log
		dialog --clear --msgbox "INSTALL LOG PURGED!" $height $width
	fi
}

# Main Menu
main_menu() {
	local exit_status
	local menu_items=(
		"INSTALLATION|Installation des emulateurs|fn|install_menu"
		"MISE A JOUR|Mise à jour des emulateurs|fn|updates_menu"
		"SAUVEGARDES|Gestion des sauvegardes|fn|saves_menu"
		"DESINSTALLATION|Desinstaller les emulateurs|fn|uninstall_menu"
		"MISE A JOUR TOOLBOX|Mise à jour de la toolbox|fn|update_bsa_toolbox"
		"QUITTER|Quitter|cmd|killall -9 xterm; exit 0"
	)
	while true; do
		create_dialog_list_menu \
			"$menu_title" "$menu_height" "$menu_width" "$menu_list_height" \
			"Confirmer" "Annuler" "off" \
			"MENU" \
			"${menu_items[@]}"
		exit_status=$?
		case $exit_status in
			1|255)
				# Annuler
				clear			
				exit
			;;
		esac
	done
}


update_bsa_toolbox() {
                clear
                DISPLAY=:0.0 xterm -fs 12 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0  curl -sL https://bit.ly/DreamerCGToolBoxBatocera | bash"
}


# ******************************************************************************
# START HERE
# ******************************************************************************
# create log file if it does not exist
[[ -f "$addon_log" ]] || purge_install_log

#run main menu
main_menu

# ******************************************************************************
# -FIN-
# ******************************************************************************
