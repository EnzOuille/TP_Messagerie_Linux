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
    rm $HOME/generation 2> /dev/null
    echo "$file" > $HOME/generation
    echo 0
}

function createKey {
	gpg --batch --generate-key $HOME/generation
}

function crypter {
    gpg --trust-model "always" -r "$2_messagerie" --encrypt "$1"
}

function archiverFichiers {
    dossier_courant=$(getMessageFolder)
    IFS=$'\n'
    all_files=$(ls $dossier_courant/*.gpg 2>/dev/null)
    current=$(date +%s);
    for file in ${all_files[*]}; do
        last_modified=$(stat -c "%Y" $file);
        if [ $((current - last_modified)) -gt 86400 ]; then
            gzip $file
        fi
    done
}