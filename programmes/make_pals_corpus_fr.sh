#!/usr/bin/env bash

SOURCE=$1
LANG=$2

if [ ! $SOURCE ] || [ ! $LANG ]
then
    echo "Usage : ./make_pals_corpus.sh <dossier_source> <code_langue>" >&2
    exit
fi

if [ ! -d $SOURCE ]
then
    echo "Le dossier $SOURCE n'existe pas..." >&2
    exit
fi

ls $SOURCE/$LANG-*.txt | while read -r file
do
    cat "$file" | while read -r line
    do
        if [[ ! $line ]]
        then
            echo ""
        fi

        echo "$line" | egrep -o "([Aa]ujourd'hui)|(\b[éèàçôöùüûïî[:alnum:]]+\'?\b)" | while read -r token
        do
            echo $token
        done
    done
done
