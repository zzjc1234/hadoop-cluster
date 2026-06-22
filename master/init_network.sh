#!/bin/bash

echo "init overlay network"
docker network inspect hadoop-net >/dev/null 2>&1 || \
    docker network create --driver=overlay --attachable hadoop-net
