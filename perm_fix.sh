#!/usr/bin/env bash
perm_fix() {
	local errors path before after
	#
	# Parse arguments
	while getopts 'm:o:g:' arg; do
		case "${arg}" in
			m) local mode="${OPTARG}";;
			o) local owner="${OPTARG}";;
			g) local group="${OPTARG}";;
			*)
				log e "Invalid opt."
				return 1
			;;
		esac
	done
	#
	# Validate user:group/octal permissions
	if
		[[ -n "${owner}" && ! "${owner}" =~ ^[0-9]+$ ]] ||
		! getent passwd -- "${owner}" &>/dev/null
	then
		errors+=("${owner} is an invalid user.")
	elif
		[[ -n "${group}" && ! "${group}" =~ ^[0-9]+$ ]] ||
		! getent group -- "${group}" &>/dev/null
	then
		errors+=("${group} is an invalid group.")
	elif [[ -n "${mode}" && ! "${mode}" =~ ^[01234567]{3,4} ]]; then
		errors+=("${mode} is an invalid octal mode.")
	fi
	if [[ -n "${errors[*]}" ]]; then
		log e "${errors[@]}"
		return 2
	fi
	#
	# Shift by the amount of getopts to get our paths
	shift "$((OPTIND - 1))"
	#
	# Iterate over every path
	for path in "$@"; do
		# Create non-existent files
		mkdir -p "$(dirname -- "${path}")" >>"${path}"
		#
		# Save stats for file pre-change
		before="$(stat -c '%a %u/%U:%g/%G' -- "${path}")"
		#
		# Attempt the change
		chown -hP -- "${owner}:${group}" "${path}" || return 3
		[[ -n "${mode}" ]] && chmod -hP -- "${mode}" "${path}" || exit 4
		#
		# Check stats for file post-change
		after="$(stat -c '%a %u/%U:%g/%G' -- "${path}")"
		#
		# Log diffs bewteen pre and post stats
		[[ "${before}" != "${after}" ]] &&
			log w "${path} with \"${before}\" deviated from, and was restored to \"${after}\"."
	done
}