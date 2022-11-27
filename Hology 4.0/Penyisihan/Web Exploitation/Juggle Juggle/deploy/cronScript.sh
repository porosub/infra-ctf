#!/usr/bin/env bash

docker kill php-juggling
docker rm php-juggling
docker run -d --name=php-juggling -p 8081:80/tcp php-juggling
