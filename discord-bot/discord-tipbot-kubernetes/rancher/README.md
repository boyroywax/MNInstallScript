# boxy-k8s Rancher 2.1 HA Set-up
Kubernetes Deployment Files

## Launching Rancher in Production - High Availability

* Cloud Host: Digital Ocean
* Rancher 3 Node Cluster 

## Installing HA 3 Node cluster using - https://rancher.com/docs/rancher/v2.x/en/installation/ha/
HA RKE deployments have more than one host with the role controlplane.

### Required local tools: 
* kubectl
* helm
* rke

### Digital Ocean Load Balancer
* TCP 80
* TCP 443
* TCP Port 80 Monitoring
* https://rancher.boxy.pw pointed to load balancer

### Digital Ocean Nodes
RKE Requirements: https://rancher.com/docs/rke/v0.1.x/en/os/
* Ubuntu 16.04 
* Docker 17.03.2
* 1 CPU/2GB RAM (I know I am going below spec of 2 CPU/4GB RAM)
* SSH RSA keys
* Private Networking Enabled

### Setting up Ubuntu 16.04 Node
#### Installing Docker 17.03.2
See [rancher-node-setup.sh](/node-setup.sh)
#### Manager Docker as Non Root: https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user
```text
SSH user - The SSH user used for node access must be a member of the docker group on the node:
```
### Installing kubernetes with RKE
```
rke up --config ./rancher-cluster.yml
```
Export the config to your kubectl
```
export KUBECONFIG=$(pwd)/kube_config_rancher-cluster.yml
```

### Installing tiller with helm to cluster
Create the tiller service account and start helm in tiller
```
kubectl -n kube-system create serviceaccount tiller

kubectl create clusterrolebinding tiller \
  --clusterrole cluster-admin \
  --serviceaccount=kube-system:tiller

helm init --service-account tiller
```

#### use lets encrypt for certs
Install the cert manager
```
helm install stable/cert-manager \
  --name cert-manager \
  --namespace kube-system \
  --version v0.5.2
```
Wait for cert-manager to be rolled out
```
kubectl -n kube-system rollout status deploy/cert-manager
```
Add the repo for stable/latest releases - https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/#add-the-helm-chart-repository
```
helm repo add rancher-<CHART_REPO> https://releases.rancher.com/server-charts/<CHART_REPO>
```
Install rancher with letsencrypt - chart repo is latest/stable
```
helm install rancher-stable/rancher \
  --name rancher \
  --namespace cattle-system \
  --set hostname=rancher.boxy.pw \
  --set ingress.tls.source=letsEncrypt \
  --set letsEncrypt.email=james@openaccess.cc
  ```
wait for rancher to be rolled out
```
kubectl -n cattle-system rollout status deploy/rancher
```

alternate install with rancher certs add the helm catalog for rancher generated certs - https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-rancher/#rancher-generated-certificates
```
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
```
install the helm catalog
```
helm install rancher-stable/rancher \
  --name rancher \
  --namespace cattle-system \
  --set hostname=boxy.pw
```


## Misc. Notes
* First trying RancherOS since Digital Ocean supports the pre-built image.
* RancherOS 1.5
* requires #cloud-config file
* Developing on macosx with vagrant is not recommended in docker-machine docs.
* Installed docker-machine on MacOSX using this command:
```bash
base=https://github.com/docker/machine/releases/download/v0.16.0 &&
curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/usr/local/bin/docker-machine &&
chmod +x /usr/local/bin/docker-machine
```