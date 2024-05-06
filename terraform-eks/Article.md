Create Node IAM role and attach policies

Worker nodes need at least two managed policies, 
`AmazonEKSWorkerNodePolicy` and `AmazonEC2ContainerRegistryReadOnly`, to be created, join the EKS cluster and work properly.

cat <<EOF > nodegroup-trust-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
}
EOF

aws iam create-role \
  --assume-role-policy-document file://nodegroup-trust-policy.json \
  --role-name Kubedemy_EKS_Managed_Nodegroup_Role \
  --tags Key=owner,Value=kubedemy

To attach necessary policies, run these commands:

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy \
  --role-name Kubedemy_EKS_Managed_Nodegroup_Role

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly \
  --role-name Kubedemy_EKS_Managed_Nodegroup_Role


aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
  --role-name Kubedemy_EKS_Managed_Nodegroup_Role
