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

#Start docker
systemctl start docker
echo "Start fake-gcs-server ..."	
docker run -d \
    --net=host \
    --restart on-failure \
    -v $PWD/gcs-data/:/data/tempo/ \
    -p 4443:4443 \
    --name gcs \
    fsouza/fake-gcs-server:latest "-public-host=gcs -port=4443"
echo "Container started on port 4443"
