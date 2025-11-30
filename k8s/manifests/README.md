# Kubernetes Manifests

This directory contains plain YAML Kubernetes manifests for deploying the nginx application.

## Files

- `namespace.yaml` - Creates the default namespace
- `deployment.yaml` - Deploys nginx with 2 replicas
- `service.yaml` - Creates a LoadBalancer service to expose nginx

## Usage

After the EKS cluster is created and kubectl is configured:

```bash
# Apply all manifests
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Or apply all at once
kubectl apply -f .

# Check status
kubectl get pods -n default
kubectl get service nginx -n default
```

## Customization

Edit the YAML files directly to customize:
- Number of replicas
- Container image
- Resource limits
- Service type (LoadBalancer, NodePort, ClusterIP)

