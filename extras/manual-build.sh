#!/usr/bin/env bash

docker build --rm=true --squash -f ./2.7/Dockerfile -t e4f41c1134c84b85a7d3c6f0aff0f8fb ./2.7/ --pull=true;
docker build --rm=true --squash -f ./2.7-slim/Dockerfile -t f8b963616e8b47359180-0b6ae75ca24a ./2.7-slim/ --pull=true;
docker build --rm=true --squash -f ./3.4/Dockerfile -t 63eab9e691874ab8ac8145db0df58e38 ./3.4/ --pull=true;
docker build --rm=true --squash -f ./3.4-slim/Dockerfile -t 125cc75372b44443b410-d2d2381263a9 ./3.4-slim/ --pull=true;

docker tag e4f41c1134c84b85a7d3c6f0aff0f8fb registry.tstllc.net/llisk/alpine-python:2.7;
docker tag f8b963616e8b473591800b6ae75ca24a registry.tstllc.net/llisk/alpine-python:2.7-slim;
docker tag 63eab9e691874ab8ac8145db0df58e38 registry.tstllc.net/llisk/alpine-python:3.4;
docker tag 125cc75372b44443b410d2d2381263a9 registry.tstllc.net/llisk/alpine-python:3.4-slim;
docker tag 63eab9e691874ab8ac8145db0df58e38 registry.tstllc.net/llisk/alpine-python:latest;

docker push registry.tstllc.net/llisk/alpine-python:2.7;
docker push registry.tstllc.net/llisk/alpine-python:2.7-slim;
docker push registry.tstllc.net/llisk/alpine-python:3.4;
docker push registry.tstllc.net/llisk/alpine-python:3.4-slim;
docker push registry.tstllc.net/llisk/alpine-python:latest;
