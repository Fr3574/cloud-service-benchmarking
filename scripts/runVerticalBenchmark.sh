#!/usr/bin/env bash
sut=$1
traceLength=$2
incrementInterval=$3
workers=$4

for i in $(seq 1 $workers); do
  sudo docker run --rm \
    --net bridge \
    -d \
    -v $PWD/benchmark_output:/app/benchmark_output \
    --name benchmark_${i} \
    benchmark:latest -sut=${sut} -mode=vertical -trace_length=${traceLength} -increment_interval=${incrementInterval} -container_name=benchmark_${i}
done
