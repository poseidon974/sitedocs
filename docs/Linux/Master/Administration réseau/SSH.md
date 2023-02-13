---
hide:
  - footer
---
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

!!!info 
    On désactive fail2ban pour la suite du tp.

## SSHGuard

Recherche de SSHGuard :

```bash
dnf search sshguard
```

Dans la liste on cherche ce qui se rapporte au firewall :

```bash linenums="1" hl_lines="4"
======================================== Nom correspond exactement à : sshguard ========================================
sshguard.x86_64 : Protects hosts from brute-force attacks against SSH and other services
========================================= Nom & Résumé correspond à : sshguard =========================================
sshguard-firewalld.x86_64 : Configuration for firewalld backend of SSHGuard
sshguard-iptables.x86_64 : Configuration for iptables backend of SSHGuard
sshguard-nftables.x86_64 : Configuration for nftables backend of SSHGuard
```

## PortKnocker

### Installation du serveur knock

!!!info 
    Port_knocker permet d’ouvrir et de fermer les ports d’une machine de façon dynamique. Il agit avec un client qui vient "frapper" à la porte de la machine sur plusieurs ports. Si la séquence est correcte, port-knocker ouvre le port qui correspond à la séquence pendant un certain temps avant de le désactiver.

Recherche du pakcge knockd :

```bash
dnf search knock
```

Installation de knock et de son serveur :

```bash
dnf -y install knock
dnf -y install knock-server
```
!!!tip
    Attention le service n'est pas démarré par défaut à l'installation. Pour le démarrer, utiliser :
    ```bash
    systemctl start knockd
    ```


Localisation des fichiers de configurations :

```bash
/etc/knockd.conf
```



On observe le fichier de configuration : 

```bash linenums="1"
[options]
        UseSyslog

[opencloseSSH]
        sequence      = 2222:udp,3333:tcp,4444:udp
        seq_timeout   = 15
        tcpflags      = syn,ack
        start_command = /sbin/iptables -A INPUT -s %IP% -p tcp --dport ssh -j ACCEPT
        cmd_timeout   = 10
        stop_command  = /sbin/iptables -D INPUT -s %IP% -p tcp --dport ssh -j ACCEPT
```

Sur la configuration, on observe la séquence utilisée avec les ports suivants: `2222:udp,3333:tcp,4444:udp`.

De plus, on remarque 2 commandes **iptables** permettant d'ajouter (option -A) et de supprimer (option -D) une ip dans le fichier iptables

!!!warning
    Pour que le port knocking fontionne correctement, il faut que tout les ports de la machine soient fermés. On utlise la commade **iptables** pour fermer tout les ports :
    ```bash
    iptables -P INPUT DROP
    ```

On réalise notre propre fichier de configuration. Au prélable, comme il n'y a pas de dossier en .d pour faire des configurations annexe, on copie le fichier de configuration pour en faire une sauvegarde.

Modification du fichier knockd.config :

```bash linenums="1"

[opencloseSSH]
        sequence      = 2222:tcp,3333:udp,4444:tcp
        seq_timeout   = 15
        start_command = /bin/firewall-cmd --zone=public --add-rich-rule 'rule family=ipv4 source address=%IP% service name=ssh accept'
        tcpflags      = syn
        cmd_timeout   = 10
        stop_command  = /bin/firewall-cmd --zone=public --remove-rich-rule 'rule family=ipv4 source address=%IP% service name=ssh accept'

```

!!!warning 
    Comme ici on utilise *firewall-cmd*, on désactive sur la zone publique ssh
    ```sh
    firewall-cmd --zone=public --remove-service=ssh
    ```

Ici nous avons utilisé ***firewall-cmd*** pour remplacer ***iptables***. Les *start_command* et *stop_command* permettent d'ajouter avec les *rich-rules* le service SSH.

Sur la séquence, les ports sont en tcp et udp. 

!!!warning
    Lorsque le port n'est pas spécifié, celui-ci prend par défaut la valeur **TCP**.*

### Connexion avec knock

Pour la connexion client, nous avons besoin du package *knock*.

On toc à la porte de la machine :

```bash
knock  10.56.126.74 2222:tcp 3333:udp 4444:tcp
```

Si on decompose la commande, on retrouve l'ip de destination puis les différents ports avec les protocoles si ce n'est pas du ***TCP***.

!!!warning
    Une fois la commande de knock envoyée, il faut envoyer la commande ssh dans le laps de temps où le port est ouvert


