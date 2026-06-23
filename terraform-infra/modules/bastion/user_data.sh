#!/bin/bash
set -euo pipefail

apt-get update -y
apt-get install -y ca-certificates curl unzip

hostnamectl set-hostname "${environment}-${project}-bastion"
