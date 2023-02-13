# Sécurité de SSH

## Changement du port de SSH

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

!!!warning

    Cette solution pour sécuriser SSH n'est pas recommandé car cela ne procure pas beaucoup de sécurité

## Fail2ban

???+ Info
    Pour chercher des packages qui ne sont pas présent sur les depôts par défaut : [dpkg.org](dpkg.org)

Installation d'un dépot supplémentaire :

```bash
dnf install epel-release
```