#!/bin/bash

HOST_USER=$(id -un)

echo "HOST_USER = "${HOST_USER}

read -rp "Enter user name,(defalut: user) : " DOCKER_USER
if [ -z "${DOCKER_USER}" ];then
    DOCKER_USER="user"
fi

read -rp "Enter user passwd,(defalut: 1) : " DOCKER_PASSWD
if [ -z "${DOCKER_PASSWD}" ];then
    DOCKER_PASSWD="1"
fi

DOCKER_FILE=${DOCKER_USER}/Dockerfile

echo "DOCKER_USER = "${DOCKER_USER}
echo "DOCKER_PASSWD = "${DOCKER_PASSWD}
echo "DOCKER_FILE = "${DOCKER_FILE}

mkdir -p ${DOCKER_USER}
tools="vim git tree net-tools iputils-ping"
cat <<EOF > "${DOCKER_FILE}"
FROM ubuntu:20.04

MAINTAINER kauchey.wang kauchey.wang@e-mail.com

# RUN sed -i "s/archive.ubuntu.com/mirrors.163.com/g" /etc/apt/sources.list && \\
#     sed -i "s/security.ubuntu.com/mirrors.163.com/g" /etc/apt/sources.list && \\
RUN apt update && apt install sudo -y \\
    && useradd --create-home --no-log-init --shell /bin/bash ${DOCKER_USER} -G sudo \\
    && echo "${DOCKER_USER}:${DOCKER_PASSWD}" | chpasswd
    # && usermod -aG sudo ${DOCKER_USER}

USER ${DOCKER_USER}

RUN echo ${DOCKER_PASSWD} | sudo -S apt update \\
    && echo ${DOCKER_PASSWD} | sudo -S apt upgrade -y \\
    && echo ${DOCKER_PASSWD} | sudo -S sudo apt install ${tools} -y
EOF

DOCKER_COMPOSE_YML=docker-compose.yml
cat <<EOF > "${DOCKER_COMPOSE_YML}"
version: "2"
services:
  ${DOCKER_USER}-server:
    image: ${DOCKER_USER}
    build:
      context: ./
      dockerfile: ${DOCKER_USER}/Dockerfile
    volumes:
      - "/Users/${HOST_USER}/.ssh:/home/${DOCKER_USER}/.ssh"
      - "/Users/${HOST_USER}/.gitconfig:/home/${DOCKER_USER}/.gitconfig"
    container_name: ${DOCKER_USER}
    tty: true
    # 宿主机重启后，容器自动重启
    # restart: always
EOF

docker-compose build --no-cache