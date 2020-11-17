#!/usr/bin/bash
source users_info.sh
source envoi.sh
function send {
 echo "TO DO"
 user=$(dialog --clear --title "Type the target" \
 --inputbox "Enter username" 10 50 3>&1 1>&2 2>&3 3>&-)
 user_home=$(getent passwd $user | cut -d: -f6)
 echo "$user_home"
 if [ -d $user_home ]
 then
  touch "$user_home/dossier_messagerie_bash/test.txt"
  gpg -e -r $user test.txt
  rm test.txt
 fi
}

function consult {
	dossier_courant=$(getMessageFolder)
	options=()
	compteur=0
	files=()
	for file in $(ls "$dossier_courant"); do
		#echo "$(cat "$dossier_courant/$file")"
		options+=("$compteur")
		let compteur++
		options+=("$(gpg -q --decrypt --armor "$dossier_courant/$file" | jq ".objet")")
		files+=("$dossier_courant/$file")
	done
	SORTIE=$(dialog --stdout --clear --title "Liste des messages" \
	--menu "Choix du message" 15 100 10 "${options[@]}")
	infos_fichier=$(gpg -q --decrypt --armor "${files[$SORTIE]}")
	dialog --clear --msgbox "Destinataires : $(echo "$infos_fichier" | jq ".destinataires") \nObjet : $(echo "$infos_fichier" | jq ".objet") \nMessage : $(echo "$infos_fichier" | jq ".message")" 0 0 
}

function interfaceDepart {
	INPUT=/tmp/menu.sh.$$
	ARRET=false
	while [ $ARRET = "false" ]; do
		dialog --clear --title "Dialog Test" \
		--menu "Choix de l'action" 20 100 3 \
		Send "Send a message" \
		Consult "Consult your messages" \
		Exit "Quit the program" 2>"${INPUT}"

		menuitem=$(<"${INPUT}")

		case $menuitem in
		 Send) interfaceEnvoiMessage;;
		 Consult) consult;;
		 Exit) 
			ARRET=true
			break;;
		esac
	done
}

function interfaceEnvoiMessage {
	utilisateurs=""
	objet=""
	message=""
	res=("" "" "")
	testNull=$(verifMessage res)
	testUser=$(verifUsers $utilisateurs)
	echo "$testUser testUser"
	while [ $testNull -ge 1 -o $testUser -ge 1 ]
	do
		VALUES=$(dialog --stdout --ok-label "Envoyer" \
			  --backtitle "$testNull - $testUser" \
			  --title "Envoyer un message" \
			  --form "Saisir les champs pour envoyer un message" \
		15 100 5 \
			"Destinataires:"         1 1	"" 	1 15 85 500 \
			"        Objet:"         3 1	""  	3 15 85 500 \
			"     Messsage:"         5 1	""  	5 15 85 1000)
		compteur=0
		IFS=$'\n'
		y=($VALUES)
		utilisateurs=${y[0]}
		objet=${y[1]}
		message=${y[2]}
		IFS=$' '
		testNull=$(verifMessage $utilisateurs $objet $message)
		testUser=$(verifUsers $utilisateurs)
	done
	envoyerMessage "$utilisateurs" "$objet" "$message"
}

function verifMessage {
	res=1
	if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ]
	then
		echo "$res"
	else
		res=0
		echo "$res"
	fi
}

function verifUsers {
	res=1
	for user in $1
	do
		if [ $(userExist $user) -eq 0 ]
		then
			res=0
		fi
	done
	echo "$res"
}