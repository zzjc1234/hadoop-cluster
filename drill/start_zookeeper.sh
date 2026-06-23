#!/bin/bash

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

echo "start drill zookeeper"
docker compose -f "$SHELL_FOLDER/docker-compose-distributed.yml" -p hadoop-zookeeper up -d zookeeper
