#!/usr/bin/env bash

source .clean_files

recursive=false
delete_temp=false
delete_empty=false
delete_duplicates=false
change_permissions=false
change_filenames=false

declare -a temp_files=()
declare -a empty_files=()
declare -a unusual_permissions_files=()
declare -a dangerous_names_files=()
declare -A file_hashes=()
declare -A duplicates=()

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

	echo -e 'Author: wiktoz (Wiktor Zawadzki)'
	echo -e 'GitHub: https://github.com/wiktoz/dir-cleaner'
	echo -e "\n"
}

function usage() {
	echo "usage: $0 [-r] [-h] [dir1 dir2 ...]"
	echo ""
	exit 1
}

function confirm_action() {
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
    local input=$(basename "$1")
    local sanitized=$(suggest_name "$input")
    
    if [[ "$sanitized" != "$input" ]]; then
        echo "true"
    else
        echo "false"
    fi
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
    local input=$(basename "$1")
    printf '%s' "$input" | tr "$dangerous_chars" '_'
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
			local file_has_dangerous_chars=$(has_dangerous_chars "$filepath")
			local file_has_unusual_permissions=$(has_unusual_permissions "$filepath")
			local new_name=$(suggest_name "$filepath")

			if [[ "$is_temp" == "true" ]]; then
                		temp_files+=("$filepath")
            		fi

			if [[ "$file_has_dangerous_chars" == "true" ]]; then
				dangerous_names_files+=("$filepath")
			fi

			if [[ "$file_has_unusual_permissions" == "true" ]]; then
				unusual_permissions_files+=("$filepath")
			fi

			if [[ "$filesize" -eq 0 ]]; then
    				empty_files+=("$filepath")
			else
    				if [[ -n "${file_hashes[$hash]}" ]]; then
        				file_hashes[$hash]="${file_hashes[$hash]}|$filepath"
    				else
        				file_hashes[$hash]="$filepath"
    				fi
			fi

			echo -e "\tProcessing file: $filepath"
			echo -e "\t\tHash: $hash"
			echo -e "\t\tPermissions: $permissions"
        		echo -e "\t\tDate: $filedate"
			echo -e "\t\tSize: $filesize"
			echo -e "\t\tTemp: $is_temp"
			echo -e "\t\tDangerous Chars: $file_has_dangerous_chars"
			echo -e "\t\tUnusual Permissions: $file_has_unusual_permissions"
			echo -e "\t\tSuggested Name: $new_name"
		fi
    	done
}

