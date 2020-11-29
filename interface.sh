#!/usr/bin/bash
source users_info.sh
source envoi.sh
source cryptage.sh

function consult {
	dossier_courant=$(getMessageFolder)
	options=()
	compteur=0
	files=()
	IFS=$'\n'
	all_files=($(find "$dossier_courant" . -name "*.gpg"))
	if [ "$(find "$dossier_courant" . -name "*.gpg")" = "" ]; then
		dialog --clear --msgbox "Vous n'avez aucun message" 0 0
	else
		for file in ${all_files[*]}; do
			options+=("$compteur")
			let compteur++
			options+=("$(gpg -q --decrypt --armor "$file" | jq ".objet")")
			files+=("$file")
		done
		IFS=$' '
		SORTIE=$(dialog --clear --title "Liste des messages" \
				--menu "Choix du message" 15 100 10 "${options[@]}" 2>&1 > /dev/tty)
		if [ $? -gt 0 ];then
		    break;
		else
		    infos_fichier=$(gpg -q --decrypt --armor "${files[$SORTIE]}")
		dialog --clear --msgbox "Destinataires : $(echo "$infos_fichier" | jq ".destinataires") \nObjet : $(echo "$infos_fichier" | jq ".objet") \nMessage : $(echo "$infos_fichier" | jq ".message")" 0 0
		fi
		
		
	fi
	
}

function interfaceDepart {
	if [ $(keyExist) -ge 1 ]; then
		generateFileForKey
		createKey
	fi
	path="$HOME/messages_script_messagerie"
	if [ ! -d $path ]; then
		mkdir "$HOME/messages_script_messagerie"
	fi
	INPUT=/tmp/menu.sh.$$
	ARRET=false
	while [ $ARRET = "false" ]; do
	    dialog --clear --title "Dialog Test" \
		   --menu "Choix de l'action" 20 100 3 \
		   Send "Send a message" \
		   Consult "Consult your messages" \
		   Exit "Quit the program" 2>"${INPUT}"
	    menuitem=$(<"${INPUT}")
	    exit=$?
	    if [ $exit -eq 0 ];then
		ARRET=true;
	    fi
	    case $menuitem in
		Send) ARRET=false
		      interfaceEnvoiMessage;;
		Consult) ARRET=false
			 consult;;
		Exit) ARRET=true
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
	ARRET=false
	while [ $testNull -ge 1 -o $testUser -ge 1 ]
	do
		VALUES=$(dialog --ok-label "Envoyer" \
			  --backtitle "$testNull - $testUser" \
			  --title "Envoyer un message" \
			  --form "Saisir les champs pour envoyer un message" \
		15 100 5 \
			"Destinataires:"         1 1	"" 	1 15 85 500 \
			"        Objet:"         3 1	""  	3 15 85 500 \
			"     Messsage:"         5 1	""  	5 15 85 1000 2>&1 > /dev/tty)
		if [ $? -gt 0  ]; then
		    break;
		fi
		compteur=0
		IFS=$'\n'
		y=($VALUES)
		utilisateurs=${y[0]}
		utilisateurs+=" $(whoami)"
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
