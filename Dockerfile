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

RUN curl -L https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf -
RUN ln -s /opt/hadoop-${HADOOP_VERSION} {HADOOP_HOME}

RUN curl -L https://dlcdn.apache.org/hive/hive-standalone-metastore-${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | tar zxf -
RUN ln -s /opt/apache-hive-metastore-${METASTORE_VERSION}-bin ${HIVE_HOME}

RUN rm ${HIVE_HOME}/lib/guava-*.jar
RUN cp {HADOOP_HOME}/share/hadoop/hdfs/lib/guava-*-jre.jar            ${HIVE_HOME}/lib/
RUN cp {HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-*.jar ${HIVE_HOME}/lib/
RUN cp {HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-*.jar          ${HIVE_HOME}/lib/

# RUN curl -L https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz | tar zxf -
# RUN ln -s /opt/apache-hive-${HIVE_VERSION}-bin /opt/hive
# RUN rm /opt/hive/lib/guava-*.jar
# RUN cp {HADOOP_HOME}/share/hadoop/hdfs/lib/guava-*-jre.jar /opt/hive/lib/
# RUN cp {HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-*.jar hive/lib/
# RUN cp {HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-*.jar hive/lib/

RUN wget https://jdbc.postgresql.org/download/postgresql-42.7.4.jar
RUN cp postgresql-42.7.4.jar ${HIVE_HOME}/lib/

COPY conf/metastore-site.xml ${HIVE_HOME}/conf
COPY scripts/entrypoint.sh /entrypoint.sh

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    chown hive:hive /entrypoint.sh && chmod +x /entrypoint.sh

USER hive
EXPOSE 9083

ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]