function handle_temp_files() {
    if [[ ${#temp_files[@]} -eq 0 ]]; then
        echo -e "\n\e[1;32m[+] No temporary files found.\e[0m"
        return
    fi

    echo -e "\n\e[1;31m[!] Temporary files found (${#temp_files[@]}):\e[0m"
    for f in "${temp_files[@]}"; do
        echo -e "\t$f"
    done

    echo -en "\e[1;33m[?] Do you want to delete all these temporary files? [yes/no]:\e[0m "
    local confirm=$(confirm_action)

    if [[ "$confirm" == "True" ]]; then
        for f in "${temp_files[@]}"; do
            echo -e "\tDeleting $f"
            rm -f "$f"
        done
        echo -e "\e[1;32m[+] All temporary files deleted.\e[0m"
    else
        echo -e "\e[1;34m[-] Temporary file deletion skipped.\e[0m"
    fi
}

function handle_empty_files() {
    if [[ ${#empty_files[@]} -eq 0 ]]; then
        echo -e "\n\e[1;32m[+] No empty files found.\e[0m"
        return
    fi

    echo -e "\n\e[1;31m[!] Empty files detected (${#empty_files[@]}):\e[0m"
    for f in "${empty_files[@]}"; do
        echo -e "\t$f"
    done

    echo -en "\e[1;33m[?] Do you want to delete all these empty files? [yes/no]:\e[0m "
    local confirm=$(confirm_action)

    if [[ "$confirm" == "True" ]]; then
        for f in "${empty_files[@]}"; do
            echo -e "\tDeleting $f"
            rm -f "$f"
        done
        echo -e "\e[1;32m[+] All empty files deleted.\e[0m"
    else
        echo -e "\e[1;34m[-] Deletion of empty files cancelled.\e[0m"
	fi
}



function handle_duplicates() {
    for hash in "${!file_hashes[@]}"; do
        IFS='|' read -r -a files <<< "${file_hashes[$hash]}"

        if [[ ${#files[@]} -gt 1 ]]; then
            echo -e "\n\e[1;31m[+] Found duplicates for hash: $hash\e[0m"
            for f in "${files[@]}"; do
                echo -e "\t$f"
            done

            # Find oldest file by creation date
            oldest_file="${files[0]}"
            oldest_time=$(get_file_create_date "$oldest_file")

            for f in "${files[@]:1}"; do
                file_time=$(get_file_create_date "$f")
                if (( file_time < oldest_time )); then
                    oldest_time=$file_time
                    oldest_file=$f
                fi
            done

            echo -en "\e[1;33m[?] Keep oldest file: $oldest_file and delete the others? [yes/no]\e[0m: "
    		local confirm=$(confirm_action)

            if [[ "$confirm" == "True" ]]; then
                for f in "${files[@]}"; do
                    if [[ "$f" != "$oldest_file" ]]; then
                        echo -e "\tDeleting $f"
                        rm -f "$f"
                    fi
                done
            else
                echo -e "\e[1;34m[-] Duplicates deletion cancelled.\e[0m"
            fi
        fi
    done
}

function handle_dangerous_names_files() {
    if [[ ${#dangerous_names_files[@]} -eq 0 ]]; then
        echo -e "\n\e[1;32m[+] No files with dangerous characters found.\e[0m"
        return
    fi

    echo -e "\n\e[1;31m[!] Files with dangerous characters in names (${#dangerous_names_files[@]}):\e[0m"
    for f in "${dangerous_names_files[@]}"; do
        echo -e "\t$f → $(suggest_name "$f")"
    done

    echo -en "\e[1;33m[?] Do you want to rename all of these files to safe names? [yes/no]:\e[0m "
    local confirm=$(confirm_action)

    if [[ "$confirm" == "True" ]]; then
        for f in "${dangerous_names_files[@]}"; do
            dir=$(dirname "$f")
            base=$(basename "$f")
            safe_name=$(suggest_name "$f")
            new_path="$dir/$safe_name"

            if [[ "$f" != "$new_path" ]]; then
                echo -e "\tRenaming: $f → $new_path"
                mv "$f" "$new_path"
            fi
        done
        echo -e "\e[1;32m[+] All files renamed successfully.\e[0m"
    else
        echo -e "\e[1;34m[-] Cancelled by user.\e[0m"
	fi
}

function permstr_to_octal() {
	local permstr="$1"

	# Validate input length
	if [[ ${#permstr} -ne 9 ]]; then
		echo "Invalid permission string length. Must be 9 characters (e.g., rwxr-xr--)." >&2
		return 1
	fi

	local octal=""
	for i in {0..2}; do
		local triplet="${permstr:$((i * 3)):3}"
		local value=0

		[[ "${triplet:0:1}" == "r" ]] && ((value+=4))
		[[ "${triplet:1:1}" == "w" ]] && ((value+=2))
		[[ "${triplet:2:1}" == "x" ]] && ((value+=1))

		octal+="$value"
	done

	echo "$octal"
}

function handle_unusual_permissions() {
	if [[ ${#unusual_permissions_files[@]} -eq 0 ]]; then
		echo -e "\n\e[1;32m[+] No files with unusual permissions found.\e[0m"
		return
	fi

	echo -e "\n\e[1;31m[!] Found ${#unusual_permissions_files[@]} files with unusual permissions.\e[0m"
	for f in "${unusual_permissions_files[@]}"; do
		echo -e "\t$f"
	done

	echo -en "\e[1;33m[?] Do you want to change permissions to $default_permissions? [yes/no]:\e[0m "
    local confirm=$(confirm_action)

	if [[ "$confirm" == "True" ]]; then
        for f in "${unusual_permissions_files[@]}"; do
            local octal_permissions=$(permstr_to_octal "$default_permissions")
			chmod "$octal_permissions" "$f" 2>/dev/null
        done
        echo -e "\e[1;32m[+] Permissions changed.\e[0m"
    else
        echo -e "\e[1;34m[-]  Skipped changing permissions.\e[0m"
	fi
}



function get_params() {
	# Get flags
	while getopts "rh" opt; do
		case "$opt" in
			r) recursive=true ;;
			t) delete_temp=true ;;
			e) delete_empty=true ;;
			d) delete_duplicates=true ;;
			p) change_permissions=true ;;
			n) change_filenames=true ;;
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
handle_temp_files
handle_empty_files
handle_duplicates
handle_dangerous_names_files
handle_unusual_permissions

exit
