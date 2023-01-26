# Les permissions

## Liste des permissions

Commande pour obtenir des informations concernant les droits :

```sh
ls -l
```

On obteint plusieurs groupes :

![Permissions sous linux](./images/OzXZ6.png)

- x : pour se déplacer dedans (pour les fichier, on execute le fichier tel qu'un script)
- w : modification de contenu avec l'ajout, la modification ou la suppression d'octect (en fichiers ou en repertoires)
- r : lecture et copie des fichiers ( répertoire : lister les fichiers)
- s : Il confère l'identité du propriétaire de la commande (avec `passwd` par exemple)
- t : on trouve la permission sur tout les dossiers temporaires/partages. **Seul le propriètaire du fichier peut le supprimer.** (sticky-bit)


## Commandes de changements de permissions

- `chown` : pour modifier mes permissions du fichier
- `chgrp` : L'administrateur et l'utilisateur peuvent modifier les permissions
- `chmod`: Permet de changer les permissions d'accès d'un fichier ou d'un répertoire (il faut etre propriètaire du fichier)

Pour chercher les fichiers qui possède le droit `s` :

```sh
find -perm /u=s
```

Et on obtient une liste de fichier plus ou moins longue si docker est installé : 

<figure markdown>
  ![Liste des fichiers possèdant le droit `s`](./images/capture_find.png)
  <figcaption>Liste des fichiers possèdant le droit s</figcaption>
</figure>
