---
hide:
  - footer
---

# Kubernetes

## Définition

Kubernetes est une solution Open Source permettant l'orchestration de ressources conteneurisées. Cette solution est une solution développée par Google et elle à été offert à la *Linux Fondation* (2014). 
Par la suite la CNCF (Cloud Native Computing Fondation) à été crée en 2015.


!!! info "Définition de kubernetes par la CNCF"
    Kubernetes est ue plateforme open source extensible et portable pour la gestion de charge de trvail et de service conteneurisés.

## Autres plateformes

On retrouve plusieurs plateformes encore active aujourd'hui contrairement à Docker Swarm, Mesos ...

Les solutions actuelles : 

- Titus, solution utilisée par Netflix
- Nomad, soltion en voggue propulsée par Hashicorp
- Apache Mesos , solution proposée par Apache

## Fonctionnement de Kubernetes

## Architecture de kubernetes

![Architecture simple](./../Images/Architecture%20Kubernetes.png)

### Termes utilisés dans Kubernetes



|Terme                      | Signification                                                                                             |
|:--------------------------|:----------------------------------------------------------------------------------------------------------|
| Master (ou control-plane) | Permet de gérer le systèmes                                                                               |
| Workers                   | Permet d'executer l'applicatif                                                                            |
| ETCD                      | Magasin de valeurs clés cohérent et hautement disponible                                                  |
| Scheduleur                | Assure les différentes contraintes (arret, démarrage des conteneurs)                                      |
| Controller Manager        | Gestion des droits                                                                                        |
| API-SERVER                | Centre névralgique de kubernetes                                                                          |
| Kube proxy                | Assure le réseau, la communication avec l'api-server                                                      |
| Kubelet                   | Seul composant non contenurisé. Service `systemctl` qui va communiquer avec le moteur de contenurisation  |
| container                 | Ressource exécutant une application                                                                       |
| pod                       | Groupement d'un ou plusieurs conteneurs                                                                   |
| deployment                | Orchestre les *pods* et *replicaSets*                                                                     |
| deamonset                 | S'assure d'avoir un pod sur chaque noeud                                                                  |
| statefullset              | [legacy] S'assure de n'avoir qu'un seul pod                                                               |
| service                   | Explose votre application sur le réseau du cluster                                                        |
| ingress                   | Permet d'exposer un service en externe (#reverseProxy)                                                    |
| persistent volumes claims | Demande d'allocation de stockage                                                                          |
| configMaps                | stockage clé-valeur non confidentiel                                                                      |
| secrets                   | stockage clé-valeur confidentiel                                                                          |

## Objets de kubernetes 

![objects](./../Images/Kubernetes%20Objects.png)