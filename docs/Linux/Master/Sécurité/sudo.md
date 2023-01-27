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

Directive de configuration avec `!log_output`