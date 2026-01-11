#!/usr/bin/env bash 
# BATOCERA - SWITCH ADD-ON: FUNCTIONS

# SOURCE GUARD TO PREVENT REDUNDANCY
[ -n "$SOURCED_FUNCTIONS" ] && return
SOURCED_FUNCTIONS=true


# DO NOTHING
do_nothing() {
	:
}


# Rename File is Exists
# Usage: rename_file <old filename> <new filename> <overwrite {**no** | yes}>
rename_file() {
	local old_file="$1"
	local new_file="$2"
	local overwrite="${3:-no}"
	overwrite="${overwrite,,}"

	if [ -f "$old_file" ]; then
		if [ "$overwrite" = "yes" ]; then
			mv -f "$old_file" "$new_file"
		else
			mv -n "$old_file" "$new_file"
		fi
	fi
}


# Return true if value found in keyed array
# Usage: found_by_key <search string> <array name>
found_by_key() {
	local found=false
	local search_value=$1
	local -n search_array=$2
	for key in "${!search_array[@]}"; do
		if [[ "${search_array[$key]}" == "$search_value" ]]; then
			found=true
			break
		fi
	done
	echo $found
}

# Output message to stdout and log file
# Usage: message <option {stdout | log | both}> <log file> <text line 1> [text line 2] etc...
message() {
	local log_it="$1"
	local log_file="$2"
	for msg in "${@:3}"; do
		msg="$msg\n"
		if [ "$log_it" = "stdout" ]; then
			printf -- "$msg" 2>>"$stderr_log"
		elif [ "$log_it" = "log" ]; then
			printf -- "$msg" >>"$log_file" 2>>"$stderr_log"
		elif [ "$log_it" = "both" ]; then
			printf -- "$msg" 2>>"$stderr_log"
			printf -- "$msg" >>"$log_file" 2>>"$stderr_log"
		fi
	done
}


# Trims leading & trailing whitespace
# Usage: trim_whitespace <text>
trim_whitespace() {
	local text="$1"
	local output="$(sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//' <<<"$text")"
	echo "$output"
}

# Trims leading & trailing whitespace,
# as well as condenses all whitespace to single space within the text
# Usage: remove_whitespace <text> [remove blank lines {true}]
remove_whitespace() {
	local text="$1"
	local blank_lines="$2"
	if [ "$blank_lines" = "true" ]; then
		local output="$(awk 'NF{$1=$1;print}' <<<"$text")"
	else
		local output="$(awk '{$1=$1;print}' <<<"$text")"
	fi
	echo "$output"
}

# Trims leading & trailing double quotes
# Usage: trim_double_quotes <text>
trim_double_quotes() {
	local text="$1"
	local output="$(sed -e 's/^"//' -e 's/"$//' <<<"$text")"
	echo "$output"
}

# Trims leading & trailing single quotes
# Usage: trim_single_quotes <text>
trim_single_quotes() {
	local text="$1"
	local output="$(sed -e "s/^'//" -e "s/'$//" <<<"$text")"
	echo "$output"
}

# Trims leading & trailing double / single quotes (starting with double)
# Usage: trim_single_quotes <text>
trim_quotes() {
	local text="$1"
	local trimmed_text="$(trim_double_quotes "$text")"
	local return_text="$(trim_single_quotes "$trimmed_text")"
	echo "$return_text"
}

# Returns TRUE if search in text
# Usage: in_string <text> <search>
in_string() {
	local text_string="$1"
	local search_string="$2"
	if [[ "$text_string" = *"$search_string"* ]]; then
		return 0
	else
		return 1
	fi
}

# Replace delimiter
# Usage: replace_delimeter <old delimiter> <new delimiter> <string>
replace_delimeter() {
	old_delimiter=$1
	new_delimiter=$2
	shift 2
	string_in=$@
	echo "$(printf "%s" "$string_in" | sed -E ":a;N;\$!ba;s/$old_delimiter/$new_delimiter/g")"
}

# Returns TRUE if search path in set of paths
# Usage: in_path <set of paths> <search path>
in_path() {
	local set_of_paths="$1"
	local search_path="$2"
	return "$(in_string ":$set_of_paths:" ":$search_path:")"
}

