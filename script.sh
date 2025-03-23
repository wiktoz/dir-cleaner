#!/usr/bin/env bash

recursive=false

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
	echo "$permissions"
}

function process_directory() {
    	local dir="$1"
    	for entry in "$dir"/*; do
        	if [ -d "$entry" ]; then
            		process_directory "$entry"  # Recurse into subdirectory
        	elif [ -f "$entry" ]; then
			local filepath=$(realpath "$entry")
		        local hash=$(calc_hash "$filepath")
			local permissions=$(get_permissions "$filepath")

			echo -e "\tProcessing file: $filepath"
			echo -e "\t\tHash: $hash"
			echo -e "\t\tPermissions: $permissions"
        		echo -e "\t\tDate: $(stat --format=%Y $filepath)"
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
	echo "$OPTIND"
	echo "$#"

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

get_params "$@"










