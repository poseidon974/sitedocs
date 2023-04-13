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
service rpcbind start
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