# Returns TRUE if search string in file
# Usage: string_in_file <file> <search string>
string_in_file() {
	local file="$1"
	local search_string="$2"
	local found_string="$(grep "$file" -e "$search_string")"
	if [[ "$found_string" != "" ]]; then
		return 0
	else
		return 1
	fi
}

# Returns the path string from variable assign string (i.e.: PATH="/sbin:/usr/sbin:/bin:/usr/sbin")
# Usage: get_path_from_assign <variable assignment text> <variable name>
get_path_from_assign() {
	local text="$1"
	local search_var="$2"
	local return_path="$(trim_quotes "$(printf '%s\n' "${text#*"$search_var="}")")"
	echo "$return_path"
}


# Return filename with timestamp at end of filename
# Usage: first_match_in_file <file> [time stamp from {**current**, file}]
add_timestamp_filename() {
	local filename="$1"
	local ts_type="${2:-current}"
	ts_type="${ts_type,,}"
	local new_filename=""

	if [ "$ts_type" = "current" ]; then
		time_stamp="$(date +"_%Y%m%d_%H%M%S")"
	else
		time_stamp="$(date -r "$filename" +"_%Y%m%d_%H%M%S")"
	fi

	if [[ "$filename" == *.* ]]; then
		new_filename="${filename%.*}${time_stamp}.${filename##*.}"
	else
		new_filename="${filename}${time_stamp}"
	fi

	echo "$new_filename"
}


# Renames the file with underscore and timestamp of file at the end.
# Usage: rename_file_with_timestamp <file> [time stamp from {**current**, file}]
rename_file_with_timestamp() {
	local input_file="$1"
	local ts_type="${2:-current}"
	ts_type="${ts_type,,}"
	local new_file=""
	
	if [ -f "$input_file" ]; then
		new_file="$(add_timestamp_filename "$input_file" "$ts_type")"
		mv "$input_file" "$new_file"
	else
		new_file=""
	fi

	echo "$new_file"
}


# Returns first match if search string in file
# Usage: first_match_in_file <file> <search string>
first_match_in_file() {
	local file="$1"
	local search_string="$2"
	found_string="$(grep -m 1 "$file" -e "$search_string")"
	echo "$found_string"
}

# Replace search string in file with replace string
# Usage: replace_in_file <file> <search string> <replace string>
replace_in_file() {
	local file="$1"
	local search_string="$2"
	local replace_string="$3"
	sed "s/$search_string/$replace_string/" "$file"
}

# Generate File (will overwrite)
# Usage: generate_file <file> <text line 1> [text line 2] etc...
generate_file() {
	local o_file="$1"
	if [ -f "$o_file" ]; then
		rm -f "$o_file" 2>>"$stderr_log"
	fi
	for text_to_output in "${@:2}"; do
		echo "$text_to_output"  >> "$o_file" 2>>"$stderr_log"
	done
}

# Generate File (will overwrite) & Make Executable
# Usage: generate_executable_file <file> <text line 1> [text line 2] etc...
generate_executable_file() {
	local o_file="$1"
	generate_file "$@"
	dos2unix "$o_file" 2>>"$stderr_log"
	chmod a+x "$o_file" 2>>"$stderr_log"
}

# Append to File
# Usage: append_file <file> <text line 1> [text line 2] etc...
append_file() {
	local o_file="$1"
	for text_to_output in "${@:2}"; do
		echo "$text_to_output"  >> "$o_file" 2>>"$stderr_log"
	done
}

# Create Symbolic Link Between Source (Real Directory) & Target (Symbolic Link Directory) Directories
# Will create Source directory if it does not exist
# Will create Target parent directory if it does not exist
# Usage: create_slink_directory <source directory> <target directory>
create_slink_directory() {
	message "log" "$addon_log" "Linking $2 to $1"
	local source_dir="$1"
	local target_dir="$2"
	# remove target directory so link can be created
	if [ -e "$target_dir" ]; then
		rm -rf "$target_dir"
	fi
	# create target parent directory if does not exist
	mkdir -p "$(dirname "$target_dir")"
	# create source directory if does not exist
	if [ ! -e "$source_dir" ]; then
		mkdir -p "$source_dir"
	fi
	# create symbolic link : "target (symbolic) --> source (real)"
	ln -s "$source_dir" "$target_dir"
}

