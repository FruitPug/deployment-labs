#!/bin/bash

set -e

echo "== Updating system =="
apt update 
apt upgrade -y

echo "== Installing packages =="
curl -fsSL https://get.docker.com | sudo sh
usermod -aG docker deploy
apt install docker-compose-plugin -y
apt install nginx -y

echo "== Creating directory =="
mkdir -p /opt/mywebapp
chown -R "$USER":"$USER" /opt/mywebapp

echo "== DONE =="
