---
hide:
    - footer
---

# Les secrets dans kubernetes

## Comment est fait un secret

Un secret est stocké dans la base ETCD de kubernetes.

Ce secret est présent en base 64.

## Création d'un secret 

La commande suivante permet de générer un fichier avec les secrets :

```bash
kubectl create secret generic wordpress --from-literal=username=wordpress --from-literal=password=password --from-literal=database=user -o yaml --dry-run=client

```

Cela nous donne :

```yaml
apiVersion: v1
data:
  database: dXNlcg==
  password: cGFzc3dvcmQ=
  username: d29yZHByZXNz
kind: Secret
metadata:
  creationTimestamp: null
  name: wordpress
```

On peux retrouver les mot de passe avec la commande suivant :

```bash 
echo "dXNlcg==" | base64 -d
```