#!/bin/bash

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

echo "start drill"
"$SHELL_FOLDER/start_zookeeper.sh"
DRILL_HTTP_PORT=8047 DRILL_USER_PORT=31010 "$SHELL_FOLDER/start_drillbit.sh" 1
DRILL_HTTP_PORT=8048 DRILL_USER_PORT=31020 "$SHELL_FOLDER/start_drillbit.sh" 2
DRILL_HTTP_PORT=8049 DRILL_USER_PORT=31030 "$SHELL_FOLDER/start_drillbit.sh" 3
