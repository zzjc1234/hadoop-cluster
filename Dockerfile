ARG HADOOP_VERSION=3.3.6
ARG SPARK_VERSION=3.5.6

FROM ubuntu:22.04 AS tarballs
WORKDIR /root

ENV DEBIAN_FRONTEND noninteractive

# RUN echo 'Acquire::http { Proxy "http://hadoop-apt-cache:3142"; };' >> /etc/apt/apt.conf.d/01proxy

RUN apt-get update && apt-get -y install pv curl apt-utils

# copy downloaded files and download new files
COPY tarballs/* tarballs/
COPY download.sh ./
# RUN bash download.sh

RUN useradd -u 1500 -s /bin/bash -d /home/hadoop hadoop

ARG HADOOP_VERSION
RUN pv -n tarballs/hadoop-${HADOOP_VERSION}.tar.gz | \
    tar --owner=hadoop --group=hadoop --mode='g+wx' -xzf -

ARG SPARK_VERSION
RUN pv -n tarballs/spark-${SPARK_VERSION}-bin-without-hadoop.tgz | \
    tar --owner=hadoop --group=hadoop --mode='g+wx' -xzf - 

FROM ubuntu:22.04
WORKDIR /root

# install openssh-server, curl, python and scala (for spark)
ENV DEBIAN_FRONTEND noninteractive


# RUN echo 'Acquire::http { Proxy "http://hadoop-apt-cache:3142"; };' >> /etc/apt/apt.conf.d/01proxy
RUN echo "" > /etc/dpkg/dpkg.cfg.d/excludes

RUN apt-get update && apt-get install -y apt-transport-https ca-certificates apt-utils man

# JDK 11 is supported by Hadoop 3.3.x and is available on both amd64 and arm64.
ENV JDK_VERSION=11
ENV JAVA_HOME=/usr/lib/jvm/default-java

RUN apt-get install -y openjdk-${JDK_VERSION}-jdk-headless \
    openssh-server curl python3 python3-pip scala r-base gcc g++ \
    binutils build-essential cmake x11-xserver-utils clang libgmp-dev
RUN ln -sfn "$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")" "$JAVA_HOME"

# generate & configure ssh key
#RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
#    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
COPY .config/id_rsa .config/id_rsa.pub config/ssh/config .ssh/
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
#COPY config/ssh/config .ssh/config


# setup hadoop user group
RUN useradd -u 1500 -s /bin/bash -d /home/hadoop hadoop

# install utils
RUN apt-get install -y net-tools locales pv pandoc vim nano sudo git 
RUN locale-gen en_US.UTF-8

# setup environment variables for hadoop
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}

# install & configure hadoop
ARG HADOOP_VERSION
COPY --chown=hadoop:hadoop --from=tarballs /root/hadoop-${HADOOP_VERSION} ${HADOOP_HOME}/
#RUN pv -n tarballs/hadoop-${HADOOP_VERSION}.tar.gz | \
#    tar --owner=hadoop --group=hadoop --mode='g+wx' -xzf - && \
#    mv hadoop-${HADOOP_VERSION} ${HADOOP_HOME} && \
#    rm tarballs/hadoop-${HADOOP_VERSION}.tar.gz
#RUN mkdir -p ${HADOOP_HOME}/hdfs/data/nameNode && \
#    mkdir -p ${HADOOP_HOME}/hdfs/data/dataNode
COPY config/hadoop/* ${HADOOP_HOME}/etc/hadoop/
ENV LD_LIBRARY_PATH=${HADOOP_HOME}/lib/native

# install & configure spark
ARG SPARK_VERSION
ENV SPARK_HOME=/usr/local/spark
COPY --chown=hadoop:hadoop --from=tarballs /root/spark-${SPARK_VERSION}-bin-without-hadoop ${SPARK_HOME}/
#RUN pip3 install tarballs/pyspark-${SPARK_VERSION}.tar.gz && \
#    rm tarballs/pyspark-${SPARK_VERSION}.tar.gz
#RUN pv -n tarballs/spark-${SPARK_VERSION}-bin-without-hadoop.tgz | \
#    tar --owner=hadoop --group=hadoop --mode='g+wx' -xzf - && \
#    mv spark-${SPARK_VERSION}-bin-without-hadoop ${SPARK_HOME} && \
#    rm tarballs/spark-${SPARK_VERSION}-bin-without-hadoop.tgz
RUN cd ${SPARK_HOME}/python && \
    python3 setup.py sdist > /dev/null && \
    pip3 install dist/pyspark-${SPARK_VERSION}.tar.gz && \
    rm dist/pyspark-${SPARK_VERSION}.tar.gz
COPY config/spark/* ${SPARK_HOME}/conf/
ENV PATH=${SPARK_HOME}/bin:${PATH}

# install softwares
RUN apt-get install -y screen unrar maven
RUN ln -s /usr/bin/python3 /usr/bin/python
COPY config/screen/* ./

# install python packages
RUN pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple virtualenv pipenv 

# install hdf5 packages
# RUN apt-get install -y libjhdf5-java libhdf5-dev hdf5-tools hdf5-helpers
COPY hdf/*.jar /usr/share/java/
COPY hdf/*.so /usr/java/packages/lib/
RUN ln -s /usr/java/packages/lib/libhdf5_java.so /usr/java/packages/lib/libhdf5_java.so.100 && \
    ln -s /usr/java/packages/lib/libhdf5_java.so /usr/java/packages/lib/libhdf5_java.so.100.4.0 && \
    ln -s /usr/java/packages/lib/libhdf_java.so /usr/java/packages/lib/libhdf_java.so.4.2.14 && \
    ln -s /usr/java/packages/lib/libhdf.so /usr/java/packages/lib/libhdf.so.4.2.14 && \
    ln -s /usr/java/packages/lib/libhdf5 /usr/java/packages/lib/libhdf5.so.103 && \
    ln -s /usr/java/packages/lib/libhdf5 /usr/java/packages/lib/libhdf5.so.103.1.0


#RUN useradd -u 1500 -s /bin/bash hadoop && \
#    chown -R hadoop:hadoop ${HADOOP_HOME} && \
#    chmod -R g+wx ${HADOOP_HOME}

# copy bash scripts
COPY script/* ./
RUN chmod +x ~/entrypoint.sh && \
    chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh 
# && \
#    chmod +x ${HADOOP_HOME}/sbin/start-dfs.sh && \
#    chmod +x ${HADOOP_HOME}/sbin/start-yarn.sh

ENTRYPOINT ["/root/entrypoint.sh"]
#CMD ["0"]
