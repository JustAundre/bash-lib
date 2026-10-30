#!/usr/bin/env bash
log() {
	if [[ -n ${FUNCNAME[1]} && ${FUNCNAME[1]} != 'main' && ${FUNCNAME[1]} != 'source' ]]; then
		local _BASH_LIB_LOG_BASE_NAME="${FUNCNAME[1]}"
	elif [[ -z ${_BASH_LIB_LOG_BASE_NAME} && -n ${BASH_SOURCE[1]} ]]; then
		local _BASH_LIB_LOG_BASE_NAME="${BASH_SOURCE[1]##*/}"
	elif [[ -z ${_BASH_LIB_LOG_BASE_NAME} ]]; then
		_BASH_LIB_LOG_BASE_NAME="${0##*/}"
	fi
	[[ ${FUNCNAME[0]}${FUNCNAME[1]}${FUNCNAME[2]} == "${FUNCNAME[0]}${FUNCNAME[0]}${FUNCNAME[0]}" ]] &&
		echo "${ansii[rev]}${ansii[red]}E: ${_BASH_LIB_LOG_BASE_NAME}: recursive error detected. | Line: ${LINENO}${ansii[reset]}"
	#
	# Catch positional arguments (or stdin if none found)
	local type="${1}" input=()
	shift 1
	if [[ -n ${1} ]]; then
		input=("${@}")
	elif [[ ! -t 0 ]]; then
		mapfile -t input </dev/stdin
	fi
	#
	# If no input, error out.
	if ((${#input[@]} < 1)); then
		log e 'missing operand.'
		return 2
	fi
	#
	# Parse input
	case "${type}" in
	i) echo "${ansii[rev]}${ansii[cyan]}i: ${_BASH_LIB_LOG_BASE_NAME}: ${input[*]}${ansii[reset]}" ;;
	w) echo "${ansii[rev]}${ansii[yellow]}W: ${_BASH_LIB_LOG_BASE_NAME}: ${input[*]}${ansii[reset]}" >&2 ;;
	e) echo "${ansii[rev]}${ansii[red]}E: ${_BASH_LIB_LOG_BASE_NAME}: ${input[*]} | Line: ${LINENO}${ansii[reset]}" >&2 ;;
	*)
		log e "unknown log type ${type@Q}."' Valid options are "i" (info), "w" (warning), or "e" (error).'
		return 3
		;;
	esac
}
export -f log
