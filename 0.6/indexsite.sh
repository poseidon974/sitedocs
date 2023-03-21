#!/bin/bash

# Chemin du répertoire à indexer
directory_path="/home/leo/Documents/Sitedoc/docs/"

# Nom du fichier index à créer
index_file="Acceuil.md"

# Efface l'ancien fichier index s'il existe
if [ -f "$index_file" ]; then
  rm "$index_file"
fi

# Écrit l'en-tête du tableau
echo "---" >> "$index_file"
echo "hide:" >> "$index_file"
echo "  - footer" >> "$index_file"
echo "---" >> "$index_file"
echo "| Nom |Fichier | Date de création | " >> "$index_file"
echo "| --- | --- | --- |" >> "$index_file"

# Parcours le répertoire et écrit les noms, les chemins complets, les dates de création, et le nom du premier dossier parent des fichiers Markdown dans le fichier index
find "$directory_path" -type f -name "*.md" -printf "| %f | [%f](%p) | %TY-%Tm-%Td |\n" >> "$index_file"