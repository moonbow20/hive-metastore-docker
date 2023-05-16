FROM openjdk:8u342-jre

RUN apt-get update \
 && apt-get install --assume-yes python3 python3-pip procps \
 && apt-get clean

RUN pip3 install pyspark~=3.3.1 pandas~=1.5.3

RUN apt-get update \
 && apt-get install --assume-yes telnet \
 && apt-get clean

WORKDIR /opt

ENV HADOOP_VERSION=3.2.4
ENV METASTORE_VERSION=3.0.0

ENV HADOOP_HOME=/opt/hadoop
ENV HIVE_HOME=/opt/hive-metastore

RUN curl -L https://apache.org/dist/hive/hive-standalone-metastore-${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | tar zxf - && \
    ln -s /opt/apache-hive-metastore-${METASTORE_VERSION}-bin hive-metastore && \
    curl -L https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - && \
    ln -s /opt/hadoop-${HADOOP_VERSION} hadoop && \
    curl -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.19.tar.gz | tar zxf - && \
    cp mysql-connector-java-8.0.19/mysql-connector-java-8.0.19.jar ${HIVE_HOME}/lib/ && \
    rm -rf  mysql-connector-java-8.0.19 && \
    rm /opt/apache-hive-metastore-${METASTORE_VERSION}-bin/lib/guava-19.0.jar && \
    cp /opt/hadoop-${HADOOP_VERSION}/share/hadoop/hdfs/lib/guava-27.0-jre.jar /opt/apache-hive-metastore-${METASTORE_VERSION}-bin/lib/


COPY conf/metastore-site.xml ${HIVE_HOME}/conf
COPY scripts/entrypoint.sh /entrypoint.sh

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    chown hive:hive /entrypoint.sh && chmod +x /entrypoint.sh

USER hive
EXPOSE 9083

ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]
