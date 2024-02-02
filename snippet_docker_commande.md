# Docker Training

2023/05/25

Authors :  
Benjamin LECHA  
Mickaël MASQUELIN  

via Min2Rien

## Demo

docker run -it r-base
docker run -it python
docker run -it python:2.7 # old version possible

## Pourquoi conteneuriser ?

### Motiv

Isoler les appli et maj ciblé pour chaque micro service.
Reponse d'agilité flexibilité résilience et scalabilité.
Reproductibilité (dépedances, bilbiotheque, doc absente, ...)

### Histoire systeme de vitrualisation

type 1 materiel + hyperviseur ou type 2 laptop + OS + Emulateur
conteneur : processus isolé, leger portable.
livraison d'image
Run time = pile logiciel qui offre un service necessaire à l'exe des applications, independamment du systeme d'exploitation
Container + Run time = processus

1970s une seule machine mais necessité de confiner les appli, les dev et la prod, restrindre les capatacités paratager entre les utilisateurs...
2000s VM "jails". ajout de capacité de virtualisation + proprité réseau. Appli independantes qui partagent le meme noyau.
2002 :
namespace linux : permet de segmenter les processus. cf illustraction, commande unshare (ne pas partager = isoler)
mount namespace : propre point de montage racine
2003 : Orchestrateur de container.
2004 : Definition de fronctière
2006 : Process Containers (Controls groups), cgroups fonctionnalité intégré dans le noyau linux, necessaire pour docker. cf illustration.
2007 : exec des processus en tant que utilisateur ou root dans un container.
2008 : linux containers (LXC)
2011 : Gestionnaire de container open source, utilise LXC
2013 : implémentation complete : cgroups + namespaces + autres fonctionnalité linux => Container docker ok !
chroot ?? question ----here
Notion de separation des responsabilité.
Création d'image : empilement de calc pour faire l'image finale.
Bridge : reseau privé virtuel + NAT : permet de rediriger les communications réseaux.
Host : réseau direct sans NAT
none : ?
Côté sécurité ! Noyau linux partagé. On peut attaquer le systeme hote jusqu'a la version 1.11 (deamon monolothique)
2015 : Pb sécu. avec chroot changement de racine.
Sensibilisation à ne pas lancer le container en tant quand que root ! On peut compromettre l'hote.
Maintenant Docker a corriger cela : containerd et runc.
Podman alternative a docker

## Installation de Docker

Voir page : 91-103
Attention peut casser le fonctionnement de virtual box. Mais une fois reinstallé cela remarche.

## Docker - CLI

CLI : outil en ligne de commande

docker run hello-world

docker run -it ubuntu bash
docker nom du logiciel
run la commande
-i interactf -t affichage du nom
ubuntu le nom de l'image
bash la commande

docker --help pour avoir la doc general
docker run --help pour avoir la doc

docker run -it ubuntu bash
touch bonjour.txt : test command pour création des fichiers ok
puis test apt update et apt install curl fonctionne.
exit pour quitter le terminal.
une fois quitter : tout l'environment a disparu
le fichier bonjour et l'installation de curl est a refaire!
(car pas de montage partagée)

l'option -d ou --detach permet de laisser tourner le container en arrière plan
On peut rentrer dans en interactif, quitter et revenir.

Autre exemple avec image nginx
docker run -d -p 8080:80 --name formation nginx
comme c'est un serveur web : port 80 part defaut (du container)
mapping de port sur ma machine et le container
on donne le port 8080 pour la machine qui correspondra à 80 dans le container
Puisque on a un port qui est exposé on peut se rendre sur le site
localhost:8080 : correspond à la page d'acceuil du server nginx

gestion des containers :
docker ps affiche les conainters
-a liste tous les containers en fonctionement ou non.
docker stop
docker start
docker rm : supprime le container

## Réseau

bridge : permet de communiquer entre l'hote et le container

curl du site : marche pas
curl adresse ip : marche mais l'IP est aléatoire

definition d'un réseau
docker network create rx-formation
docker network connect rx-formation formation
docker network connect rx-formation ubuntu_formation_docker
docker exec -it ubuntu_formation_docker bash
  > curl formation # accession au site sur le meme réseau

pour nettoyer :
docker network rm
ou pour aller plus loin docker system prune (imag non utilisé, réseau non utilisé, container stoppé)

## Exercice

https://gitlab.univ-lille.fr/formation-docker-cnrs/session-debutant

### Exercice 01

docker run --detach -p 8001:80 --name formation_nginx nginx
docker stop formation_nginx
docker rm formation_nginx

