#!/usr/bin/bash
source users_info.sh
source cryptage.sh
function envoyerMessage {
	IMF=" "
	name="$2.json"
	jq -n --arg destinataires "$1" --arg objet "$2" --arg message "$3" '{destinataires: $destinataires, objet: $objet, message: $message }' > "$name"
	crypter "$name"
	rm $name
	for user in $1
	do
		home=$(getHome $user)
		verifDossier $home
		sudo cp "$name.asc" "$home/messages_script_messagerie/$name.asc"
		sudo chmod 700 "$home/messages_script_messagerie/$name.asc"
		sudo chown -R "$user:$user" "$home/messages_script_messagerie/$name.asc"
	done
	rm "$name.asc"
	IMF="\n"
}

envoyerMessage "enzouille enzouille2" "deuxiemeTest" "Hello World"