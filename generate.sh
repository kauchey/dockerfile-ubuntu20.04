#!/bin/bash

HOST_USER=$(id -un)
HOST_HOME=$(echo ${HOME})

echo "HOST_USER = "${HOST_USER}
echo "HOST_HOME = "${HOST_HOME}

read -rp "Enter user name,(defalut: user) : " DOCKER_USER
if [ -z "${DOCKER_USER}" ];then
    DOCKER_USER="user"
fi

read -rp "Enter user passwd,(defalut: 1) : " DOCKER_PASSWD
if [ -z "${DOCKER_PASSWD}" ];then
    DOCKER_PASSWD="1"
fi

DEFALUT_DOCKER_WORKSPACE=${HOST_HOME}/workspace
read -rp "Enter workspace path,(defalut: ${DEFALUT_DOCKER_WORKSPACE}): " DOCKER_WORKSPACE
if [ -z "${DOCKER_WORKSPACE}" ];then
    DOCKER_WORKSPACE=${DEFALUT_DOCKER_WORKSPACE}
fi
if [ ! -d "${DOCKER_WORKSPACE}" ];then
    mkdir -p ${DOCKER_WORKSPACE}
fi

DOCKER_FILE=${DOCKER_USER}/Dockerfile

echo "DOCKER_USER = "${DOCKER_USER}
echo "DOCKER_PASSWD = "${DOCKER_PASSWD}
echo "DOCKER_FILE = "${DOCKER_FILE}
echo "DOCKER_WORKSPACE = "${DOCKER_WORKSPACE}

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
      - "${HOST_HOME}/.ssh:/home/${DOCKER_USER}/.ssh"
      - "${HOST_HOME}/.gitconfig:/home/${DOCKER_USER}/.gitconfig"
      - "${DOCKER_WORKSPACE}:/home/${DOCKER_USER}/workspace"
    container_name: ${DOCKER_USER}
    tty: true
    # 宿主机重启后，容器自动重启
    # restart: always
EOF

docker-compose build --no-cache