#!/usr/bin/env bash

FILENAME=$1
LANG=$2
REGEX=$3

DIR_ASPI="./aspirations"
DIR_DUMP="./dumps-text"
DIR_CONCORD="./concordances"
DIR_CONTEXT="./contextes"

# Vérification des arguments
if [ ! $FILENAME ] || [ ! $LANG ] || [ ! $REGEX ]
then
    echo "Usage : ./aspiration.sh <urls_filename> <lang_code> <word_regex>" >&2
    exit
fi

# Vérification des dossiers
if [ ! -d $DIR_ASPI ]; then mkdir $DIR_ASPI; fi
if [ ! -d $DIR_DUMP ]; then mkdir $DIR_DUMP; fi
if [ ! -d $DIR_CONCORD ]; then mkdir $DIR_CONCORD; fi
if [ ! -d $DIR_CONTEXT ]; then mkdir $DIR_CONTEXT; fi

if [ ! -d $DIR_ASPI ] || [ ! -d $DIR_DUMP ] || [ ! -d $DIR_CONCORD ] || [ ! -d $DIR_CONTEXT ]
then
    echo "Vous n'avez pas les droits pour écrire dans les dossiers" >&2
    exit
fi

TAB_UP=$(
        echo "<!DOCTYPE html>"
        echo "<html>"
        echo "<head>"
        echo "<title>Projet PPE1-2024</title>"
        echo "<meta charset=\"utf-8\" />"
        echo "<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css\">"
        echo "</head>"
        echo "<body>"

        echo "<style>"
        echo ".content{overflow:scroll}"
        echo "</style>"

        echo "<section class=\"section\" >"
        echo "<div class=\"container is-max-desktop\" >"
        echo "<div class=\"content\" >"
        echo "<h2 class=\"title\" >Tableau <code>$LANG</code></h2>"
        echo "<table class=\"table\" >"
        echo "<tr>"

        # Colonnes du tableau

        echo "<td>" "Ligne" "</td>"
        echo "<td>" "URL" "</td>"
        echo "<td>" "Code HTTP" "</td>"
        echo "<td>" "Encodage" "</td>"
        echo "<td>" "Page html" "</td>"
        echo "<td>" "Dump textuel" "</td>"
        echo "<td>" "Nombre d'occurences" "</td>"
        echo "<td>" "Contexte" "</td>"
        echo "<td>" "Concordancier" "</td>"

        echo "</tr>"
    )

TAB_DOWN=$(
        echo "</table>"
        echo "</div>"
        echo "</div>"
        echo "</section>"
        echo "</body>"
        echo "</html>"
    )

echo "$TAB_UP"

