---
hide:
  - footer
---

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
