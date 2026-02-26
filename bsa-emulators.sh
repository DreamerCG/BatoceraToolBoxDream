#!/usr/bin/env bash 
# BATOCERA - SWITCH ADD-ON : INSTALL EMULATOR APPIMAGES / BINARIES

# SOURCE GUARD TO PREVENT REDUNDANCY
[ -n "$SOURCED_EMULATORS" ] && return
SOURCED_EMULATORS=true


# INSTALL RYUJINX APPIMAGE
install_emulator_ryujinx() {
	message "log" "$addon_log" "<<< [ INSTALL RYUJINX APPIMAGE ]>>>"

	# INSTALL/UNPACK EMULATOR
	# EMULATOR INSTALL ARCHIVE/APP NOT FOUND LOCALLY THEN ATTEMPT TO DOWNLOAD
	message "log" "$addon_log" "Installing Ryujinx Emulator App"
	# Get lastest version from database & set the version for download
	ryujinx_release_html="$(curl -s "https://release-monitoring.org/project/377871/")"
	ryujinx_install_url="https://git.ryujinx.app/api/v4/projects/1/packages/generic/Ryubing/1.3.3/ryujinx-1.3.3-x64.AppImage"
	
	# If missing from local storage then attempt to download latest version
	download_missing_file "$ryujinx_install_url" "$switch_install_emus_dir/$ryujinx_install_file" "Ryujinx (Ryubing)"
	if [ $wget_exit_code -eq 0 ]; then
		copy_make_executable "$ryujinx_install_file" "$switch_install_emus_dir" "$ryujinx_emu_dir"
	fi
}


# INSTALL YUZU APPIMAGE
install_emulator_yuzu() {
	message "log" "$addon_log" "<<< [ INSTALL YUZU APPIMAGE ]>>>"

	# INSTALL/UNPACK EMULATOR
	# EMULATOR INSTALL ARCHIVE/APP NOT FOUND LOCALLY THEN ATTEMPT TO DOWNLOAD
	message "log" "$addon_log" "Installing Yuzu Emulator App"
	yuzu_release_html=""
	yuzu_release_version=""
	yuzu_install_url="https://foclabroc.freeboxos.fr:55973/share/6_FB-NuZriqYuHKt/yuzuea4176.AppImage"
	download_missing_file "$yuzu_install_url" "$switch_install_emus_dir/$yuzu_install_file" "Yuzu (Early Acccess)"
	if [ $wget_exit_code -eq 0 ]; then
		copy_make_executable "$yuzu_install_file" "$switch_install_emus_dir" "$yuzu_emu_dir"
	fi
}




# # INSTALL EDEN APPIMAGE
# install_emulator_eden() {
# 	message "log" "$addon_log" "<<< [ INSTALL : EDEN ]>>>"

# 	# INSTALL/UNPACK EMULATOR
# 	# EMULATOR INSTALL ARCHIVE/APP NOT FOUND LOCALLY THEN ATTEMPT TO DOWNLOAD
# 	message "log" "$addon_log" "Installing Eden Emulator App"
# 	# Get lastest version from database & set the version for download
# 	eden_release_html=""
# 	eden_release_version="$(curl -Ls https://api.github.com/repos/eden-emulator/Releases/releases/latest | grep -o '"tag_name": *"[^"]*"' | sed -E 's/.*"tag_name":\s*"([^"]*)".*/\1/')"
# 	eden_install_url="https://github.com/eden-emulator/Releases/releases/download/${eden_release_version}/Eden-Linux-${eden_release_version}-amd64-gcc-standard.AppImage"
# 	# If missing from local storage then attempt to download latest version
# 	download_missing_file "$eden_install_url" "$switch_install_emus_dir/$eden_install_file" "Eden"
# 	if [ $wget_exit_code -eq 0 ]; then
# 		copy_make_executable "$eden_install_file" "$switch_install_emus_dir" "$eden_emu_dir"
# 	fi
# }

