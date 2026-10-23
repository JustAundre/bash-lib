#!/usr/bin/env bash
pkg-mgr() {
	if [[ ! "${pkg_backend}" =~ ('apt-get'|'dnf'|'yum'|'pacman'|'pkg') ]]; then
		log e "unsupported package manager: ${pkg_backend@Q}"
		return 1
	fi
	local action="${1}" pkgs=()
	shift

	case "${action}" in
	'install')
		case "${pkg_backend}" in
		'apt-get'|'dnf'|'yum')
			"${pkg_backend}" install -y "${@}"
			;;
		'pacman')
			"${pkg_backend}" -S --noconfirm "${@}"
			;;
		'pkg')
			"${pkg_backend}" install -y "${@}"
			;;
		esac
		;;
	'reset')
		case "${pkg_backend}" in
		'apt-get')
			"${pkg_backend}" autoremove -y --purge "${@}"
			"${pkg_backend}" install "${@}" -y -o Dpkg::Options::='--force-confnew' -o Dpkg::Options::='--force-confmiss'
			;;
		'dnf'|'yum')
			"${pkg_backend}" remove -y "${@}"
			;;
		'pacman')
			"${pkg_backend}" -Rns --noconfirm "${@}"
			;;
		'pkg')
			"${pkg_backend}" delete -y "${@}"
			"${pkg_backend}" install -fy "${@}"
			;;
		esac
		;;
	'update')
		case "${pkg_backend}" in
		'apt-get')
			"${pkg_backend}" update
			"${pkg_backend}" full-upgrade -y
			;;
		'dnf'|'yum')
			"${pkg_backend}" upgrade -y
			;;
		'pacman')
			"${pkg_backend}" -Syu --noconfirm
			;;
		'pkg')
			"${pkg_backend}" update
			"${pkg_backend}" upgrade -y
			;;
		esac
		;;
	'remove')
		case "${pkg_backend}" in
		'apt-get')
			"${pkg_backend}" autoremove -y --purge "${@}"
			;;
		'dnf'|'yum')
			"${pkg_backend}" remove "${@}"
			;;
		'pacman')
			"${pkg_backend}" -R --noconfirm "${@}"
			;;
		'pkg')
			"${pkg_backend}" delete -y "${@}"
			;;
		esac
		;;
	'verify-pkg')
		case "${pkg_backend}" in
		'apt-get')
			dpkg -V "${@}"
			;;
		'dnf'|'yum')
			rpm -V "${@}"
			;;
		'pacman')
			pacman -Qk "${@}"
			;;
		'pkg')
			"${pkg_backend}" check -s "${@}"
			;;
		esac
		;;
	'verify-file')
		case "${pkg_backend}" in
		'apt-get')
			if ! hash debsums &>/dev/null; then
		 		log e "'debsums' needs to be installed."
		   		return 4
		 	fi
			debsums -s "${@}"
			;;
		'dnf'|'yum')
			rpm -Vf "${@}"
			;;
		'pacman')
			mapfile -t pkgs < <("${pkg_backend}" -Qo -q "${@}" 2>/dev/null | sort -u)
			((${#pkgs[@]})) && pacman -Qk "${pkgs[@]}"
			;;
		'pkg')
			mapfile -t pkgs < <("${pkg_backend}" which -q "${@}" 2>/dev/null | sort -u)
			((${#pkgs[@]})) && pkg check -s "${pkgs[@]}"
			;;
		esac
		;;
	'verify-all')
		case "${pkg_backend}" in
		'apt-get')
			dpkg -Va
			;;
		'dnf'|'yum')
			rpm -Va
			;;
		'pacman')
			"${pkg_backend}" -Qkk
			;;
		'pkg')
			"${pkg_backend}" check -sa
			;;
		esac
		;;
	'query-owner')
		case "${pkg_backend}" in
		'apt-get')
			dpkg -S "${@}"
			;;
		'dnf'|'yum')
			rpm -qf "${@}"
			;;
		'pacman')
			"${pkg_backend}" -Qo "${@}"
			;;
		'pkg')
			"${pkg_backend}" which "${@}"
			;;
		esac
		;;
	*)
		log e "Invalid command: ${action@Q}"
		return 2
		;;
	esac
}
export -f pkg-mgr
