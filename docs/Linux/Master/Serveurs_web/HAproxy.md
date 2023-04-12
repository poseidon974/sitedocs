---
hide:
    - footer
---

# HAProxy

## Configuration de HAproxy 

!!!info "Localisation des fichiers de configurations"

    Les fichiers se trouvent dans `/etc/haproxy`.

    !!!success "Rappel"
        Pour rappel lorsqu'on a un dossier en `.d` pour les configurations, on **utilise impérativement** ce dossier qui prendra tout les fichiers et qui les intègras dans la condiguration de nginx.

### Mise en place d'une configuration minimale

Copie du fichier de configuration par défaut et mise en place de notre propre fichier de configuration haproxy.cfg :

```ini linenums="1"
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     100
    user        haproxy
    group       haproxy
defaults
    mode        http
    log         global
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    maxconn                 100
```

### Mise en place d'un fichier de configuration dans le drop-in directory

Mise en place du fichier `00-default.cfg` :

```ini linenums="1"
frontend vservice1
    bind *:80
    # mode http
    use_backend webservers

backend webservers
    server web1   10.0.0.1:80 check inter 5000 rise 2 fall 5 maxconn 10
    server web2   10.0.0.2:80 check inter 5000 rise 2 fall 5 maxconn 10
```

### Mise en place de la page de statistiques

Création d'un fichier de configuration `00-stats.cfg` :

```ini linenums="1"
# --DEBUT /hastats
frontend stats
   bind *:80

   stats enable
   stats uri     /hastats
   stats hide-version

   stats realm   Haproxy\ Statistics
   stats auth    admin:passadmin
   stats refresh 1s

   # SCOPE : détermine les backends à afficher dans les tableaux
   stats scope vservice1
   stats scope webservers
   # stats scope appli
   # stats scope images

# --FIN /hastats
```

On peux se connecter sur l'interface web et on obtient cela :

<figure markdown>
  ![Image de la page de statistiques](./images/Capture%20d'%C3%A9cran%202023-04-12%20163743.png)
  <figcaption>Image de la page de statistiques</figcaption>
</figure>

