# Les permissions

Commande pour obtenir des informations concernant les droits :

`ls -l`

On obteint plusieurs groupes :

![Permissions sous linux](./images/OzXZ6.png)

- x : pour se déplacer dedans (pour les fichier, on execute le fichier tel qu'un script)
- w : modification de contenu avec l'ajout, la modification ou la suppression d'octect (en fichiers ou en repertoires)
- r : lecture et copie des fichiers ( répertoire : lister les fichiers)
- s : Il confère l'identité du propriétaire de la commande (avec `passwd` par exemple)
- t : on trouve la permission sur tout les dossiers temporaires/partages. **Seul le propriètaire du fichier peut le supprimer.** (sticky-bit)