# Create Symbolic Link Between Source (Real) & Target (Symbolic) Files
# Usage: create_slink_file <source file> <target file>
create_slink_file() {
	message "log" "$addon_log" "Linking $2 to $1"
	local source_file="$1"
	local target_file="$2"
	local target_dir=$(dirname "${target_file}")
	# create symbolic link : "target (symbolic) --> source (real)" if file exists
	if [ -f "$source_file" ]; then
		# create target directory path if does not exist
		if [ ! -d "$target_dir" ]; then
			mkdir -p "$target_dir" 2>>"$stderr_log"
		fi		
		# remove target file to create link
		if [ -f "$target_file" ]; then
			rm -rf "$target_file"
		fi
		# create symbolic link : "target (symbolic) --> source (real)"
		ln -s "$source_file" "$target_file" 2>>"$stderr_log"
	else
		message "log" "$addon_log" "ERR: File $source_file does not exist ... link not created"
	fi
}


# Check Syntax of XML File
# Usage: is_valid_xml <XML File>
is_valid_xml() {
	xml_file="$(realpath "$1")"
	if ! xmllint --noout "$xml_file"; then
		return 1		
	fi
}


# Check if Node 
# Usage: xml_node_empty <XML File> <Node XPath>
xml_node_empty() {
	local xml_file="$(realpath "$1")"
	local xpath="$2"

	# Check XML File Exists
	if [[ ! -f "$xml_file" ]]; then
		message "log" "$addon_log" "ERROR: XML Node Check Failed" "FILE DOES NOT EXIST: $xml_file"
		return 2
	fi

	# Get Node
	local content
	content="$(xmllint --xpath "string($xpath)" "$xml_file" 2>/dev/null)"
	local exit_status=$?

	# Node Does Not Exist
	[ $exit_status -ne 0 ] && return 3

	# Trim Node (remove whitespace)
	local trimmed_content=$(echo "$content" | xargs)

	# Check Node
	if [[ -z "$trimmed_content" ]]; then
		# Node Eexists is Empty
		return 0
	else
		# Node Exists & Has Data
		return 1
	fi
}


# Inject Node into XML File
# Usage: xml_file_inject_node <XML File> <Parent XPath> <Dedupe XPath> <XML Node Snippet>
xml_file_inject_node() {
	local xml_file="$(realpath "$1")"
	local parent_xpath="$2"	 # e.g., "//root/child1/child2"
	local duplicate_xpath="$3"  # e.g., "child3"
	local xml_snippet="$4"	  # The actual <node>...</node> to insert

	# Temp File: Garbage Collection Clean Up
	local tmp_files=()
	trap 'rm -f "${tmp_files[@]}"' RETURN

	# Check XML File Exists
	if [[ ! -f "$xml_file" ]]; then
		message "log" "$addon_log" "ERROR: XML Node Insert Failed" "FILE DOES NOT EXIST: $xml_file"
		return 1
	fi

	local XSL_FILE=$(mktemp); tmp_files+=("$XSL_FILE")
	local temp_xml=$(mktemp); tmp_files+=("$temp_xml")
 
	# XSLT Logic
	cat <<EOF > "$XSL_FILE"
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no"/>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="$parent_xpath">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:if test="not($duplicate_xpath)">
				$xml_snippet
			</xsl:if>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
EOF

	# Insert
	if xsltproc "$XSL_FILE" "$xml_file" | XMLLINT_INDENT=$'\t' xmllint --format - > "$temp_xml"; then
		mv "$temp_xml" "$xml_file"
	else
		message "log" "ERROR: XML Node Insert Failed" "UNCHANGED: $xml_file"
		return 1
	fi
}


