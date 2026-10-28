#!/usr/bin/env bash
dirname() {
	local path="${1}"
	while [[ ${path} == *'/' && ${path} != '/' ]]; do
		path="${path%/}"
	done
	local dir="${path%/*}"
	if [[ ${dir} == "${path}" ]]; then
		echo '.'
	elif [[ -z "${dir}" ]]; then
		echo '/'
	else
		echo "${dir}"
	fi
}
export -f dirname
