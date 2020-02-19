# NFS Server Ubuntu 16.04 Setup
Goal: setup up nfs server for kubernetes persistent data storage colume

## NFS-server Setup
### Environment
* Digital Ocean Ubuntu 16.04 x64 VPS
* 100 GB block storage volume mounted to VPS
* insecure,all_squash need added to etc/exports to work with anonymous pods.

### Client Setup for testing
* Used the following syntax to add nfs-server to etc/fstab
```
sudo mkdir -p /mnt
sudo mount server_IP:/NFS_directory_on_server /mnt
sudo nano /etc/fstab
nfs-server:/   /mnt   nfs4    _netdev,auto  0  0
sudo ufw allow from any to any port nfs
```

## Resources
* https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-16-04
* https://www.dummies.com/computers/operating-systems/linux/how-to-share-files-with-nfs-on-linux-systems/
* https://linux.die.net/man/5/exports
* https://serverfault.com/questions/240897/how-to-properly-set-permissions-for-nfs-folder-permission-denied-on-mounting-en
* https://websiteforstudents.com/setup-nfs-mounts-on-ubuntu-16-04-lts-servers-for-client-computers-to-access/
* https://rancher.com/docs/rancher/v2.x/en/k8s-in-rancher/volumes-and-storage/examples/nfs/