# Delete Node from XML File
# Usage: xml_file_delete_node <XML File> <XPath to Remove>
xml_file_delete_node() {
	local xml_file="$(realpath "$1")"
	local target_xpath="$2" # The XPath of the node(s) to remove

	# Temp File: Garbage Collection Clean Up
	local tmp_files=()
	trap 'rm -f "${tmp_files[@]}"' RETURN

	# Check XML File Exists
	if [[ ! -f "$xml_file" ]]; then
		message "log" "$addon_log" "ERROR: XML Node Delete Failed" "FILE DOES NOT EXIST: $xml_file"
		return 1
	fi

	local XSL_FILE=$(mktemp); tmp_files+=("$XSL_FILE")
	local temp_xml=$(mktemp); tmp_files+=("$temp_xml")
	
	# XSLT Logic
	cat <<EOF > "$XSL_FILE"
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<!-- Empty Template: Matches the target and produces nothing (deletes it) -->
	<xsl:template match="$target_xpath"/>

</xsl:stylesheet>
EOF

	# Delete
	if xsltproc "$XSL_FILE" "$xml_file" | XMLLINT_INDENT=$'\t' xmllint --format - > "$temp_xml"; then
		if [[ -s "$temp_xml" ]] && xmllint --noout "$temp_xml" 2>/dev/null; then
			mv "$temp_xml" "$xml_file"
			return 0
		fi
	fi

	message "log" "ERROR: XML Node Delete Failed" "UNCHANGED: $xml_file"
	return 1
}


# Merge XML Files : Master XML <- XML to Merge (Master is Overwritten)
# Usage: xml_file_merge <XML Master File> <XML File to Merge> <Dedupe Tag Name>
xml_file_merge() {
	local xml_master="$(realpath "$1")"
	local xml_to_merge="$(realpath "$2")"
	local duplicate_parse_tag="$3"
	local xml_master_backup="$(add_timestamp_filename "$xml_master")"

	# Temp File: Garbage Collection Clean Up
	local tmp_files=()
	trap 'rm -f "${tmp_files[@]}"' RETURN

	# Check XML File to Merge Exists
	if [[ ! -f "$xml_to_merge" ]]; then
		message "log" "$addon_log" "ERROR: XML Merge Failed" "FILE DOES NOT EXIST: $xml_to_merge"
		return 1
	fi

	# Check XML Master File Exists; If not then just copy XML File to Merge to XML Master File
	if [[ ! -f "$xml_master" ]]; then
		cp "$xml_to_merge" "$xml_master" 2>>"$stderr_log"
		return 0
	fi

	# Validate Master XML Syntax
	if ! is_valid_xml "$xml_master"; then
		message "log" "ERROR: Invalid XML Syntax" "... $xml_master" "UNCHANGED: $xml_master"
		return 1
	fi
	
	# Validate Merge XML Syntax
	if ! is_valid_xml "$xml_to_merge"; then
		message "log" "ERROR: Invalid XML Syntax" "... $xml_master" "UNCHANGED: $xml_master"
		return 1
	fi

	# Create Backup of Master
	if cp "$xml_master" "$xml_master_backup" 2>>/dev/null; then
		message "log" "xml_master backed to $$xml_master_backup"
	else
		message "log" "ERROR: Creating Backup Failed" "UNCHANGED: $xml_master"
		return 1
	fi

	local XSL_FILE=$(mktemp); tmp_files+=("$XSL_FILE")
	local temp_xml=$(mktemp); tmp_files+=("$temp_xml")

	# XSLT Logic
	cat <<'EOF' > "$XSL_FILE"
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<xsl:param name="xml_to_merge_param"/>
	<xsl:param name="tag_name_param"/>

	<!-- Remove existing indentation whitespace to let xsltproc re-indent cleanly -->
	<xsl:strip-space elements="*"/>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			
			<xsl:variable name="master_ids" select="*/*[local-name()=$tag_name_param]"/>
			
			<xsl:for-each select="document($xml_to_merge_param)/*/*">
				<xsl:variable name="current_id" select="*[local-name()=$tag_name_param]"/>
				<xsl:if test="not($master_ids = $current_id)">
					<xsl:copy-of select="."/>
				</xsl:if>
			</xsl:for-each>

			<!-- Force a newline before the closing root tag -->
			<xsl:text>&#xa;</xsl:text>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
EOF

	# Merge
	if xsltproc --nonet --novalid \
				--stringparam xml_to_merge_param "file://$(realpath "$xml_to_merge")" \
				--stringparam tag_name_param "$duplicate_parse_tag" \
				"$XSL_FILE" "$xml_master" | XMLLINT_INDENT=$'\t' xmllint --format - > "$temp_xml"; then
		mv "$temp_xml" "$xml_master"
		message "log" "MERGED: $xml_to_merge -> $xml_master."
	else
		message "log" "ERROR: XML Merge Failed." "UNCHANGED: $xml_master"
		return 1
	fi
}