# INSTALL EDEN APPIMAGE
install_emulator_eden() {

    # Latest version
    eden_release_version="$(curl -Ls https://api.github.com/repos/eden-emulator/Releases/releases/latest \
        | grep -o '"tag_name": *"[^"]*"' \
        | sed -E 's/.*"tag_name":\s*"([^"]*)".*/\1/')"

    # Detect platform
    pname="$(tr '[:upper:]' '[:lower:]' < /sys/class/dmi/id/product_name 2>/dev/null)"

    case "$pname" in
        jupiter|galileo|*"steam deck"*)
            platform="steamdeck"
            eden_appimage="Eden-Linux-${eden_release_version}-steamdeck-gcc-standard.AppImage"
            ;;
        *rc71l*|*"rog ally"*|*"rog-ally"*)
            platform="rog-ally"
            eden_appimage="Eden-Linux-${eden_release_version}-rog-ally-gcc-standard.AppImage"
            ;;
        *)
            platform="generic"
            eden_appimage="Eden-Linux-${eden_release_version}-amd64-gcc-standard.AppImage"
            ;;
    esac

    eden_install_url="https://github.com/eden-emulator/Releases/releases/download/${eden_release_version}/${eden_appimage}"

    message "both" "$addon_log" "Platform detected : $platform"
    message "both" "$addon_log" "Eden Version : $eden_appimage"
    message "both" "$addon_log" "Download URL       : $eden_install_url"

    # Download & install
    download_missing_file "$eden_install_url" "$switch_install_emus_dir/$eden_install_file" "Eden"
    if [ $wget_exit_code -eq 0 ]; then
        copy_make_executable "$eden_install_file" "$switch_install_emus_dir" "$eden_emu_dir"
    fi
}


# # INSTALL EDEN APPIMAGE
# install_emulator_eden_pgo() {
# 	message "log" "$addon_log" "<<< [ INSTALL : EDEN PGO ]>>>"

# 	# INSTALL/UNPACK EMULATOR
# 	# EMULATOR INSTALL ARCHIVE/APP NOT FOUND LOCALLY THEN ATTEMPT TO DOWNLOAD
# 	message "log" "$addon_log" "Installing Eden PGO Emulator App"
# 	# Get lastest version from database & set the version for download
# 	eden_release_html=""
# 	eden_release_version="$(curl -Ls https://api.github.com/repos/eden-emulator/Releases/releases/latest | grep -o '"tag_name": *"[^"]*"' | sed -E 's/.*"tag_name":\s*"([^"]*)".*/\1/')"
# 	eden_install_url="https://github.com/eden-emulator/Releases/releases/download/${eden_release_version}/Eden-Linux-${eden_release_version}-amd64-clang-pgo.AppImage"

# 	message "log" "$addon_log" "$eden_install_url"

# 	# If missing from local storage then attempt to download latest version
# 	download_missing_file "$eden_install_url" "$switch_install_emus_dir/$eden_pgo_install_file" "Eden-pgo"
# 	if [ $wget_exit_code -eq 0 ]; then
# 		copy_make_executable "$eden_pgo_install_file" "$switch_install_emus_dir" "$eden_emu_dir"
# 	fi
# }


install_emulator_eden_pgo() {

    # Latest version
    eden_release_version="$(curl -Ls https://api.github.com/repos/eden-emulator/Releases/releases/latest \
        | grep -o '"tag_name": *"[^"]*"' \
        | sed -E 's/.*"tag_name":\s*"([^"]*)".*/\1/')"

    # Detect platform
    pname="$(tr '[:upper:]' '[:lower:]' < /sys/class/dmi/id/product_name 2>/dev/null)"

    case "$pname" in
        jupiter|galileo|*"steam deck"*)
            platform="steamdeck"
            eden_appimage="Eden-Linux-${eden_release_version}-steamdeck-clang-pgo.AppImage"
            ;;
        *rc71l*|*"rog ally"*|*"rog-ally"*)
            platform="rog-ally"
            eden_appimage="Eden-Linux-${eden_release_version}-rog-ally-clang-pgo.AppImage"
            ;;
        *)
            platform="generic"
            eden_appimage="Eden-Linux-${eden_release_version}-amd64-clang-pgo.AppImage"
            ;;
    esac

    eden_install_url="https://github.com/eden-emulator/Releases/releases/download/${eden_release_version}/${eden_appimage}"

    message "both" "$addon_log" "Platform detected : $platform"
    message "both" "$addon_log" "Eden Version : $eden_appimage"
    message "both" "$addon_log" "Download URL       : $eden_install_url"

    # Download & install
    download_missing_file "$eden_install_url" "$switch_install_emus_dir/$eden_pgo_install_file" "Eden-pgo"
    if [ $wget_exit_code -eq 0 ]; then
        copy_make_executable "$eden_pgo_install_file" "$switch_install_emus_dir" "$eden_emu_dir"
    fi
}



