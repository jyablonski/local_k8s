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

kubectl rollout restart deployment nginx

# brute force option - usually you can just rollout restart the mfer
kubectl delete pods -l app=nginx

kubectl delete deployment nginx
kubectl delete service nginx-service

kubectl get pods -o wide

# kubectl apply -f services/nginx/deployment.yaml
# kubectl apply -f services/nginx/service.yaml
# kubectl apply -f services/nginx/ingress.yaml

# apply all 3 at once
kubectl apply -f services/nginx/
kubectl delete -f services/nginx/

kubectl logs -l app.kubernetes.io/name=traefik
```

left off at getting the example dag file - seems like might have to create own docker image and bake the dags + task code inside like that.

- https://airflow.apache.org/docs/helm-chart/stable/manage-dag-files.html

``` mermaid
graph LR
    A[Kind Worker Node] -->|NodePort 30080 exposed via hostPort| B[Traefik Ingress Controller]
    A[Kind Worker Node] -->|NodePort 30081 exposed via hostPort| B[Traefik Ingress Controller]
    B[Traefik Ingress Controller] -->|Forward Traffic on NodePort 30080| C[Local Machine Port 80]
    B[Traefik Ingress Controller] -->|Forward Traffic on NodePort 30081| D[Local Machine Port 8080]
    style A fill:#f9f,stroke:#333,stroke-width:4px
    style B fill:#bbf,stroke:#333,stroke-width:4px
    style C fill:#cfc,stroke:#333,stroke-width:4px
    style D fill:#cfc,stroke:#333,stroke-width:4px

```

### K8s Concepts

#### Cluster Roles

- RBAC (Role-Based Access Control) Roles:  
  In Kubernetes, RBAC allows you to control access to the Kubernetes API by defining roles and assigning them to users, groups, or service accounts. These roles specify what actions are allowed on which resources (e.g., pods, deployments, namespaces).
  
- Cluster Roles vs. Service Accounts:  
  - Cluster Role: A ClusterRole defines a set of permissions for accessing and manipulating resources at a cluster level. Cluster roles can be used across all namespaces (e.g., granting permissions for all pods in the cluster).
  - Service Account: A ServiceAccount is used by pods to interact with the Kubernetes API server. A service account is tied to a pod and allows it to access resources, based on the roles assigned to it. It doesn't define permissions on its own but is granted permissions via RBAC (e.g., assigning a ClusterRole to the service account).
  
  Key difference: A ClusterRole defines what actions are allowed, while a ServiceAccount is an identity under which a pod runs, potentially having access to resources defined by roles (ClusterRoles, RoleBindings).

You create Service Accounts that you assign to Deployments for Pods to have various K8s permissions, and then you specify what permissions they actually have by assigning Cluster Roles.

- You tie the 2 together via Role Bindings

#### Deployments

- Image:  
  A Kubernetes Deployment specifies which container image to use. The image is the executable environment (e.g., Docker image) for the application. You define the image version and any environment variables or configurations for the container in the deployment YAML file.
  
- Resource Minimum + Maximum Configurations:  
  You can define resource limits for a container inside a Deployment. This involves setting CPU and memory requests (minimum resources the container needs) and limits (maximum resources the container can use). For example:
  ```yaml
  resources:
    requests:
      memory: "64Mi"
      cpu: "250m"
    limits:
      memory: "128Mi"
      cpu: "500m"
  ```
  This helps Kubernetes manage resources more efficiently.

- Ports:  
  In a deployment, you define which ports are exposed by the containers to allow communication. For example, if your app runs on port `9000` inside the container, you would specify this in the `ports` section of your deployment YAML. 
  - This is the container port the application inside the pod will use to listen for traffic.
  - `- containerPort: 9000  # Exposing port 9000 inside the container` - This tells Kubernetes that the application inside the container is listening on port 9000.


