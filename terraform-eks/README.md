terraform fmt

terraform validate

terraform init -backend-config=./environments/dev/backend.txt

terraform plan 

terraform apply -var-file=./environments/dev/values.tfvars 

terraform destroy -var-file=./environments/dev/values.tfvars

## Change to other environment

terraform init tfplan -backend-config=./environments/pro/backend.txt -reconfigure



aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>


aws configure --profile developer

aws configure list-profiles


aws sts get-caller-identity --profile developer

```
vim ~/.aws/config

[profile eks-admin]
role_arn = arn:aws:iam::1111111111:role/eks-admin
source_profile = developer
``````

aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>

aws eks update-kubeconfig \
  --name rias-touch-cluster \
  --region eu-central-1 \
  --profile eks-admin


kubectl auth can-i "*" "*"

kubectl config get-contexts

$ terraform state rm module.eks.kubernetes_config_map_v1_data.aws_auth[0]


kubectl config delete-context arn:aws:eks:eu-central-1:953523290929:cluster/rias-touch-ecommerce-cluster






kubectl scale deployment inflate --replicas 5

kubectl logs -f -n "${KARPENTER_NAMESPACE}" -l app.kubernetes.io/name=karpenter -c controller

 Error: waiting for EKS Add-On (rias-touch-ecommerce-cluster:coredns) create: timeout while waiting for state to become 'ACTIVE' (last state: 'DEGRADED', timeout: 20m0s)
│ 
│   with module.eks.aws_eks_addon.this["coredns"],
│   on .terraform/modules/eks/main.tf line 390, in resource "aws_eks_addon" "this":
│  390: resource "aws_eks_addon" "this" {
│ 
╵
╷
│ Error: waiting for EKS Add-On (rias-touch-ecommerce-cluster:aws-ebs-csi-driver) create: timeout while waiting for state to become 'ACTIVE' (last state: 'DEGRADED', timeout: 20m0s)
│ 
│   with module.eks.aws_eks_addon.this["aws-ebs-csi-driver"],
│   on .terraform/modules/eks/main.tf line 390, in resource "aws_eks_addon" "this":
│  390: resource "aws_eks_addon" "this" {