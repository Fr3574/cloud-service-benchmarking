#!/usr/bin/env bash
sut=$1
incrementInterval=$2
counter=0
end_time=$(( $(date +%s) + 1800 )) # 30min from now on

mkdir output
echo "read, number_containers" >> output/output_${sut}_benchmark.csv
while [[ $(date +%s) -lt $end_time ]]; do
    counter=$((counter + 1))
    sudo docker run --rm \
        --net bridge \
        -d \
        --name benchmark_${counter} \
        benchmark:latest -sut=${sut} -mode=horizontal -trace_length=0.1
    # Write one line to the CSV file after each iteration
    echo "$(date +'%Y-%m-%d %H:%M:%S.%N %z %Z'), $counter" >> output/output_${sut}_benchmark.csv
    sleep $incrementInterval
done