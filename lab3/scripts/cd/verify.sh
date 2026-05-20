#!/bin/bash

set -e

BASE_URL="http://localhost"

printf "\nChecking nginx config..."
docker compose exec nginx nginx -t

printf "\nChecking alive endpoint..."
curl -f ${BASE_URL}/health/alive

printf "\nChecking ready endpoint..."
curl -f ${BASE_URL}/health/ready

printf "\nChecking tasks endpoint..."
curl -f ${BASE_URL}/tasks

printf "\nVerification successful\n"
