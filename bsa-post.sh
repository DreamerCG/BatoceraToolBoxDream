#!/usr/bin/env bash 
# BATOCERA - SWITCH ADD-ON : POST INSTALL

# SOURCE GUARD TO PREVENT REDUNDANCY
[ -n "$SOURCED_POST" ] && return
SOURCED_POST=true



# POST INSTALL COMMON
post_install_common() {
	# SOURCE GUARD TO PREVENT REDUNDANCY
	[ -n "$RAN_POST_INSTALL_COMMON" ] && return

	message "log" "$addon_log" "<<< [ POST INSTALL COMMON ]>>>"

	# INSTALL BSA SCRIPTS
	# copy_make_executable "bsa-variables.sh" "./" "$switch_system_dir"
	# copy_make_executable "bsa-functions.sh" "./" "$switch_system_dir"
	# copy_make_executable "bsa-pre-common.sh" "$switch_install_scripts_dir" "$switch_system_dir"
	# copy_make_executable "bsa-mousemove.sh" "$switch_install_scripts_dir" "$switch_bin_dir"
	copy_make_executable "ryujinxloadfirmware.sh" "$switch_install_configgen_dir/generators" "$switch_configgen_dir/generators"

	CONFIG_FILE="/userdata/system/batocera.conf"

	# R�cup�re la langue actuelle
	batocera_language=$(grep '^system.language=' "$CONFIG_FILE" | cut -d '=' -f2)
	
	# Si la langue est FR, ajoute les lignes seulement si elles n'existent pas d�j�
	if [ "$batocera_language" = "fr_FR" ]; then
		grep -q "^switch.region=" "$CONFIG_FILE" || echo "switch.region=2" >> "$CONFIG_FILE"
		grep -q "^switch.language=" "$CONFIG_FILE" || echo "switch.language=2" >> "$CONFIG_FILE"
		message "both" "$addon_log" "- Preconfiguration en FR pour la switch"		
	fi

	# INSTALL PORTS
	post_install_ports

	# SOURCE GUARD TO PREVENT REDUNDANCY
	RAN_POST_INSTALL_COMMON=true
}


# POST INSTALL RYUJINX
post_install_ryujinx() {
	# POST INSTALL COMMON
	post_install_common

	message "log" "$addon_log" "<<< [ POST INSTALL FOR RYUJINX ]>>>"

	# INSTALL BSA SCRIPTS
	# copy_make_executable "ryujinx-controller-patcher.sh" "$switch_install_scripts_dir" "$switch_bin_dir"
	# copy_make_executable "ryujinx-fixes.sh" "$switch_install_scripts_dir" "$switch_bin_dir"
	copy_make_executable "ryujinx_config.sh" "$switch_install_roms_ports_dir" "$switch_ports_dir"
	copy_make_executable "ryujinx_config.sh.keys" "$switch_install_roms_ports_dir" "$switch_ports_dir"
	cp -f "$switch_install_script_dir/install/gamecontroller_ryujinx.txt" "$switch_configgen_dir/generators/gamecontroller_ryujinx.txt" 2>>"$stderr_log"

	gamelist_file="/userdata/roms/ports/gamelist.xml"
	# Ensure the gamelist.xml exists
	if [ ! -f "$gamelist_file" ]; then
		echo '<?xml version="1.0" encoding="UTF-8"?><gameList></gameList>' > "$gamelist_file"
	fi

	xmlstarlet ed -L \
		-d "/gameList/game[path='./ryujinx_config.sh']" \
		-s "/gameList" -t elem -n "game" -v "" \
		-s "/gameList/game[last()]" -t elem -n "path" -v "./ryujinx_config.sh" \
		-s "/gameList/game[last()]" -t elem -n "name" -v "Configuration de Ryujinx" \
		-s "/gameList/game[last()]" -t elem -n "desc" -v "Configuration de Ryujinx" \
		-s "/gameList/game[last()]" -t elem -n "developer" -v "Ryujinx" \
		-s "/gameList/game[last()]" -t elem -n "publisher" -v "Ryujinx" \
		-s "/gameList/game[last()]" -t elem -n "genre" -v "Toolbox" \
		-s "/gameList/game[last()]" -t elem -n "rating" -v "1.00" \
		-s "/gameList/game[last()]" -t elem -n "region" -v "eu" \
		-s "/gameList/game[last()]" -t elem -n "lang" -v "fr" \
		-s "/gameList/game[last()]" -t elem -n "image" -v "./images/ryujinx_config-image.png" \
		-s "/gameList/game[last()]" -t elem -n "marquee" -v "./images/ryujinx_config-logo.png" \
		-s "/gameList/game[last()]" -t elem -n "thumbnail" -v "./images/ryujinx_config.png" \
		"$gamelist_file"

		message "both" "$addon_log" "- Ajout de Ryujinx Config dans la game list $gamelist_file"		

	# On restaure les mods Ryujinx depuis ryujinx_mods_backup_dir
	restore_saves_mods_ryujinx

}

