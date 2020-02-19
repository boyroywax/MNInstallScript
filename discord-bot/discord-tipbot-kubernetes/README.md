# Crypto-Currency Cloud-native Discord Tip Bot
Abstract: Discord Crypto Currency Tip Bot for the Cloud.  Cluster designed for deployment of Discord Tip Bot and crypto wallet daemons along with all other needed services.

## Goal
Full service cluster environment.

## Planned Features:
- Kubernetes managed Cryptocurrency TipBot Cluster
- Email 2FA
- Standard Wallet Funcions
- Coin/Chain Swap Ready
- Social Tipping Features: Rain, Soak, Games, ETC.
- Web panel for user access
- Web admin panel and dashboard

## Process
1. DONE - Update Discord Bot Core to Asyncio Python 3.7
2. DONE - Containerize bot, wallet, and redis into cluster
3. DONE - Provision Rancher environment for cluster management
4. DONE - Configure CI pipeline
5. Add features to Tipbot
6. Create web admin panel

### Kubernetes Environment
* 3 Node HA cluster dedicated to Rancher 2.1
* 3 Node Sandbox cluster managed by Rancher cluster
* 100GB NFS File Server

### Development Tools
- Version Control: boyroywax [GitHub](https://github.com/boyroywax/ccloudbot)
- Local Virtual Env for testing: Anaconda (conda)
- Coding Language: Python 3.7.2
- GUI Editor: Microsoft Visual Studio Code
- Testing Framework: pytest package
- Asyncio Concurrent Development
- Logging: logging module
- f. strings
- KV store: Redis
- Database: Postgres
- Web Dashboard: Django
- Chat Interface: [Discord.py](https://discordpy.readthedocs.io/en/latest/migrating.html)
- HTTP and REST: Requests package
- Container Environmnet: Docker + Kubernetes + Rancher
- Continuous Integration: Rancher Pipeline
- Docker for Desktop (Mac)

### Development Notes

---

#### Use python 3.7 async/await BUT cannot with latest discord.py package. Forced to use python 3.6 - https://github.com/Rapptz/discord.py/issues/1249
SOLUTION - For Python 3.7, the async branch of discord.py is used. - https://github.com/Rapptz/discord.py/pull/1500
```
pip install --no-deps https://github.com/Rapptz/discord.py/archive/async.zip
```

---

#### Install kompose to convert docker-compose to kubectl manifest files - https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/
```
curl -L https://github.com/kubernetes/kompose/releases/download/v1.16.0/kompose-darwin-amd64 -o kompose
```
or on MAC OSX
```
brew install kompose
```
after you have your docker-compose.yaml file - https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/
```
kompose up
```
Copy those generated files to k8s-spec/ folder

---

#### Async Redis and Python 3.7
I attemtped to implement aioredis but failed.  Getting an error that hiredis cannot be pip'd to my Python3.6-alpine container - https://pythoncomputing.com/blog/redis-in-asyncio-land.html 

SOLUTION - for asycio redis on python 3.7 - https://github.com/jonathanslenders/asyncio-redis
```
pip install asyncio_redis
```

All data pushed to redis server is string format! - https://www.thegeekstuff.com/2016/05/redis-string-commands/
HashMap keys cannot be duplicates of normal key-value pairs.

---

#### gitignore files stopped working
SOLUTION - https://stackoverflow.com/questions/25436312/gitignore-not-working
```
git rm -rf --cached .
git add .
```

---

#### Add persistent volumes to cluster. - https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/ * https://kubernetes.io/docs/concepts/storage/persistent-volumes/
- redis - to store db
- wallet - to store wallet.dat and blockchain files
- bot - to store log files, look into upgrade logging.
- Need to learn more about kubernetes and open stack for provisioning persistent storage.
- Why Does OpenStack use CentOS?
  
SOLUTION - NFS Storage Server. See https://github.com/boyroywax/boxy-k8s/nfs-server

---

#### Rancher CI pipeline configuration
* https://github.com/rancher/pipeline-example-go/blob/master/deployment.yaml

---

#### Logging in Python inside Docker Containers
Logging must be passed to dev/stdout or dev/stderr to be easily accessible using docker
```
import logging
import sys

root = logging.getLogger()
root.setLevel(logging.DEBUG)

handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
root.addHandler(handler)
```
* https://stackoverflow.com/questions/14058453/making-python-loggers-output-all-messages-to-stdout-in-addition-to-log-file

Python 3.7.2 Docs for logging - https://docs.python.org/3/library/asyncio-dev.html
Discord Docs for logging - https://discordpy.readthedocs.io/en/latest/logging.html

---

#### Django for web apps - Admin Panel and User UI.
* Create different docker files for different uses - https://blog.devartis.com/django-development-with-docker-a-completed-development-cycle-7322ad8ba508

Celery task queue - http://docs.celeryproject.org/en/latest/getting-started/first-steps-with-celery.html#first-steps

Depends on RabbitMQ - Messaging Broker
* 5 Minute Intro to RabbitMQ - https://www.youtube.com/watch?v=deG25y_r6OY
* RabbitMQ in Rancher - https://rancher.com/setting-up-a-rabbitmq-container-using-rancher/


---

## Resources (Unordered)
* Incomplete Node.js discord container tutorial - https://github.com/truency/docker-discordjs-tutorial
* Skaffold Documentation - https://skaffold.dev/docs/references/cli/
* Discord.py alternative docs - https://discordpy.readthedocs.io/en/rewrite/intro.html
* Well maintained Python3.7 Async Discord Bot - https://gitlab.com/delta1512/grc-wallet-bot/tree/master
* Force ubuntu container to stay alive - https://stackoverflow.com/questions/31870222/how-can-i-keep-container-running-on-kubernetes
* Basic Kubernetes - https://zihao.me/post/creating-a-kubernetes-cluster-from-scratch-with-kubeadm/
