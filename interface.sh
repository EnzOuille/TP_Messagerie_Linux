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
	all_files=$(ls $dossier_courant)
	lines=$(ls $dossier_courant | wc -l)
	files_to_delete=()
	if [ $lines -eq 0 ]; then
		dialog --clear --msgbox "Vous n'avez aucun message" 0 0
	else
		for file in ${all_files[*]}; do
			if [[ $file == *.gz ]];then
				gzip -d -k "$dossier_courant/$file"
				nom_raccourci=$(basename $file .gz)
				options+=("$compteur")
				let compteur++
				options+=("$(gpg -q --decrypt --armor "$dossier_courant/$nom_raccourci" | jq ".objet")")
				files+=("$nom_raccourci")
				files_to_delete+=("$nom_raccourci")
			elif [[ $file == *.json.gpg ]]; then
				options+=("$compteur")
				let compteur++
				options+=("$(gpg -q --decrypt --armor "$dossier_courant/$file" | jq ".objet")")
				files+=("$file")
			fi
		done
		IFS=$' '
		SORTIE=$(dialog --clear --title "Liste des messages" \
				--menu "Choix du message" 15 100 10 "${options[@]}" 2>&1 > /dev/tty)
		if [ $? -ne 1 ] && [ $? -ne 255 ]; then
		    infos_fichier=$(gpg -q --decrypt --armor "$dossier_courant/${files[$SORTIE]}")
			dialog --clear --msgbox "Destinataires : $(echo "$infos_fichier" | jq ".destinataires") \nObjet : $(echo "$infos_fichier" | jq ".objet") \nMessage : $(echo "$infos_fichier" | jq ".message")" 0 0
		fi
		IFS=$'\n'
		for file in ${files_to_delete[*]}; do
			rm "$dossier_courant/$file" 2>/dev/null
		done
	fi
	
}

function interfaceDepart {
	archiverFichiers
	if [ $(keyExist) -ge 1 ]; then
		generateFileForKey
		createKey
		dialog --clear --msgbox "Nous venons de créer une clé publique, veuillez l'importer chez les autres utilisateurs." 0 0
	fi
	path="$HOME/messages_script_messagerie"
	if [ ! -d $path ]; then
		sudo mkdir "$HOME/messages_script_messagerie"
		sudo chown "$(whoami)" "$HOME/messages_script_messagerie" 
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
	info_user=""
	info_null=""
	echo "$testUser testUser"
	ARRET=false
	while [ $testNull -ge 1 -o $testUser -ge 1 ]
	do
		VALUES=$(dialog --ok-label "Envoyer" \
			  --title "Envoyer un message" \
			  --form "Saisir les champs pour envoyer un message $info_null $info_user" \
		15 100 5 \
			"Destinataires:"         1 1	"" 	1 15 85 500 \
			"        Objet:"         3 1	""  	3 15 85 500 \
			"     Messsage:"         5 1	""  	5 15 85 1000 2>&1 > /dev/tty)
		if [ $? -gt 0 ]; then
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
		if [ $testNull -ge 1 ]; then
			info_null="\nTout les champs doivent être remplis"
		else
			info_null=""
		fi
		if [ $testUser -ge 1 ]; then
			info_user="\nLe ou les utilisateurs saisis ne sont pas valides"
		else
			info_user=""
		fi
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
