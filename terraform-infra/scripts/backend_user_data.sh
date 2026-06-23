#!/bin/bash
set -euo pipefail

apt-get update -y
apt-get install -y ca-certificates curl docker.io unzip

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
  DATABASE_URL="$(aws secretsmanager get-secret-value \
    --region "${region}" \
    --secret-id "${db_secret_arn}" \
    --query SecretString \
    --output text)"
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
