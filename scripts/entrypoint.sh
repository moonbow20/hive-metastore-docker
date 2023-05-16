#!/bin/sh


export HADOOP_HOME=/opt/hadoop
export HIVE_HOME=/opt/hive-metastore

export HADOOP_CLASSPATH=$(find $HADOOP_HOME -name "aws-java-sdk-bundle*.jar" | head -n 1):$(find $HADOOP_HOME -name "hadoop-aws-*.jar" | head -n 1)
export JAVA_HOME=/usr/local/openjdk-8

# Make sure mariadb is ready
MAX_TRIES=8
CURRENT_TRY=1
SLEEP_BETWEEN_TRY=4
until [ "$(telnet mariadb 3306 | sed -n 2p)" = "Connected to mariadb." ] || [ "$CURRENT_TRY" -gt "$MAX_TRIES" ]; do
    echo "Waiting for mariadb server..."
    sleep "$SLEEP_BETWEEN_TRY"
    CURRENT_TRY=$((CURRENT_TRY + 1))
done

if [ "$CURRENT_TRY" -gt "$MAX_TRIES" ]; then
  echo "WARNING: Timeout when waiting for mariadb."
fi

# Check if schema exists
/opt/hive-metastore/bin/schematool -dbType mysql -info

if [ $? -eq 1 ]; then
  echo "Getting schema info failed. Probably not initialized. Initializing..."
  /opt/hive-metastore/bin/schematool -initSchema -dbType mysql
fi

/opt/hive-metastore/bin/start-metastore
