
1. Create Dockerfile 
2. RUN docker build
```azure
    docker build -t rifky86/go-end2-end:v1 .
```
3. create container
```azure
    docker run -p 8080:8080 -it -d rifky86/go-end2-end:v1 
```


4. Login Docker hub 

```
    docker login
```
```
    docker tag rifky86/go-end2-end:v1 rifky86/go-end2-end:v1
```
```azure
    docker push rifky86/go-end2-end:v1
```



### CREATE K8S

1. create folder k8s
2. create folder k8s/manifest 
3. create deployment.yaml




### CREATE EKS

1. install aws cli 
    - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
   ```json
        
        $ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        aws --version
    ```
   
    ```json
      add user 
      and add permission 
   
   AttachedPolicies:
       - PolicyArn: arn:aws:iam::aws:policy/AmazonSSMFullAccess
         PolicyName: AmazonSSMFullAccess
       - PolicyArn: arn:aws:iam::aws:policy/AmazonEC2FullAccess
         PolicyName: AmazonEC2FullAccess
       - PolicyArn: arn:aws:iam::aws:policy/IAMFullAccess
         PolicyName: IAMFullAccess
       - PolicyArn: arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
         PolicyName: AmazonEKSClusterPolicy
       - PolicyArn: arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
         PolicyName: AmazonEKSWorkerNodePolicy
       - PolicyArn: arn:aws:iam::aws:policy/AmazonEKSServicePolicy
         PolicyName: AmazonEKSServicePolicy
       - PolicyArn: arn:aws:iam::aws:policy/AWSCloudFormationFullAccess
         PolicyName: AWSCloudFormationFullAccess
      ```
  
     Create Custom Polices
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": [
                   "eks:*"
               ],
               "Resource": "*"
           },
           {
               "Effect": "Allow",
               "Action": [
                   "iam:PassRole"
               ],
               "Resource": "*",
               "Condition": {
                   "StringEquals": {
                       "iam:PassedToService": "eks.amazonaws.com"
                   }
               }
           }
       ]
       }
    
     ```
    Check List Permission
    ```json
        # default policies
        aws iam list-attached-user-policies --user-name userdemo
        #custom inline
        aws iam list-user-policies --user-name userdemo 
       
    ```   


      ```json
          aws configure
      ```
  
2. install minikube
2. install kubectl 
3. install eksctl 
    https://eksctl.io/installation/


### Create cluster 

1. Create Cluster 
```json 
  eksctl create cluster --name demo-cluster --region us-east-1
```


### apply manifest minikube
1. Apply deployment
```json
   kubectl apply -f k8s/manifests/deployment.yaml

# check deployment up 
  kubectl get deployment
# check pods
  kubectl get pods

```

2. Apply service

```json
   kubectl apply -f k8s/manifests/service.yaml
# check service/ svc
   kubectl get svc
```

3. Apply ingress 

```json
      kubectl apply -f k8s/manifests/ingress.yaml
# Check ingress
  kubectl get ing


NAME          CLASS   HOSTS               ADDRESS   PORTS   AGE
go-end2-end   nginx   go-end2-end.local             80      55s


```
NOTE: Address not assign yet

by default svc set ClusterIP 
so we need edit svc to NodePort

```json
  kubectl edit svc go-end2-end
# check type to NodePort
```
SO cluster IP Will created 
```json
kubectl get svc
NAME          TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
go-end2-end   NodePort    10.100.10.0   <none>        80:30291/TCP   5m39s
kubernetes    ClusterIP   10.100.0.1    <none>        443/TCP        42m

