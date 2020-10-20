#!/usr/bin/bash

function users {
 dialog --clear --title "Liste des utilisateurs" \
 --msgbox "$(awk -F: '{ print $1}' /etc/passwd)" 15 100
}

function send {
 echo "TO DO"
 user=$(dialog --clear --title "Type the target" \
 --inputbox "Enter username" 10 50 3>&1 1>&2 2>&3 3>&-)
 user_home=$(getent passwd $user | cut -d: -f6)
 echo "$user_home"
 if [ -d $user_home ]
 then
  touch "$user_home/test.txt"
 fi
}

function consult {
 FILE=$(dialog --clear --title "Select the message you want" --stdout --title "Please choose a message" --fselect /home/enzouille/messages/ 10 50)
 dialog --title "File" --msgbox "$FILE" 10 50
}

INPUT=/tmp/menu.sh.$$

dialog --clear --title "Dialog Test" \
--menu "Choix de l'action" 15 100 4 \
Send "Send a message" \
Consult "Consult your messages" \
Users "See the users" \
Exit "Quit the program" 2>"${INPUT}"

menuitem=$(<"${INPUT}")

case $menuitem in
 Send) send;;
 Consult) consult;;
 Users) users;;
 Exit) echo "Exiting the program"; break;;
esac
