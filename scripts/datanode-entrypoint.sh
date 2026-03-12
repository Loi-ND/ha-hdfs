#! /bin/bash

mkdir -p /workspace/spark-events
hdfs --daemon start datanode; 
yarn --daemon start nodemanager; 
sleep 3; 
tail -f /dev/null
