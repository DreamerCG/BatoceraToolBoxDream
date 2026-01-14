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
	copy_make_executable "bsa-variables.sh" "./" "$switch_system_dir"
	copy_make_executable "bsa-functions.sh" "./" "$switch_system_dir"
	copy_make_executable "bsa-pre-common.sh" "$switch_install_scripts_dir" "$switch_system_dir"
	copy_make_executable "bsa-mousemove.sh" "$switch_install_scripts_dir" "$switch_bin_dir"
	copy_make_executable "bsa-nsz-converter.sh" "$switch_install_scripts_dir" "$switch_bin_dir"

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
	copy_make_executable "ryujinx-controller-patcher.sh" "$switch_install_scripts_dir" "$switch_bin_dir"
	copy_make_executable "ryujinx-fixes.sh" "$switch_install_scripts_dir" "$switch_bin_dir"
	copy_make_executable "ryujinx_config.sh" "$switch_install_roms_dir" "$switch_ports_dir"
	copy_make_executable "ryujinx_config.sh.key" "$switch_install_roms_dir" "$switch_ports_dir"

}


# POST INSTALL YUZU COMMON
post_install_yuzu_common() {
	# SOURCE GUARD TO PREVENT REDUNDANCY
	[ -n "$RAN_POST_INSTALL_COMMON_YUZU" ] && return
	
	# POST INSTALL COMMON
	post_install_common

	message "log" "$addon_log" "<<< [ POST INSTALL COMMON FOR YUZU & FORKS ]>>>"

	# INSTALL BSA SCRIPTS
	copy_make_executable "yuzu-controller-patcher.sh" "$switch_install_scripts_dir" "$switch_bin_dir"
	copy_make_executable "yuzu_config.sh" "$switch_install_roms_dir" "$switch_ports_dir"
	copy_make_executable "yuzu_config.sh.key" "$switch_install_roms_dir" "$switch_ports_dir"

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


# POST INSTALL CITRON
post_install_citron() {
	# POST INSTALL COMMON YUZU
	post_install_yuzu_common

	message "log" "$addon_log" "<<< [ POST INSTALL FOR CITRON ]>>>"

	# REPLACE WITH CODE
	message "log" "$addon_log" "N/A"
}

