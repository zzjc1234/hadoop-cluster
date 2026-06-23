ARG DRILL_VERSION=1.22.0
ARG ZOOKEEPER_VERSION=3.7.2

FROM ubuntu:22.04

WORKDIR /root
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y ca-certificates openjdk-11-jre-headless procps && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/default-java
RUN ln -sfn "$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")" "$JAVA_HOME"

ARG DRILL_VERSION
ARG ZOOKEEPER_VERSION
ENV DRILL_HOME=/usr/local/drill
ENV ZOOKEEPER_HOME=/usr/local/zookeeper
ENV PATH=${DRILL_HOME}/bin:${JAVA_HOME}/bin:${PATH}
ENV HADOOP_CONF_DIR=${DRILL_HOME}/conf

COPY tarballs/apache-drill-${DRILL_VERSION}.tar.gz /tmp/
COPY tarballs/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz /tmp/
RUN tar -xzf /tmp/apache-drill-${DRILL_VERSION}.tar.gz -C /usr/local && \
    mv /usr/local/apache-drill-${DRILL_VERSION} ${DRILL_HOME} && \
    tar -xzf /tmp/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz -C /usr/local && \
    mv /usr/local/apache-zookeeper-${ZOOKEEPER_VERSION}-bin ${ZOOKEEPER_HOME} && \
    rm /tmp/apache-drill-${DRILL_VERSION}.tar.gz /tmp/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz

COPY config/drill/* ${DRILL_HOME}/conf/
COPY config/hadoop/* ${DRILL_HOME}/conf/
COPY drill/drill-override.conf ${DRILL_HOME}/conf/
COPY drill/zoo.cfg ${ZOOKEEPER_HOME}/conf/
COPY drill/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 2181 8047 31010 31011

ENTRYPOINT ["/entrypoint.sh"]
