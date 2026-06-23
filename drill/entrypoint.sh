#!/bin/bash
set -e

case "$1" in
zookeeper)
    mkdir -p "$ZOOKEEPER_HOME/data"
    exec "$ZOOKEEPER_HOME/bin/zkServer.sh" start-foreground
    ;;
drillbit|"")
    exec "$DRILL_HOME/bin/drillbit.sh" run
    ;;
*)
    exec "$@"
    ;;
esac
