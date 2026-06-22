#!/bin/bash

export WORKER_NUMBER=2

master/start.sh
WORKER_ID=1 worker/start.sh
WORKER_ID=2 worker/start.sh
#WORKER_ID=3 worker/start.sh
for container in hadoop-master hadoop-worker-1 hadoop-worker-2; do
    for _ in {1..60}; do
        docker exec "$container" service ssh status >/dev/null 2>&1 && break
        sleep 1
    done
    docker exec "$container" service ssh status >/dev/null 2>&1 || exit 1
done
master/start_hadoop.sh
for _ in {1..120}; do
    docker exec hadoop-master hdfs dfsadmin -report >/dev/null 2>&1 && exit 0
    sleep 1
done
docker exec hadoop-master hdfs dfsadmin -report
exit 1
