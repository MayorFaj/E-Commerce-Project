```
helm upgrade --install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost --create-namespace

```

```
kubectl port-forward --namespace kubecost svc/kubecost-cost-analyzer 9090, then accessing http://localhost:9090
```