# Unzip file with message
# Usage: unzip_file <zip file> <destination directory>
unzip_file() {
	local zip_file="$1"
	local destination_dir="$2"
	message "log" "$addon_log" "${@:3}"
	# If destination directory does not exist then create directory path 
	if [[ ! -d "$destination_dir" ]]; then
		mkdir -p "$destination_dir" 2>>"$stderr_log"
	fi
	# If file exist then unzip file to destination
	if [ -f "$zip_file" ]; then
		unzip -oq "$zip_file" -d "$destination_dir" 2>>"$stderr_log"
	else
		message "log" "$addon_log" "ERR: File $zip_file does not exist."
	fi
}

# chmod a+x specfic file
# Usage: chmod_ax_file <file>
chmod_ax_file() {
	local file="$1"
	dos2unix "$file" 2>>"$stderr_log"
	chmod a+x "$file" 2>>"$stderr_log"
}

# Recursively chmod a+x files in target directory
# Usage: chmod_ax_files <directory> <file parse>
chmod_ax_files() {
	local dir="$1"
	local file="$2" 
	dos2unix "$dir/"$file 2>>"$stderr_log"
	chmod a+x "$dir/"$file 2>>"$stderr_log"
	for subdir in "$dir"/*; do
		if [ -d "$subdir" ]; then
			chmod_ax_files "$subdir" "$file"
		fi
	done
}

# Returns set of paths with added path as needed (adds to beginning by default)
# Usage: add_path <paths> <path to add> [add to end {end}]
add_path() {
	local paths="$1"
	local path_to_add="$2"
	local option="$3"
	if (in_string "$paths" "$path_to_add"); then
		echo "$paths"
	else
		if [ "$option" = "end" ]; then
			echo "$paths:$path_to_add"
		else
			echo "$path_to_add:$paths"
		fi
	fi
}

# Adds path to path variable assignment in a file (adds to beginning by default)
# Usage: add_path_to_path_var_in_file <file> <variable name> <path to add> [add to end {end}]
add_path_to_path_var_in_file() {
	local file="$1"
	local search_var="$2"
	local path_to_add="$3"
	local option="$4"
	local set_of_paths=""
	local new_paths=""
	# use last occurance
	local text_found="$(trim_whitespace "$(grep -w -e "$search_var=" "$file" | tail -1)")"
	if [ "$text_found" != "" ]; then
		# if found in file then modify assignment string
		# get paths string from variable assignment string
		set_of_paths="$(get_path_from_assign "$text_found" "$search_var")"
	else
		# else generate assignment string
		set_of_paths="\$$search_var"
	fi
	# generate new paths string with path to add (as needed)
	new_paths="$(add_path "$set_of_paths" "$path_to_add" "$option")"
	# append to file
	if [ "$new_paths" != "$set_of_paths" ]; then
		append_file "$file" "export $search_var=\"$new_paths\""
	fi
}


# Run Command as either Source, Command Line, or Function
# Usage: execute_command <command> [execution type={**cmd** | fn | src}]
execute_command() {
	local run_cmd="$1"
	local run_type="${2:-cmd}"
	run_type="${run_type,,}"

	case $run_type in
		"cmd")
			eval "$run_cmd" 2>>"$stderr_log"
		;;
		"fn")
			local cmd_array
			read -ra cmd_array <<< "$run_cmd"
			local func_name="${cmd_array[0]}"
			if declare -F "$func_name" > /dev/null; then
				$run_cmd 2>>"$stderr_log"
			else
				message "log" "$addon_log" "ERROR :: Function Not Found: $func_name"
			fi
		;;
		"src")
			if [ -f "$run_cmd" ]; then
				source "$run_cmd"
			else
				echo ""
				message "log" "$addon_log" "ERROR :: Source File Not Found: $run_cmd"
			fi
		;;
		*)
			# error
			message "log" "$addon_log" "ERROR :: Invalid Run Type: $run_type"
		;;
	esac
}

# Download file from URL into destination file
# Usage: download_file <URL> <Destination File>
download_file() {
	local url="$1"
	local dfile="$2"
	local ecode=0
#	wget --quiet --show-progress --progress=bar:force:noscroll --tries=10 --timeout=30 --waitretry=3 --no-check-certificate --no-cache --no-cookies -O "$dfile" "$url"
	wget --quiet --show-progress --progress=bar:force:noscroll \
		--tries=10 --timeout=30 --waitretry=3 --no-check-certificate --no-cache --no-cookies \
		-O "$dfile" "$url" 2>&1 >/dev/tty

	wget_exit_code=$?
}


# Download File if Missing
# Usage: download_missing_file <URL> <Destination File Path> [File Description]
download_missing_file() {
	local url="$1"
	local dpath="$2"
	local ddir="${dpath%/*}"
	local dfile="${dpath##*/}"
	local file_desc="${3:-$url}"

	wget_exit_code=0
	if [ ! -f "$dpath" ]; then
		message "log" "$addon_log" "$file_desc not found at $dpath."		
		# create destination directory if needed
		mkdir -p "$ddir" 2>>"$stderr_log"
		# attempt to download emulator
		download_file "$url" "$dpath"
		if [ $wget_exit_code -eq 0 ]; then
			message "log" "$addon_log" "SUCCUESS:: $file_desc downloaded to $dpath using URL: $url"
		else
			message "log" "$addon_log" "FAILED:: $file_desc download to $dpath using URL: $url" "NOTICE:: Place $dpath manually and re-install."
			# remove partial failed download
			rm -f "$dpath"
		fi
	fi
}


