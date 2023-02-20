# Docker

## Préparation de l'installation docker

### Création d'un système de fichier

Création d'un dossier /var/lib/docker :

```bash
mkdir -p /var/lib/docker
```

Création d'un d'un volume groupe :

```bash
lvcreate -L 5G -n rootvg/lvdocker
```

!!!tip
    - option `-L` pour spécifier la taille (ou sinon l'option `--size`)
    - option `-n` pour spécifier le nom du volume groupe

Vérification de la création du volume groupe avec `lvscan` :

```bash
  ACTIVE            '/dev/rootvg/rootlv' [32,50 GiB] inherit
  ACTIVE            '/dev/rootvg/lvdocker' [5,00 GiB] inherit
```
