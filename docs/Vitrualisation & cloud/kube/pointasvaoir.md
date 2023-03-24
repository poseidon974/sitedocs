---
hide : 
    - footer
---

# Point à savoir

- définir etat désiré
- deploiement d'un etat désiré partout 
- mise a l'echelle
- 110 pods max par noeuds (kubectl top pod)
- pour débugger (log / describe / debug / exec)
- penser les applications avec les architectures les plus récentes (developpement et execution)
- déplacement des charges de travail avec (k drain)
- arch mini 1 / archi mini recommandée 3 / archi focntionnnelle 5
- roles controle plain et worker
- ETCD (base clé valeur)
- Terraform (piloter avec de la configuration as the code)
- 1 pod peux contenir plusieurs conteneurs (bonne pratique 1 = 1)
- bdd dans un conteneur à eviter
- Ingress controler pour de la gestion de trafik (redirection de trafik)
- CSI = Conteneur storage interface
- CNI = Conteneur network interface
- stockage = mode block / mode fichier / mode objet
- service = règle de parefeu 
- réseau = clusterIP / loadbancer
- demonset = permettre d'avoir des pods sur des noeuds différents
- Replicaset = uniquement dans un deploiement
- manifests sont enregistrés dans la base ETCD
- CRD permet de rajouter des plugins (ingressroute / ingressrouteTCP)
- RBAC = Role BAse Access Controle
- Secret / Configmap = base 64 qui diffère

