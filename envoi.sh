#!/usr/bin/bash
source users_info.sh
source cryptage.sh
function envoyerMessage {
	name="$2.json"
	jq -n --arg destinataires "$1" --arg objet "$2" --arg message "$3" '{destinataires: $destinataires, objet: $objet, message: $message}' > "$HOME/messages_script_messagerie/$name"
	IFS=$' '
	for user in $1
	do
		crypter "$HOME/messages_script_messagerie/$name" "$user"
		home_user=$(getHome $user)
		verifDossier $home
		sudo cp "$HOME/messages_script_messagerie/$name.asc" "$home_user/messages_script_messagerie/$name.asc"
		sudo chmod 700 "$home_user/messages_script_messagerie/$name.asc"
		sudo chown -R "$user:emails" "$home_user/messages_script_messagerie/$name.asc"
		rm "$HOME/messages_script_messagerie/$name.asc"
	done
	#rm "$HOME/messages_script_messagerie/$name"
}

function verifDossier {
	if [ -d "$1/messages_script_messagerie" ]; then
		echo 0
	else
		echo 1
		sudo mkdir "$1/messages_script_messagerie"
	fi
}