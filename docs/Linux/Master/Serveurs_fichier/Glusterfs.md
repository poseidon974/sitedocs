---
hide :
    - footer
--- 

# Glusterfs

## Informations générales 

GlusterFS est une solution de virtualisation du stockage (cluster de stockage) sur 2 (ou N) machines.
GlusterFS offre :
- un stockage distribué,
-  des fonctionnalités proche du RAID,
- Plusieurs petaoctets,
- Bonnes performances,
- Grand nombre de clients connectés,
- Fail-over des connexions clients

## Installation de gluster 

recherche des dernières versions de Gluster :

```bash
dnf search gluster*
``` 

On obtient les résultats suivants :

```bash
=========================================================================== Nom & Résumé correspond à : gluster ============================================================================
centos-release-gluster10.noarch : Gluster 10 packages from the CentOS Storage SIG repository
centos-release-gluster11.noarch : Gluster 11 packages from the CentOS Storage SIG repository
centos-release-gluster9.noarch : Gluster 9 packages from the CentOS Storage SIG repository
glusterfs-api.x86_64 : GlusterFS api library
glusterfs-cli.x86_64 : GlusterFS CLI
glusterfs-client-xlators.x86_64 : GlusterFS client-side translators
glusterfs-libs.x86_64 : GlusterFS common libraries
glusterfs-rdma.x86_64 : GlusterFS rdma support for ib-verbs
pcp-pmda-gluster.x86_64 : Performance Co-Pilot (PCP) metrics for the Gluster filesystem
python3-gluster.x86_64 : GlusterFS python library
================================================================================ Nom correspond à : gluster ================================================================================
glusterfs.x86_64 : Distributed File System
glusterfs-cloudsync-plugins.x86_64 : Cloudsync Plugins
glusterfs-fuse.x86_64 : Fuse client
```

Installation de la version 10 : 

```bash
dnf install -y centos-release-gluster10.noarch
```

Installation du server gluster :

```bash
dnf install -y glusterfs-server
```

Démarrage du service :

```bash
systemctl start glusterd
```

## Gestion d'un cluster

Pour ajouter les noeuds dans un cluster :

```bash
gluster peer probe la_machine
```

Pour voir les noeuds d'un cluster :

```bash
gluster pool list
```

Pour partir du cluster :

```bash
gluster peer detach la_machine
```