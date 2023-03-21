---
hide:
  - footer
---

# Apache

## Définition de apache

Apache est un logiciel open source. 

Plusieurs règles s'applique aux logiciels open source et donc ici à apache :

- Réactivité importante des développeurs en cas de « bug »
- Correctifs de sécurité à appliquer...
- Mises à jour et évolutions fréquentes
- Obsolescence rapide des paquetages binaires

## Installation de apache

Pour installer apache, on utilise dnf :

```bash
dnf install -y httpd
``` 

Suivant les systèmes, on trouve les fichiers de configuration à deux endroits différents :

=== "Debian"
    ```bash
    /etc/apache2/apache2.conf
    ```
=== "Redhat"
    ```bash
    /etc/httpd/conf/httpd.conf
    ```

**On ne va pas modifier le fichier de configuration de apache mais on va utiliser les includes.**

=== "Debian"

    On cherche tout les fichier pour apache :
    ```bash
    grep -nri --color "^*Include" /etc/apache2
    ```

=== "Redhat"

    On cherche tout les fichier pour apache :
    ```bash
    grep -nri --color "^Include" /etc/httpd
    ```

    On obtient les fichiers suivants :

    ```bash linenums="1"
    /etc/httpd/conf/httpd.conf.rpmsave:61:Include conf.modules.d/*.conf
    /etc/httpd/conf/httpd.conf.rpmsave:358:IncludeOptional conf.d/*.conf
    /etc/httpd/conf/httpd.conf:61:Include conf.modules.d/*.conf
    /etc/httpd/conf/httpd.conf:358:IncludeOptional conf.d/*.conf
    ```

## Structuration de la configuration de apache

La configuration est découpée en plusieurs contextes :

- Server-config : Configuration du serveur
- VirtualHost : Configuration d'un serveur Virtuel
- Directory : Configuration relative à un dossier
- Htaccess : Dans un fichier .htaccess

Les formes de contextes sont les suivantes :

- `<Directory ...>`
- `<Location ...>`
- `<Files ...>`

Le fichier de configuration `.htaccess` porte des directives d'accès. C'est de la délégation de pourvoir d'accès.

Le fichier de configuration accepte les fautes de configurations dans son fichier. La configuration est comme sautée si il y a un problème de configuration. 

Si on cherche les fichiers de logs avec `grep -nri --color ErrorLog /etc/httpd`:

```bash linenums="1"
/etc/httpd/conf/httpd.conf:181:# ErrorLog: The location of the error log file.
/etc/httpd/conf/httpd.conf:182:# If you do not specify an ErrorLog directive within a <VirtualHost>
/etc/httpd/conf/httpd.conf:187:ErrorLog "logs/error_log"
```

!!!info "Les liens symboliques"

    Les logs sont stockés dans le dossier `/etc/httpd/logs/` mais en réel, nous avons une redirection avec un lien symbolique (`ls -l /etc/httpd`):

    ```bash linenums="1" hl_lines="5"
    total 12
    drwxr-xr-x. 2 root root 4096 21 mars  11:11 conf
    drwxr-xr-x. 2 root root 4096 21 mars  11:11 conf.d
    drwxr-xr-x. 2 root root 4096 21 mars  11:11 conf.modules.d
    lrwxrwxrwx. 1 root root   19 31 janv. 17:10 logs -> ../../var/log/httpd
    lrwxrwxrwx. 1 root root   29 31 janv. 17:10 modules -> ../../usr/lib64/httpd/modules
    lrwxrwxrwx. 1 root root   10 31 janv. 17:10 run -> /run/httpd
    lrwxrwxrwx. 1 root root   19 31 janv. 17:10 state -> ../../var/lib/httpd
    ```

Pour avoir une installation minimale, on désactive tout les modules :

```bash linenums="1"
 cd /etc/httpd/conf.modules.d/
 sed -i 's,^LoadModule,#LoadModule,' *.conf
 systemctl restart httpd
```

On obtiens une erreur lors du redémarrage du service :

```bash
Job for httpd.service failed because the control process exited with error code.
See "systemctl status httpd.service" and "journalctl -xeu httpd.service" for details.
```

On cherche ensuite quelle est l'erreur avec la commande `journalctl -u httpd.service | tail` :

```bash linenums="1"
mars 21 12:02:32 LG-stream9-1.local systemd[1]: Starting The Apache HTTP Server...
mars 21 12:02:32 LG-stream9-1.local httpd[540060]: AH00534: httpd: Configuration error: No MPM loaded.
mars 21 12:02:32 LG-stream9-1.local systemd[1]: httpd.service: Main process exited, code=exited, status=1/FAILURE
mars 21 12:02:32 LG-stream9-1.local systemd[1]: httpd.service: Failed with result 'exit-code'.
mars 21 12:02:32 LG-stream9-1.local systemd[1]: Failed to start The Apache HTTP Server.
```

On cherche les différents modules à activer : 

- mpm_prefork_module
- unixd_module
- mod_authz_core
- mod_autoindex
- mod_alias
- mod_systemd

Ici c'est la configuration minimale afin que apache se lance. 

!!!warning "Attention"

    Il ne faut pas oublier de relancer le service httpd
    ```bash 
    systemctl restart httpd
    ```

Pour que apache puisse voir les fichiers déposés dans le dossier `\var\wwww\html`, il faut activer le module suivant :

- mod_dir

Le fichier qui est affiché si aucun fichier n'est présent dans le dossier précedent, il y a un fichier qui se trouve dans `/etc/httpd/conf.d/welcome.conf` :

```conf linenums="1"
# 
# This configuration file enables the default "Welcome" page if there
# is no default index page present for the root URL.  To disable the
# Welcome page, comment out all the lines below. 
#
# NOTE: if this file is removed, it will be restored on upgrades.
#
<LocationMatch "^/+$">
    Options -Indexes
    ErrorDocument 403 /.noindex.html
</LocationMatch>

<Directory /usr/share/httpd/noindex>
    AllowOverride None
    Require all granted
</Directory>

Alias /.noindex.html /usr/share/httpd/noindex/index.html
Alias /poweredby.png /usr/share/httpd/icons/apache_pb3.png
Alias /system_noindex_logo.png /usr/share/httpd/icons/system_noindex_logo.png
```

