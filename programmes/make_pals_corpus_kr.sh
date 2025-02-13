#!/usr/bin/env bash

export LC_ALL=ko_KR.UTF-8
export LANG=ko_KR.UTF-8

SOURCE=$1
LANG=$2

if [ ! $SOURCE ] || [ ! $LANG ]
then
    echo "Usage : ./make_pals_corpus-ko.sh <dossier_source> <code_langue>" >&2
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
        else
            echo "$line" | egrep -o "([가-힣]+|[A-Za-z]+|[0-9]+)" | while read -r token; do
                echo "$token"
            done
        fi
    done
done
