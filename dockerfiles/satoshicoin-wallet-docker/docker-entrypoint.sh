#!/bin/bash
set -e
BOOTSTRAP=http://51.68.212.221/download/bootstrapV3.zip
CONF_DIR=/root/.satc
CONF_CONF_FILE=satc.conf
RPC_USER=docker_rpc_user
RPC_PASS=docker_rpc_password
RPC_ALLOW_IP=0.0.0.0
RPC_PORT=3878
PORT=3877


RUN cd /root/$CONF_DIR
    && wget $BOOTSTRAP \
    && unzip -o bootstrapV3.zip \
    && rm bootstrapV3.zip
RUN cd $CONF_DIR \
    && touch $CONF_FILE \
    && echo "rpcuser=$RPC_USER" >> $CONF_FILE \
    && echo "rpcpassword=$RPC_PASS" >> $CONF_FILE \
    && echo "rpcallowip=$RPC_ALLOW_IP" >> $CONF_FILE \
    && echo "rpcport=$RPC_PORT" >> $CONF_FILE \
    && echo "listen=1" >> $CONF_FILE \
    && echo "server=1" >> $CONF_FILE \
    && echo "daemon=1" >> $CONF_FILE \
    && echo "logtimestamps=1" >> $CONF_FILE \
    && echo "masternode=0" >> $CONF_FILE \
    && echo "port=$PORT" >> $CONF_FILE