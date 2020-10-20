#!/usr/bin/bash
CURRENT_USER=""

function main {
	echo "Ceci est le main du projet. Merci de faire le reste"
	getUser
}

function getUser {
	echo "Utilisateur courant : $(whoami)."
}
main
