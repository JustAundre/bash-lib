#!/usr/bin/env bash
reconfig() {
	local OPTIND=1 opt delimiter=' ' exception='abort' create_nonexistent=0 key value file lines=() found=0 i stripped
	while getopts 'd:x:p' opt; do
		case ${opt} in
			d) delimiter="${OPTARG}" ;;
			x) exception="${OPTARG}" ;;
			p) create_nonexistent=1 ;;
			*) return 1 ;;
		esac
	done
	shift "$((OPTIND - 1))"
	if (($# != 3)); then
		log e 'usage: reconfig [-d delim] [-x replace|append|abort] [-p] key value file'
		return 1
	fi
	key=${1} value=${2} file=${3}
	if [[ ! ${exception} =~ ^('replace'|'append'|'abort')$ ]]; then
		log e "${exception@Q} is not a valid value for -x."
		log i 'valid values for -x are: "replace", "append", or "abort".'
		return 1
	fi
	if [[ -d ${file} ]]; then
		log e "cannot write to a directory: ${file@Q}"
		return 3
	elif [[ ! -f ${file} ]]; then
		if ((create_nonexistent)); then
			{ [[ ${file} != */* ]] || mkdir -p -- "${file%/*}/"; } && : >>"${file}" || return 3
		else
			log e "${file@Q} doesn't exist."
			return 3
		fi
	fi
	mapfile -t lines <"${file}" || return 3
	for i in "${!lines[@]}"; do
		# Strip leading whitespace, then match key+delimiter as a literal prefix
		stripped=${lines[i]#"${lines[i]%%[![:space:]]*}"}
		[[ ${stripped} == "${key}${delimiter}"* ]] || continue
		found=1
		case ${exception} in
			abort)
				log e "operation aborted: ${key@Q} is already defined in ${file@Q}."
				return 2
				;;
			append)
				break
				;;
			replace)
				lines[i]=${key}${delimiter}${value}
				;;
		esac
	done
	if ((found)) && [[ ${exception} == 'replace' ]]; then
		for i in "${!lines[@]}"; do
			echo "${lines[i]}"
		done >"${file}" || return 3
	else
		echo "${key}${delimiter}${value}" >>"${file}" || return 3
	fi
}
export -f reconfig
