#!/usr/bin/env bash
perm-fix() {
	# Parse arguments
	local OPTIND=1 errors=() mode='' owner='' group='' force=0 no_args_success=0 i=0 arg='' paths=() stdin_path='' stdin_paths=()
	while getopts 'm:o:g:fs' arg 2>(log e); do
		case "${arg}" in
		m)
			mode="${OPTARG}"
			[[ ${mode} =~ ^[01234567]{3,4}$ ]] ||
				errors+=("${mode@Q} is an invalid octal mode.")
			;;
		o)
			owner="${OPTARG}"
			[[ ${owner} =~ ^[0-9]+$ ]] ||
				getent passwd -- "${owner}" &>/dev/null ||
				errors+=("${owner@Q} is an invalid user.")
			;;
		g)
			group="${OPTARG}"
			[[ ${group} =~ ^[0-9]+$ ]] ||
				getent group -- "${group}" &>/dev/null ||
				errors+=("${group@Q} is an invalid group.")
			;;
		f)
			force=1
			;;
		s)
			no_args_success=1
			;;
		esac
	done
	shift "$((OPTIND - 1))"
	#
	# Collect paths from the arguments, then append any NUL-delimited paths piped in via stdin.
	# Empty entries (i.e. from a trailing or doubled delimiter) are ignored.
	paths=("${@}")
	if ((!${#paths[@]})) && [[ ! -t 0 ]]; then
		mapfile -t -d '' stdin_paths
		for stdin_path in "${stdin_paths[@]}"; do
			[[ -n ${stdin_path} ]] && paths+=("${stdin_path}")
		done
	fi
	#
	# Iterate over every path
	# Loop over a snapshot of the indices so unsetting entries can't skip later paths.
	for i in "${!paths[@]}"; do
		# Validate path
		if [[ ! -e ${paths[${i}]} ]]; then
			log e "cannot access ${paths["${i}"]@Q}: No such file or directory."
			unset "paths[${i}]"
			continue
		fi
		if [[ -L ${paths[${i}]} ]]; then
			if ((!force)); then
				log e "refused to process symlink ${paths["${i}"]@Q} without option -f."
				unset "paths[${i}]"
			else
				log w "${paths["${i}"]@Q} is a symlink to $(realpath -- "${paths["${i}"]}")."
			fi
		fi
	done
	#
	# Validate args
	if ((!${#paths[@]})) || [[ -z ${mode} && -z ${owner} && -z ${group} ]]; then
		errors+=("insufficient operand(s)")
	fi
		if ((${#errors[@]})); then
			log e "${errors[@]}"
			return 1
		fi
	if ((no_args_success)); then
		((${#paths[@]})) || return 5
	else
		return 0
	fi
	#
	# Apply changes
	if [[ -n ${owner} && -n ${group} ]]; then
		printf '%s\0' "${paths[@]}" | xargs -0 -L 250 chown -c -- "${owner}:${group}" || return 3
	elif [[ -n ${owner} && -z ${group} ]]; then
		printf '%s\0' "${paths[@]}" | xargs -0 -L 250 chown -c -- "${owner}" || return 3
	elif [[ -z ${owner} && -n ${group} ]]; then
		printf '%s\0' "${paths[@]}" | xargs -0 -L 250 chgrp -c -- "${group}" || return 3
	fi
	if [[ -n ${mode} ]]; then
		printf '%s\0' "${paths[@]}" | xargs -0 -L 250 chmod -c -- "${mode}" || return 4
	fi
}
export -f perm-fix
