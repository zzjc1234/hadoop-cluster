#!/bin/bash

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

echo -e "\nbuild docker drill image\n"
docker build -f "$SHELL_FOLDER/../drill/Dockerfile" -t tcimba/drill:latest "$SHELL_FOLDER/.."
