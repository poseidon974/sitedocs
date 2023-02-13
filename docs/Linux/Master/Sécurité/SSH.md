# Sécurité de SSH

## Changement du port de SSH

!!!warning

    Cette solution pour sécuriser SSH n'est pas recommandé car cela ne procure pas beaucoup de sécurité


Localisation du fichier de configguration de SSH 

```bash
/etc/ssh/sshd_config
```

Pour modifier le port, on modifie la ligne :

```bash
#Port 22
```
On enregistre ensuite le fichier et on execute la policy de SE linux : 

```bash
semanage port -a -t ssh_port_t -p tcp #PORTNUMBER
```

On restart aussi le service :

```bash
sudo systemctl restart sshd
```


## Fail2ban

???+ Info
    Pour chercher des packages qui ne sont pas présent sur les depôts par défaut : [dpkg.org](dpkg.org)

Installation d'un dépot supplémentaire :

```bash
dnf install epel-release
```
On cherche le repo `fail2ban` et de quoi il est composé:

```bash linenums="1"
dnf search fail2ban
dnf info fail2ban
```

Installation de bail2ban :

```bash
dnf install fail2ban-firewalld
```

!!!info
    Systemd à la main sur cron, fstab, les services et aussi les logs

Dans le service journald, on cherche les envois de logs avec `grep Forward /etc/systemd/journald.conf`.

Cela nous retourne : 

```bash linenums="1" hl_lines="1"
#ForwardToSyslog=no
#ForwardToKMsg=no
#ForwardToConsole=no
#ForwardToWall=yes
```

Pour obtenir les logs de sshd avec systemctl :

```bash
journalctl --unit sshd.service
```

Installation d'un package supplémentaire :

```bash
dnf install -y fail2ban-systemd
```

!!!tip
    Le service de fail2ban n'est pas en démarrage automatique dès son installation.

Mise en route du service fail2ban :

```bash
systemctl start fail2ban
```

Observation des prisons `fail2ban-client status`:

```bash linenums="1"
Status
|- Number of jail:      0
`- Jail list:
```

Localisation des fichiers de configuation des fichiers de fail2ban :

```bash
/etc/fail2ban/
```

!!!failure "Interdiction"
    On ne travaille pas sur le fichier de configuration direct, on utilise le dossier en .d à la fin

Affichage de pages de man installées avec le package `rpm -ql fail2ban-server | grep /man ` et on cherche la documentation sur les jails :

```bash linenums="1" hl_lines="6"
/usr/share/man/man1/fail2ban-client.1.gz
/usr/share/man/man1/fail2ban-python.1.gz
/usr/share/man/man1/fail2ban-regex.1.gz
/usr/share/man/man1/fail2ban-server.1.gz
/usr/share/man/man1/fail2ban.1.gz
/usr/share/man/man5/jail.conf.5.gz
```

Ajout d'un fichier de configuration dans le dossier jail.d :

```bash linenums="1"
[sshd]
enabled = true

# Mise en place d'un blocage de 30 minutes si il y a 5 essais erronés en 5 minutes

bantime = 1800
findtime = 300
maxretry = 5
```

On restart le service fail2ban :

```bash
systemctl restart fail2ban.service
```

On peut observer les jail:

```bash
fail2ban-client get sshd banned
```

On déban juste d'un jail avec la commande : 

```bash
fail2ban-cleint set sshd unbanip #ipdelamachine
```

On déban une ip de toutes les jails:

```bash
fail2ban-clent unban #ipdelamachine
```
