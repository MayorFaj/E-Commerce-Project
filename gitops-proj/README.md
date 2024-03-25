kubectl kustomize overlays/dev --enable-helm | kubectl apply -f -

kubectl kustomize overlays/dev --enable-helm | kubectl delete -f -


- ExternalDNS
- Cert Manager
- Cluster Issuer
- nginx-ingress-controller
- argocd