#!/bin/bash

CLUSTER_NAME=jyablonski-cluster

echo "Creating kind cluster ${CLUSTER_NAME}"
kind create cluster --name $CLUSTER_NAME --config ./clusters/kind/kind-cluster.yml

# Step 1: Install the Custom Metrics Server
echo "Installing Custom Metrics Server"
kubectl apply -f ./services/metrics-server/deployment.yaml

# Step 2: Wait for the Metrics Server to be up and running
echo "Waiting for the Metrics Server to be ready..."
kubectl rollout status deployment/metrics-server -n kube-system

# Step 3: build nginx deployment
kubectl apply -f services/nginx/deployment.yaml

echo "Setup completed!"

# step 4: build airflow deployment
helm upgrade --install airflow apache-airflow/airflow \
    -f services/airflow/values.yaml

# step 5: build trino deployment
helm upgrade --install trino trino/trino \
    -f services/trino/values.yaml