# POST INSTALL YUZU COMMON
post_install_yuzu_common() {
	# SOURCE GUARD TO PREVENT REDUNDANCY
	[ -n "$RAN_POST_INSTALL_COMMON_YUZU" ] && return
	
	# POST INSTALL COMMON
	post_install_common

	message "log" "$addon_log" "<<< [ POST INSTALL COMMON FOR YUZU & FORKS ]>>>"

	# INSTALL BSA SCRIPTS
	# copy_make_executable "yuzu-controller-patcher.sh" "$switch_install_scripts_dir" "$switch_bin_dir"
	copy_make_executable "yuzu_config.sh" "$switch_install_roms_ports_dir" "$switch_ports_dir"
	copy_make_executable "yuzu_config.sh.keys" "$switch_install_roms_ports_dir" "$switch_ports_dir"
	copy_make_executable "citron_config.sh" "$switch_install_roms_ports_dir" "$switch_ports_dir"
	copy_make_executable "citron_config.sh.keys" "$switch_install_roms_ports_dir" "$switch_ports_dir"

	gamelist_file="/userdata/roms/ports/gamelist.xml"
	# Ensure the gamelist.xml exists
	if [ ! -f "$gamelist_file" ]; then
		echo '<?xml version="1.0" encoding="UTF-8"?><gameList></gameList>' > "$gamelist_file"
	fi
	
	xmlstarlet ed -L \
	  -d "/gameList/game[path='./citron_config.sh']" \
	  -s "/gameList" -t elem -n "game" -v "" \
	  -s "/gameList/game[last()]" -t elem -n "path" -v "./citron_config.sh" \
	  -s "/gameList/game[last()]" -t elem -n "name" -v "Configuration de Citron" \
	  -s "/gameList/game[last()]" -t elem -n "desc" -v "Configuration de Citron" \
	  -s "/gameList/game[last()]" -t elem -n "developer" -v "Citron" \
	  -s "/gameList/game[last()]" -t elem -n "publisher" -v "Citron" \
	  -s "/gameList/game[last()]" -t elem -n "genre" -v "Toolbox" \
	  -s "/gameList/game[last()]" -t elem -n "rating" -v "1.00" \
	  -s "/gameList/game[last()]" -t elem -n "region" -v "eu" \
	  -s "/gameList/game[last()]" -t elem -n "lang" -v "fr" \
	  -s "/gameList/game[last()]" -t elem -n "image" -v "./images/citron_config-image.png" \
	  -s "/gameList/game[last()]" -t elem -n "marquee" -v "./images/citron_config-logo.png" \
	  -s "/gameList/game[last()]" -t elem -n "thumbnail" -v "./images/citron_config.png" \
	  "$gamelist_file"
	  
	message "both" "$addon_log" "- Ajout de Eden Config dans la game list $gamelist_file"


	xmlstarlet ed -L \
	  -d "/gameList/game[path='./yuzu_config.sh']" \
	  -s "/gameList" -t elem -n "game" -v "" \
	  -s "/gameList/game[last()]" -t elem -n "path" -v "./yuzu_config.sh" \
	  -s "/gameList/game[last()]" -t elem -n "name" -v "Configuration de Eden" \
	  -s "/gameList/game[last()]" -t elem -n "desc" -v "Configuration de Eden" \
	  -s "/gameList/game[last()]" -t elem -n "developer" -v "Eden" \
	  -s "/gameList/game[last()]" -t elem -n "publisher" -v "Eden" \
	  -s "/gameList/game[last()]" -t elem -n "genre" -v "Toolbox" \
	  -s "/gameList/game[last()]" -t elem -n "rating" -v "1.00" \
	  -s "/gameList/game[last()]" -t elem -n "region" -v "eu" \
	  -s "/gameList/game[last()]" -t elem -n "lang" -v "fr" \
	  -s "/gameList/game[last()]" -t elem -n "image" -v "./images/yuzu_config-image.png" \
	  -s "/gameList/game[last()]" -t elem -n "marquee" -v "./images/yuzu_config-logo.png" \
	  -s "/gameList/game[last()]" -t elem -n "thumbnail" -v "./images/yuzu_config.png" \
	  "$gamelist_file"
	  
	message "both" "$addon_log" "- Ajout de Eden Config dans la game list $gamelist_file"


	message "both" "$addon_log" "- Demarrage de la copie des mods Yuzu/Citron/Eden/, Merci de patienter cela peut etre long"
	message "both" "$addon_log" "- Selon la taille des mods cela peut prendre plusieurs minutes..."
	
	# On restaure les mods Yuzu/Citron/Eden/Sudachi depuis yuzu_mods_backup_dir
	restore_saves_mods_yuzu


	# SOURCE GUARD TO PREVENT REDUNDANCY
	RAN_POST_INSTALL_COMMON_YUZU=true
}


# POST INSTALL YUZU
post_install_yuzu() {
	# POST INSTALL COMMON YUZU
	post_install_yuzu_common

	message "log" "$addon_log" "<<< [ POST INSTALL FOR YUZU ]>>>"

	# REPLACE WITH CODE
	message "log" "$addon_log" "N/A"
}


# POST INSTALL EDEN
post_install_eden() {
	# POST INSTALL COMMON YUZU
	post_install_yuzu_common

	message "log" "$addon_log" "<<< [ POST INSTALL FOR EDEN ]>>>"

	# REPLACE WITH CODE
	message "log" "$addon_log" "N/A"
}

# POST INSTALL EDEN PGO
post_install_eden_pgo() {
	# POST INSTALL COMMON YUZU
	post_install_yuzu_common

	message "log" "$addon_log" "<<< [ POST INSTALL FOR EDEN ]>>>"

	# REPLACE WITH CODE
	message "log" "$addon_log" "N/A"
}


# POST INSTALL CITRON
post_install_citron() {
	# POST INSTALL COMMON YUZU
	post_install_yuzu_common

	message "log" "$addon_log" "<<< [ POST INSTALL FOR CITRON ]>>>"

	# REPLACE WITH CODE
	message "log" "$addon_log" "N/A"
}

