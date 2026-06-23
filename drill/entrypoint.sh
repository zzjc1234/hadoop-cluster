#!/bin/bash
set -e

mkdir -p "$ZOOKEEPER_HOME/data"
"$ZOOKEEPER_HOME/bin/zkServer.sh" start

exec "$DRILL_HOME/bin/drillbit.sh" run
