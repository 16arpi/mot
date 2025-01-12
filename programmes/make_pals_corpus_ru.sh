#!/bin/bash

export LC_ALL=ru_RU.UTF-8
export LANG=ru_RU.UTF-8


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

        echo "$line" | egrep -o "\b[0-9А-ЯЁа-яё]+(-[А-ЯЁа-яё]+)*\b" | while read -r token
        do
            echo $token
        done
    done
done
