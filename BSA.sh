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

	"install_emulator_${emu}"
}

# MOVE ROMS
# This will move the ROMs from the BSA roms directory to Batocera's roms directory
# By default the install copies the ROMs
move_roms() {
	message "log" "$addon_log" "<<< [ MOVE ROMS ]>>>"
	copy_roms "$switch_install_roms_switch_dir" "$switch_roms_dir" "yes"
}

# BACKUP RYUJINX SAVES
backup_saves_ryujinx() {
	local save_file="$switch_saves_dir/saves-ryujinx_$(date +"%Y%m%d_%H%M%S").zip"
	message "log" "$addon_log" "<<< [ BACKUP RYUJINX SAVES ]>>>"
	zip_it "$ryujinx_saves_dir" "$save_file"
	message "log" "$addon_log" "CURRENT RYUJINX SAVES BACKED-UP: $save_file"
}

# BACKUP RYUJINX SAVES TO BSA PACKAGES
backup_saves_ryujinx_bsa() {
	local save_file="$switch_install_packages_dir/saves-ryujinx.zip"
	message "log" "$addon_log" "<<< [ BACKUP RYUJINX SAVES TO BSA PACKAGES ]>>>"
	local back_save_file="$(rename_file_with_timestamp "$save_file")"
	message "log" "$addon_log" "BSA PACKAGES RYUJINX SAVES RENAMED AS: $back_save_file"
	zip_it "$ryujinx_saves_dir" "$save_file"
	message "log" "$addon_log" "CURRENT RYUJINX SAVES BACKED-UP TO BSA PACKAGES"
}

# BACKUP YUZU SAVES
backup_saves_yuzu() {
	local save_file="$switch_saves_dir/saves-yuzu_$(date +"%Y%m%d_%H%M%S").zip"
	message "log" "$addon_log" "<<< [ BACKUP YUZU SAVES ]>>>"
	zip_it "$yuzu_saves_dir" "$save_file"
	message "log" "$addon_log" "CURRENT YUZU SAVES BACKED-UP: $save_file"
}

# BACKUP YUZU SAVES TO BSA PACKAGES
backup_saves_yuzu_bsa() {
	local save_file="$switch_install_packages_dir/saves-yuzu.zip"
	message "log" "$addon_log" "<<< [ BACKUP YUZU SAVES TO BSA PACKAGES ]>>>"
	local back_save_file="$(rename_file_with_timestamp "$save_file")"
	message "log" "$addon_log" "BSA PACKAGES YUZU SAVES RENAMED AS: $back_save_file"
	zip_it "$yuzu_saves_dir" "$save_file"
	message "log" "$addon_log" "CURRENT YUZU SAVES BACKED-UP TO BSA PACKAGES"
}


# ******************************************************************************
# MENUS
# ******************************************************************************
menu_title="BATOCERA Switch Add-On"
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
		"Ryujinx|Install Ryujinx|on|fn|full_install "ryujinx""
		"Yuzu|Install Yuzu|on|fn|full_install "yuzu""
		"Eden|Install Eden|on|fn|full_install "eden""
		"Citron|Install Citron|on|fn|full_install "citron""
		"Sudachi|Install Sudachi|on|fn|full_install "sudachi""
	)
	unset RAN_POST_INSTALL_COMMON
	unset RAN_POST_INSTALL_COMMON_YUZU
	create_dialog_checkbox_menu \
		"$menu_title :: Install" "$menu_height" "$menu_width" "$menu_list_height" \
		"INSTALL" "CANCEL" "on" \
		"Select Emulators to Install" \
		"Confirm Install" "Install?" \
		"BSA :: INSTALLING" "" \
		"INSTALLING" "INSTALLED" \
		"${menu_items[@]}"
}

# Updates Menu
updates_menu() {
	local menu_items=(
		"Ryujinx Local|Update Ryujinx Local|off|fn|update_emulator "ryujinx" "local""
		"Ryujinx Remote|Update Ryujinx Remote|off|fn|update_emulator "ryujinx" "remote""
		"Yuzu Local|Update Yuzu Local|off|fn|update_emulator "yuzu" "local""
		"Yuzu Remote|Update Yuzu Remote|off|fn|update_emulator "yuzu" "remote""
		"Eden Local|Update Eden Local|off|fn|update_emulator "eden" "local""
		"Eden Remote|Update Eden Remote|off|fn|update_emulator "eden" "remote""
		"Citron Local|Update Citron Local|off|fn|update_emulator "citron" "local""
		"Citron Remote|Update Citron Remote|off|fn|update_emulator "citron" "remote""
		"Sudachi Local|Update Sudachi Local|off|fn|update_emulator "sudachi" "local""
		"Sudachi Remote|Update Sudachi Remote|off|fn|update_emulator "sudachi" "remote""
	)
	create_dialog_checkbox_menu \
		"$menu_title :: Update" "$menu_height" "$menu_width" "$menu_list_height" \
		"UPDATE" "CANCEL" "on" \
		"Select Emulators to Update" \
		"Confirm Update" "Update?" \
		"BSA :: UPDATING" "" \
		"UPDATING" "UPDATED" \
		"${menu_items[@]}"
}

