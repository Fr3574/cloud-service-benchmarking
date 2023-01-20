#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt update
apt upgrade -y
apt-get install -y -q language-pack-de
apt install -y -q apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository --yes "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
# Install go
apt install -y -q golang-go
apt update
apt upgrade -y
apt install -y -q docker-ce

# Start docker
systemctl start docker
# Clone Benchmark repo
git clone https://github.com/Fr3574/cloud-service-benchmarking.git
cd cloud-service-benchmarking
# Build docker images
docker build -f benchmark.Dockerfile -t benchmark .
docker build -f monitor.Dockerfile -t monitor .
