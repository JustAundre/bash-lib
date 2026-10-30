#!/usr/bin/env bash
pause() {
	local seconds="${1:-10}" REPLY=''
	if [[ "${seconds}" == 0 ]]; then
		read -r -n 1 -p "(Paused indefinitely)"$'\n⏸ ⏸ ⏸ > > PRESS ANY KEY TO RESUME < < ⏸ ⏸ ⏸\n'
	else
		read -r -t "${seconds}" -n 1 -p "(Auto-resuming in ${seconds} seconds...)"$'\n⏸ ⏸ ⏸ > > PRESS ANY KEY TO RESUME < < ⏸ ⏸ ⏸\n'
	fi
	log i 'Resumed script.'
}
export -f pause
