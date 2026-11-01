#!/usr/bin/env bash
pause() {
	local seconds="${1:-10}" REPLY='' status='0'
	if [[ "${seconds}" == 0 ]]; then
		read -r -n 1 -p "(Paused indefinitely)"$'\n⏸ ⏸ ⏸ > > PRESS ANY KEY TO RESUME < < ⏸ ⏸ ⏸\n'
	else
		read -r -t "${seconds}" -n 1 -p "(Auto-resuming in ${seconds} seconds...)"$'\n⏸ ⏸ ⏸ > > PRESS ANY KEY TO RESUME < < ⏸ ⏸ ⏸\n' || status='1'
	fi
	log i 'Resumed script.'
	((status))
}
export -f pause