I=1
while read -r URL
do
    # Récupération header + html
    RESPONSE=$(curl -s -i -L "$URL")

    # Code HTTP
    HTTP_CODE=$(echo $RESPONSE | head -n 1 | cut -d ' ' -f 2)

    # Si le code HTTP n'est pas 200
    if [ $HTTP_CODE != "200" ]
    then
        echo "URL $URL non traité car != 200" >&2
        continue
    fi

    # On récupère le HTML après le header de cURL
    HTML=$(echo "$RESPONSE" | sed -n '/^[[:space:]]*</,$p')

    # Encoding
    ENCODING=$(echo $RESPONSE | egrep -i '^content-type:' | egrep -o 'charset=[[:alnum:]-]+' | cut -d '=' -f 2 | xargs)

    # On écrit le html dans un fichier
    FILENAME_HTML="$DIR_ASPI/$LANG-$I.html"
    echo $HTML | iconv -f utf-8 -t utf-8 -c > $FILENAME_HTML

    # On écrit le dump dans un fichier et on force l'encodage en utf-8
    FILENAME_DUMP="$DIR_DUMP/$LANG-$I.txt"
    lynx -dump -nolist --display_charset=utf-8 $URL | iconv -f utf-8 -t utf-8 -c > $FILENAME_DUMP

    # On crée le fichier lang-kr-processed.txt dans le même répertoire que le fichier de base
    FILENAME_DUMP_PROCESSED="./$(dirname $FILENAME)/lang-kr-processed.txt"

    #On nettoie le fichier
    cat $FILENAME_DUMP | iconv -f utf-8 -t utf-8 -c > $FILENAME_DUMP.cleaned

    #On le traite avec pykospacing
    pykos $FILENAME_DUMP.cleaned $FILENAME_DUMP_PROCESSED

    #On supprime les fichiers temporaires cleaned
    rm $FILENAME_DUMP.cleaned

    # On compte le nombre de mots dans le dump traité
    TOTAL_COUNT=$(egrep "\b[[:alnum:]]+\b" -o < "$FILENAME_DUMP_PROCESSED" | wc -l | xargs)

    # Si l'encodage n'est pas trouvé, on écrit "nan"
    if [ ! $ENCODING ]
    then
        ENCODING="nan"
    fi

    # Compte des occurrences
    WORD_COUNT=$(cat $FILENAME_DUMP_PROCESSED | egrep -o $REGEX | wc -l | xargs)

    # Contextes
    FILENAME_CONTEXT="$DIR_CONTEXT/$LANG-$I.txt"
    cat $FILENAME_DUMP_PROCESSED | egrep $REGEX -C 1 > $FILENAME_CONTEXT

    # Création du concordancier
    FILENAME_CONCORD="$DIR_CONCORD/$LANG-$I.html"
    CONCS_UP=$(
        echo "<!DOCTYPE html>"
        echo "<html>"
        echo "<head>"
        echo "<title>Projet PPE1-2024</title>"
        echo "<meta charset=\"utf-8\" />"
        echo "<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css\">"
        echo "</head>"
        echo "<body>"
        echo "<section class=\"section\" >"
        echo "<div class=\"container is-max-desktop\" >"
        echo "<div class=\"content\" >"
        echo "<h2 class=\"title\" >Concordancier <code>$LANG-$I</code></h2>"
        echo "<table class=\"table\" >"
        echo "<tr><th>Contexte gauche</th><th>Mot</th><th>Contexte droit</th></tr>"
    )
    CONCS_DOWN=$(
        echo "</table>"
        echo "</div>"
        echo "</div>"
        echo "</section>"
        echo "</body>"
        echo "</html>"
    )
    CONCS_LINES=$(egrep $REGEX $FILENAME_CONTEXT | while read -r line
    do
        W=$(echo "$line" | egrep -o $REGEX | head -n1)

        LEFT_SED="s/\(.*\)$W.*/\1/p"
        RIGHT_SED="s/.*$W\(.*\)/\1/p"

        LEFT=$(echo "$line" | sed -n $LEFT_SED)
        RIGHT=$(echo "$line" | sed -n $RIGHT_SED)

        echo "<tr>"
        echo "<td>$LEFT</td>"
        echo "<td>$W</td>"
        echo "<td>$RIGHT</td>"
        echo "</tr>"
    done)

    echo $CONCS_UP $CONCS_LINES $CONCS_DOWN > $FILENAME_CONCORD

    echo "<tr>"
    echo "<td>" "$I" "</td>"
    echo "<td>" "<a href=\"$URL\" >Lien internet</a>" "</td>"
    echo "<td>" "$HTTP_CODE" "</td>"
    echo "<td>" "$ENCODING" "</td>"
    echo "<td>" "<a href=\".$FILENAME_HTML\" >html</a>" "</td>"
    echo "<td>" "<a href=\".$FILENAME_DUMP\" >dump</a>" "</td>"
    echo "<td>" "$WORD_COUNT" "</td>"
    echo "<td>" "<a href=\".$FILENAME_CONTEXT\" >contextes</a>" "</td>"
    echo "<td>" "<a href=\".$FILENAME_CONCORD\" >concordancier</a>" "</td>"
    echo "</tr>"

    ((I++))

done < $FILENAME

echo "$TAB_DOWN"