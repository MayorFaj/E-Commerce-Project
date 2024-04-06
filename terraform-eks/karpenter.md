Setup that we will need to do is to update our EKS IAM mappings to allow Karpenter nodes to join the cluster:

To do that we have to modify the aws-auth ConfigMap in the cluster.

```
kubectl edit configmap aws-auth -n kube-system

kubectl describe configmap -n kube-system aws-auth

```

 ```
- groups:
    - system:bootstrappers
    - system:nodes
  rolearn: arn:aws:iam::953523290929:role/KarpenterNodeRole-rias-touch-cluster
  username: system:node:{{EC2PrivateDNSName}}
 ```


### Instance types
Instance	vCPU*	 Mem(GiB) Network Performance

t2.xlarge	4	    	16	 EBS-Only	Moderate
t2.medium	2	        4	 EBS-Only   Low to Moderate
t3.medium	2	        4	EBS-Only    Up to 5
t3.small	2           2	EBS-Only    Up to 5
t3.large	2	        8	EBS-Only	Up to 5
t3.medium	2	        4	EBS-Only    Up to 5




### Using eks NODE VIEWER
```
# Standard usage
eks-node-viewer
# Karpenter nodes only
eks-node-viewer --node-selector karpenter.sh/nodepool
# Display both CPU and Memory Usage
eks-node-viewer --resources cpu,memory
# Display extra labels, i.e. AZ
eks-node-viewer --extra-labels topology.kubernetes.io/zone
# Sort by CPU usage in descending order
eks-node-viewer --node-sort=eks-node-viewer/node-cpu-usage=dsc
# Specify a particular AWS profile and region
AWS_PROFILE=myprofile AWS_REGION=us-west-2
```

- eks-node-viewer supports some custom label names that can be passed to the --extra-labels to display additional node information.
```
eks-node-viewer/node-age - Age of the node
eks-node-viewer/node-cpu-usage - CPU usage (requests)
eks-node-viewer/node-memory-usage - Memory usage (requests)
eks-node-viewer/node-pods-usage - Pod usage (requests)
eks-node-viewer/node-ephemeral-storage-usage - Ephemeral Storage usage (requests)
```

## Scaling Application

1. Now, let's scale the deployment from 0 to 5 replicas

`kubectl scale deployment inflate --replicas 5`

2. Check the logs of Karpenter (you should see this log in one of the karpenter controller pod logs).
- Note: LAbels on karpenter
**app.kubernetes.io/instance=karpenter app.kubernetes.io/name=karpenter pod-template-hash=9b954d6c4**
`kubectl -n karpenter logs -l app.kubernetes.io/name=karpenter`
`kubectl logs -l app.kubernetes.io/instance=karpenter -n karpenter | jq '.'`
`kubectl logs -l app.kubernetes.io/instance=karpenter -n karpenter | grep 'launched nodeclaim' | jq '.'`
3. See in the eks-node-viewer terminal, you will see one node in the below case c6a.2xlarge (that has 8 vCPU) has been created by Karpenter

`eks-node-viewer`

4. Check the nodes managed by the Karpenter NodePool we created

`kubectl get nodes -l Environment=tooling`

5. We can also check the metadata added to the node created by Karpenter:

`kubectl get node -l Environment=tooling -o json | jq -r '.items[0].metadata.labels'`



        {
            "Sid": "ExplicitSelfRoleAssumption",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "ArnLike": {
                    "aws:PrincipalArn": "arn:aws:iam::953523290929:role/KarpenterNodeRole-rias-touch-cluster"
                }
            }
        },