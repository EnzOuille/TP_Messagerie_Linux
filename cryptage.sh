#!/usr/bin/bash
source users_info.sh

function keyExist {
	gpg --list-key "$(currentUser)_messagerie" > /dev/null
	echo "$?"
}

function generateFileForKey {
	file="
     Key-Type: default
     Subkey-Type: default
     Name-Real: $(currentUser)_messagerie
     Name-Comment: generation
     Name-Email: generation
     Expire-Date: 0
     %no-protection
     %commit
     "
    #if [ -f "generation" ]
    #then
    #	sudo rm generation
    #fi
    echo "$file" > nouveau
    echo 0
}

function createKey {
	gpg --batch --generate-key generation
}

function crypter {
    gpg --armor --encrypt -r "$2_messagerie" "$1"
}
