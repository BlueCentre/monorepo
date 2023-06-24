#!/usr/bin/env bash

docker images -a | grep "flyr" | awk '{print $3}' | xargs docker rmi -f
