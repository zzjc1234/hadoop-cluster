#!/bin/bash
export SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" = "active" ]; then
    echo "swarm already active"
    exit 0
fi

export IP_ADDR=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$IP_ADDR" ] && command -v ipconfig >/dev/null 2>&1; then
    export IP_ADDR=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)
fi

echo "init swarm with master ip: ${IP_ADDR}"
if [ -n "$IP_ADDR" ]; then
    docker swarm init --advertise-addr=$IP_ADDR
else
    docker swarm init
fi
