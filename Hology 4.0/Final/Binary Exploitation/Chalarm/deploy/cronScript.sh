#!/usr/bin/env bash

docker kill chalarm
docker rm chalarm
docker run -d --name=chalarm -p 33333:33333/tcp chalarm

