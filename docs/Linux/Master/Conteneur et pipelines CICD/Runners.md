---
hide: -footer
---

# Deploiement de runners

## Gitlab

On cherche à utiliser un seul et unqiue runner. Sous gitlab, si on utilise les runners fournis par le site, on utilisera pas forcement le même runner pour toutes les actions CI/CD.

Ecriture du fichier CI de début nommé `.gitlab-ci.yml` :

```yml
image: docker:stable
variables:
  IMAGE_NAME: ${CI_REGISTRY}/${CI_PROJECT_PATH}

# Définition des étapes du pipline

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
