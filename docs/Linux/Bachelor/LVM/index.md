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


# RAID

## Installation 

### **Installation via ansible**

Installer ansible `apt install ansible`

Installation de mdadm : `ansible localhost -m package -a "name=mdadm state=latest"`

### **Création du raid**

Mise en place du raid avec 1 disque manaquant (d'où l'option `missing`) : 

`mdadm --create /dev/md0 --level 1 --raid-device 2 /dev/sdb6 missing`

Status du raid : `mdadm --detail /dev/md0`

Ajout d'un disque : `mdadm --manage /dev/md0 --add /dev/sdb7`

Disque HS : `mdadm /dev/md0 --fail /dev/sdb6`

Retirer le disque : `mdadm /dev/md0 --remove /dev/sdb6`

Montage de /data via ansible : `ansible localhost -m mount -a "src=/dev/md0 path=/data state=mounted"`

Recherche dans la doc `ansible-doc -l |grep -i --color filesystem`

Montage via l'UUID : `ansible localhost -m mount -a "src= '-U 07684c31-dd62-45be-82bb-a72cae950930 name=/data fstype=ext4 state=present'"`

formatage avec l'UUID : `ansible localhost -m filesystem -a "dev=/dev/md0  fstype=ext4 state=present opts='-U 06b4a9c3-9487-4685-a672-d28b6df2b5f6'"`

cible de anible playbook : `ansible-playbook make-filesystem.yml`


# Deployment ansible

## Génération des clés SSH

Génération de la clé : ```ssh-keygen ```

Mise en place de la clé : ```ssh-copy-id 127.0.0.1```
 > Demande une dernière fois un mot de passe pour confirmer l'ajout

Mise en place des privilèges : `nano /etc/sudoers`

```bash
# User privilege specification
root    ALL=(ALL:ALL) NOPASSWD: ALL
# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) NOPASSWD:  ALL
```
> rajout de l'option **NOPASSWD:**

## Test ansible ping

Mise en place de l'inventaire : ```echo "debian-locale ansible_host=127.0.0.1" >> inventaire.txt```

Dans le fichier `ansible.cfg`, ajout de redirecteurs :

``` ini linenums="1"
[defaults]

deprecation_warnings=False //enlèvement des warnings
inventory = inventaire.txt // redirecteur
```

Commande de ping : `ansible all -m ping -o`

# Boot d'une machine

## Démarrage

MBR : Master boot record

Sous windows on utilise pas le bootloader. On va utiliser le premier secteur bootable sur le disque. (pas de programme d'ammorcage)

RO = Read only dans les options de démarrage 

Démarrage du système :

- > Construction du système de base 

- > Démarrage des services 

- > Lancements de taches dites "supervisée" comme le lancement d'une session

`Systemctl status` permet d'obtenir des informations globalement sur la machine et donne l'état général de tout les services lancés avec ceux qui sont failed et running.

Mise en place d'un /data avec `/etc/systemd/system/data.mount` :

```ini linenums="1"

[Unit]

[Mount]

What=UUID=915bcbeb-c17a-44e9-9e4f-beb8b79b724c
Where=/data
Type=ext4
Options=defaults

```

## Passage avec ansible 

Mise en place de l'invetaire en yml avec `ansible-inventory -y --list` (option -y pour yaml/yml)

Modification du fichier ansible.cfg pour intégrer l'invetaire en yml

```ini linenums="1"
[defaults]

deprecation_warnings=False //enlèvement des warnings
inventory = inventaire.yml // redirecteur
```



## Timer

```sudo nano /etc/systemd/system/compteur.timer ```

## Modifier une conf

```systemctl edit xx.socket```


# Logs

## Mise en place de rsyslog avec envoi de msg sur un autre serveur 

- Installation du package rsyslog-relp avec apt.

- Modification de la conf de `/etc/rsyslog.conf` :
```
module(load="omrelp")
module(load="immark" interval="180")

local1.info    :omrelp:IP:PORT
```

- envoi d'un msg `sudo logger -p local1.info -t "tag-du-jour" "J'ai réussi "`

## Mise en place avec Ansible

Mise en place d'un dossier roles `mkdir roles`

Création des fichier liés au roles `ansible-galaxy role init roles/rsyslog`

Fichier de configuration des tasks

```yml linenums="1"
---
# tasks file for roles/rsyslog

- name: maj dernière version
  apt:
    name: "*"
    state: latest

- name: install Rsyslog
  package:
    name: rsyslog
    state: latest

- name: install Rsyslog_relp
  package:
    name: rsyslog-relp
    state: latest

- name: Démarrer et activer rsyslog
  ansible.builtin.service:
    name: "{{ rsyslog_service }}"
    state: started
    enabled: yes

- name: Mise en place de la Config
  template:
    src: rsyslog_relp.j2
    dest: "/etc/rsyslog.d/rsyslog-relp.conf"
    owner: root
    group: root
    mode: "0644"
  notify: restart-rsyslog

```
Mise en place des des variables dans defaults :

```yml linenums="1"
relp_port: 0000
relp_server: 1.2.3.4

```

Configuration d'un template : 

```j2 linenums="1"

[Unit]
Description= Mise en place de RELP

[Service]

module(load="omrelp")
module(load="immark" interval="180")

*.info      :omrelp:{{relp_server}}:{{relp_port}}
```


## Logs

Plusieurs application de logs :

- journalctl
- rsyslog

=> Les configuruations de rsyslog permettent de pouvoir conserver des données suivant le poids d'un fichier, le nombre de jours, ... 