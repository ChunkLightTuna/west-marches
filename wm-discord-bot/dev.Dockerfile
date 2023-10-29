# syntax = docker/dockerfile:1.2
FROM ubuntu:22.04

WORKDIR /opt/redbot

LABEL updated_at="202305241800"

RUN apt update && \
    apt -y install software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    DEBIAN_FRONTEND=noninteractive TZ=Europe/Paris apt install -y git build-essential python3.9 python3.9-dev python3.9-venv python3-pip locales

RUN locale-gen fr_FR.UTF-8

COPY ./wm-utils /opt/project/wm-utils
COPY ./wm-discord-bot /opt/project/wm-discord-bot

ENV VIRTUAL_ENV=/opt/venv

RUN python3.9 -m venv $VIRTUAL_ENV

ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN pip install --no-cache-dir -r /opt/project/wm-discord-bot/dev-requirements.txt

RUN apt update && apt -y install npm

RUN npm install pm2 -g

CMD ["redbot"]
