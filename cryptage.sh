#!/usr/bin/bash
source users_info.sh

function keyExist {
	gpg -q --list-key "$(currentUser)_messagerie" > /dev/null 2> /dev/null
	echo "$?"
}

function generateFileForKey {
	file="Key-Type: default
     Subkey-Type: default
     Name-Real: $(currentUser)_messagerie
     Name-Comment: generation
     Name-Email: generation
     Expire-Date: 0
     %no-protection
     %commit
     %echo done"
    #rm $HOME/generation 2> /dev/null
    echo "$file" > $HOME/generation
    echo 0
}

function createKey {
	gpg --batch --generate-key $HOME/generation
}

function crypter {
    gpg --armor --trust-model always -r "$2_messagerie" --encrypt "$1"
}
