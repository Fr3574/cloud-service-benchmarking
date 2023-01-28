#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt update
apt upgrade -y
apt-get install -y -q language-pack-de
apt install -y -q apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository --yes "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt update
apt upgrade -y
apt install -y -q docker-ce

# Tell docker daemon to listen on specific port so data can be scraped by monitor on client
# Add the -H flag to the Docker daemon command in the init script
sed -i 's|^ExecStart.*|ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock|' /lib/systemd/system/docker.service

# Reload the systemd configuration
systemctl daemon-reload

# Start docker
systemctl start docker
# Restart docker (don't ask me why this works)
systemctl restart docker

# Get sample config 
curl -O https://raw.githubusercontent.com/grafana/tempo/main/example/docker-compose/gcs/tempo-gcs.yaml
echo "Start Grafana tempo ..."
docker run --rm \
    --net bridge \
    -d \
    -v $PWD/tempo-gcs.yaml:/etc/tempo.yaml \
    -v $PWD/tempo-data:/tmp/tempo \
    -p 3200:3200 \
    -p 4317:4317 \
    --name tempo \
    grafana/tempo:latest "-config.file=/etc/tempo.yaml"
echo "Container started on port 3200"
