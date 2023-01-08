#!/usr/bin/env bash
echo "Cleanup ..."
docker rm -f tempo grafana gcs jaeger elasticsearch benchmark monitor
