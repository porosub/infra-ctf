#!/usr/bin/env bash

docker kill welcome
docker rm welcome
docker run -d --name=welcome -p 31337:31337/tcp welcome
