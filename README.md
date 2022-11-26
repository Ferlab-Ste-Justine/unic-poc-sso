
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


Unfortunately, cannot use due to https://issues.apache.org/jira/browse/SPARK-33332 :
```
"spark.authenticate.secret.file": "/etc/secret/spark-secret"
```

```
kubectl exec -it vault-0 -- /bin/sh
vault auth enable kubernetes
vault write auth/kubernetes/config kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"

vault secrets enable -path=notebook kv-v2

vault policy write notebook-user1 - <<EOF
path "notebook/data/user1/*" {
  capabilities = ["read"]
}
EOF

vault write auth/kubernetes/role/notebook-user1 \
    bound_service_account_names=user1 \
    bound_service_account_namespaces=default \
    policies=notebook-user1 \
    ttl=24h

vault write auth/kubernetes/role/notebook-ns-user1 \
    bound_service_account_names=default \
    bound_service_account_namespaces=user1 \
    policies=notebook-user1 \
    ttl=24h
```

TODO :
Run spark executor as another user than root
