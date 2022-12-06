# POC How to secure notebook 

## Prerequisite 

- Install minikube and docker
- xpath CLI tools must be installed (already present in macOS)

## Minikube and Kubernetes configuration
Add ingress addons in minikube:
```
minikube addons enable ingress
```

Pull these images locally :
```
minikube ssh docker pull quay.io/keycloak/keycloak:20.0.1
minikube ssh docker pull jupyter/scipy-notebook
```

Modify your host file :
```
127.0.0.1    keycloak.info minio.info minio-console.info jupyter.info
```

Launch tunnel :
```
minikube tunnel
```
It will prompt for your password because some ports required some privileges. Enter your password.

Create namespace `user1` :
```
k create namespace user1 
```


Build `ferlabcrsj/setup-spark-config` locally : 
```
docker build -t ferlabcrsj/setup-spark-config ./setup-spark-config
minikube image load ferlabcrsj/setup-spark-config
```
This image is used to configure spark-default.conf in notebook pod.

## Service Account
Apply K8 manifests :
```
kubectl apply -f ./serviceaccount/access-user1.yml
```
This manifest will create Service Account for user 1. It will be used by notebook Pod to create Spark Executor in namespace user 1.

## Vault :
Install Vault helm chart :
```
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault --set "server.dev.enabled=true"
```

Verify that these 2 pods are running :
```
kubectl get pods
NAME                                    READY   STATUS    RESTARTS   AGE
vault-0                                 1/1     Running   0          80s
vault-agent-injector-5945fb98b5-tpglz   1/1     Running   0          80s
```

## Postgres 
Apply K8 manifests :
```
kubectl apply -f ./postgres/postgres.yml
```

## Keycloak

- Apply K8 manifests :
```
kubectl apply -f ./keycloak/db.yml
kubectl apply -f ./keycloak/keycloak.yml
kubectl apply -f ./keycloak/ingress.yml 
```

- Connect to keycloak 
  - URL : [https://keycloak.info/](https://keycloak.info/).  
  - Login : admin
  - Password : admin

- Import realm :
Click on Realm select box, and then click on `Create Realm` button. In `Resource File`, click on `Browse...` button and then select file `realm-export.json`in `script`directory.
In `Realm name` type `unic`.
Then click on create.

- Create user `user1`:
In left menu, click on `Users`. Then click on `Add user` button. 
In `Username` type `user1` then click on create.
Then click on `Credentials` tab and on `Set Password` button. Enter a password for the user, and unselect `Temporary` button. Click on save.

 Note : This password is used in `get_token.sh` script. If you change the defaulkt password for `user1`, change the value in the script also.

- Assign role to user1
Click on `Role mapping` tab, then click on `Assign role` button. Select `Filter by clients` in first select. Then select `readwrite` role. 

## Minio

Apply K8 manifests :
```
kubectl apply -f ./minio/minio.yml
kubectl apply -f ./minio/ingress.yml 
```

## Spark

Apply K8 manifests :
```
kubectl apply -f ./spark/configmap-default.yml
kubectl apply -f ./spark/configmap-user1.yml
kubectl apply -f ./spark/secret-user1.yml
```
- configmap-default.yml : contains default spark configuration for all notebook. 
- configmap-user1.yml : contains spark configuration for user1 specifically.
- secret-user1.yml : contains secret shaered between driver and executor for user1 cluster. This could be also a secret stored in vault. It could be also be initialized bay a script in a side container. 

## Authenticate user using script

`script/get_token.sh` is a utility to :
- Authenticate a user in Keycloak using REST Api
- Exchange Keycloak access toke with minio identifiers
- Set secrets in vault. These secrets are then inject into pods.

Execute this script.

## Jupyter :

Apply K8 manifests :
```
kubectl apply -f  ./jupyter/jupyter.yml
kubectl apply -f  ./jupyter/ingress.yml
```

Note: Jupyter is configured fo user1. It will not start until minio secrets are present in vault. You must execute `get_token.sh` to be able to access Jupyter. 
Then for accessing Jupyter, you need to get access token from jupyter Log
```
kubectl logs jupyter-0
....
[I 2022-11-26 14:45:01.897 ServerApp] Jupyter Server 1.23.2 is running at:
[I 2022-11-26 14:45:01.897 ServerApp] http://jupyter-0:8888/lab?token=816c42686f6b066bce098cd5d886dc483a9871d94b70dbe2
[I 2022-11-26 14:45:01.897 ServerApp]  or http://127.0.0.1:8888/lab?token=816c42686f6b066bce098cd5d886dc483a9871d94b70dbe2
...
```
Copy token and then access to :
```
https://jupyter.info/lab?token=YOUR_TOKEN_HERE
```

## Test notebook
In minio : 
- Create bucket test
- push file stocks.csv in bucket test

Import spark notebook in Jupyter. Then run it. It should work.
Then open a terminal in Jupyter and install boto3 :
```
pip install boto3
```
Import notebook minio_boto3 and run it, it should work.

In jupyter, open a new terminal and install kubernetes package :
```
pip install boto3
```
Import notebook test_k8.
All paragraph works, except the last one because Service Account associted to notebook pod is not allowed.


