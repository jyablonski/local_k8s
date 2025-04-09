#!/bin/bash
SERVICE=$1
TAG=local

docker build -t $SERVICE:$TAG ./services/$SERVICE
kind load docker-image $SERVICE:$TAG --name dev-cluster

helm upgrade --install $SERVICE ./charts/$SERVICE \
  --values clusters/kind/values/dev-values.yaml \
  --set image.tag=$TAG