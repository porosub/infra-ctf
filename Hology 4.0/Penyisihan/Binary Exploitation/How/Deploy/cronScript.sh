#!/usr/bin/env bash

docker kill how
docker rm how
docker run -d --name=how -p 37013:37013/tcp how

