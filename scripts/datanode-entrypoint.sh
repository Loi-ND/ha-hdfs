#! /bin/bash

mkdir /workspace/spark-events
hdfs --daemon start datanode; 
hdfs --daemon start journalnode;
yarn --daemon start nodemanager; 
sleep 3; 
tail -f /dev/null