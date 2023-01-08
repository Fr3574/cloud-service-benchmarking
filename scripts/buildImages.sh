#!/usr/bin/env bash
docker build -f benchmark.Dockerfile -t benchmark .
docker build -f monitor.Dockerfile -t monitor .