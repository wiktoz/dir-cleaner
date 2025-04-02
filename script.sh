#!/usr/bin/env bash

source .clean_files

echo $dangerous_chars

recursive=false

function welcome() {
	echo -e "
d8888b. d888888b d8888b.          .o88b. db      d88888b  .d8b.  d8b   db d88888b d8888b.
88  \`8D   \`88'   88  \`8D         d8P  Y8 88      88'     d8' \`8b 888o  88 88'     88  \`8D
88   88    88    88oobY'         8P      88      88ooooo 88ooo88 88V8o 88 88ooooo 88oobY'
88   88    88    88\`8b           8b      88      88~~~~~ 88~~~88 88 V8o88 88~~~~~ 88\`8b
88  .8D   .88.   88 \`88.         Y8b  d8 88booo. 88.     88   88 88  V888 88.     88 \`88.
Y8888D' Y888888P 88   YD C88888D  \`Y88P' Y88888P Y88888P YP   YP VP   V8P Y88888P 88   YD
	"

	echo -e '\e[1;33m[*] STARTING DIR_CLEANER\e[m'

	echo -e 'Author: wiktoz'
	echo -e 'GitHub: https://github.com/wiktoz/dir_cleaner'
	echo -e "\n"
}

function usage() {
	echo "usage: $0 [-r] [-h] [dir1 dir2 ...]"
	echo ""
	exit 1
}

function confirm_action() {
	echo "Do you confirm this action? [yes/no]:"
	read choice

	choice_lowercase="${choice,,}"

	if [[ "$choice_lowercase" == "yes" || "$choice_lowercase" == "y" ]]; then
		echo "True"
	elif [[ "$choice_lowercase" == "no" || "$choice_lowercase" == "n" ]]; then
		echo "False"
	else
		echo "Incorrect action"
		confirm_action
	fi

}

function calc_hash() {
	local sum=$(sha256sum "$1" | awk '{print $1}')
	echo "$sum"
}

function get_permissions() {
	local permissions=$(ls -la "$1" | awk '{print $1}')
	echo "${permissions:1}"
}

function get_file_create_date() {
	local date=$(stat --format="%Y" "$1")
	echo "$date"
}

function get_file_size() {
	local size=$(stat --format="%s" "$1")
	echo "$size"
}

function is_file_temp() {
	local match_found=false

	for pattern in "${temp_extensions[@]}"; do
		if [[ $(basename "$1") == $pattern ]]; then
			match_found=true
			break
		fi
	done

	echo "$match_found"
}

function has_dangerous_chars() {
	local match_found=false

	for pattern in "${dangerous_chars[@]}"; do
		if [[ $(basename "$1") == *$pattern* ]]; then
			match_found=true
			break
		fi
	done

	echo "$match_found"
}

function has_unusual_permissions() {
	local match_found=false

	for permission in "${unusual_permissions[@]}"; do
		if [[ $(get_permissions "$1") == $permission ]]; then
			match_found=true
			break
		fi
	done

	echo "$match_found"
}

function suggest_name() {
    local new_name=$(basename "$1")

    for char in "${dangerous_chars[@]}"; do
	echo "ZNAK: "
	echo $char
	new_name="${new_name//${char}/$default_substitute}"
    done

    echo "$new_name"
}

function process_directory() {
    	local dir="$1"
    	for entry in "$dir"/*; do
        	if [[ -d "$entry" && "$recursive" == "true" ]]; then
            		process_directory "$entry"  # Recurse into subdirectory
        	elif [ -f "$entry" ]; then
			local filepath=$(realpath "$entry")
		        local hash=$(calc_hash "$filepath")
			local permissions=$(get_permissions "$filepath")
			local filedate=$(get_file_create_date "$filepath")
			local filesize=$(get_file_size "$filepath")
			local is_temp=$(is_file_temp "$filepath")
			local dangerous_chars=$(has_dangerous_chars "$filepath")
			local unusual_permissions=$(has_unusual_permissions "$filepath")

			echo -e "\tProcessing file: $filepath"
			echo -e "\t\tHash: $hash"
			echo -e "\t\tPermissions: $permissions"
        		echo -e "\t\tDate: $filedate"
			echo -e "\t\tSize: $filesize"
			echo -e "\t\tTemp: $is_temp"
			echo -e "\t\tDangerous Chars: $dangerous_chars"
			echo -e "\t\tUnusual Permissions: $unusual_permissions"
			echo -e "\t\tSuggested Name: $(suggest_name $filepath)"
		fi
    	done
}


function get_params() {
	# Get flags
	while getopts "rh" opt; do
		case "$opt" in
			r) recursive=true ;;
			h) usage ;;
			*) usage ;;
		esac
	done

	# Get params (directories to check)
	shift $((OPTIND - 1))

	if [[ $# -eq 0 ]]; then
		echo "You have to specify directories"
		usage
	fi

	for dir in "$@"; do
		if [[ -d "$dir" ]]; then
			echo "Processing dir: $dir"
			process_directory "$dir"
		else
			echo "$dir is not a directory"
			usage
		fi
	done
}

welcome
get_params "$@"










