# Helm Chart for nginx Application

This Helm chart deploys an nginx application on Kubernetes.

## Installation

After the EKS cluster is created and kubectl is configured:

```bash
# Install with default values
helm install my-app .

# Install with custom values
helm install my-app . --set replicaCount=3

# Install with custom values file
helm install my-app . -f custom-values.yaml
```

## Upgrading

```bash
# Upgrade with new values
helm upgrade my-app . --set replicaCount=5

# Upgrade with values file
helm upgrade my-app . -f custom-values.yaml
```

## Uninstallation

```bash
helm uninstall my-app
```

## Customization

Edit `values.yaml` to customize:
- Number of replicas
- Container image and tag
- Resource requests and limits
- Service type and ports
- Health check probes

## Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `2` |
| `image.repository` | Container image repository | `nginx` |
| `image.tag` | Container image tag | `alpine` |
| `service.type` | Kubernetes service type | `LoadBalancer` |
| `service.port` | Service port | `80` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |

