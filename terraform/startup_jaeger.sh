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

echo "Start Jaeger ..."
docker run --name jaeger -d \
    --restart on-failure \
    --net bridge \
    -e COLLECTOR_OTLP_ENABLED=true \
    -p 6831:6831/udp \
    -p 6832:6832/udp \
    -p 5778:5778 \
    -p 16686:16686 \
    -p 4317:4317 \
    -p 4318:4318 \
    -p 14250:14250 \
    -p 14268:14268 \
    -p 14269:14269 \
    -p 9411:9411 \
    -e no_proxy=localhost \
    -e SPAN_STORAGE_TYPE=elasticsearch \
    -e ES_SERVER_URLS=http://elasticsearch:9200 \
    -e ES_NUM_SHARDS=1 \
    -e ES_NUM_REPLICAS=0 \
    jaegertracing/all-in-one:1.40
echo "Container started"
