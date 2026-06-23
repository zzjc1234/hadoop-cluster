# Hadoop Cluster
A Hadoop cluster consists of multiple (N) Docker containers (1 master and N-1 workers).

- [x] Deploy a Hadoop cluster on a single machine with multiple Docker containers.
- [x] Deploy a fully distributed Hadoop cluster on multiple host machines by connecting the standalone containers with Docker swarm overlay network.
- [ ] Support common libraries for big data

### Deploy & Test Hadoop Cluster Locally

1. Build docker image.
```bash
mkdir -p .config && cp ~/.ssh/{id_rsa,id_rsa.pub} .config
./download.sh
./build/docker-build-image.sh
```

2. Init docker and create a Hadoop network.
```bash
docker system prune
master/init_swarm.sh # does not work on manjaro
master/init_network.sh
```

3. Start containers.
```bash
./standalone.sh
```

4. Run WordCount example in `hadoop-master` container.
```bash
./run-wordcount.sh
```

5. Start a Drillbit cluster with ZooKeeper.
```bash
./build/docker-build-drill-image.sh
drill/start.sh
```
Drill Web UIs are exposed at `http://localhost:8047`, `http://localhost:8048`, and `http://localhost:8049`.

### Deploy Hadoop Cluster on Multiple Host Machines

1. Build docker image.
```bash
./download.sh
./docker-build-image.sh
```

2. On `manager`, initialize the swarm.
```bash
docker system prune
master/init_swarm.sh
```

3. On `worker-n`, join the swarm. If the host only has one network interface, the --advertise-addr flag is optional.
```bash
docker system prune
worker/join_swarm.sh <TOKEN> <IP-ADDRESS-OF-MANAGER>
```

4. On `manager`, create an attachable overlay network called `hadoop-net`.
```bash
msater/init_network.sh
```

5. On `manager`, start an interactive (-it) container `hadoop-master` that connects to `hadoop-net`.
```bash
export WORKER_NUMBER=N
master/start.sh
```

6. On `worker-n`, start a detached (-d) and interactive (-it) container `hadoop-worker-n` that connects to `hadoop-net`.
```bash
export WORKER_NUMBER=N
export WORKER_ID=X
worker/start.sh
```

7. Start NameNode daemon, DataNode daemon, ResourceManager daemon and NodeManager daemon in `hadoop-master` container.
```bash
master/start_hadoop.sh
```

8. Run WordCount example in `hadoop-master` container.
```bash
./run-wordcount.sh
```

9. Start Drill on multiple host machines.
```bash
# On manager
drill/start_zookeeper.sh

# On each host
drill/start_drillbit.sh 1
```
Use a different Drillbit ID on each host. If you run multiple Drillbits on one host, set `DRILL_HTTP_PORT` and `DRILL_USER_PORT` to avoid port conflicts.
