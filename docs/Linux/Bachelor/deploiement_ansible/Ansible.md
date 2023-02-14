---
hide:
  - footer
---

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