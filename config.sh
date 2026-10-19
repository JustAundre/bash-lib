#!/usr/bin/env bash
declare -A ansii
ansii=(
	[rev]=$'\e[7m'
	[lime]=$'\e[92m'
	[cyan]=$'\e[36m'
	[yellow]=$'\e[33m'
	[red]=$'\e[31m'
	[reset]=$'\e[0m'
	[dim]=$'\e[2m'
)
sed_delim=$'\x01'
export ansii sed_delim
