#!/usr/bin/bash
source users_info.sh

function keyExist {
	gpg --list-key "$(currentUser)_messagerie" > /dev/null
	echo $?
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
    if [ -f "generation.txt" ]
    then
    	rm generation.txt
    fi
    echo "$file" > generation
    echo 0
}

function createKey {
	gpg --batch --generate-key generation
}
