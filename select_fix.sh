#!/usr/bin/env bash
#
# Environment Setup
#
fixes=(
	'Change ownership'
	'Change permissions'
	'Rename node'
	'' '' ''
	'Delete'
)





#
# Define Function
#
select_fix() {
	# Prompt for action
	local preprompt_msg+="\"${1}\" is owned by $(stat -c '%U:%G/%u:%g' "${1}") with permissions $(stat -c '%a' "${1}")" selection x y user group basename
	#
	# Act on selections
	for selection in "$(checklist 'Select a method of remediation.' checklist "${fixes[@]}")"; do
		# Prompt for new ownership
		# Validate given user and group
		# Change the ownership
		case "${selection}" in
			'Change ownership')
				until [[ "${user}" =~ ^[0-9]+$ ]] || getent passwd -- "${user}" &>/dev/null && [[ -n "${user}" ]]; do
					[[ -n "${x}" ]] && log w 'Invalid username/UID provided.' || x=true
					read -rp 'Enter the new user owner: ' user
				done
				until [[ "${user}" =~ ^[0-9]+$ ]] || getent group -- "${group}" &>/dev/null && [[ -n "${group}" ]]; do
					[[ -n "${y}" ]] && log w 'Invalid group/GID provided.' || y=true
					read -rp 'Enter the new group owner: ' group
				done
				chown -hc -- "${user}:${group}" "${1}"
			;;'Change permissions')
				until [[ "${perm}" =~ ^[1234567]{3,4}$ ]]; do
					read -rp 'Enter the octal permission: ' perm
				done
				chmod -c -- "${perm}" "${1}"
			;;'Rename node')
				read -rp 'Enter the new name for the node' basename
				mv -- "${1}" "$(dirname -- "${1}")""${basename}"
			;;'Delete node')
				rm -rfv -- "${1}"
			;;
		esac
	done
}