#!/usr/bin/env bash
echo "Starting elasticsearch container"
docker run --name elasticsearch --rm -d  \
    --net elastic-jaeger \
    -p 127.0.0.1:9200:9200 \
    -p 127.0.0.1:9300:9300 \
    -e cluster.name=jaeger-cluster \
    -e discovery.type=single-node \
    -e http.host=0.0.0.0 \
    -e transport.host=127.0.0.1 \
    -e ES_JAVA_OPTS="-Xms512m -Xmx512m" \
    -e xpack.security.enabled=false \
    -v esdata:/usr/share/elasticsearch/data \
    docker.elastic.co/elasticsearch/elasticsearch:7.9.3

echo "Starting grafana container"
docker run --rm \
    -d \
    --net elastic-jaeger \
    -v $PWD/grafana-datasources.yaml:/etc/grafana/provisioning/datasources/datasources.yaml \
    -p 3000:3000 \
    --env GF_AUTH_ANONYMOUS_ENABLED=true \
    --env GF_AUTH_ANONYMOUS_ORG_ROLE=Admin \
    --env GF_AUTH_DISABLE_LOGIN_FORM=true \
    --name grafana \
    grafana/grafana:9.3.0

echo "Starting jaeger container"
docker run --name jaeger -d \
    --restart on-failure \
    --net elastic-jaeger \
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

sleep 10

echo "Starting monitor container"
docker run --rm \
    --net=elastic-jaeger \
    -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $PWD/output:/app/output \
    --name monitor \
    monitor:latest "-output=output_jaeger.csv"

echo "Starting benchmark container"
docker run --rm \
    -d \
    --net=elastic-jaeger \
    --name benchmark \
    benchmark:latest "-sut=jaeger" "-trace_length=0.0001"
