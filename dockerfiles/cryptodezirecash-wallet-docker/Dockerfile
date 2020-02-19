#  Build CDZC from source and keep alive
FROM ubuntu:18.04
ENV SOURCE_ORIGIN https://github.com/cryptodezire/CryptoDezireCash.git
ENV COMMIT 150652b14c163d702dd57580f5021405a6fc2fbd
ENV EXT_PORT 35601
ENV RPC_PORT 35602
ARG SOURCE_LOCAL_ROOT=/root/CryptoDezireCash
ARG DAEMON_NAME=cryptodezirecashd
ARG DATA_FOLDER=/.cryptodezirecash
WORKDIR /root
RUN apt-get update \
    #  basic build tools
    && apt-get install -y --no-install-recommends \
       build-essential \
       bsdmainutils \
       libssl-dev \
       libtool \
       openssl \
       pkg-config \
       wget \
       python-dev \
       python3 \
       autotools-dev \
       software-properties-common \
       autoconf \
       automake \
       libzmq3-dev \
       libminiupnpc-dev \
       libevent-dev \
       libgmp-dev
    #  select boost libraries
RUN apt-get install -y --no-install-recommends \
       libboost-chrono-dev \
       libboost-filesystem-dev \
       libboost-program-options-dev \
       libboost-system-dev \
       libboost-test-dev \
       libboost-thread-dev
    #  wallet db v4.8 repository
RUN add-apt-repository ppa:bitcoin/bitcoin && apt-get update
    #  wallet db v4.8 install
RUN apt-get install -y --no-install-recommends libdb4.8-dev libdb4.8++-dev
    #  Git source code
RUN apt-get install -y --no-install-recommends \
       ca-certificates \
       git 
RUN git clone ${SOURCE_ORIGIN}
RUN cd ${SOURCE_LOCAL_ROOT} \
    #  Use a GREEN commit
    && git checkout ${COMMIT}
    #  build the wallet
RUN cd ${SOURCE_LOCAL_ROOT}/src/leveldb \
    && wget https://github.com/google/leveldb/archive/v1.18.tar.gz \
    && tar xfv v1.18.tar.gz \
    && cp leveldb-1.18/Makefile ${SOURCE_LOCAL_ROOT}/src/leveldb/ \
    && cd ${SOURCE_LOCAL_ROOT}/src \
    && chmod +x leveldb/build_detect_platform
RUN cd ${SOURCE_LOCAL_ROOT} && \
    ./autogen.sh && \
    ./configure --enable-upnp-default --with-unsupported-ssl && \
    make && \ 
    make install
    #  At this point, wallet should be useable.
    #  create the datadir to mount PVC
RUN mkdir /root/${DATA_FOLDER}
#  a few minor docker-specific tweaks
#  see https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap
RUN set -xe \
	\
#  https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L40-L48
	&& echo '#!/bin/sh' > /usr/sbin/policy-rc.d \
	&& echo 'exit 101' >> /usr/sbin/policy-rc.d \
	&& chmod +x /usr/sbin/policy-rc.d \
	\
#  https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L54-L56
	&& dpkg-divert --local --rename --add /sbin/initctl \
	&& cp -a /usr/sbin/policy-rc.d /sbin/initctl \
	&& sed -i 's/^exit.*/exit 0/' /sbin/initctl \
	\
#  https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L71-L78
	&& echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup \
	\
#  https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L85-L105
	&& echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean \
	&& echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean \
	&& echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean \
	\
#  https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L109-L115
	&& echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages \
	\
#  https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L118-L130
	&& echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes \
	\
#  https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L134-L151
	&& echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests
#  delete all the apt list files since they're big and get stale quickly
RUN rm -rf /var/lib/apt/lists/*
#  this forces "apt-get update" in dependent images, which is also good
#  (see also https://bugs.launchpad.net/cloud-images/+bug/1699913)
#  make systemd-detect-virt return "docker"
#  See: https://github.com/systemd/systemd/blob/aa0c34279ee40bce2f9681b496922dedbadfca19/src/basic/virt.c#L434
RUN mkdir -p /run/systemd && echo 'docker' > /run/systemd/container
EXPOSE ${EXT_PORT}
EXPOSE ${RPC_PORT}
# Define our command to be run when launching the container
CMD exec /bin/bash -c "${DAEMON_NAME} -daemon & trap : TERM INT; sleep infinity & wait"