install_emulator_citron_final() {
	message "log" "$addon_log" "<<< [ INSTALL : CITRON ]>>>"

	# INSTALL/UNPACK EMULATOR
	# EMULATOR INSTALL ARCHIVE/APP NOT FOUND LOCALLY THEN ATTEMPT TO DOWNLOAD
	message "log" "$addon_log" "Installing Citron Emulator App"
	# Get lastest version from database & set the version for download
	citron_release_html=""
		citron_release_version="$(curl -Ls https://git.citron-emu.org/Citron/Emulator/releases | grep -Eo '/Citron/Emulator/releases/download/[0-9]+\.[0-9]+\.[0-9]+' | sed -E 's#.*/download/##' | sort -V | tail -n1)"
	citron_commit_version="$(curl -Ls https://git.citron-emu.org/Citron/Emulator/releases | grep -Eo '/Citron/Emulator/src/commit/[a-f0-9]+' | head -n1 | sed -E 's#.*/commit/([a-f0-9]{9}).*#\1#')"
	citron_install_url="https://git.citron-emu.org/Citron/Emulator/releases/download/${citron_release_version}/citron_stable-${citron_commit_version}-linux-x86_64.AppImage"

	# If missing from local storage then attempt to download latest version
	download_missing_file "$citron_install_url" "$switch_install_emus_dir/$citron_install_file" "Citron"
	if [ $wget_exit_code -eq 0 ]; then
		copy_make_executable "$citron_install_file" "$switch_install_emus_dir" "$citron_emu_dir"
	fi
}

# Version PKG FORGE - Spécial Thanks @Foclabroc
install_emulator_citron() {

	message "log" "$addon_log" "<<< [ INSTALL : CITRON ]>>>"

	# INSTALL/UNPACK EMULATOR
	# EMULATOR INSTALL ARCHIVE/APP NOT FOUND LOCALLY THEN ATTEMPT TO DOWNLOAD
	message "log" "$addon_log" "Installing Citron Emulator App"
	# Get lastest version from database & set the version for download
    page=$(curl -Ls "https://github.com/pkgforge-dev/Citron-AppImage/tags")

    if [[ -z "$page" ]]; then
        echo "ERROR Citron: unable to download tags page"
        echo "STATUS_CITRON=ERREUR" >> "$STATUS_FILE"
        return
    fi

    # Dernier tag stable (URL encodé)
    tag=$(echo "$page" |
        grep -Eo '/pkgforge-dev/Citron-AppImage/releases/tag/[^"]+' |
        grep -v nightly |
        head -n1 |
        sed 's#.*/##')

    if [[ -z "$tag" ]]; then
        echo "ERROR Citron: no stable tag found"
        echo "STATUS_CITRON=ERREUR" >> "$STATUS_FILE"
        return
    fi

    # Décodage %40 ? @
    tag_decoded="${tag//%40/@}"

    # Version = avant @
    version="${tag_decoded%%@*}"

    # citron_install_url="https://github.com/pkgforge-dev/Citron-AppImage/releases/download/$tag_decoded/Citron-$version-anylinux-x86_64.AppImage"
    citron_install_url="https://foclabroc.freeboxos.fr:55973/share/h8_4jY4c_fFsHWrf/citron-emu(2026.02.1-Pathfinder).AppImage"

	# If missing from local storage then attempt to download latest version
	download_missing_file "$citron_install_url" "$switch_install_emus_dir/$citron_install_file" "Citron"
	if [ $wget_exit_code -eq 0 ]; then
		copy_make_executable "$citron_install_file" "$switch_install_emus_dir" "$citron_emu_dir"
	fi
}