# Download & Unpack (ZST) package if Missing
# Usage: dl_unpack_missing_package <URL> <Package File Path (without extension)> [Package Description]
zst_file="" # global for use elsewhere
tar_file="" # global for use elsewhere
dl_unpack_missing_package() {
	local url="$1"
	local pkg_path="$2"
	local pkg_dir="${pkg_path%/*}"
	local pkg_file="${pkg_path##*/}"
	local pkg_desc="${3:-$url}"

	zst_file="$pkg_dir/$pkg_file.pkg.tar.zst"
	tar_file="$pkg_dir/$pkg_file.pkg.tar"

	download_missing_file "$url" "$zst_file" "$pkg_desc"
	if [ $wget_exit_code -eq 0 ]; then
		message "log" "$addon_log" "Unpacking $pkg_desc: $zst_file -> $tar_file"
		zstd -df "$zst_file" 2>>"$stderr_log"
	fi
}


# Create Script & Make Executable
# Usage: generate_script <file> <text line 1> [text line 2] etc ...
function generate_script() { 
	script_file="$1"
	generate_file "$@"
	chmod_ax_file "$script_file"
} 

# Create Script, Make Executable & Run
# Usage: generate_script_run <file> <text line 1> [text line 2] etc ...
function generate_script_run() { 
	script_file="$1"
	generate_file "$@"
	chmod_ax_file "$script_file"
	execute_command "$script_file"
} 

# Create .desktop for F1-Applications Menu
# Usage: generate_desktop_file <applications directory> <icon directory> <emulator> <display name> <execute file>
function generate_desktop_file() {
# SCALING FOR F1 APPS, DEFAULT 128@1 
	DPI=128
	SCALE=1
	local appdir=$1
	local icondir=$2
	local emu=$3
	local name=$4
	local exec_file="${5:-${emu}-config.sh}"
	local dfile="$appdir/$emu.desktop"
	local src_icon="$switch_install_icons_dir/$emu.png"

	generate_file "$dfile" \
		"[Desktop Entry]" \
		"Version=1.0" \
		"Icon=$icondir/$emu.png" \
		"Exec=$switch_system_dir/$exec_file" \
		"Terminal=false" \
		"Type=Application" \
		"Categories=Game;batocera.linux;" \
		"Name=$name"

	chmod_ax_file "$dfile"
	
	if [ -f "$src_icon" ]; then
		cp -f "$src_icon" "$icondir" 2>>"$stderr_log"
	fi
} 

