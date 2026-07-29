#!/usr/bin/env bash
#
# Environment Setup
#
# Declare ANSII colors used in global scope.
declare -A ansii
ansii[blue]='\033[48;5;18m'
ansii[yellow]='\033[48;5;58m'
ansii[red]='\033[48;5;88m'
ansii[reset]='\033[0m'





#
# Define Function
#
log() {
	# ANSII escapes for coloring output
	local type
	#
	# Catch arguments (if no input in args, grab input from stdin.)
	type="${1}"; shift 1
	if [[ -t 0 && -n "${1}" ]]; then input=("$@")
	else input=("$(</dev/stdin)")
	fi
	#
	# If no input, error out.
	if [[ "${#input[@]}" -lt 1 ]]; then
		log e 'Missing message for "log" library command.'
		return 2
	fi
	#
	# Parse input
	case "${type}" in
		i) printf -- '%bi: %s' "${ansii[blue]}" "${input[@]}";;
		w) printf -- '%bW: %s' "${ansii[yellow]}" "${input[@]}" >&2;;
		e) printf -- '%bE: %s' "${ansii[red]}" "${input[@]}" >&2;;
		*)
			log e "Invalid log type \"${type}\". Valid options are \"i\" (info), \"w\" (warning), or \"e\" (error)."
			return 3
		;;
	esac
	#
	# Stop color from leaking & prints newline.
	printf '%b\n' "${ansii[reset]}"
}