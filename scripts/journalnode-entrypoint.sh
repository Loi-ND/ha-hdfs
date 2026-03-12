#! /bin/bash

mkdir /workspace/spark-events
hdfs --daemon start journalnode;
sleep 3; 
tail -f /dev/null
