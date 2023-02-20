---
hide:
    - footer
---

# Docker

## Préparation de l'installation docker

### Création d'un système de fichier

Création d'un dossier /var/lib/docker :

```bash
mkdir -p /var/lib/docker
```

Création d'un d'un volume groupe :

```bash
lvcreate -L 5G -n rootvg/lvdocker
```

!!!tip
    - option `-L` pour spécifier la taille (ou sinon l'option `--size`)
    - option `-n` pour spécifier le nom du volume groupe

Vérification de la création du volume groupe avec `lvscan` :

```bash
  ACTIVE            '/dev/rootvg/rootlv' [32,50 GiB] inherit
  ACTIVE            '/dev/rootvg/lvdocker' [5,00 GiB] inherit
```

Formatage du volume en ext4 :

```bash
mkfs.ext4 /dev/rootvg/lvdocker
```

Enregistrement du fichier dans fstab :

```bash
echo "/dev/rootvg/lvdocker  /var/lib/docker    ext4 defaults" >> /etc/fstab
```

Montage du volume :

```bash
mount -a
```

Vérification du montage avec `df` :

```bash
/dev/mapper/rootvg-lvdocker     5074592       24    4796040   1% /var/lib/docker
```

### Installation de docker 

Récupération du fichier d'installation docker :

```bash
curl -sSL https://get.docker.com > get-docker.sh
```

Exécution du script :

```bash
bash get-docker.sh
```

Si la machine est en almalinux, on modifie le script pour autoriser l'installation du alma :

```bash
350:            almalinux|centos|rhel|sles)
458:            almalinux|centos|fedora|rhel)
```

!!!failure
    Si on excute le script modifié, on obtiendra une erreur sur les repository de docker. 

    **La solution n'est pas maintenable !!!**


Récupération du repo :
```bash
curl -s https://download.docker.com/linux/centos/docker-ce.repo > /etc/yum.repos.d/docker-ce.repo
```

Installation de docker :
```bash
dnf -y install docker-ce
```

Création d'une arborésence :

```bash
├── docker
│   └── compose
│       └── test
```

Activation du service et du socket :

```bash
systemctl enable --now docker.socket
systemctl enable --now docker.service
```

### Test du **docker compose** V2

Docker compose prend en charge 4 noms de fichier :

- docker-compose.yml
- docker-compose.yaml
- compose.yml
- compose.yaml

Création d'un fichier `/root/docker/compose/test/compose.yml` :

```yml
services:
  app:
    image: traefik/whoami
    ports:
    - published: 8080
      target: 80
```

Test de la configuration avec :

- 
```bash 
docker compose config
```

- 
```bash 
docker compose convert
```

Activation du conteneur avec docker compose :

```bash
docker compose up -d
```

!!!tip
    L'option `-d` permet de lancer le conteneur en mode détaché pour ne pas voir les logs

Verification du lancement du conteneur avec `docker container ls` :
```bash
CONTAINER ID   IMAGE            COMMAND     CREATED         STATUS         PORTS                                   NAMES
36a318e3ec0e   traefik/whoami   "/whoami"   2 minutes ago   Up 2 minutes   0.0.0.0:8080->80/tcp, :::8080->80/tcp   test-app-1
```

### Docker compose et les builds

Création d'un dossier sitedoc , build ainsi que de 2 fichiers supplémentaires:
```bash
.
├── sitedoc
│   ├── build
│   │   └── Dockerfile
│   └── compose.yml
```

Mise en place du fichier dockerfile :
```bash
FROM registry.actilis.net/docker-images/httpd:2.4-alpine
```

Mise en place du compose.yml

```yaml
services:
  app:
    #image: 
    build:
      context: build
      dockerfile: Dockerfile
    ports:
    - published: 8080
      target: 80
```

!!!tip
    Pour la déclaration des ports, 2 synthaxes sont possibles avec une *short* et une *long*

    Documentation de docker disponible : [Reférence docker](https://docs.docker.com/compose/compose-file/#ports)


Pour forcer un rebuild d'un docker compose, la commande à un ajout d'une option pour forcer le build :
```bash
docker compose up -d --build
```

Modification de docker file pour ajouter le contenu d'un dossier :
```bash hl_lines="3"
FROM registry.actilis.net/docker-images/httpd:2.4-alpine

COPY site-content/ /var/www/html
```

Ajout du dossier site-content et d'un fichier d'index.html :
```bash
.
├── build
│   ├── Dockerfile
│   └── site-content
│       └── index.html
└── compose.yml
```

## Docker compose et mkdocs

Ajout d'un fichier mkdocs.yml dans le dossier build et ajout de la configuration.

Ajout d'un dockerfile :

```bash
#### Build en deux étapes
## Première étape : Compiler la documentation dans un dossier
FROM registry.actilis.net/docker-images/mkdocs:latest as constructeur
COPY .git .git
COPY mkdocs.yml /docs
COPY src        /docs/src
#COPY includes   /docs/includes
RUN mkdocs build


## Deuxième étape : Construire l'image basée sur nginx
FROM registry.actilis.net/docker-images/httpd:2.4-alpine 
COPY --from=constructeur --chown=www-data /docs/site /var/www/html
```

Ajout d'un docker compose pour directement lancer l'application :

```yml
services:
  dev-serv:
    image: registry.actilis.net/docker-images/mkdocs:latest
    command: serve -a 0.0.0.0:80
    restart: on-failure
    ports:
    - 8000:80
    volumes:
    - ./:/docs
```

Création d'un makefile :

```bash
serve:
	docker compose -f dev.yml up -d
build:
	docker compose build

deploy:
	docker compose up -d --build 
```
