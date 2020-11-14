#!/usr/bin/bash
source users_info.sh

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
 FILE=$(dialog --clear --title "Select the message you want" --stdout --title "Please choose a message" --fselect /home/enzouille/messages/ 10 50)
 gpg -d test.txt test.txt.gpg
 dialog --title "File" --msgbox "$(cat $FILE)" 10 50
}

function interfaceDepart {
	INPUT=/tmp/menu.sh.$$

dialog --clear --title "Dialog Test" \
--menu "Choix de l'action" 20 100 3 \
Send "Send a message" \
Consult "Consult your messages" \
Exit "Quit the program" 2>"${INPUT}"

menuitem=$(<"${INPUT}")

case $menuitem in
 Send) send;;
 Consult) consult;;
 Exit) echo "Exiting the program"; break;;
esac
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
		# open fd
		exec 3>&1

		# Store data to $VALUES variable
		VALUES=$(dialog --ok-label "Envoyer" \
			  --backtitle "$testNull - $testUser" \
			  --title "Envoyer un message" \
			  --form "Saisir les champs pour envoyer un message" \
		15 100 5 \
			"Destinataires:"         1 1	"" 	1 15 85 500 \
			"        Objet:"         3 1	""  	3 15 85 500 \
			"     Messsage:"         5 1	""  	5 15 85 1000 \
		2>&1 1>&3)

		# close fd
		exec 3>&-

		# display values just entered
		compteur=0
		for ligne in $VALUES
		do
			if [ $compteur -eq 0 ]
			then
				utilisateurs=$ligne
			fi
			if [ $compteur -eq 1 ]
			then
				objet=$ligne
			fi
			if [ $compteur -eq 2 ]
			then
				message=$ligne
			fi
			compteur=$((compteur+1))
		done
		testNull=$(verifMessage $utilisateurs $objet $message)
		testUser=$(verifUsers $utilisateurs)
	done
	echo "C'est tout bon"
}

function verifMessage {
	if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ]
	then
		echo 1
	else
		echo 0
	fi
}

function verifUsers {
	res=1
	IMF=" "
	for user in $1
	do
		if [ $(userExist $user) -eq 0 ]
		then
			res=0
		fi
	done
	echo "$res"
}