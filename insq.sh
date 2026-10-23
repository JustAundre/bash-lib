#!/usr/bin/env bash
insq() {
	# in^2/insq | (in)telligent (in)sertation
	local file="${1}" anchor="${2}" pos="${3}" delta_indent="${4}" base_indent='' indent='' block='' entry='' i=0
	shift 4
	if ! [[ ${pos} == append || ${pos} == prepend ]]; then
		log e 'position argument 3 must be "append" or "prepend".'
		return 1
	fi
	#
	# One indentation level, taken from the first indented non-blank line
	base_indent="$(awk 'match($0, /^[[:space:]]+[^[:space:]]/) { print substr($0, 1, RLENGTH - 1); exit }' "${file}")"
	: "${base_indent:=    }"
	for ((i = 0; i < delta_indent; i++)); do
		indent+="${base_indent}"
	done
	#
	# Build the inserted block
	for entry in "${@}"; do
		# Escape backslashes and ampersands
		entry="${entry//\\/\\\\}"
		entry="${entry//&/\\&}"
		#
		# ("\1" re-uses the anchor line's indentation)
		block+="${block:+\\n}\\1${indent}${entry}"
	done
	if [[ ${pos} == append ]]; then
		block='\1\2\n'"${block}"
	else
		block="${block}"'\n\1\2'
	fi
	sed -Ei "s${sed_delim}^([[:space:]]*)(${anchor})${sed_delim}${block}${sed_delim}" "${file}"
}
export -f insq
