#!/bin/bash

set -e

cd /opt/mywebapp

docker compose pull

docker compose up -d

docker image prune -f
