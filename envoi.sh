#!/usr/bin/bash
source users_info.sh
source cryptage.sh
function envoyerMessage {
	name="$2.json"
	jq -n --arg destinataires "$1" --arg objet "$2" --arg message "$3" '{destinataires: $destinataires, objet: $objet, message: $message}' > "$HOME/messages_script_messagerie/$name"
	IFS=$' '
	for user in $1
	do
		if [ $user != $(whoami) ]; then
			crypter "$HOME/messages_script_messagerie/$name" "$user"
			home_user=$(getHome $user)
			verifDossier $home
			sudo cp "$HOME/messages_script_messagerie/$name.gpg" "$home_user/messages_script_messagerie/$name.gpg"
			sudo chmod 700 "$home_user/messages_script_messagerie/$name.gpg"
			sudo chown -R "$user:emails" "$home_user/messages_script_messagerie/$name.gpg"
			rm "$HOME/messages_script_messagerie/$name.gpg"
		else
			crypter "$HOME/messages_script_messagerie/$name" "$user"
		fi
	done
	rm "$HOME/messages_script_messagerie/$name"
}

function verifDossier {
	if [ -d "$1/messages_script_messagerie" ]; then
		echo 0
	else
		echo 1
		sudo mkdir "$1/messages_script_messagerie"
	fi
}