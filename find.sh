#!/usr/bin/env bash
find() {
	local arg args
	for arg in "${@}"; do
		if [[ ${arg} == '-xephem' ]]; then
			args+=(
				'('
				-path /tmp
				-o -path /run
				-o -path /dev
				-o -path /proc
				-o -path /sys
				-o -path /var/run
				-o -path /var/lock
				-o -path /var/tmp
				-o -path /var/cache
				')'
				-prune
				-o
			)
		else
			args+=("${arg}")
		fi
	done
	command find "${args[@]}"
}
export -f find
