#!/bin/bash
echo "ZK_ID=${ZK_ID}"
echo "${ZK_ID}" > /workspace/zookeeper/data/myid
zkServer.sh start-foreground