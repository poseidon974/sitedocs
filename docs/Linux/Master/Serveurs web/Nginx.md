---
hide:
    - footer
---

# Nginx

## Installation de Nginx

Dernière version : 1.23.4 (mars 2023)

Installation de nginx :

```bash
dnf install -y nginx
```

Démarrage de nginx :

```bash
systemctl start nginx
```

!!!info
    - On retrouve les fichiers de configuration dans `/etc/nginx`.
    - Les sites se trouvent dans `/usr/share/nginx/html`.

    !!!success "Rappel"
        Pour rappel lorsqu'on a un dossier en `.d` pour les configurations, on **utilise impérativement** ce dossier qui prendra tout les fichiers et qui les intègras dans la condiguration de nginx.


## Changement de configuration de Nginx

### Création d'un premier virtualhost

Création d'un fichier de configuration pour "surcharger" la configuration de nginx (dans `conf.d/`) :

```bash linenums="1" hl_lines="5"
server {
        listen       80;
        listen       [::]:80;
        server_name  test.local;
        root         /var/www/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

Dans cette configuration, on utilise un autre répertoire que celui par défaut (ligne en surbrillance).

On peux vérifier site le site est mis en ligne avec la commande :

```bash
curl -H "Host: test.local" http://127.0.0.1:80
```

### Création de mutliples virtualhosts

On utilise plusieurs fichiers de configurations qui se trouvent dans le dossier `conf.d`. Les modifications des deux fichiers sont en surbrillances 

VirtalHost 1 :

```bash hl_lines="4-5" linenums="1"
server {
        listen       80;
        listen       [::]:80;
        server_name  test.local;
        root         /var/www/html/site;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

Virtalhost 2:

```bash hl_lines="4-5" linenums="1"
server {
        listen       80;
        listen       [::]:80;
        server_name  test1.local;
        root         /var/www/html/site1;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

Si on regarde les résultats, on obtient 2 pages différentes avec la commande `curl -H "Host: test.local" http://127.0.0.1:80` et `curl -H "Host: test1.local" http://127.0.0.1:80` :

=== "test.local"

    ```bash
    hello world
    by nginx
    Site default
    ```
=== "test2.local"

    ```bash
    hello world
    by nginx
    Site 2
    ```

