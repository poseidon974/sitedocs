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

```bash linenums="1"
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

```yml linenums="1"
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

```yml linenums="1"
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

```yml linenums="1"
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

!!!info
  Ici on réalise une comparaison des fichier entre github et gitlab

### Création du runner

Pour réaliser un runner, on utilise une image disponible sur le web. On clone donc un repository github :

```bash
git clone https://github.com/tcardonne/docker-github-runner
```
Dans le dossier à la racine `./docker-github-runner/`, on va créer un fichier `.env` :

```bash
RUNNER_REPOSITORY_URL=https://github.com/poseidon974/cours
GITHUB_ACCESS_TOKEN= votre_token
```

!!!info "Comment générer votre token"
    Pour générer votre token, veuillez vous rendre sur github :

    - Settings

    - Developper settings

    - Personnal access tokens

    - Generate new token

    - **Copier et garder bien le token car il sera affiché uniquement 1 fois.**

Modification du make file pour ajouter une commande nommée compose :
```bash
compose:
	docker compose up -d --scale runner=4
	sleep 1
	docker compose ps 

```
Pour lancer le runner, vous devez build l'image docker qui servira de runner. 

```bash
make build
```
!!!warning "Attention"
    Avant de lancer le build, je vous conseille de mettre le plus de reesources sur votre machine virtuelle car cela peut prendre **beacuoup du temps**.

Pour lancer l'image que vous venez de build, utiliser la commande :

```bash 
make compose
```

### Ecriture du pipeline 

!!!warning 
    L'ecriture de la documentation du pipeline n'est terminée


En première étape, nous allons pouvoir observer avec l'écriture d'un premier pipeline toutes les variables disponibles :

```yml linenums="1"
name: Permier-deploiement
on:
  push:
    branches:
      - main

jobs:
   check:
     runs-on: self-hosted
     steps:
     - name: Affichage Envvars
       uses: actions/checkout@v3
     - run: |
         set
```

!!!info
    Les options présentes ci-dessus permettent :
    
      - `runs-on` : permet d'utiliser le runner hébergé localement
      - `run : set` : permet d'afffihcer les variables d'environement


On va ensuite tester la connexion à `ghcr.io` avec le pipeline :
```yml linenums="1"
name: Test_login
on:
  push:
    branches:
      - main

jobs:
  logingit:
    runs-on: self-hosted
    steps:
      - name: Login to Github Packages
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
```
!!!info
    On utlise ici des variables d'environement mises à disposition par Github :
      - `${{ github.actor }}`: permet d'afficher le nom d'utilisateur du propriètaire
      - `${{ secrets.GITHUB_TOKEN }}`: permet d'utiliser le token de github pour se connecter

```yml linenums="1"
name: Test_build
on:
  push:
    branches:
      - main

jobs:
  buildimage:
    runs-on: self-hosted
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Build image
        run: docker build -t ${{ github.repository }}:build-temp .
```

!!!info
    On utlise ici des variables d'environement mises à disposition par Github :
      - `${{ github.repository }}`: permet d'afficher le nom de repository

```yml linenums="1"

name: Deployment sitedocs
permissions: write-all
on:
  push:
    branches:
      - main

jobs:
   check:
     runs-on: self-hosted
     steps:
     - name: Affichage Envvars
       uses: actions/checkout@v3
     - run: |
         set
     - run: 
         echo "tag name ${{ github.ref_name }}"
     - name:  Set variables
       run: |
           if [ ${{ github.ref_name }} = 'main' ] ; then   $VARIABLE_TAG='devel' ; else  $VARIABLE_TAG=${{github.ref_name}} ; fi

  logingit:
    runs-on: self-hosted
    steps:
      - name: Login to Github Packages
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

  buildimage:
    runs-on: self-hosted
    needs: [logingit]
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Build image
        run: docker build -t ${{ github.repository }}:build-temp .
     
  
  pushimage:
    runs-on: self-hosted
    needs: [buildimage]
    steps:
      # - name:  Set variables
      #   run: |
      #     if [ ${{ github.ref_name }} = 'main' ] ; then   VARIABLE_TAG='devel' ; else  VARIABLE_TAG=${{github.ref_name}} ; fi
      - name: Push image
        run: |
          echo ${{ secrets.GITHUB_TOKEN }} | docker login ghcr.io -u ${{ github.actor }} --password-stdin
          docker tag ${{ github.repository }}:build-temp ghcr.io/${{ github.repository }}:0.4
          docker push ghcr.io/${{ github.repository }}:0.4
          docker logout
      - name: Clean up
        run: docker image rm ${{ github.repository }}:build-temp ${{ github.repository }}:0.4

```
