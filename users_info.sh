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

function getMessageFolder {
	user_home=$(getHome $(currentUser))
	res="$user_home/messages_script_messagerie"
	echo "$res"
}