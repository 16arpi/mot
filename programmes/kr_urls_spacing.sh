#!/usr/bin/env bash

FICHIER_URLS=$1
NOUV_FICHIER="lang-kr-processed.txt"

> $NOUV_FICHIER

#Lire chauqe url et traiter son contenu avec pykospacing
while read -r URL; do
	CONTENU_HTML=$(curl -s "$URL")
	TEXTE_BRUT=$(echo "$CONTENU_HTML" | lynx -dump -nolist)
	TEXTE_TRAITE=$(echo "$TEXTE_BRUT" | python -m pykospacing.pykos)
	echo "$TEXTE_TRAITE" >> $NOUV_FICHIER
done < "$FICHIER_URLS"

echo "Tout a été traités et enregistrer dans $NOUV_FICHIER"