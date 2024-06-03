Prerequisites: 
## cluster access

In order to make ArgoCD manage other clusters, we need to allow access to them. To do so in AWS, we first associate an IAM role to ArgoCD, then add this role to the aws-auth ConfigMap. This ConfigMap is specific to AWS EKS and associates IAM Roles with Kubernetes Roles inside the cluster.
1. Create an IAM role with a trust policy that allows your Kubernetes service accounts to assume this role.
2. create the role and attach the necessary IAM policies that define what this role can do.
3. ArgoCD needs to be configured to use the IAM role for its operations. This involves annotating the specific Kubernetes service accounts with the ARN of the IAM role.

modify ArgoCD’s ServiceAccount with an annotation indicating the ARN of this role, like so:
```
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<AWS_ACCOUNT_ID>:role/argocd
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/name: argocd-server
    app.kubernetes.io/part-of: argocd
  name: argocd-server
```
Also, add this annotation to the application-controller and applicationset-controller ServiceAccounts.

## Updating the ConfigMap

Now that ArgoCD has a role, we need to allow it to create resources inside our clusters. To do so, EKS uses a ConfigMap, named aws-auth, which defines which IAM roles have which RBAC permissions. Simply edit this ConfigMap to give ArgoCD the system:masters permission. 
```
    - groups:
      - system:masters
      rolearn: arn:aws:iam::<AWS_ACCOUNT_ID>:role/argocd
      username: arn:aws:iam::<AWS_ACCOUNT_ID>:role/argocd
```








# ARGOCD User Management
ArgoCD manages RBAC through the `argocd-rbac-cm` ConfigMap, and users through the `argocd-cm` ConfigMap.

First, you declare users in argocd-cm simply by adding lines such as accounts.foo-user: apiKey, login. This would add a foo-user account that can connect through ArgoCD’s interface or using an API key. Then, edit the argocd-rbac-cm ConfigMap to define roles with permissions and assign them to users.

On the installation of Argo CD, there is a built in user that has full access to the system.
It is recommended to use the admin user only for initial configuration and then switch to;
- Local Users
- SSO integration

Local users/accounts
I will walk you through how we can create local users/account gfo rArgoCD in this article;
1. POssibility to configure an API account with limited access and generate an authentication token.
2. THe n the token can be used to automatically create applications, projects
3. Login to argocd UI interface.
4. The local users don't provide advanced features such as groups, login history

FIrst , let us confirm some details;
Run;
`kubectl get cm -n argocd`


The `argocd-cm` is holding all of the users which is required to be in the argocd server.
If you want to add any user, you need to modify the configmap file.

Lets creack on;
Run 
`kubectl get cm -n argocd`
`kubectl describe cm argocd-cm -n argocd`

IN the data section, add an additional local user with apikey and login capabilities
- apiKey - allows generating authentication tokens for API access
- login - allows to login using UI

accounts.user1: apiKey login

By default, configured users are enabled, if there is a need to disable
acount.User1.enabled: "false"

Disable admin user

admin.enabled: "false" 

To get full users list
`argocd account list `
Get specific user details
`argocd account get <username>`
Set user password
argocd account  --password \ --acount <usenamename> \
--current-password <current-admin> \ --new-password <new-user-password>
Generate Auth token
`argocd account generate-token -account <username`
 
User/Group Permission/Authorization
edit cm name `argocd-rbac-cm`, and modify data section 

```
policy.default: role:readonly
policy.csv: |
POLICY ROLE            RESOURCES        ACTIONS, APLLICATIONS/PROJ, PERMISION
p,     role:User,      applications,    *,       */*,               allow
p,     role:User,      clusters,        get,     adservice,         allow
p, role:User, repositories, get, *, allow
p, role:User, repositories, create, *, allow
p, role:User, repositories, update, *, allow
p, role:User, repositories, delete , *, allow

Group   SUBJECT                 ROLE
g,      username/group/role, role:User1
```



kind: ConfigMap
metadata:
  name: argocd-rbac-cm
data:
  policy.csv: |
    # Define a foo role and give it permissions
    p, role:foo, applications, sync, staging-team-foo/*, allow
    p, role:foo, applications, update, production-team-foo/*, allow

    # Assign foo-user to the roles foo and readonly (pre-existing role)
    g, foo-user, role:foo
    g, foo-user, role:readonly