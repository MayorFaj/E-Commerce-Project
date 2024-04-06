tags = {
  Environment = "dev"
  kubernetes.io/os                              =  "linux"
  "kubernetes.io/cluster/${local.name}-cluster" = "shared"
  GithubRepo  = "terraform-aws-eks" 
  GithubOrg   = "terraform-aws-modules"
}