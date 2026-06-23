#!/bin/bash

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

echo "stop drill"
"$SHELL_FOLDER/stop_drillbit.sh" 3
"$SHELL_FOLDER/stop_drillbit.sh" 2
"$SHELL_FOLDER/stop_drillbit.sh" 1
"$SHELL_FOLDER/stop_zookeeper.sh"
