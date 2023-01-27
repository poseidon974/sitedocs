---
hide:
  - footer
---
# Sudo et Sudoreplay

## Introduction

Sudo est une abréviation de "substitute user do", "super user do" ou "switch user do " , en français : « se substituer à l'utilisateur pour faire », « faire en tant que super-utilisateur » ou « changer d'utilisateur pour faire »). 

Elle est utilisée dans tquasi tout les systèmes de types UNIX.

???+warning "Important"
    Le fichier de configuration de sudo est `/etc/sudoers`. Ce fichier est **logiquement en lecture seule**.

Pour configurer sudo, on utlise les dossiers générés par le package. Ici, un dossier est présent pour laisser un fichier avec une configuration personnalisée dans `/etc/sudoers.d/`.

Dans ce dossier, vous pouvez créer un fichier avec n'importe quelle extension avec les configurations souhaitées.

## Mise en oeuvre de sudo


???+ info "Directives de configurations"
    Ici chez sudo, nous avons une directive de configuration avec `!log_output`. Tout est redirigé dans le dossier `/var/log/sudo-io`.

### Mise en place des logs

Création du dossier pour le stockage des logs d'output :

```sh
mkdir -p /var/log/sudo-io
```

Application des redirections de logs dans le dossier nouvellement crée. Ici on place un nouveau fichier dans `/etc/sudoers.d/` nommé *config* :

```sh
Defaults log_output
Defaults!/usr/bin/sudoreplay !log_output
Defaults!/sbin/reboot !log_output
```

### Réalisaton de règles pour sudo

#### Commandes swap

On souhaite que le groupe `users` puisse réaliser les commandes :

- `swapon`avec n'importe quel argument 
- `swapoff`avec l'argument unique \dev\sda3

On réalise un nouveau fichier nommé `swap_off_users` dans le dossier de configuration de sudo :

```sh
%users     ALL   =    (ALL)     /sbin/swapon, /sbin/swapoff /dev/sda3
```


!!!tip
    Pour tester les commandes, il est conseillé de prendre un utilisateur sans aucun groupes afin de pouvoir tester simplement.

    Rappel : pour ajouter un user la commande est `useradd` et la commande pour ajouter dans un groupe `usermod -aG`

Ici on ajoute l'utlisateur `utlisateur` dans le groupe users :

```sh
usermod -aG users utilisateur
```

Pour tester les commandes, on utlise les commandes suivantes :

```sh linenums="1"
sudo swapon /dev/sda3
sudo swapoff /dev/sda3
```
#### Commande ID

## Sudoreplay

Avec l'activation des logs réalisé plus haut, tout les logs ont été enregistrés. Les logs se trouvent dans `/var/log/sudo-io`

On peux afficher les logs avec la commande :
```sh
ls -trl /var/log/sudo-io/00/00/*
```

On peux aussi afficher les replays avec le TSID avec la commande :

```sh
sudoreplay -l
```

Pour jouer les sessions, on utlise sudoreplay avec `sudoreplay TSID`.