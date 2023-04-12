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

## Apllication d'un autoindex

Modification du virtualhost :

```bash hl_lines="6-8 10-14" linenums="1"
    server {

        server_name  site.local;
        root         /var/www/html/site;

        location /sous-dossier/ {
            autoindex on;
        }

        location /icons/ {
            root /usr/share/httpd;
            # alias /usr/share/httpd/icons/;
            autoindex on;
        }


    }
```

Pour les différents locations, on obtient les valeurs suivantes :

=== "Sous-dossier"

    Afin de d'avoir une valeur avec le curl, on crée dans `/var/www/html` un premier dossier `sous-dossier` et un second dossier dedans `dossier1`

    ```html linenums="1"
    <html>
    <head><title>Index of /sous-dossier/</title></head>
    <body>
    <h1>Index of /sous-dossier/</h1><hr><pre><a href="../">../</a>
    <a href="dossier1/">dossier1/</a>                                          11-Apr-2023 09:43                   -
    </pre><hr></body>
    </html>
    ```
=== "Icons"

    ```html
    <a href="small/">small/</a>                                             21-Mar-2023 10:11                   -
    <a href="README">README</a>                                             28-Aug-2007 10:47                5108
    <a href="README.html">README.html</a>                                        28-Aug-2007 10:47               36057
    <a href="a.gif">a.gif</a>                                              20-Nov-2004 20:16                 246
    <a href="a.png">a.png</a>                                              11-Sep-2007 05:11                 306
    .
    .
    .
    .
    </pre><hr></body>
    </html>
    ```
## Mise en place d'un controle d'accès

Ajout d'une nouvelle règle :

```bash linenums="1" hl_lines="10-13"
    server {

        server_name  site.local;
        root         /var/www/html/site;

        location /sous-dossier/ {
            autoindex on;
        }

        location /prive/ {
                allow 127.0.0.1;
                deny all;
        }
        location /icons/ {
            root /usr/share/httpd;
            # alias /usr/share/httpd/icons/;
            autoindex on;
        }
    }
```

On crée un fichier index.html dans `/var/www/html/site/prive` et on obtient :

```bash
hello-private
```

Si on accède par l'IP de la machine (et non 127.0.0.1), on obtient :

```html
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.22.1</center>
</body>
</html>
```

## Ajout d'erreurs

```bash linenums="1" 
    server {

        server_name  site.local;
        root         /var/www/html/site;

        location /sous-dossier/ {
            autoindex on;
        }

        location /prive/ {
                allow 127.0.0.1;
                deny all;
        }
        location /icons/ {
            root /usr/share/httpd;
            # alias /usr/share/httpd/icons/;
            autoindex on;
        }
        location /errors/ {
            alias /var/www/errors;
        }
        error_page 403 =418 /errors/403.html;
        error_page 418 /errors/418.html;
    }
```

## Php-fpm

### Installation

Installation de Php-fpm :

```bash
dnf install -y php-fpm
```

### Démarrage et écriture de fichier 

!!!info "Configuration"

        On retrouve la configuration dans `/etc/php-fpm.conf`.

Mise en place de la configuration dans le serveur nginx :

```bash linenums="1" hl_lines="7"
server {

        server_name  site.local;
        root         /var/www/html/site;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location /sous-dossier/ {
            autoindex on;
        }

        location /prive/ {
                allow 127.0.0.1;
                deny all;
        }
        location /icons/ {
            root /usr/share/httpd;
            # alias /usr/share/httpd/icons/;
            autoindex on;
        }
        location /errors/ {
            alias /var/www/errors;
        }
        error_page 403 =418 /errors/403.html;
        error_page 418 /errors/418.html;
    }
```

Ajout d'un fichier `/var/www/html/site/index.php` :

```php
<?php

        echo "Avant<br>";
        phpinfo();
        echo "Après<br>";

?>
```

Démarrage du php-fpm :

```bash 
systemctl start php-fpm
```

Restart du service nginx :

```bash 
systemctl reload nginx
```

On obteint ensuite :

```html
Avant<br><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"><head>
<style type="text/css">
.
.
.
</p>
<p>If you did not receive a copy of the PHP license, or have any questions about PHP licensing, please contact license@php.net.
</p>
</td></tr>
</table>
</div></body></html>Après<br>
```