docker run -d -p 8082:80 --name formation_apache httpd
docker stop formation_apache
docker rm formation_apache

docker run -d -p 3306:3306 --name formation_mysql mysql
docker container logs formation_mysql
  > "root@localhost is created with an empty password !"
docker stop formation_mysql
docker rm formation_mysql

docker run -d -p 3306:3306 --name formation_mysql --env "MYSQL_RANDOM_ROOT_PASSWORD=yes" mysql
docker container logs formation_mysql
  > "2023-05-25 08:57:35+00:00 [Note] [Entrypoint]: GENERATED ROOT PASSWORD: LV9Bke7e2BE5LCO5a/fGr8Mex9ELbz+H"
docker stop formation_mysql
docker rm formation_mysql

### Exercice 02

#### Terminal 1

docker run -it --publish 8001:80 --name webserver_2004 ubuntu:20.04
apt-get update && apt-get -y install curl
apt-get update && apt-get install nginx -y && service nginx start
curl webserver_2204

#### Terminal 2

docker run -it --publish 8002:80 --name webserver_2204 ubuntu:22.04
apt-get update && apt-get -y install curl
apt-get update && apt-get install apache2 –y && service apache2 start
curl webserver_2004

#### Creation du network_test

docker network create network_test
docker network connect network_test webserver_2004
docker network connect network_test webserver_2204

docker stop webserver_2004
docker rm webserver_2004
docker stop webserver_2204
docker rm webserver_2204
docker network rm network_test

docker stop $(docker ps -a -s) # stop tous les containers

Correction :
https://gitlab.univ-lille.fr/formation-docker-cnrs/session-debutant/-/blob/correction/Solution.md

## Pause dej

## Dockerfile

recette de cuisine
texte lu par docker pour constuire l'image
mot clé impératif

### FROM

l'image de base du container
c'est une boite noire a prendre comme telle
Notes : 
il existe un outil pour reconstuire le dockerfile a partir d'une image sur dockerhub mais c'est approximatif.
reverse engineering :
https://github.com/wagoodman/dive Sert à explorer les couches du Dockerfile (va plus loin que `docker history`)
https://github.com/mrhavens/Dedockify Permet de reconstruire le Dockerfile d’origine partiellement (ça ne redonnera pas magiquement les fichiers issus pour un COPY :))


dockerHub est le registre par defaut : https://hub.docker.com/search?q=r-base
(mais on peut en installer un autre)

On peut trouver des exemples pratiques tel que :
FROM r-base
COPY . /usr/local/src/myscripts
WORKDIR /usr/local/src/myscripts
CMD ["Rscript", "myscript.R"]

### RUN

RUN equivalent de lancer des commande dans le terminal
il faut connaitre l'environement pour connaitre le language de base
les RUN se font en root si on lance docker en root de base

### COPY/ADD

copie colle entre 2 dossiers machine vers l'image

### ENV

variable d'environement connu dans toute l'image
exemple l'heure :
ENV TZ="Europe/Paris" (TZ pour time zone)
les var sont modifiable par la suite mais une fois construit cela sera propre a un container.

### LABEL

donner des étiquettes
docker inspect
commande pour affichier les info

### CMD

commande une seule fois et executée la fin

### Build

docker build --tag tokyo .
 -t --tag tokyo tag l'image avec un nom explicite
 par defaut la version est "latest"

 . correspond au contexte d'execution. ou aller indiquer le dockerfile

docker images | grep tokyo

docker run tokyo : démarre le containeur basé sur l'image tokyo

Dans la machine les images sont physiquement dans /var/lob/docker/image/overlay2/imagedb

## Execerices

### Exercice 03 : Créer son premier Dockerfile

```bash
touch example.html
echo hello > exemple.html
```

ou 

```html
<html>
    <head>
        <title>Formation Docker</title>
    </head>
    <body>
        <h1>La formation Docker ... ça nous permet d'apprendre des choses :)</h1>
    </body>
</html>
```

Dans un fichier DOCKERFILE

```dockerfile

FROM bitnami/minideb

RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y nginx

EXPOSE 80/udp

WORKDIR "/var/www/html" ## mot clé pour se placer dans ce dossier au démarrage

COPY exemple.html index.html

CMD ["nginx", "-g", "daemon off;"]

```

Sauver ce texte dans un fichier nommé exactement "Dockerfile",
Dans le même dossier lancer :
docker build --tag nginx_test .

lancer l'image
docker run -d -p 8081:80 --name nginx_container nginx_test

http://localhost:8081 # sous windows?
docker15.egid.local:8081 # sous server labo

## Bonne pratique

Trucs et astuce

