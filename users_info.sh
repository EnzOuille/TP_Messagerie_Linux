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

function getHome {
	user_home=$(getent passwd $1 | cut -d: -f6)
	echo "$user_home"
}

function verifDossier {
	if [ -d "$1/messages_script_messagerie" ]; then
		echo 0
	else
		echo 1
		mkdir "$1/messages_script_messagerie"
	fi
}