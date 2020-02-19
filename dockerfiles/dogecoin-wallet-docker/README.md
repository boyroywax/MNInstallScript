# DogeCoin can haz Dockerfiles

## Containers for the Cloud. 
- Designed for use with BTCPayServer
- Also can be used stand-alone.

## Design Goals:
- Easy to update
- Slim and light
- Bootstrapped with Current Blockchain.

## To-do:
- Create Multistage build for Ubuntu.
- GUI build for Ubuntu
- Alpine builds
- Armv8, arm32v7, and armhf builds

## Notes:
- libdb5.3 is substituted for 5.1

## Test Running the container
```bash
docker run -v /Users/jdev/Documents/GitHub/docker-dogecoin/doge:/root/.dogecoin --rm -it boyroywax/dogecoin-ubuntu1804:latest
```
Replacing ```/Users/jdev/Documents/GitHub/docker-dogecoin/doge``` with the location to the local data directory you would like to keep the dogecoin blockchain.