---
hide:
  - footer
---

# Commandes dans Kubernetes

Changement de l'espace de travail 

```bash
kubectl config set-context --current --namespace kube-system
```

Création d'un espace de travail

```bash
kubectl create namespace leo
```

Se situer dans l'environement 

```bash
kubectl config get-contexts
```
Création d'un déployment

```bash
 kubectl create deployment --image nginx:latest --port 80 nginx
```

Lister les deployments

```bash
kubectl get deployments
```

Lister les pods de manière simple

```bash
kubectl get pods
```

Lister les pods de manière plus complète 

```bash
kubectl get pods  -o wide
```

Lister tout les pods 

```bash
kubectl get pods -A
```


Création d'un service

```bash
kubectl create service loadbalancer --tcp 80:80 ngnix
```

Recuprer le service

```bash
 kubectl get service
```

Edition du réplicat 

```bash
kubectl scale --replicas=3 deployment nginx
```

Déployement d'un template 

```bash
kubectl apply -f ./Deployment_whomi.yml 
```

Voir les logs d'un pod 

```bash
kubectl logs -f whoami
```

Voir les logs d'un pod avec le label

```bash
kubectl logs -f -l app=whoami
```

Passer en mode exectution dans le pod

```bash
kubectl exec -it nginx-deployment -- sh
```

