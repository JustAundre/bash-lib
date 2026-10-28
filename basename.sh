#!/usr/bin/env bash
basename() {
	local path="${1}"
	local suffix="${2}"
	while [[ ${path} == *'/' && ${path} != '/' ]]; do
	    path="${path%/}"
	done
	local name="${path##*/}"
	if [[ -n ${suffix} && ${name} == *"${suffix}" && ${name} != "${suffix}" ]]; then
	    name="${name%"${suffix}"}"
	fi
	echo "${name:-/}"
}
export -f basename
