#!/bin/bash
set -euo pipefail

apt-get update -y
apt-get install -y ca-certificates curl docker.io jq unzip

systemctl enable docker
systemctl start docker

curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

if [ -n "${dockerhub_username}" ] && [ -n "${dockerhub_password}" ]; then
  echo "${dockerhub_password}" | docker login --username "${dockerhub_username}" --password-stdin
fi

DATABASE_URL=""
if [ -n "${db_secret_arn}" ]; then
  DB_SECRET="$(aws secretsmanager get-secret-value \
    --region "${region}" \
    --secret-id "${db_secret_arn}" \
    --query SecretString \
    --output text)"
  DB_USERNAME="$(echo "$DB_SECRET" | jq -r '.username')"
  DB_PASSWORD="$(echo "$DB_SECRET" | jq -r '.password')"
  DB_HOST="$(echo "$DB_SECRET" | jq -r '.host')"
  DB_PORT="$(echo "$DB_SECRET" | jq -r '.port')"
  DB_NAME="$(echo "$DB_SECRET" | jq -r '.dbname')"
  DATABASE_URL="postgres://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME?sslmode=disable"
else
  DATABASE_URL="${database_url}"
fi

docker rm -f feedback-backend || true
docker pull "${docker_image}"

docker run -d \
  --name feedback-backend \
  --restart unless-stopped \
  -p 8080:8080 \
  -e PORT="8080" \
  -e DATABASE_URL="$DATABASE_URL" \
  -e ENVIRONMENT="${environment}" \
  -e PROJECT="${project}" \
  "${docker_image}"