# Copy File and Make Executable (WARNING:: Will overwrite file at destination!!!)
# Usage: copy_make_executable <file> <scource directory> <destination directory>
function copy_make_executable() {
	local file=$1
	local from_dir=$2
	local to_dir=$3

	cp -f "$from_dir/$file" "$to_dir" 2>>"$stderr_log"
	chmod_ax_file "$to_dir/$file"
}

# Delete File or Directory (Recursively) and Log
# Usage: delete_recursive <file/directory> <description> [log {stdout | log | both}]
function delete_recursive() {
	local file_or_dir=$1
	local description=$2
	local log_it=$3

	if [ ! -z "$log_it" ]; then
		message "$log_it" "$addon_log" "DELETE :: $description ::  $file_or_dir"
	fi

	if [ -f "$file_or_dir" ]; then
		rm -f "$file_or_dir" 2>>"$stderr_log"
	elif [ -d "$file_or_dir" ]; then
		rm -rf "$file_or_dir" 2>>"$stderr_log"
	else
		message "log" "$addon_log" "ERROR:: $file_or_dir not a file or directory. Unable to delete."
	fi
}


# ZIPs the contents of the source directory into the zip file
# Usage: zip_it <source directory> <zip file>
zip_it() {
	local path_to_zip="$1"
	local zip_file="$2"
	[[ -d "$path_to_zip" ]] && (cd "$path_to_zip" && zip -rq9 - . > "$zip_file")	
}


# ====================
# | DIALOG FUNCTIONS |
# ====================
#
# Create Confirm Message (Yes/No)
# Usage: create_dialog_confirm <title> <height> <width> <confirm text> [cursor {**no** |yes}]
create_dialog_confirm() {
	# get menu settings from parameters (shift to next set of parameters)
	local title="$1"
	local height=$2
	local width=$3
	local confirm_text="$4"
	local default_flag=$([[ "$5" == "yes" ]] && echo "" || echo "--defaultno")

	# dialog command
	local dialog_args=(
		--clear
		$default_flag
		--title "$title"
		--yesno	"$confirm_text" $height $width
	)

	dialog "${dialog_args[@]}" 2>&1 >/dev/tty

	return $?
}


# Create/Process List Menu
# Usage: create_dialog_list_menu \
#									<title> <height> <width> <list height> \
#									<ok label> <cancel label> <cancel to previous {on | off}> \
#									<menu text> \
#									<menu items()>
#
#	menu item = "<key>|<description>|<run type {cmd | fn | src}>|<run command>"
#
create_dialog_list_menu() {
	# get menu settings from parameters (shift to next set of parameters)
	local title="$1"
	local height=$2
	local width=$3
	local list_height=$4
	local ok_label="$5"
	local cancel_label="$6"
	local cancel_to_previous="on"; [[ "${7,,}" == "off" ]] && cancel_to_previous="off"
	local menu_text="$8"
	shift 8
	# get menu items from parameters
	local menu_items=("$@")

	# menu processing
	local selection
	local exit_status
	# used for looping / menu processing
	local item
	local key
	local desc
	local run_type
	local run_cmd

	# Run Type | Run Command Keyed Array
	local -A menu_cmds

	# dialog command
	local dialog_args=(
		--clear
		--title "$title"
		--ok-label "$ok_label"
		--cancel-label "$cancel_label"
		--menu "$menu_text" $height $width $list_height
	)
	for item in "${menu_items[@]}"; do
		IFS='|' read -r key desc run_type run_cmd <<< "$item";
		menu_cmds["$key"]="$run_type|$run_cmd"
		dialog_args+=("$key" "$desc")
	done

	# execute dialog command
	selection=$(dialog "${dialog_args[@]}" 2>&1 >/dev/tty)
	exit_status=$?

	# process selections
	case $exit_status in
		0)
			IFS='|' read -r run_type run_cmd <<< "${menu_cmds["$selection"]}"
			execute_command "$run_cmd" "$run_type"			
		;;
		1|255)
			# Cancel
			if [ "$cancel_to_previous" = "off" ]; then
				return $exit_status
			else
				return 0
			fi
		;;
	esac
}


