---
hide:
  - footer
---
# Mise en place des partitions

## Découverte des disques

### Emplacement des disques 

```/dev/sda``` 

sda = Premier disque 

sdb = Second disque

De manière générale sd*x* avec le *x* qui est le disque (par ordre aphabétique)

### Partitions des disques 

```/dev/sda1```

sda1 = Première partition du disque

sda2 = Seconde partition du disque

De manière géénrale sd*x**z* avec *z* qui le numéro de la partition.

## Création des partitions

### Liste des partitions

- >1 partition swap
- >1 partition filesystem
- >3 partition LVM
- >3 partitions RAID

Commande :
```fdisk /dev/sdb```

Pour accèder au menu : ```m``` pour l'aide de la commande

Création de la nouvelle table en GPT : ```g```

Création de la nouvelle partition : ```n```

    -> Numéro de partition
    -> Premier secteur 
    -> Dernier secteur (possibilité de mettre un espace en K,M,G,T,P)

Création du type de la partition : ```t```

    -> Numéro de la partition à modifier
    -> Numéro ou alias de type de partition

# Mise en place de sauvegarde

## Mise en place de l'archive de sauvegarde

Sauvegarde : ```tar -cvz -f /home.tar.gz /home```

    -> -c = Création d'archive
    -> -v = Verbose
    -> -z = Compression du fichier
    -> -f = Nom de l'archive (Toujours cette option en dernière)

Test de l'archive : ```tar -tf /home.tar.gz```

    -> -t = pour tester l'archive
    -> -f = spécification du fichier (Toujours cette option en dernière)

# Mise en place du nouveau /home

## Vidange du répertoire

Plusieurs façon de vider le répertoire /home :

```rm -rf /home ; mkdir /home```

ou 

```rm -rf /home/*```

**Attention à ne pas mettre d'espace entre `/` et `home` car cela supprimerais tout le système de fichier.** 

## Mise en place du formatage

Formatage en EXT4 pour la partition `FileSystem` :

```mkfs.ext4 /dev/sdb2```

*Message d'erreur si la partition est déjà formatée*

Obtenir l'UUID d'une partition : 

```lsblk -o uuid -n /dev/sdb2```

Modification de fstab : 

```nano /etc/fstab```

Montage de la partition et test si fstab est correct:

```sudo mount -av```

## Restauration de l'archive

```sudo tar -C / -xf /home.tar.gz```

```ls -l /home```

**Vigilance sur la taille du système de fichier sinon l'extraction ne focntionnera pas.**

# LVM

## Commandes LVM2

Scan des partitions LVM : ```pvs``` alias => ```pvscan```

Création disques physiques pour les  volumes logiques : ```pvcreate /dev/sdb3 /dev/sdb4 /dev/sdb5``` alias => ```pvcreate /dev/sdb{3..5}```


Création d'un volume logique vgdata
```vgcreate vgdata /dev/sdb3```

`lsblk` pour affihcer tout les volumes 

VG => Volume groupe

- L'extention de VG prends des volumes physiques `sudo vgextend vgdata /dev/sdb4`

LV => Logical Volume 
- pour utiliser les commandes à partir de PV.... , on parle de volume physique.

PV => Physical volume

## Commandes pour afficher les volumes

* pvscan
* lvscan
* pvscan

## Suppression des volumes

 > La suppression des volumes entraine la suppression des données stockées sur le logical volume

* Démontage des volumes en premier : `unmount \data`
* Suppression du volume logique : `lvremove /dev/rootvg/lvdata`
* Suppression du volume groupe : `vgremove /dev/rootvg`
* Suppression des volumes physique : `pvremove /dev/sdb3 /dev/sdb4 /dev/sdb5`
* Modification du fstab pour ne pas demarrer en mode recovery


