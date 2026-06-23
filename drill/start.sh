#!/bin/bash

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

echo "start drill"
docker compose -f "$SHELL_FOLDER/docker-compose.yml" -p hadoop-drill up -d
