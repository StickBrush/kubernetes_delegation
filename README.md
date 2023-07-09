# kubernetes_delegation
## Create miniKube: 
  1. Download: https://kubernetes.io/releases/download/
  2. Create cluster with 3 nodes: `minikube start --nodes 3 --no-vtx-check` or `minikube node add` to add a new node

## Deploy the pod
`kubectl apply -f [YAML file name]`

## Forward the local port to a pod’s port
`kubectl port-forward service/<my-service <local port>:<Kubernetes port>`     
For example: `kubectl port-forward pod/director 8080:8888` OR `kubectl port-forward service/director-service 8080:8888`

## Add label to node
Add label to node which is used to assign replica to a certain node: `kubectl label nodes <node name> node=<assign number>`
Ex: "kubectl label nodes minikube-m02 node=2"
Check label: `kubectl get nodes --show-labels`

## Some Useful Command:
1. Check status: `minikube status` or `kubectl get all`
2. Check service: `kubectl describe service [service name]`
3. Check pod: `kubectl describe pod [pod name]` OR `kubectl get pods -o wide`
4. Delete pod and restart a new one: `kubectl delete pod [pod name]`
5. Delete deployment and delete related pods: `kubectl delete deployment [name]`
