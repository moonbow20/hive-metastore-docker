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
ENV HIVE_VERSION=3.1.3
ENV METASTORE_VERSION=3.0.0

ENV HADOOP_HOME=/opt/hadoop
ENV HIVE_HOME=/opt/hive-metastore

RUN curl -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.19.tar.gz | tar zxf - && \
    curl -L https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - && \
    ln -s /opt/hadoop-${HADOOP_VERSION} /opt/hadoop && \
    curl -L https://dlcdn.apache.org/hive/hive-standalone-metastore-${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | tar zxf - && \
    ln -s /opt/apache-hive-metastore-${METASTORE_VERSION}-bin /opt/hive-metastore && \
    rm /opt/hive-metastore/lib/guava-*.jar && \
    cp /opt/hadoop/share/hadoop/hdfs/lib/guava-*-jre.jar /opt/hive-metastore/lib/ && \
    cp mysql-connector-java-8.0.19/mysql-connector-java-8.0.19.jar /opt/hive-metastore/lib/ && \
    curl -L https://dlcdn.apache.org/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz | tar zxf - && \
    ln -s /opt/apache-hive-${HIVE_VERSION}-bin /opt/hive && \
    rm /opt/hive/lib/guava-*.jar && \
    cp /opt/hadoop/share/hadoop/hdfs/lib/guava-*-jre.jar /opt/hive/lib/ && \
    cp mysql-connector-java-8.0.19/mysql-connector-java-8.0.19.jar /opt/hive/lib/ && \
    rm -rf  mysql-connector-java-8.0.19 && \
    cp hadoop/share/hadoop/tools/lib/aws-java-sdk-bundle-*.jar hive-metastore/lib/ && \
    cp hadoop/share/hadoop/tools/lib/hadoop-aws-*.jar hive-metastore/lib/ && \
    echo "done" 



COPY conf/metastore-site.xml ${HIVE_HOME}/conf
COPY scripts/entrypoint.sh /entrypoint.sh

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    chown hive:hive /entrypoint.sh && chmod +x /entrypoint.sh

USER hive
EXPOSE 9083

ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]
