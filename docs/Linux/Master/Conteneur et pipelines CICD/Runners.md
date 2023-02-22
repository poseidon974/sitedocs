---
hide: -footer
---

# Deploiement de runners

## Gitlab

!!!example "Objectifs"
    On cherche à utiliser un seul et unqiue runner. Sous gitlab, si on utilise les runners fournis par le site, on utilisera pas forcement le même runner pour toutes les actions CI/CD.

### Déploiement du runner local

!!!abstract "Lien pour un runner gitlab by F.micaux"
    [https://gitlab.actilis.net/formation/gitlab/deploy-runner/-/tree/main/](https://gitlab.actilis.net/formation/gitlab/deploy-runner/-/tree/main/)

On clone le repo afin de pouvoir utiliser le runner en local.

Après le clone, on modifie le fichier `formation.env` pour modifier le token, le serveur et le nom du projet :

```bash
COMPOSE_PROJECT_NAME=runner-cours-cs2i
GITLAB_SERVER_URL=https://gitlab.com/
RUNNER_TOKEN=GR1348941tjJ6Vjq-xhxNzbPBqKx2
```

Lancement du runner avec docker :

```bash
docker compose --env-file formation.env up -d
```

### Création du fichier de pipeline

Ecriture du fichier CI de début nommé `.gitlab-ci.yml` :

```yml
image: docker:stable
variables:
  IMAGE_NAME: ${CI_REGISTRY}/${CI_PROJECT_PATH}

# Définition des étapes du pipeline (ordre à bien respecter)

stages:  
  - prebuild 
  - build

# Etape n°1 :
# Permet d'afficher toutes les variables disponibles
Prebuild:
  stage: prebuild 
  script:
  - set 

# Etape N°2: Build de l'image et push

Construction:      
  stage: build
  script:
#Build de l'image avec le nom de l'image (ici le repo)
    - docker image build -t ${IMAGE_NAME}:build-temp .
#Ajout d'un tag à l'image. Si pas de tag spécifié, cela utilisera l'option -devel
    - docker image tag ${IMAGE_NAME}:build-temp ${IMAGE_NAME}:${CI_COMMIT_TAG:-devel}
#Connexion 
    - echo ${CI_REGISTRY_PASSWORD} |  docker login ${CI_REGISTRY} -u ${CI_REGISTRY_USER} --password-stdin
#Push de l'image
    - docker image push  ${IMAGE_NAME}:${CI_COMMIT_TAG:-devel}
#Fermeture de la connexion 
    - docker logout

  after_script:
#Clean du runner
    - docker image rm ${IMAGE_NAME}:build-temp ${IMAGE_NAME}:${CI_COMMIT_TAG:-devel}

```

!!!info
    La documentation de toutes les variables est disponible sur [Gitlab](https://docs.gitlab.com/ee/ci/variables/predefined_variables.html).


Modification du script afin d'optimiser le runner local :

```yml
image: docker:stable
variables:
  IMAGE_NAME: ${CI_REGISTRY}/${CI_PROJECT_PATH}

stages:     
  - build
  - push


Construction:      
  stage: build
  before_script:
  - set 
  script:
    - docker image build -t ${IMAGE_NAME}:build-temp .
    

publication de l'image:
  stage: push
  script:
    - docker image tag ${IMAGE_NAME}:build-temp ${IMAGE_NAME}:${CI_COMMIT_TAG:-devel}
    - echo ${CI_REGISTRY_PASSWORD} |  docker login ${CI_REGISTRY} -u ${CI_REGISTRY_USER} --password-stdin
    - docker image push  ${IMAGE_NAME}:${CI_COMMIT_TAG:-devel}
    - docker logout
  after_script:
    - docker image rm ${IMAGE_NAME}:build-temp ${IMAGE_NAME}:${CI_COMMIT_TAG:-devel}
```

### Ajout d'une recherche de vulnérabilité

Ajout d'un module de sécuité :

```yml
vul-scan:  # renommé "vul-scan" au lieu de "scan de vulnérabilité"
  stage: vul-scan
  script:
    # On s'assure que le dossier de rapport existe
    - mkdir -p -m 2770 ./scan-result

    # Lancement du scan
    - docker container run --rm -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache/ aquasec/trivy --cache-dir /root/.cache/  image --scanners vuln --no-progress ${IMAGE_NAME}:build-temp | tee ./scan-result/scan-${CI_PROJECT_NAME}.log

    # Inspection du rapport pour contorle si il y a des VULN et le cas échéant si on doit ou pas s'arrêter
    - |
      grep -q "CRITICAL: [^0]" ./scan-result/scan-${CI_PROJECT_NAME}.log && if [ ${STOP_IF_VULNERABILITY_FOUND:-0} != 0 ] ; then  echo "Vulnérabilité CRITICAL détectée, arrêt du pipeline" && exit 1  ; fi ; true

```


## Github

### Création du runner

- Duplicatat d'un repo git
- modification d'un make file
- make build 
- make compose

### Ecriture du pipeline 

