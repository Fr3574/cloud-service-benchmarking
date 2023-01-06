#!/usr/bin/env bash
echo "Starting grafana container"
docker run --rm \
    --net=cloud-service-benchmarking_default \
    -d \
    -v $PWD/grafana-datasources.yaml:/etc/grafana/provisioning/datasources/datasources.yaml \
    -p 3000:3000 \
    --env GF_AUTH_ANONYMOUS_ENABLED=true \
    --env GF_AUTH_ANONYMOUS_ORG_ROLE=Admin \
    --env GF_AUTH_DISABLE_LOGIN_FORM=true \
    --name grafana \
    grafana/grafana:9.3.0

echo "Starting gcs container"
docker run --rm \
    --net=cloud-service-benchmarking_default \
    -d \
    -v $PWD/tempo/gcs-data/:/data/tempo/ \
    -p 4443:4443 \
    --name gcs \
    fsouza/fake-gcs-server:latest "-public-host=gcs -port=4443"

sleep 10

echo "Starting tempo container"
docker run --rm \
    --net=cloud-service-benchmarking_default \
    -d \
    -v $PWD/tempo/tempo-config.yaml:/etc/tempo.yaml \
    -v $PWD/tempo/tempo-data:/tmp/tempo \
    -p 3200:3200 \
    --name tempo \
    grafana/tempo:latest "-config.file=/etc/tempo.yaml"

echo "Starting benchmark container"
docker run --rm \
    --net=cloud-service-benchmarking_default \
    -d \
    --name benchmark \
    benchmark:latest "-sut=tempo"