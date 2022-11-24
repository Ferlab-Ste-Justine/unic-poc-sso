
```
minikube ssh docker pull quay.io/keycloak/keycloak:20.0.1
minikube ssh docker pull jupyter/scipy-notebook
```

Fichier host :
127.0.0.1    keycloak.info minio.info minio-console.info jupyter.info

```
minikube tunnel
```


```
mc alias set myminio http://minio.info minioroot minioroot
```

```
brew install jq
```

```
. ./get_token.sh
```

```
k create namespace user1 
```

```
docker build -t ferlabcrsj/setup-spark-config ./setup-spark-config
minikube image load ferlabcrsj/setup-spark-config
```


# "spark.authenticate.secret.file": "/etc/secret/spark-secret", # https://issues.apache.org/jira/browse/SPARK-33332 :(