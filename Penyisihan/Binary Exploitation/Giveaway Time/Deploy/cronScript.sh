#!/usr/bin/env bash

docker kill giveaway
docker rm giveaway
docker run -d --name=giveaway -p 31420:31420/tcp giveaway
