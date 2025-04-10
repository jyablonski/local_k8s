# Notes

[Example](https://github.com/raystack/optimus/blob/5874457c7bbe9ed08f41c8300e984ac7fc28f78a/dev/Makefile#L15)

## Kind

Kind is a tool written in Go for running Kubernetes locally using Docker. You can create a Cluster w/ `kind create cluster` and then add Kubernetes deployments to run within that cluster.

You can load local docker images of services that you want to run into the cluster by running commands such as `kind load docker-image my-custom-image:unique-tag`

- You must explicitly load these this way, or kind won't be able to access them.

It uses the concept of "nodes" to run your actual services.

- Locally, these nodes are just separate spaces of your CPU + Memory
- In production, nodes are different cloud compute servers

``` sh
go install sigs.k8s.io/kind@v0.27.0

kind load docker-image my-custom-image-0 my-custom-image-1

# can see what docker images are loaded within the cluster
docker exec -it my-node-name crictl images
```

## Helm

## Kubectl


Have to install a Metrics Server to be able to see resource utilization for all the nodes + pods, and to enable the use of HPA (Horizontal Pod Autoscaling). You also need to define resource minimums and maximums for CPU and Memory, or else this won't work.

``` sh

kubectl config get-contexts

kubectl config delete-context arn:aws:eks:us-east-1:680048507123:cluster/dev-cluster

kubectl config use-context kind-jyablonski-cluster

kubectl cluster-info

kubectl apply -f services/nginx/deployment.yaml

# the actual k8s deployments
kubectl get pods

# the servers running the k8s deployments
kubectl get nodes

# tells you the k8s deployments, their status, and what node they're being ran on
kubectl get pods -o wide

# create metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.2/components.yaml

# system pods
kubectl get pods -n kube-system

kubectl logs metrics-server-596474b58-g5tf8 -n kube-system

kubectl -n kube-system edit deployment metrics-server

kubectl top pods

kubectl autoscale deployment nginx --cpu-percent=50 --min=1 --max=10

kubectl get hpa

docker build -t kind-astro-image .

helm repo add apache-airflow https://airflow.apache.org

helm install apache-airflow

helm repo add astronomer https://helm.astronomer.io

helm install airflow astronomer/airflow

kubectl port-forward svc/airflow-webserver 8080:8080

# create a new one
helm install airflow astronomer/airflow -f services/airflow/values.yaml

# update the eixsting one with the new values.yaml
helm upgrade airflow astronomer/airflow -f services/airflow/values.yaml

helm uninstall

helm upgrade --install airflow apache-airflow/airflow -f services/airflow/values.yaml

kubectl port-forward svc/airflow-webserver 8080:8080

helm upgrade --install airflow apache-airflow/airflow \
    --set scheduler.extraVolumes[0].hostPath.path=services/airflow/dags \
    -f services/airflow/values.yaml

helm upgrade --install airflow apache-airflow/airflow \
    -f services/airflow/values.yaml

kubectl rollout restart deployment airflow-scheduler
kubectl rollout restart deployment airflow-webserver
kubectl rollout restart deployment airflow-statsd

kubectl get events --sort-by='.lastTimestamp'

helm repo add trino https://trinodb.github.io/charts/

helm search repo trino

helm install trino trino/trino --version 1.38.0

kubectl --namespace default port-forward svc/trino 8080:8080
```

left off at getting the example dag file - seems like might have to create own docker image and bake the dags + task code inside like that.

- https://airflow.apache.org/docs/helm-chart/stable/manage-dag-files.html