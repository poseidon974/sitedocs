---
hide:
    - footer
---

# Docker Swarm

Les *nodes* sont des noeuds.

On manipule les nodes avec les commandes qui commencent par `docker node COMMAND`.

On obtient les options suivantes : 

```bash

Commands:
  demote      Demote one or more nodes from manager in the swarm
  inspect     Display detailed information on one or more nodes
  ls          List nodes in the swarm
  promote     Promote one or more nodes to manager in the swarm
  ps          List tasks running on one or more nodes, defaults to current node
  rm          Remove one or more nodes from the swarm
  update      Update a node

```

Le *swarm* est un cluster. C'est orchestrateur de serveur docker. On demande au cluster d'excuter une tâche qui s'appelle un *service*. 

Lorsque on déploie un service, l'orchestrateur va executer une *tâche*. Cette tâche est un conteneur exécuté sur une machine que nous ne connaissons pas car l'orchestrateur va décider sans nous en faire part.
