#!/bin/bash
set -euo pipefail

apt-get update -y
apt-get install -y ca-certificates curl docker.io

systemctl enable docker
systemctl start docker

if [ -n "${dockerhub_username}" ] && [ -n "${dockerhub_password}" ]; then
  echo "${dockerhub_password}" | docker login --username "${dockerhub_username}" --password-stdin
fi

docker rm -f feedback-frontend || true
docker pull "${docker_image}"

docker run -d \
  --name feedback-frontend \
  --restart unless-stopped \
  -p 3000:3000 \
  -e BACKEND_INTERNAL_URL="${backend_internal_url}" \
  -e ENVIRONMENT="${environment}" \
  -e PROJECT="${project}" \
  "${docker_image}"
