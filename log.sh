#!/usr/bin/env bash
log() {
	# Catch arguments (if no input in args, grab input from stdin.)
	if [[ ! ${FUNCNAME[1]} =~ ^('main'|'source'|'')$ ]]; then
		local _BASH_LIB_LOG_BASE_NAME="${FUNCNAME[1]}"
	elif [[ -z ${_BASH_LIB_LOG_BASE_NAME} ]]; then
		_BASH_LIB_LOG_BASE_NAME="${0##*/}"
	fi
	local type="${1}" input=()
	shift 1
	if [[ -n ${1} ]]; then
		input=("${@}")
	elif [[ ! -t 0 ]]; then
		input=("$(</dev/stdin)")
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
	i) printf -- "${ansii[rev]}${ansii[cyan]}i: ${_BASH_LIB_LOG_BASE_NAME}: %s${ansii[reset]}\n" "${input[@]}" ;;
	w) printf -- "${ansii[rev]}${ansii[yellow]}W: ${_BASH_LIB_LOG_BASE_NAME}: %s${ansii[reset]}\n" "${input[@]}" >&2 ;;
	e) printf -- "${ansii[rev]}${ansii[red]}E: ${_BASH_LIB_LOG_BASE_NAME}: %s${ansii[reset]}\n" "${input[@]}" >&2 ;;
	*)
		log e "unknown log type ${type@Q}."' Valid options are "i" (info), "w" (warning), or "e" (error).'
		return 3
		;;
	esac
}
export -f log
