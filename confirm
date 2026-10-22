#!/usr/bin/env bash
confirm() {
	local response=''
	until [[ ${response} =~ ^[YyNn]$ ]]; do
		read -rep "${ansii[rev]}${ansii[lime]}Q: ${1}? [y/n]: ${ansii[reset]}" response
	done
	[[ "${response}" =~ ^[Yy]$ ]]
}
export -f confirm
