# docker-satoshicoin_wallet
Satoshi v1.0.2.1 wallet running inside Ubuntu 16.04 base image docker container.

## ENV Variables to change
```
ENV RPC_USER docker_rpc_user
ENV RPC_PASS docker_rpc_password
ENV RPC_ALLOW_IP 0.0.0.0 // Generally 127.0.0.1 or localhost
```