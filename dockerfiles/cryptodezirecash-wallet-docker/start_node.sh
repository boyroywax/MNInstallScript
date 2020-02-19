#/bin/bash

if [ $# -ne 1 ]; then
    echo $0: usage: node setup
    exit 1
fi

NUM=$1
CODENAME boxy
MNODE_DAEMON boxyd
MNODE_CONF_BASE /root/.boxy/conf
MNODE_DATA_BASE /root/.boxy/data

# PIDFile=${MNODE_DATA_BASE}/${CODENAME}${NUM}/${CODENAME}.pid
${MNODE_DAEMON} -daemon -pid=${MNODE_DATA_BASE}/${CODENAME}${NUM}/${CODENAME}.pid -conf=${MNODE_CONF_BASE}/${CODENAME}${NUM}.conf -datadir=${MNODE_DATA_BASE}/${CODENAME}${NUM}