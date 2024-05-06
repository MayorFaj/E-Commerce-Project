# Cost Optimisation on EKS cluster using Karpenter

Karpenter is an open-source, Kubernetes-native cluster autoscaler designed to optimize cluster resources efficiently. It automatically adjusts the number of nodes in a Kubernetes cluster based on workload demand, ensuring optimal resource utilization and cost efficiency.

Karpenter continuously monitor the cluster for pending pods and scale up the cluster by provisioning new nodes to satisfy the pod's requirements.
In this article, we will install karpenter and see how Karpenter provisions nodes when we scale application pods and they're in a pending state.

# Configuration of Karpenter on AWS EKS with Terraform;

## Create IAM roles and attach the required policies to the role;
We first need to create two new IAM roles for **nodes provisioned with Karpenter** and the **Karpenter controller**.

- Create policy and attach to role to be used by nodes provisioned with Karpenter
- create an IAM role that the Karpenter controller will use to provision new instances

Note: The `SSMManagedInstanceCore` permission is used by Karpenter to fetch the latest EKS optimised AMI from the public SSM parameter store.

## Add tags to subnets and security groups
- Add tags to our nodegroup subnet

- Add tags to our security groups

## Update aws-auth ConfigMap
- kubectl edit configmap aws-auth -n kube-system

```
- groups:
  - system:bootstrappers
  - system:nodes
  rolearn: arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:role/KarpenterNodeRole-${CLUSTER_NAME}
  username: system:node:{{EC2PrivateDNSName}}
```

## Deploy Karpenter
### Set node affinity

```
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: karpenter.sh/nodepool
          operator: DoesNotExist
      - matchExpressions:
        - key: eks.amazonaws.com/nodegroup
          operator: In
          values:
          - ${NODEGROUP}
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - topologyKey: "kubernetes.io/hostname"
```

We can now generate a full Karpenter deployment yaml from the Helm chart

## Create the NodePool CRD

## Create default NodePool
- We need to create a default NodePool so Karpenter knows what types of nodes we want for unscheduled workloads.

## Limitations

Lack of integration with some cloud providers: Karpenter is designed to work with Kubernetes, but it may not integrate seamlessly with all cloud providers. This can make it more challenging to deploy Karpenter in certain environments.

Despite these limitations, Karpenter is still an excellent choice for many Kubernetes users. Its ability to optimize resource utilization, customize scaling behaviors, and reduce costs make it a compelling option for many organizations.
