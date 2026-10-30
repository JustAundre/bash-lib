#!/usr/bin/env bash
reconfig() {
	# Parse arguments
	local OPTIND=1 delimiter=' ' exception='abort' create_nonexistent=0 duplicate=0 arg=''
	while getopts 'd:x:p' arg 2>(log e); do
		case "${arg}" in
		d)
			delimiter="${OPTARG}"
			;;
		x)
			exception="${OPTARG}"
			;;
		p)
			create_nonexistent=1
			;;
		esac
	done
	shift "$((OPTIND - 1))"
	#
	# Create non-existent path if specified.
	[[ -f "${3}" ]] || if ((create_nonexistent)); then
		mkdir -p "$(dirname "${3}")" && true >> "${3}"
	elif [[ -d "${3}" ]]; then
		log e "cannot write to a directory: ${3@Q}"
	else
		log e "${3@Q} doesn't exist."
		return 3
	fi
	#
	# Handle duplicate entries accordingly
	grep -m 1 -q -E "^[^#]*${1}${delimiter}.*$" "${3}" && duplicate=1
	((duplicate)) && case "${exception}" in
	'replace')
		sed -i "s${sed_delim}^[^#]*${1}.*\$${sed_delim}${1}${delimiter}${2}${sed_delim}" "${3}"
		;;
	'append')
		echo "${1}${delimiter}${2}" >> "${3}"
		;;
	'abort')
		log e "operation aborted: ${1@Q} is already defined in ${3@Q}."
		return 2
		;;
	*)
		log e "${exception@Q} is not a valid value for -x."
		log i 'valid values for -x are: "replace", "append", or "abort".'
		return 1
		;;
	esac
}
export -f reconfig