- Service Account:  
  The ServiceAccount is used by pods to interact with the Kubernetes API server. A service account can be associated with a pod to define the set of permissions the pod has in terms of interacting with the Kubernetes cluster.  
  - For example, if you want your pod to interact with certain Kubernetes resources (like pods, secrets, etc.), you would create a service account and assign it a Role or ClusterRole to grant the necessary permissions.

  To clarify your specific AWS/EKS scenario:  
  If you're hosting on EKS (Elastic Kubernetes Service) and want your pods to use specific IAM roles, you can leverage IAM Roles for Service Accounts (IRSA). This allows you to associate an IAM role with a Kubernetes ServiceAccount, and then allow the pod to assume the IAM role (with the permissions attached to that IAM role) when interacting with AWS services (e.g., S3, DynamoDB).

#### Services

- Service:  
  A Service in Kubernetes is a resource that abstracts access to a set of pods. It provides a stable endpoint (IP and port) for clients to interact with, regardless of which pods are actually running or their dynamic IPs.
  
  - The `selector` in a Service defines which pods are targeted by the service. The selector is a label query, where you specify the labels on the pods that the service will route traffic to. For example, if you have a service that should only target pods with the label `app=frontend`, you would define a selector like:
    ```yaml
    selector:
      app: frontend
    ```
  
  - A Service exposes specific ports on the pods. If your application runs on port 8080, the service definition will map the pod's port 8080 to the service port.


  - In the Service, you define a port to expose traffic and a targetPort to forward traffic to the correct port inside the container.
     - If you want users to access your service on port 8000, but your container is actually serving the app on port 9000, you would define the Service like this:

    ``` yaml
    apiVersion: v1
    kind: Service
    metadata:
    name: my-api-service
    spec:
    ports:
        - port: 8000         # This is the port that external traffic will hit (service port)
          targetPort: 9000   # This is the port inside the container to forward the traffic to
    selector:
        app: my-api
    ```
#### Ingress

- Ingress:  
  An Ingress is a collection of rules that allows inbound connections to reach the cluster services. It typically manages HTTP and HTTPS traffic, handling routing and traffic management for web services.

  - How it works: An ingress controller (like Traefik, Nginx, or HAProxy) listens for requests to the defined host and path in the ingress resource and then forwards the request to the appropriate service in the cluster.
  
  - For example, if you have a service for your frontend app and want to expose it on `http://localhost`, you would define an Ingress that routes traffic to the service based on the path.

  - Path-based routing: You can define rules based on the URL path, such as:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
name: my-api-ingress
spec:
rules:
- host: my-api.example.com  # Optional: If you want a domain to point to this API
    http:
    paths:
        - path: /api/v1         # Path users will hit, like 'my-api.example.com/api/v1'
        pathType: Prefix
        backend:
            service:
            name: my-api-service
            port:
                number: 8000  # Port of the service that will handle the traffic
```

    In this case, traffic going to `http://localhost/api/v1` will be forwarded to the `my-api-service` on port 8000.

  - SSL/TLS: If you're exposing a service over HTTPS, you can configure SSL certificates in the ingress to secure the traffic.
  
  - The Ingress doesn't need to know about the container's port (9000) directly. It just forwards traffic to the Service, and the Service handles routing it to the correct port inside the container (targetPort: 9000).

---

### Cleaned Up Summary:

so for deployment, i can expose a container port. so if i have an api running on port 9000, ill expose port 9000 in that deployment yaml file.

for a service, i specify a port to expose traffic to the outside world. so if i want outside traffic to be able to hit my service at port 8000, ill specify `port: 8000` and `targetPort: 9000` so when users hit port 8000 for the app, they'll actually be receiving content served from the pod running the app which is pulling from port 9000 where the container is serving the app.

for ingress, if i want users to be able to hit my api at `/api/v1` to make requests, then i'll specify that path and specify `port: 8000` as this is what was setup in the service file. and then users will be able to hit my api service at `/api/v1` instead of having to specify the port number.