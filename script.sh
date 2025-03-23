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

confirm_action

while getopts "rh" opt; do
	case "$opt" in
		r) recursive=true ;;
		h) usage ;;
		*) usage ;;
	esac
done

