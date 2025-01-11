LANG=$1
REGEX=$2

if [ ! $LANG ] || [ ! $REGEX ]
then
	echo "Usage : ./concordancier.sh <lang_code> <word_regex>" >&2
	exit
fi

DIR_CONTEXT="./contextes"
DIR_CONCORD="./concordances"

I=1
for file in $DIR_CONTEXT/$LANG-*.txt
do
    echo $file

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
    CONCS_LINES=$(egrep $REGEX $file | while read -r line
    do
        W=$(echo "$line" | egrep -o $REGEX | head -n1)

        LEFT_SED="s/\(.*\)$W.*/\1/p"
        RIGHT_SED="s/.*$W\(.*\)/\1/p"

        #echo $LEFT_SED >&2
        #echo $RIGHT_SED >&2

        LEFT=$(echo "$line" | sed -n $LEFT_SED)
        RIGHT=$(echo "$line" | sed -n $RIGHT_SED)

        # Formater ici le HTML
        echo "<tr>"
        echo "<td>$LEFT</td>"
        echo "<td>$W</td>"
        echo "<td>$RIGHT</td>"
        echo "</tr>"
    done)

    echo "$CONCS_UP" "$CONCS_LINES" "$CONCS_DOWN" > $FILENAME_CONCORD

    ((I++))
done

