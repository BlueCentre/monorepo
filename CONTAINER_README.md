# Reference

## minikube

https://skaffold.dev/docs/environment/local-cluster/
```
eval $(minikube -p minikube docker-env)
minikube image ls --format='table'
```

## docker

```
docker images
docker ps -a
```

## containerd

/var/run/docker/containerd/containerd.toml (default: /etc/containerd/config.toml)
```
sudo ctr --address /var/run/docker/containerd/containerd.sock plugins ls
sudo ctr --address /var/run/docker/containerd/containerd.sock ns ls
sudo ctr --address /var/run/docker/containerd/containerd.sock images ls
sudo ctr --address /var/run/docker/containerd/containerd.sock containers ls
sudo ctr --address /var/run/docker/containerd/containerd.sock --namespace moby containers ls

```