```
Check node
```json
kubectl get nodes -o wide
```

Note: 
see ip address external-ip 

Issue Commont
cluster not maping kube RBAC VIA ConfigMap
```json
kubectl get configmap aws-auth -n kube-system -o yaml
```

make sure security group set NodePort range IP correct


trys call in browser
http://<IP ADDRESS>>:30291/home



### CREATE INGRESS CONTROLLER

https://kubernetes.github.io/ingress-nginx/deploy/#aws
```json
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/aws/deploy.yaml
```
Check Pods 

```json
kubectl get pods -n ingress-nginx
```

Edit config ingress-nginx 

```json
kubectl edit pod ingress-nginx-controller-cbb88bdbc-2bgsx -n ingress-nginx
```

ingress.yaml link to config ingress-controller
ingressClassName: nginx ->  - --ingress-class=nginx

```json
     containers:
         - args:
         - /nginx-ingress-controller
         - --publish-service=$(POD_NAMESPACE)/ingress-nginx-controller
         - --election-id=ingress-nginx-leader
         - --controller-class=k8s.io/ingress-nginx
         - --ingress-class=nginx
         - --configmap=$(POD_NAMESPACE)/ingress-nginx-controller
         - --validating-webhook=:8443
         - --validating-webhook-certificate=/usr/local/certificates/cert
          - --validating-webhook-key=/usr/local/certificates/key
```

should be will link address to amazon 
```json
go-end2-end   nginx   go-end2-end.local   a49771142626b4f0e801d50023c23621-88463bbbc2c33678.elb.us-east-1.amazonaws.com   80      118m
```

go to aws consolse 
```json
load balance -> EC2  
```

should be aws load balancer will shown
example 
```json
http://xxxx-xxxxx.elb.us-east-1.amazonaws.com
```


get dress 
```json
nslookup    xxxx-xxxxx.elb.us-east-1.amazonaws.com
```
should be show address



mapping 
set spoofing 

```json
sudo vi /etc/hosts
```

```json
<IP nslookup result> go-end2-end.local
```

now we can call using domain 
```json
http://go-end2-end.local/home
```




### CREATE HELM 
1. install helm 
```json
wget https://get.helm.sh/helm-v3.17.1-linux-amd64.tar.gz
tar -zxvf helm-v3.17.1-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
helm --version
```

```json
cd /helm
helm create go-end2-end

# no need chart
rm -rf charts/
rm -rf templates/*

```

copy
- deployment.yaml
- service.yaml
- ingress.yaml 

```json
cp k8s/manifests/* helm/go-end2-end/templates/

```

change in templates for dynamic image 
example 
```json
   image: rifky86/go-end2-end:{{ .Values.image.tag }}
```

change helm value.yaml

```json
replicaCount: 1
image:
repository: rifky86/go-end2-end
pullPolicy: IfNotPresent
tag: "v1"

ingress:
enabled: false
className: ""
annotations: {}
hosts:
- host: chart-example.local
paths:
- path: /
pathType: ImplementationSpecific
```

Lets test remove all deploy, service and ingress
```json
kubectl get deploy
kubectl get svc
kubectl get ing

kubectl delete deploy go-end2-end
kubectl delete svc go-end2-end
kubectl delete ing go-end2-end


```


try apply using helm 

```json
   cd helm/
  helm install go-end2-end ./go-end2-end
#check
kubectl get deployment
kubectl get svc
kubectl get ing

# check image version should be image version will dynamic by tag
  kubectl edit deploy go-end2-end
  see ==> simage: rifky86/go-end2-end:v1
```

now uninstall we deploy start using CI/CD

```json
helm uninstall  go-end2-end

```



### START ci 




add secret github action 
```json
https://github.com/rifkytech86/go-end2-end/settings/secrets/actions
```


and create token for account login 



Docker generate token in project
https://app.docker.com/settings/personal-access-tokens
```json

```


### install argo cd

```json
  kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```


Access the Argo CD UI (Loadbalancer service)
```json
  kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

  kubectl get svc -n argocd

  kubectl get nodes -o wide

```

try access externapl-IP with port service 

example 
```json
https://18.206.161.89:31477/
```

```json
  kubectl get secrets -n argocd
```


Update secret
```json
apiVersion: v1
data:
  password: xxxxxxx==

```

encode

```json
 echo xxxxxxx | base64 --decode
```




