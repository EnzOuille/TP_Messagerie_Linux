#!/usr/bin/bash

function getUsers {
	echo "$(awk -F: '{ print $1}' /etc/passwd)"
}

function userExist {
	chaine_minuscule=$(echo "$1" | awk '{ print tolower($0) }')
	if id "$chaine_minuscule" &>/dev/null; then
		echo 0
	else
		echo 1
	fi
}

function currentUser {
	echo "$(whoami)"
}

userExist invite