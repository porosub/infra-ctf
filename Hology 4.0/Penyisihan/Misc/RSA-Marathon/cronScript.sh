#!/usr/bin/env bash

docker kill marathon
docker rm marathon
docker run -d --name=marathon -p 36998:36998/tcp marathon
