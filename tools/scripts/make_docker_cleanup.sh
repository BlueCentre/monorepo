#!/usr/bin/env bash

# See: https://www.digitalocean.com/community/tutorials/how-to-remove-docker-images-containers-and-volumes

# Remove all container "example" images 
docker images -a | grep "bazel" | awk '{print $3}' | xargs docker rmi -f

# Remove all exited containers
docker rm $(docker ps -a -f status=exited -q)
