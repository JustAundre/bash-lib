#!/usr/bin/env bash
reconfig() {
	local OPTIND=1 opt delimiter=' ' exception='abort' create_nonexistent=0 duplicate=0 key_re='' delim_re='' key_rep='' delim_rep='' value_rep=''
	while getopts 'd:x:p' opt; do
		case "${opt}" in
			d) delimiter="${OPTARG}" ;;
			x) exception="${OPTARG}" ;;
			p) create_nonexistent=1  ;;
			*) return 1              ;;
		esac
	done
	shift "$((OPTIND - 1))"
	if (($# != 3)); then
		log e 'usage: reconfig [-d delim] [-x replace|append|abort] [-p] key value file'
		return 1
	fi
	local key="${1}" value="${2}" file="${3}"
	#
	# Validation
	case "${exception}" in
		replace|append|abort) ;;
		*)
			log e "${exception@Q} is not a valid value for -x."
			log i 'valid values for -x are: "replace", "append", or "abort".'
			return 1
			;;
	esac
	#
	# Create non-existent path if specified
	if [[ -d "${file}" ]]; then
		log e "cannot write to a directory: ${file@Q}"
		return 3
	elif [[ ! -f "${file}" ]]; then
		if ((create_nonexistent)); then
			mkdir -p "$(dirname "${file}")" && : >>"${file}" || return 3
		else
			log e "${file@Q} doesn't exist."
			return 3
		fi
	fi
	#
	# Escape helpers: one for ERE patterns, one for sed replacement text
	key_re="$(sed 's/[][\\.*^$+?(){}|/]/\\&/g' <<<"${key}")"
	delim_re="$(sed 's/[][\\.*^$+?(){}|/]/\\&/g' <<<"${delimiter}")"
	key_rep="$(sed 's/[\\&/]/\\&/g' <<<"${key}")"
	delim_rep="$(sed 's/[\\&/]/\\&/g' <<<"${delimiter}")"
	value_rep="$(sed 's/[\\&/]/\\&/g' <<<"${value}")"
	local pattern="^[[:space:]]*${key_re}${delim_re}"
	grep -q -E "${pattern}" "${file}" && duplicate=1
	if ((duplicate)) && [[ "${exception}" != 'append' ]]; then
		case "${exception}" in
		replace)
			sed -i -E "s/${pattern}.*\$/${key_rep}${delim_rep}${value_rep}/" "${file}"
			;;
		abort)
			log e "operation aborted: ${key@Q} is already defined in ${file@Q}."
			return 2
			;;
		esac
	else
		echo "${key}${delimiter}${value}" >>"${file}"
	fi
}
export -f reconfig