1) creation d'un réseau dédié pour un service
avec des namespaces dédiés
le firewall (NAT) peut adapter ses exigences en matières de sécurité

2) attention aux instructions dans le dockerfile
quand on fait des modifications dans le dockerfile car on est sur un system de couche
utilisation du cache optimal : mettre les choses + modifié à la fin

3) COPY ou ADD
copy est plus limité car il copie un truc du server vers le container
add peut aussi source un fichier distant sur web ou sourcer un fichier compressé et il le décompressera automatiquement dans le container

4) ENTRYPOINT ou CMD
CMD : facilement contournable
ENTRYPOINT : il faudra surchargé explicitement la commande pour changer un element
au moment de faire docker run image qqch <- ici on surcharge un commande "qqch" qui se subsitue à CMD

5) syntaxe array ou string
Provilégier la syntaxe array car eviter d'appeler shell ou bash pour lire les elements avec SIGTERM

6) Activer BuildKit
améliorer le processus de construction de l'image docker
permet de faire du build multi platforme (achitecture arm?)

7) Mettre en cache les packages sur l'hote docker
indiquer qu'on utilise la syntaxe dockerfile 1.2
dans un fichier requirement.txt
et recharger les pkg qu'on a deja dans un cache

8) Minimiser le nombre de couches
rassembler les cmd avec &&
on peut passer en multiligne avec \
et lister les param par ordre alphabetique

9) Utiliser les petites images de base de docker
plus modulaire et plus sécurisé
dans dockerhub image nommé -slim
ou -alpine : encore plus petit mais version particuliaire

10) penser à mettre à jour les images
pour la securité
conseil intégration continue

11) conteneurs non privilégiés
ajouter un groupe et un utilisateur a ce groupe et changer l'user

12) limiter les cpu ou la ram si besoin
docker run --cpus=2 -m 512m nginx
voir https://docs.docker.com/config/containers/resource_constraints/

13) un service = un container

14) System de supervision : Healthcheck
dans le dockerfile
HEALTHCHECK CMD curl --fail http://localhost:5000 || exit 1
fait toutes les 30 sec par defaut

15) nommage des images
se donner une convention (horodatage, id, etc)

16) Ne jamais stocker les secrets dans son image
mot de passe typiquement !
voir l'otpion mount-type=secret

17) démarrer avec docker init
dockerignore a revoir...

18) DockerDesktop enrichi avec de nombreux pluggin (graphana etccc)

## Linting

lint roller : permet d'affiner l'image avec les erreurs de rédactions
hadolint Dockerfile
version utilisable en ligne: https://hadolint.github.io/hadolint/
ou via pluggin VScode https://marketplace.visualstudio.com/items?itemName=exiasr.hadolint

advices :
Préciser les versions explicites
Ne pas prompter


```Dockerfile
FROM bitnami/minideb:bullseye

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends curl=7.74.0-1.3+deb11u7 nginx=1.18.0-6.1+deb11u3 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

EXPOSE 80

WORKDIR /var/www/html

COPY exemple.html index.html

CMD ["nginx", "-g", "daemon off;"]

```

## Pause

## Docker - Volume

persistance grace aux volumes
bind mount : non solution (historique)
volume : espace disque dans le container depuis un contenu disque de l'hote

creation de volume en amont : docker volume create mon_vol
permet la persistance des fichiers si on quite re run l'image avec le meme volume, on retrouve les fichiers écrits.

sinon creation de volume à la volée : montage directement d'un dossier directe de l'hote.
Attention ce dossier sera directement impacté (si rm par exemple)

:ro ajouté après le volume pour mettre un fichier volume en read only ! +++
exemple :
docker run -it -v .:/home:ro ubuntu

## Exercice 04 : Utilisation des volumes

voir https://gitlab.univ-lille.fr/formation-docker-cnrs/session-debutant/-/blob/main/exemple.html

```bash
docker run -itd \
  -v /Isiprod1/project/SB_mboissel/scripts:/usr/local/apache2/htdocs/ \ # necessaire dans docker version 20.10.12
  --name mon_apache \
  --publish 9000:80 \
  httpd:2.4

docker run -itd \
  -v .:/usr/local/apache2/htdocs/ \  # ok dans docker version 23.0.3
  --name mon_apache \
  --publish 9000:80 \
  httpd:2.4
```

## Sauvegarde

modification d'une image : quick patch ! +++
image > docker commit > new images > docker save > newimage.tar

partage de la nouvelle solution
newimage.tar > docker load > newimage > docker run

## Info session

docker version
(in lab's server : 20.10.12)

## Session 2

docker compose sera abordé (cool!)
