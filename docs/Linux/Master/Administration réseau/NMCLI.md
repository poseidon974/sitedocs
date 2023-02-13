---
hide:
  - footer
---

# Configuration réseau

## Configuration d'une IP fixe avec nmcli

!!!info
    *nmcli* est un outil qui permet de gérer la configuration réseau en interagissant avec le deamon *NetworkManager*. nmcli est utilisé pour créer, afficher, modifier, supprimer, activer et désactiver les connexions réseau, ainsi que pour contrôler et afficher l'état des périphériques réseau.

Pour ajouter une IP fixe, *nmcli* propose une gestion de profile permettant d'activer une configuration personnalisée pour chaque réseau souhaité.

Ici, nous souhaitons avoir les informations suivantes :

- **Adresse IP** : 10.56.126.223
- **Masque** : 255.255.255.0
- **Gateway** : 10.56.126.254
- **DNS** : 1.1.1.1


Ajout d'un profil pour une connexion ip fixe :

```bash 
nmcli connection add type ethernet con-name ipfixe ifname eth0 ipv4.addresses 10.56.126.223/24 ipv4.gateway 10.56.126.254 ipv4.dns 1.1.1.1 ipv4.method manual
```

On observe ensuite les différentes connection avec `nmcli connection show` :

```bash linenums="1"
NAME     UUID                                  TYPE      DEVICE
ipfixe   693bdc04-28e0-4e83-9b58-fef659d8f33c  ethernet  eth0
docker0  0250129c-212a-4ecc-a7f3-35649a492f08  bridge    docker0
lo       45cc8d65-2e4e-40ce-bdbd-1c90b23dada8  loopback  lo
eth0     40d5bcc8-ca0c-42a9-9fad-388b15a5e856  ethernet  --
``` 

On active la connextion avec :

```bash
nmcli connection up ipfixe
```

## Network Manager

Installation du package *systemd-networkd* pour obtenir la commande `networkctl`:

```bash
dnf -y install systemd-networkd
```

Pour observer les différentes cartes réseaux, on utlise *networkctl* :

```bash linenums="1"
IDX LINK        TYPE     OPERATIONAL SETUP
  1 lo          loopback carrier     unmanaged
  2 eth0        ether    routable    unmanaged
  3 eth1        ether    carrier     unmanaged
  4 docker0     bridge   routable    unmanaged
  6 vethda849ef ether    enslaved    unmanaged
```

Empecher le management des cartes tout le temps :

- Ajout d'un fichier dans /etc/NetworkManager/conf.d/99-unmanaged.conf
```bash
[keyfile]
  unmanaged-devices=mac:00:15:5d:85:01:0f,mac:00:15:5d:85:01:10
```
- Suppression des profiles avec nmcli : 
```bash
nmcli connection delete #nomdelaconnexion
```

Configuration d'une carte avec un fichier de configuration dans `/etc/systemd/network/` avec un fichier en .network :

```bash
# Configuration du LAN 1
[Match]
MACAddress=00:15:5d:85:01:0f


[Network]
Address=192.168.131.254/24
# Configuration du LAN 2
[Match]
MACAddress=00:15:5d:85:01:10


[Network]
Address=192.168.132.254/24
```

!!!tip
  Pour continuer le tp, on utilise 3 machines différentes afin d'avoir la possibilité de communiquer entre elles.

Modification des fichiers de configuration de network :
```bash
# Configuration du LAN 1
[Match]
MACAddress=00:15:5d:85:01:0f


[Network]
Address=192.168.131.1/24
Gateway=192.168.131.254
```
