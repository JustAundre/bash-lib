#!/usr/bin/env bash
pause() {
	local seconds="${1:-10}"
	read -t"${seconds}" -n1 -rp "(Auto-resuming in ${seconds} seconds...)"$'\n⏸️ ⏸️ ⏸️ ===> ANY TO RESUME <=== ⏸️ ⏸️ ⏸️\n'
	log i 'Resumed.'
}