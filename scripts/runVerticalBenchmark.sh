#!/usr/bin/env bash
sut=$1
traceLength=$2
incrementInterval=$3

sudo docker run --rm \
    --net bridge \
    -d \
    -v $PWD/benchmark_output:/app/benchmark_output \
    --name benchmark_1 \
    benchmark:latest -sut=${sut} -mode=vertical -trace_length=${traceLength} -increment_interval=${incrementInterval} -name=benchmark_1

sudo docker run --rm \
    --net bridge \
    -d \
    -v $PWD/benchmark_output:/app/benchmark_output \
    --name benchmark_2 \
    benchmark:latest -sut=${sut} -mode=vertical -trace_length=${traceLength} -increment_interval=${incrementInterval} -name=benchmark_2

sudo docker run --rm \
    --net bridge \
    -d \
    -v $PWD/benchmark_output:/app/benchmark_output \
    --name benchmark_3 \
    benchmark:latest -sut=${sut} -mode=vertical -trace_length=${traceLength} -increment_interval=${incrementInterval} -name=benchmark_3