#!/bin/bash

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
export DRILLBIT_ID=${1:-$DRILLBIT_ID}

if [ -z "$DRILLBIT_ID" ]; then
    echo "usage: drill/stop_drillbit.sh <DRILLBIT_ID>"
    exit 1
fi

echo "stop drillbit ${DRILLBIT_ID}"
docker compose -f "$SHELL_FOLDER/docker-compose-distributed.yml" -p "hadoop-drillbit-${DRILLBIT_ID}" down
