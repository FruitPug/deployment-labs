#!/bin/bash

set -e

echo "== Updating system =="
apt update
apt upgrade -y

echo "== Installing dependencies =="
apt install -y \
    curl \
    git \
    jq \
    unzip \
    docker.io

echo "== Enabling Docker =="
systemctl enable docker
systemctl start docker

echo "== Creating github-runner user =="

if ! id github-runner >/dev/null 2>&1; then
    adduser --disabled-password --gecos "" github-runner
fi

echo "== Adding github-runner user to docker group =="
usermod -aG docker github-runner

echo "== Creating runner directory =="
mkdir -p /home/github-runner/actions-runner

echo "== Setting ownership =="
chown -R github-runner:github-runner /home/github-runner/actions-runner

echo "== DONE =="

echo
echo "Next manual steps:"
echo "1. Switch to github-runner user"
echo "2. Download GitHub Actions runner"
echo "3. Run ./config.sh with repository token"
echo "4. Install runner service"
