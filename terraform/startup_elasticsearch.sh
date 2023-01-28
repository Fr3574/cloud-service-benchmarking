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
echo "Start elasticsearch ..."	
docker run --name elasticsearch --rm -d  \
    --net bridge \
    -p 9200:9200 \
    -p 9300:9300 \
    -e cluster.name=jaeger-cluster \
    -e discovery.type=single-node \
    -e http.host=0.0.0.0 \
    -e transport.host=127.0.0.1 \
    -e ES_JAVA_OPTS="-Xms512m -Xmx512m" \
    -e xpack.security.enabled=false \
    -v esdata:/usr/share/elasticsearch/data \
    docker.elastic.co/elasticsearch/elasticsearch:7.9.3
echo "Container started"
