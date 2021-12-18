#!/usr/bin/env bash

docker kill tag
docker rm tag
docker run -d --name=tag -p 3446:3445/tcp tag

