# monitoring argoCD n kubernetes project repo

## Prerequisites

- Docker
- minikube
- kubectl
- helm
- argocd CLI

## ArgoCD Setup

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available --timeout=120s deployment/argocd-server -n argocd
```

Get password

```bash
argocd admin initial-password -n argocd
```

### Port-forward ArgoCD

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
argocd login localhost:8080 --username admin --insecure
```

### Deploy apps

```bash
kubectl apply -f argocd/monitoring-app.yaml
kubectl apply -f argocd/demo-app.yaml
kubectl apply -f argocd/grafana-dashboards-app.yaml
```

### Access services

```bash
# Grafana
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80

# Prometheus
kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090

# Alertmanager
kubectl port-forward svc/monitoring-kube-prometheus-alertmanager -n monitoring 9093:9093

# ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## Alerts

| Alert | Condition  | Severity |
|---|---|---|
| PodCrashLooping | Pod restart rate > 0 for 1 min | critical |
| HighNodeCPU | Node CPU > 80% for 2 min | warning  |

### Trigger PodCrashLooping

```bash
kubectl patch deployment demo-app -n demo --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/command","value":["sh","-c","exit 1"]}]'
```

### Restore

```bash
kubectl rollout undo deployment/demo-app -n demo
```

## Grafana Dashboard

### Cluster Overview dashboard shows

- Node CPU usage %
- Node memory usage %
- Demo app CPU usage
- Demo app pod restarts

As well as standard Helm charts
