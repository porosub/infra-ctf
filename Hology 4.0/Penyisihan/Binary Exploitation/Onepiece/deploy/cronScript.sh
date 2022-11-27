#!/usr/bin/env bash

docker kill onepiece
docker rm onepiece
docker run -d --name=onepiece -p 38823:38823/tcp onepiece
