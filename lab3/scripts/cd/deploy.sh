#!/bin/bash

set -e

cd /opt/mywebapp

docker compose down

MAX_RETRIES=5
RETRY_DELAY=10

for i in $(seq 1 $MAX_RETRIES); do
    echo "Pull attempt $i..."

    if docker compose pull; then
        echo "Images pulled successfully"
        break
    fi

    if [ "$i" -eq "$MAX_RETRIES" ]; then
        echo "Failed after $MAX_RETRIES attempts"
        exit 1
    fi

    echo "Retrying in $RETRY_DELAY seconds..."
    sleep $RETRY_DELAY
done

docker compose up -d

docker image prune -f
