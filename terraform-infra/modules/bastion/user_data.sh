#!/bin/bash
set -e

apt-get update -y
apt-get install -y \
   vim \
   wget \
   git \
   htop \
   curl \
   dnsutils \
   jq \
   unzip


# install docker
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# aws session manager plugin install
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
dpkg -i session-manager-plugin.deb
rm -f session-manager-plugin.deb

# Configure AWS CLI region
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
mkdir -p /home/ubuntu/.aws
cat > /home/ubuntu/.aws/config << EOF
[default]
region = $REGION
output = json
EOF
chown -R ubuntu:ubuntu /home/ubuntu/.aws

echo "Bastion host setup complete - $(date)" > /var/log/user-data.log
