export TKN=$(curl -X POST -k 'https://keycloak.info/realms/unic/protocol/openid-connect/token' \
 -H "Content-Type: application/x-www-form-urlencoded" \
 -d "username=user1" \
 -d 'password=user1' \
 -d 'grant_type=password' \
 -d 'client_id=notebook' | jq -r '.access_token')

export MINIO_TOKEN=$(curl -X POST -k \
  -H 'Accept: application/json' \
  --data-urlencode "WebIdentityToken=${TKN}" \
  --data-urlencode "Action=AssumeRoleWithWebIdentity" \
  --data-urlencode "Version=2011-06-15" \
  --data-urlencode "DurationSeconds=86000" \
  http://minio.info
  )
#echo $MINIO_TOKEN > token.xml
export AWS_ACCESS_KEY_ID=$(echo $MINIO_TOKEN | xpath -q -e '/AssumeRoleWithWebIdentityResponse/AssumeRoleWithWebIdentityResult/Credentials/AccessKeyId/text()')
export AWS_SECRET_ACCESS_KEY=$(echo $MINIO_TOKEN | xpath -q -e '/AssumeRoleWithWebIdentityResponse/AssumeRoleWithWebIdentityResult/Credentials/SecretAccessKey/text()')
export AWS_SESSION_TOKEN=$(echo $MINIO_TOKEN | xpath -q -e '/AssumeRoleWithWebIdentityResponse/AssumeRoleWithWebIdentityResult/Credentials/SessionToken/text()')
export EXPIRATION=$(echo $MINIO_TOKEN | xpath -q -e '/AssumeRoleWithWebIdentityResponse/AssumeRoleWithWebIdentityResult/Credentials/Expiration/text()')

echo -n "[default]\n" > credentials
echo -n "aws_access_key_id = ${AWS_ACCESS_KEY_ID}\n" >> credentials
echo -n "aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}\n" >> credentials
echo -n "aws_session_token = ${AWS_SESSION_TOKEN}\n" >> credentials
echo -n "expiration = ${EXPIRATION}\n" >> credentials

kubectl create secret generic minio-secret-user1 \
  --save-config \
  --dry-run=client \
  --from-file=./credentials \
  -o yaml | \
  kubectl apply -f -

kubectl create secret -n user1 generic minio-secret-user1 \
  --save-config \
  --dry-run=client \
  --from-file=./credentials \
  -o yaml | \
  kubectl apply -f -