# Create/Process Checkbox Menu
# Usage: create_dialog_checkbox_menu \
#										<title> <height> <width> <list height> \
#										<ok label> <cancel label> <cancel to previous {on | off}> \
#										<menu text> \
#										<confirm title> <confirm text> \
#										<processing title> <processing text> \
#										<processing start text> <processing end text> \
#										<menu items()>
#
#	menu item = "<key>|<description>|<value>{on/off}|<run type {cmd | fn | src}>|<run command>
#
create_dialog_checkbox_menu() {
	# get menu settings from parameters (shift to next set of parameters)
	local title="$1"
	local height=$2
	local width=$3
	local list_height=$4
	local ok_label="$5"
	local cancel_label="$6"
	local cancel_to_previous="on"; [[ "${7,,}" == "off" ]] && cancel_to_previous="off"
	local menu_text="$8"
	shift 8
	# get confirmation menu settings from parameters (shift to next set of parameters)
	local confirm_title="$1"
	local confirm_text="$2"
	shift 2
	# get processing menu settings from parameters (shift to next set of parameters)
	local processing_title="$1"
	local processing_text="$2"
	local processing_start_text="$3"
	local processing_end_text="$4"
	shift 4
	# get menu items from parameters
	local menu_items=("$@")

	# menu processing
	local -a selections
	local exit_status
	# used for looping / menu processing
	local item
	local key
	local desc
	local value
	local run_type
	local run_cmd

	# Run Type | Run Command Keyed Array
	local -A menu_cmds

	# dialog command
	local dialog_args=(
		--clear
		--title "$title"
		--separate-output
		--separator '|'
		--ok-label "$ok_label"
		--cancel-label "$cancel_label"
		--checklist "$menu_text" $height $width $list_height
	)
	for item in "${menu_items[@]}"; do
		IFS='|' read -r key desc value run_type run_cmd <<< "$item"
		menu_cmds["$key"]="$run_type|$run_cmd"
		dialog_args+=("$key" "$desc" $value)
	done

	while true; do
		# execute dialog command
		selections=$(dialog "${dialog_args[@]}" 2>&1 >/dev/tty)
		exit_status=$?

		# process selections
		case $exit_status in
			0)
				if [[ -n "$selections" ]]; then
                    # Confirm Install
					IFS='|' read -r selections <<< $selections
					local formatted_selections=$(replace_delimeter "\n" ", " "${selections[*]}")
					local full_text="$confirm_text\n\n$formatted_selections"					
					if create_dialog_confirm "$confirm_title" $height $width "$full_text"; then
						# Install
						DIALOG_PIPE_FILE=$(mktemp -u)
						mkfifo "$DIALOG_PIPE_FILE"
						dialog --clear --title "$processing_title" --programbox "$processing_text" $height $width <"$DIALOG_PIPE_FILE" 2>&1 >/dev/tty &
						local DIALOG_PID=$!
						(
							local menu_cmd
							local selections_array
							IFS='|' read -ra selections_array <<< "$selections"
							for key in "${selections_array[@]}"; do
								IFS='|' read -r run_type run_cmd <<< "${menu_cmds["$key"]}"
								echo "$processing_start_text $key ..."
								execute_command "$run_cmd" "$run_type"
								echo "... $key $processing_end_text!"
								echo ""
							done
						) > "$DIALOG_PIPE_FILE"
						wait $DIALOG_PID
						rm "$DIALOG_PIPE_FILE"
						return 0
					fi
				fi
			;;
			1|255)
				# Cancel
				if [ "$cancel_to_previous" = "off" ]; then
					return $exit_status
				else
					return 0
				fi
			;;
		esac
	done
}


# Create/Process Checkbox Menu
# Usage: create_dialog_textbox \
#										<title> <height> <width> \
#										<exit label> \
#										<text file>

create_dialog_textbox() {

	# get textbox settings from parameters (shift to next set of parameters)
	local title="$1"
	local height=$2
	local width=$3
	local exit_label="$4"
	shift 4
	local text_file="$1"

	if [[ ! -f "$text_file" ]]; then
		dialog --msgbox "FILE DOES NOT EXIST!" $height $width 2>&1 >/dev/tty
		return 1
	fi

	local dialog_args=(
		--clear
		--scrollbar
		--title "$title"
		--exit-label "$exit_label"
		--textbox "$text_file" $height $width
	)

	dialog "${dialog_args[@]}" 2>&1 >/dev/tty
	exit_status=$?

	return $exit_status
}


