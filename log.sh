#!/usr/bin/env bash
log() {
	# Catch arguments (if no input in args, grab input from stdin.)
	local type="${1}" input=()
	shift 1
	if [[ -n "${1}" ]]; then
		input=("${@}")
	elif [[ ! -t 0 ]]; then
		input=("$(< /dev/stdin)")
	fi
	#
	# If no input, error out.
	if [[ "${#input[@]}" -lt 1 ]]; then
		log e 'log: Missing operand.'
		return 2
	fi
	#
	# Parse input
	case "${type}" in
	i) printf -- "${ansii[rev]}${ansii[cyan]}i: %s${ansii[reset]}\n" "${input[@]}" ;;
	w) printf -- "${ansii[rev]}${ansii[yellow]}W: %s${ansii[reset]}\n" "${input[@]}" >&2 ;;
	e) printf -- "${ansii[rev]}${ansii[red]}E: %s${ansii[reset]}\n" "${input[@]}" >&2 ;;
	*)
		log e "log: invalid log type ${type@Q}. Valid options are \"i\" (info), \"w\" (warning), or \"e\" (error)."
		return 3
		;;
	esac
}
export -f log
