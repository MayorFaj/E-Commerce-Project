tags = {
  Environment = "dev"
  "kubernetes.io/cluster/${local.name}-cluster" = "shared"
  GithubRepo  = "terraform-aws-eks" 
  GithubOrg   = "terraform-aws-modules"
}