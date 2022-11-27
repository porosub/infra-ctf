#!/usr/bin/env bash

docker kill bog
docker rm bog
docker run -d --name=bog -p 34465:34465/tcp bog

