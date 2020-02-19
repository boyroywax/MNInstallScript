# Get Satc wallet daemon and run waiting.

FROM ubuntu:16.04

ENV DAEMON_ORIGIN https://github.com/SatoshiCoin-Crypto/SatoshiCoin-rebrand/releases/download/v1.0.2.1/ubuntu16.04-daemon.zip
ENV DAEMON_COMMANDS http://51.68.212.221/download/commands.zip
ENV BOOTSTRAP http://51.68.212.221/download/bootstrapV3.zip
ENV SOURCE_LOCAL_ROOT /root/satc
ENV DAEMON_NAME satcd
ENV CLI_NAME satc-cli
ENV CONF_DIR /root/.satc
ENV CONF_FILE satc.conf
ENV RPC_USER docker_rpc_user
ENV RPC_PASS docker_rpc_password
ENV RPC_ALLOW_IP 0.0.0.0
ENV RPC_PORT 3878
ENV PORT 3877

WORKDIR /root

# 1. We need to do this first in order to see any packages at all
RUN apt-get update \
    && apt-get upgrade -y
    # 2. Install the basic foundation of build tools.
RUN apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    libtool \
    openssl \
    pkg-config \
    wget \
    python-dev \
    autotools-dev \
    software-properties-common \
    autoconf \
    automake \
    libzmq3-dev \
    libminiupnpc-dev \
    libevent-dev \
    libgmp-dev \
    unzip
    # 3. We don't need all of the boost libraries, only selectively install a handful of them
RUN apt-get install -y --no-install-recommends \
    libboost-chrono-dev \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libboost-test-dev \
    libboost-thread-dev
    # 4. We need this because we want to get v4.8 of the wallet db
RUN add-apt-repository -y ppa:bitcoin/bitcoin \
    # 4.2 And now we need to update this again
    && apt-get update \
    # 4.3 Now get v4.8 of the wallet db
    && apt-get install -y --no-install-recommends libdb4.8-dev libdb4.8++-dev \
    # 5. Now clone the source code.
    && apt-get install -y --no-install-recommends \
       ca-certificates
RUN mkdir -p $SOURCE_LOCAL_ROOT \
    && cd $SOURCE_LOCAL_ROOT \
    # We happen to know that this particular commit works.
    && wget $DAEMON_ORIGIN \
    && wget $DAEMON_COMMANDS \
    && unzip -o ubuntu16.04-daemon.zip \
    && unzip -o commands.zip \
    && mv $DAEMON_NAME /usr/local/bin/$DAEMON_NAME \
    && mv $CLI_NAME /usr/local/bin/$CLI_NAME \
    && chmod +x /usr/local/bin/satc* \
    && chmod +x blocks wallet start stop restart status commands \
    && mv blocks wallet start stop restart status commands /usr/local/bin/ \
    && rm ubuntu16.04-daemon.zip \
    && rm commands.zip
RUN cd /root && mkdir -p $CONF_DIR
#     && cd $CONF_DIR \
#     && wget $BOOTSTRAP \
#     && unzip -o bootstrapV3.zip \
#     && rm bootstrapV3.zip
# RUN cd $CONF_DIR \
#     && touch $CONF_FILE \
#     && echo "rpcuser=$RPC_USER" >> $CONF_FILE \
#     && echo "rpcpassword=$RPC_PASS" >> $CONF_FILE \
#     && echo "rpcallowip=$RPC_ALLOW_IP" >> $CONF_FILE \
#     && echo "rpcport=$RPC_PORT" >> $CONF_FILE \
#     && echo "listen=1" >> $CONF_FILE \
#     && echo "server=1" >> $CONF_FILE \
#     && echo "daemon=1" >> $CONF_FILE \
#     && echo "logtimestamps=1" >> $CONF_FILE \
#     && echo "masternode=0" >> $CONF_FILE \
#     && echo "port=$PORT" >> $CONF_FILE
# a few minor docker-specific tweaks
# see https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap
RUN set -xe \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L40-L48
	&& echo '#!/bin/sh' > /usr/sbin/policy-rc.d \
	&& echo 'exit 101' >> /usr/sbin/policy-rc.d \
	&& chmod +x /usr/sbin/policy-rc.d \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L54-L56
	&& dpkg-divert --local --rename --add /sbin/initctl \
	&& cp -a /usr/sbin/policy-rc.d /sbin/initctl \
	&& sed -i 's/^exit.*/exit 0/' /sbin/initctl \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L71-L78
	&& echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L85-L105
	&& echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean \
	&& echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean \
	&& echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L109-L115
	&& echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L118-L130
	&& echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L134-L151
	&& echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests

# delete all the apt list files since they're big and get stale quickly
RUN rm -rf /var/lib/apt/lists/*
# this forces "apt-get update" in dependent images, which is also good
# (see also https://bugs.launchpad.net/cloud-images/+bug/1699913)

# make systemd-detect-virt return "docker"
# See: https://github.com/systemd/systemd/blob/aa0c34279ee40bce2f9681b496922dedbadfca19/src/basic/virt.c#L434
RUN mkdir -p /run/systemd && echo 'docker' > /run/systemd/container

EXPOSE $PORT

# COPY ./docker-entrypoint.sh /
# ENTRYPOINT [ "/docker-entrypoint.sh" ]

# Define our command to be run when launching the container
CMD exec /bin/bash -c "$DAEMON_NAME -daemon & trap : TERM INT; tail -f /dev/null & wait"