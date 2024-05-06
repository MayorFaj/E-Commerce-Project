---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inflate
spec:
  replicas: 8
  selector:
    matchLabels:
      app: inflate
  template:
    metadata:
      labels:
        app: inflate
    spec:
      nodeSelector:
        Environment: tooling
      terminationGracePeriodSeconds: 0
      containers:
        - name: inflate
          image: public.ecr.aws/eks-distro/kubernetes/pause:3.2
          resources:
            requests:
              memory: 500Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inflate2
spec:
  replicas: 5
  selector:
    matchLabels:
      app: inflate
  template:
    metadata:
      labels:
        app: inflate
    spec:
      nodeSelector:
        Environment: production
      terminationGracePeriodSeconds: 0
      containers:
        - name: inflate
          image: public.ecr.aws/eks-distro/kubernetes/pause:3.2
          resources:
            requests:
              memory: 1Gi
      tolerations:
      - key: Environment
        operator: "Equal"
        value: "production"
        effect: "NoSchedule"