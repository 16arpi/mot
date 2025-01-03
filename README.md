# Projet *mot*

Dépôt git du projet en Projet Encadré (M1 TAL). Les contributeurs de ce projet sont :

* César Pichon - [profil github](https://github.com/16arpi) [dépôt personnel pour PPE](https://github.com/16arpi/PPE1-2024)

* Sébastien Durna - [profil github](https://github.com/Seeeb3) [dépôt perso PPE](https://github.com/Seeeb3/PPE1-2024)

## Tableau de bord collectif

### Vendredi 3 janvier 2025

Bonne année ! Bonne résolution pour cette année, se mettre au travail pour le projet :) Cette longue journée a été l'occasion de terminer la feuille d'exercice pour générer le tableau informant sur tous les URLs du corpus. Le programme est une sorte de _pipeline_ qui part d'une langue, d'une regex représentant un mot et d'une liste d'URLs pour générer, à la suite et pour chaque lien :

- un document HTML
- son dump textuel
- le contextes d'apparition du mot
- le concordancier (au format html) des occurences
- un tableau qui résume toutes ces informations

Le dump textuel a été obtenu grâce à `lynx` et son option `-dump`. Ensuite, pour chaque occurence obtenue grâce à `egrep` dans les contextes, la commande `sed` nous permet de récupérer la chaîne de caractère à gauche du match de la regexp, ainsi qu'à droite. Le tout est mis en forme dans un tableau HTML (stylisé grâce à la feuille de style Bulma).

Cela nous donne en conséquence un dossier `./ressources` qui contient toutes les informations sur nos contextes. Il s'agit maintenant de générer un fichier corpus compatible avec PALS, d'y appliquer les analyses du programme et de passer à l'analyse qualitative de notre corpus !

**Usage du script**

Le script `./urls-to-table.sh` prend comme entrées trois arguments (l'emplacement du fichier URL, le code de langue, l'expression régulière du mot) et va :

- retourner dans stdin le tableau de synthèse au format HTML
- créer et remplir quatre répertoires dans le repertoire où est executé le script :
    - `./aspirations` : l'ensemble des contenus HTML obtenus à partir des URLs
    - `./concordances` : les pages HTML présentant le concordancier des occurences sur chaque page
    - `./contextes` : les contextes d'occurence du mot dans chaque page
    - `./dumps-text` : les dumps textuels de chaque page

Exemple d'usage (se placer dans le dossier `./ressources`)

```bash
$ chmod +x ../programmes/urls-to-table.sh
$ ../programmes/urls-to-table.sh ./URLs/lang-fr.txt fr '[Ll]angues?' > ./tableaux/fr.html
```
