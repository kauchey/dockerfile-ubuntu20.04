FROM ubuntu:20.04

ARG user=kauchey
ARG passwd=1

MAINTAINER kauchey.wang kauchey.wang@e-mail.com

# RUN sed -i "s/archive.ubuntu.com/mirrors.163.com/g" /etc/apt/sources.list && \
#     sed -i "s/security.ubuntu.com/mirrors.163.com/g" /etc/apt/sources.list && \
RUN apt update && apt install sudo -y \
    && useradd --create-home --no-log-init --shell /bin/bash ${user} -G sudo \
    && echo "${user}:${passwd}" | chpasswd
    # && usermod -aG sudo ${user}

USER ${user}

ARG tools="vim git tree net-tools iputils-ping"

RUN echo ${passwd} | sudo -S apt update \
    && echo ${passwd} | sudo -S apt upgrade -y \
    && echo ${passwd} | sudo -S sudo apt install ${tools} -y

