---
hide:
    - footer
---

# NFS

## Informations générales

Network File System (NFS) permet le partage de fichier via le réseau.

Il y a 4 protocoles différents et donc 4 deamons différents :

- NFS / nfsd
- mountd / mountd
- nsm / statd
- nlm / lockd


Le *portmapper* associe des adresses universelles aux programmes RPC (Remote Procedure Call): il convertit les numéros de
services en numéros de ports. Quand un service RPC démarre, il avertit le *portmapper*, et lui dit quel
port il utilise et quels sont les numéros de programmes qu'il gère.
Quand le client veut accéder à un service RPC, il contacte le *portmapper*, qui le renseigne sur le port à
utiliser pour communiquer avec le service RPC.
*Portmapper* est maintenant remplacé par *rpcbind*

## Démarrage de RPC

Installation de RPC :

```bash
dnf - y install nfs-utils
```

Démarrage du service :

```bash 
systemctl start rpcbind 
```

Pour lister les différents ports RPC, la commande `rpcinfo -p localhost` nous donne ce résultat :

```bash linenums="1"
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
```

## Démarrage de NFS serveur

Démarrage de nfs-serveur :

```bash
systemctl enable --now nfs-server
```

!!!info "Localisation de configuration"

        Les configuration se trouvent dans `/etc/exports`. Cela permet de définir un répertoire à *exporter* ainsi que les options et autorisations d'accès qui lui seront appliquées. 

### Ajout d'un logical volume 

Ajout d'un nouveau disque dur et mise en place dans le volume groupe

```bash
vgextend rootvg /dev/sdc
```

Ajout d'un logical volume :

```bash
lvcreate -n rootvg/datalv -L 3G
```

Formatage du volume :

```bash
mkfs.ext4 /dev/rootvg/datalv
```

Création d'un dossier :

```bash
mkdir /srv/nfsdata
```

Mise en place dans le fstab :

```bash
echo "/dev/rootvg/datalv /srv/nfsdata  ext4 defaults" >> /etc/fstab
```

Montage du volume :

```bash
mount -a
```

### Mise en place du paratage de fichier

Ajout d'une ligne de configuration dans le fichier de configuration avec un droit de Read-only:

```bash
echo "/srv/nfsdata   10.56.126.0/24(ro,no_root_squash)" >> /etc/exports

exportfs -a

exportfs -v
```

Montage du dossier partagé :

```bash
 mkdir /data
 find /data
 mount 10.56.126.222:/srv/nfsdata   /data

```

### Modification des permissions 

Modification du partage de fichier pour les permissions :

```bash
/srv/nfsdata   10.56.126.0/24(rw,no_root_squash)
```

!!!info "Les permissions"

        - RO (read-only) 
        - RW (read-write)
        - root_squash (mappage d'un root distant sur "nobody"), par défaut, annulable par "no_root_squash "
        - all_squash : mappage de tout utilisateur sur "nobody".
        - anonuid , anongid : mappage de "nobody" sur des UID et GID locaux

Rechargement des de la configuration :

```bash
exportfs -a
```

## Mise en place avec une DB sur docker et le volume disponible sur une autre machine

Ajout d'un fichier de docker compose :

```yaml
volumes:
       dbdata:
          driver_opts:
            type: "nfs"
            o: "addr=10.56.126.220,soft,rw"
            device: ":/srv/nfsdata/03/db"

     
services:
       db:
         image: mysql:5.7
         volumes:
         - dbdata:/var/lib/mysql
         environment:
         - MYSQL_ROOT_PASSWORD=secret
```

Démontage de l'ancien partage si existant :

```bash
umont /data
```

Montage du nouveau partage :

```bash
mount 10.56.126.220:/srv/nfsdata/03 /data
```

Création d'un dossier 

```bash
mkdir /data/db
```

Mise en route du container :

```bash
docker compose up -d
```

Si on regarde maintenant l'arbre on trouve cela :

```bash
/data/
└── db
    ├── auto.cnf
    ├── ca-key.pem
    ├── ca.pem
    ├── client-cert.pem
    ├── client-key.pem
    ├── ib_buffer_pool
    ├── ibdata1
    ├── ib_logfile0
    ├── ib_logfile1
    ├── ibtmp1
    ├── mysql
    ├── mysql.sock -> /var/run/mysqld/mysqld.sock
    ├── performance_schema
    ├── private_key.pem
    ├── public_key.pem
    ├── server-cert.pem
    ├── server-key.pem
    └── sys
```