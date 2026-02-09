#!/bin/bash
set -e

if [ "$NAMENODE_ROLE" = "active" ]; then
    if [ ! -d /workspace/hadoop/dfs/name/current ]; then
        echo "Formatting active NameNode..."
        hdfs namenode -format -force
    fi

    ZKFC_FORMAT_FLAG=/workspace/hadoop/.zkfc_formatted
    if [ ! -f "$ZKFC_FORMAT_FLAG" ]; then
        echo "Formatting ZK Failover state..."
        hdfs zkfc -formatZK -force
        touch "$ZKFC_FORMAT_FLAG"
    fi
else
    if [ ! -d /workspace/hadoop/dfs/name/current ]; then
        echo "Waiting for Active NameNode nn1..."
        until hdfs haadmin -getServiceState nn1 >/dev/null 2>&1; do
            sleep 3
        done
        
        echo "Bootstrapping Standby NameNode..."
        hdfs namenode -bootstrapStandby
    fi
fi

mkdir -p /workspace/src
mkdir -p /workspace/spark-events

echo "Starting NameNode..."
hdfs --daemon start namenode

echo "Starting Zookeeper Failover Controller..."
hdfs --daemon start zkfc

echo "Starting ResourceManager..."
yarn --daemon start resourcemanager

echo "Starting MapReduce HistoryServer..."
mapred --daemon start historyserver

echo "Waiting for HDFS to be ready..."
until hdfs haadmin -getServiceState nn1 >/dev/null 2>&1; do
    sleep 3
done

echo "Starting Spark History Server..."
start-history-server.sh &

echo "Starting Jupyter Notebook..."
cd /workspace/src
nohup jupyter lab --ip=0.0.0.0 --no-browser --allow-root --port=8888 \
  > /workspace/jupyter.log 2>&1 &

tail -f /dev/null