# Packages Menu
packages_menu() {
	local menu_items=(
		"Ryujinx Firmware|Unpack Ryujinx Firmware|off|fn|unpack_packages_ryujinx_firmware"
		"Yuzu Firmware|Unpack Yuzu Firmware|off|fn|unpack_packages_yuzu_firmware"
		"Ryujinx Keys|Unpack Ryujinx Keys|off|fn|unpack_packages_ryujinx_keys"
		"Yuzu Keys|Unpack Yuzu Keys|off|fn|unpack_packages_yuzu_keys"
		"Ryujinx Saves|Unpack Ryujinx Saves|off|fn|unpack_packages_ryujinx_saves"
		"Yuzu Saves|Unpack Yuzu Saves|off|fn|unpack_packages_yuzu_saves"
		"Amiibo|Unpack Amiibo|off|fn|unpack_packages_amiibo"
		#"NSZ|Unpack NSZ|off|fn|unpack_packages_nsz"
	)
	unset RAN_UNPACK_PACKAGES_COMMON
	unset RAN_UNPACK_PACKAGES_COMMON_YUZU
	create_dialog_checkbox_menu \
		"$menu_title :: Packages" "$menu_height" "$menu_width" "$menu_list_height" \
		"UNPACK" "CANCEL" "on" \
		"Select Packagess to Unpack" \
		"Confirm Unpack" "Unpack?" \
		"BSA :: UNPACKING" "" \
		"UNPACKING" "UNPACKED" \
		"${menu_items[@]}"
}

# ROMs Menu
roms_menu() {
	local menu_items=(
		"COPY ROMS|Copy ROMs from BSA|on|fn|post_install_roms"
		"COPY PORTS|Sudachi QLauncher|off|fn|post_install_ports"
		"MOVE ROMS|Move ROMs from BSA|off|fn|move_roms"
	)
	create_dialog_checkbox_menu \
		"$menu_title :: Roms" "$menu_height" "$menu_width" "$menu_list_height" \
		"DO IT!" "CANCEL" "on" \
		"Select Options for ROMs" \
		"Confirm ROMs Options" "Do it?" \
		"BSA :: ROMS" "" \
		"ROM OPTION" "COMPLETE" \
		"${menu_items[@]}"
}

# Saves Menu
saves_menu() {
	local menu_items=(
		"BACKUP RYUJINX|Backup Ryujinx Saves|on|fn|backup_saves_ryujinx"
		"BACKUP YUZU|Backup Yuzu Saves|on|fn|backup_saves_yuzu"
		"BSA RYUJINX|Backup Ryujinx Saves to BSA Packages|off|fn|backup_saves_ryujinx_bsa"
		"BSA YUZU|Backup Yuzu Saves to BSA Packages|off|fn|backup_saves_yuzu_bsa"
	)
	create_dialog_checkbox_menu \
		"$menu_title :: Saves" "$menu_height" "$menu_width" "$menu_list_height" \
		"SAVE IT!" "CANCEL" "on" \
		"Select Options for Saves" \
		"Confirm Saves Options" "Save it?" \
		"BSA :: SAVES" "" \
		"SAVES OPTION" "COMPLETE" \
		"${menu_items[@]}"
}

# Fixes Menu
fixes_menu() {
	local menu_items=(
		"Ryujinx|Fix Ryujinx Structure|off|fn|initialize_ryujinx"
		"Yuzu|Fix Yuzu Structure|off|fn|initialize_yuzu"
		"Eden|Fix Eden Structure|off|fn|initialize_eden"
		"Citron|Fix Citron Structure|off|fn|initialize_citron"
		"Sudachi|Fix Sudachi Structure|off|fn|initialize_sudachi"
	)
	unset RAN_INITIALIZE_COMMON
	create_dialog_checkbox_menu \
		"$menu_title :: Fixes" "$menu_height" "$menu_width" "$menu_list_height" \
		"FIX" "CANCEL" "on" \
		"Select Fixes to Apply" \
		"Confirm Fixes" "Apply?" \
		"BSA :: FIXING" "" \
		"FIXING" "FIXED" \
		"${menu_items[@]}"
}

# Uninstall Menu
uninstall_menu() {
	local menu_items=(
		"BSA|Remove BSA not Firmware/Keys/Saves/Amiibo|off|fn|uninstall_BSA"
		"Firmware|Remove Firmware|off|fn|uninstall_firmware"
		"Keys|Remove Keys|off|fn|uninstall_keys"
		"Amiibo|Remove Amiibo|off|fn|uninstall_amiibo"
		"Saves|Remove Saves|off|fn|uninstall_saves"
		"ROMs|Remove ROMS|off|fn|uninstall_roms"
	)
	create_dialog_checkbox_menu \
		"$menu_title :: Uninstall" "$menu_height" "$menu_width" "$menu_list_height" \
		"UNINSTALL" "CANCEL" "on" \
		"Select Emulators/Packages to Uninstall" \
		"Confirm Uninstall" "Uninstall?" \
		"BSA :: UNINSTALLING" "" \
		"UNINSTALLING" "UNINSTALLED" \
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
		"INSTALL|Install Batocera Switch Add-on|fn|install_menu"
		"UPDATES|Updates|fn|updates_menu"
		"PACKAGES|Packages (Firmware, Keys, Saves, Amiibo)|fn|packages_menu"
		"ROMS|ROMs Options|fn|roms_menu"
		"SAVES|Saves Options|fn|saves_menu"
		"FIXES|Fix directory structure & others|fn|fixes_menu"
		"UNINSTALL|Uninstall Batocera Switch Add-on|fn|uninstall_menu"
		"DISPLAY LOG|Display Install Log|fn|display_install_log"
		"PURGE LOG|Purge Install Log|fn|confirm_purge_install_log"
		"EXIT|Exit to the Street|cmd|exit_tools"
	)
	while true; do
		create_dialog_list_menu \
			"$menu_title" "$menu_height" "$menu_width" "$menu_list_height" \
			"OPEN" "CANCEL" "off" \
			"DO YOU WANT TO SWITCH?" \
			"${menu_items[@]}"
		exit_status=$?
		case $exit_status in
			1|255)
				# Cancel
				clear			
				exit
			;;
		esac
	done
}

exit_tools() {
                killall -9 xterm
				killall -9 emulationstation
                clear
                exit 0
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
