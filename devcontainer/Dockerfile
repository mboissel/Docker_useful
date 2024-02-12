ARG IMAGE
FROM ${IMAGE}

RUN apt-get update && apt-get install -y openssh-client sudo
RUN apt-get install pkg-config
RUN apt-get install jags

ARG USERNAME=umr1283
ARG USERID=1000
RUN if [[ -d /home/${USERNAME} ]]; then CH="--no-create-home"; else CH="--create-home"; fi \
    && useradd \
        ${CH} \
        --no-user-group \
        --shell /bin/bash \
        --uid ${USERID} \
        --gid staff \
        --groups staff \
        ${USERNAME} \
    && usermod -aG sudo ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN Rscript -e 'pak::pkg_install(c("languageserver"))'
# "httpgd" archived 2024/01
# install.packages(pkgs="/Isiprod1/archive/httpgd_1.3.1.tar.gz", type="source", repos=NULL) 

USER ${USERNAME}
