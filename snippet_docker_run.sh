#### docker run bash extract  ####

``` bash
PROJECT="project_name"
SCRIPT="01-file.R"
#docker container stop $(whoami)--${PROJECT}--${SCRIPT}
docker container run \
  --name "$(whoami)--${PROJECT}--${SCRIPT}" \
  --group-add staff \
  --detach \
  --rm \
  --env "RENV_PATHS_CACHE=/renv_cache" \
  --volume /root/datatmp/dockertmp/$(whoami)--${PROJECT}--${SCRIPT}:/tmp \
  --volume /root/datatmp/dockertmp/renv_pkgs_cache:/renv_cache \
  --volume /root:/root \
  umr1283/umr1283:4.0.5 /bin/bash -c "cd /root/project/${PROJECT}; Rscript scripts/${SCRIPT} >& logs/${SCRIPT}.log;"

```

#### docker run function ####

#!/bin/bash

function run_container() {
  DIRMOUNT=/root
  
  if [ -z "$1" ]; then
    echo "Error 1: Missing project directory name!"
    return 1
  fi

  if [ -z "$2" ]; then
    echo "Error 2: Missing script name!"
    return 2
  fi

  if [ -z "$3" ]; then
    echo "Error 3: Missing IMAGE!"
    return 3
  else
    local IMAGE=$3
  fi

  local PROJECT=$1
  local SCRIPT=$2
  local SCRIPTCLEAN=${SCRIPT//\//-}

  local LOG=${SCRIPTCLEAN%.*}
  local ROOTPROJECT=${DIRMOUNT}/project/${PROJECT}

  local TMP=${DIRMOUNT}/datatmp/dockertmp

  if [ -n "${SUDO_USER}" ]; then
    local USER_NAME=${SUDO_USER}
  else
    local USER_NAME=$(whoami)
  fi

  if [[ (-n "$(docker ps | grep -E '${USER_NAME}--${PROJECT}--${SCRIPTCLEAN}$')") ]]; then
    echo "Error 4: A container with the same name is already running!"
    return 4
  fi

  local TMPDIR=${TMP}/${USER_NAME}--${HOSTNAME}--${PROJECT}--${SCRIPTCLEAN}
  if [ -e ${TMPDIR} ]; then
    rm -rf ${TMPDIR}
  fi
  mkdir -p -m 775 ${TMPDIR}
  chgrp staff ${TMPDIR}

  local TMPRENV=${TMP}/renv_pkgs_cache
  if [ ! -e ${TMPRENV} ]; then
    mkdir -p -m 775 ${TMPRENV}
  fi

  docker run \
    --name "${USER_NAME}--${PROJECT}--${SCRIPTCLEAN}" \
    --detach \
    --rm \
     --group-add staff \
    --volume ${TMPDIR}:/tmp \
    --volume ${TMPRENV}:/renv_cache \
    --env "RENV_PATHS_CACHE=/renv_cache" \
    --volume ${DIRMOUNT}:/media \
    --volume ${DIRMOUNT}:/root \
    --volume /etc/localtime:/etc/localtime \
    ${IMAGE} /bin/bash -c "cd ${ROOTPROJECT}; Rscript scripts/${SCRIPT} >& logs/${LOG}.log; rm -rf /tmp/*;"

  echo "Docker container \"${USER_NAME}--${PROJECT}--${SCRIPTCLEAN}\" online!"

  return 0
}


# sudo bash -c "$(declare -f run_container); run_container project_name script.R umr1283/umr1283:4.*.*"

#### old example 1 ####
## Avec run , une fonction bash, example
## renv::restore() is may be too much...

run() {
  if [ -z "$1" ]
  then
    echo 'Missing project directory name!'
    exit 1
  fi

  if [ -z "$2" ]
  then
    echo 'Missing script name!'
    exit 1
  fi

  if [ -z "$3" ]
  then
    echo 'Missing version for "umr1283/stat"! Defaulting to "umr1283/stat:4.04"!'
    local VERSION="4.0.4"
  else 
    local VERSION=$3
  fi

  local PROJECT=$1
  local SCRIPT=$2

  docker run \
    --name ${PROJECT} \
    --detach \
    --rm \
    --volume /media/Datatmp/dockertmp/${PROJECT}:/tmp \
    --volume /media/Datatmp/dockertmp/renv_cache:/renv_cache \
    --env "RENV_PATHS_CACHE=/renv_cache" \
    --volume /media/Run:/disks/RUN \
    --volume /media/Data:/disks/DATA \
    --volume /media/Project:/disks/PROJECT \
    --volume /media/Datatmp:/disks/DATATMP \
    --volume /media/Project/${PROJECT}:/project \
    umr1283/stat:${VERSION} /bin/bash -c "Rscript --vanilla -e 'setwd(\"/project\"); renv::restore(); source(\"/project/scripts/${SCRIPT}\")' >& /project/logs/${SCRIPT//[!0-9]/}.log"
}

#### old example 2 ####

#!/bin/bash 

## how to run it
## nohup ./scripts/docker_run.sh > logs/nohup_docker_run.log & 

docker_run () {
  if [ -z "$1" ]
  then
    echo 'Missing project directory name!'
    exit 1
  fi

  if [ -z "$2" ]
  then
    echo 'Missing script name!'
    exit 1
  fi

  if [ -z "$3" ]
  then
    echo 'Missing version for "umr1283/stat"! Defaulting to "umr1283/stat:4.0.5"!'
    local VERSION="4.0.5"
  else 
    local VERSION=$3
  fi

  local PROJECT=$1
  local SCRIPT=$2
  
  docker run \
    --name ${PROJECT}_${SCRIPT} \
    --detach \
    --rm \
    --volume /media/Datatmp/dockertmp/${PROJECT}:/tmp \
    --volume /media/Datatmp/dockertmp/renv_cache:/renv_cache \
    --env "RENV_PATHS_CACHE=/renv_cache" \
    --volume /media/Run:/disks/RUN \
    --volume /media/Data:/disks/DATA \
    --volume /media/Project:/disks/PROJECT \
    --volume /media/Datatmp:/disks/DATATMP \
    umr1283/stat:${VERSION} /bin/bash -c "Rscript --vanilla -e 'setwd(\"/disks/PROJECT/$PROJECT\"); message(getwd()); renv::restore(); message(\"HelloWorld\"); source(\"/disks/PROJECT/$PROJECT/scripts/${SCRIPT}\") ; message(\"ByeByeWorld\");' >& /disks/PROJECT/$PROJECT/logs/${SCRIPT}.log"

  echo "docker run"
}

#### show time
date

#### exec ####
# docker_run Project_name 12-de.R 
# docker_run Project_name 12-de_hg38.R 

#### show time
date


#### Note commande to re run monitoring ####

## command on server14
# cd /media/Project/TEAM_project/docker_services/monitoring/
# l
# docker-compose down
# docker ps -a
# docker system prune --all
# source /media/Project/TEAM_project/docker_services/main.sh
# monitoring /media/Project/TEAM_project/docker_services/monitoring/docker-compose.yml
# docker ps -a
# exit
# 
# ## command on server15
# docker ps -a
# docker system prune --volume
# docker volume prune
# docker restart cadvisor 
# docker restart prometheus 
# htop
# htop
# docker ps -a
# source /media/Project/TEAM_project/docker_services/main.sh
# monitoring /media/Project/TEAM_project/docker_services/monitoring/docker-compose.yml
# docker ps -a
# docker stop 45189cd790f7_cadvisor prometheus 
# docker system prune --all
# docker ps -a
# docker stop 45189cd790f7_cadvisor 
# docker ps -a
# docker stop --force 45189cd790f7_cadvisor 
# docker container kill prometheus 
# docker ps -a
# docker container kill 45189cd790f7_cadvisor 
# docker ps -a
# docker rm --force prometheus 
# docker ps -a
# docker rm --force 45189cd790f7_cadvisor 
# docker ps -a
# docker system prune --all --force
# docker system prune --all --force
# docker system prune --all --force
# monitoring /media/Project/TEAM_project/docker_services/monitoring/docker-compose.yml
# docker ps -a
# docker system prune --all --force
# docker system prune --all --force
# docker-compose down
# cd /media/Project/TEAM_project/docker_services/
# l
# cd monitoring/
# l
# docker-compose down
# docker container ls -a
# docker network disconnect -f monitoring_default 71777a333afc45931454a91ef2af5e29246ded5d78e946507603aa687d961305
# docker network inspect
# docker network inspect monitoring_default 
# docker network disconnect -f monitoring_default
# docker network disconnect -f monitoring_default 45189cd790f7_cadvisor
# docker network disconnect -f monitoring_default prometheus
# docker network inspect monitoring_default 
# docker system prune --all
# monitoring /media/Project/TEAM_project/docker_services/monitoring/docker-compose.yml
# docker ps -a
# docker ps -a
# docker ps -a
# exit


#### monitoring ####
 # docker exec -it project_name_script_name.R htop

