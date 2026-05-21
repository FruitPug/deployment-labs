#!/bin/bash

set -e

echo "== Updating system =="
apt update
apt upgrade -y

echo "== Installing dependencies =="
apt install -y \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    nginx

echo "== Installing Docker =="
curl -fsSL https://get.docker.com | sh

echo "== Installing Docker Compose plugin =="
apt install -y docker-compose-plugin

echo "== Enabling Docker =="
systemctl enable docker
systemctl start docker

echo "== Creating deploy user =="

if ! id deploy >/dev/null 2>&1; then
    adduser --disabled-password --gecos "" deploy
fi

echo "== Adding deploy user to docker group =="
usermod -aG docker deploy

echo "== Creating application directory =="
mkdir -p /opt/mywebapp

echo "== Setting ownership =="
chown -R deploy:deploy /opt/mywebapp

echo "== DONE =="
