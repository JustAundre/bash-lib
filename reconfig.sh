#!/usr/bin/env bash
reconfig() {
	# Parse arguments
	while getopts 'd:' arg; do
		case "${arg}" in
			d) local delimiter="${OPTARG}";;
			*)
				log e "Invalid argument."
				return 1
			;;
		esac
	done
	delimiter="${delimiter:-' '}"
	shift "$((OPTIND - 1))"
	#
	# The divider used to delimitate the key and value; and the target file.
	# Defined via an environment variable to avoid extreme repetition.
	# Remove any existing keys & then add the new entry
	mkdir -p "$(dirname -- ${3})"; >>"${3}"
	grep -qE "^[^#].*${1}${delimiter}.*$" <"${3}" &&
		sed -i "s/^[^#]*${1}.*$/${1}${delimiter}${2}/" <"${3}"
	echo "${1}${delimiter}${2}" >>"${3}"
}