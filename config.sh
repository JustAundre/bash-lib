#!/usr/bin/env bash
#
# Environment Setup
#
# Declare ANSII colors used in global scope.
declare -A ansii
ansii[rev]='\e[7m'
ansii[cyan]='\e[36m'
ansii[yellow]='\e[33m'
ansii[red]='\e[31m'
ansii[reset]='\e[0m'
