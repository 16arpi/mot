LANG=$1
REGEX=$2

if [ ! $LANG ] || [ ! $REGEX ]
then
	echo "Usage : ./contextes.sh <lang_code> <word_regex>" >&2
	exit
fi

DIR_DUMP="./dumps-text"
DIR_CONTEXT="./contextes"

I=1
for file in $DIR_DUMP/$LANG-*.txt
do
    echo $file
    FILENAME_CONTEXT="$DIR_CONTEXT/$LANG-$I.txt"
    cat $file | egrep $REGEX -C 1 > $FILENAME_CONTEXT
    ((I++))
done

