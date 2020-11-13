#!/usr/bin/bash

function getUsers {
	echo "$(awk -F: '{ print $1}' /etc/passwd)"
}

function userExist {
	chaine_minuscule=$(echo "$1" | awk '{ print tolower($0) }')
	if [[ "$(getUsers)" == *"$chaine_minuscule"* ]]
	then
		echo "L'utilisateur est présent"
	else
		echo "Faute"
	fi
}

userExist ENZOUILLE