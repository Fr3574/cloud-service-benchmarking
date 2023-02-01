#!/usr/bin/env bash
clientInstanceName="client"
sut=$1
mode=$2
incrementInterval=$3
incrementPercentage=$4

if [ $sut == "tempo" ]; then
    database="gcs"
elif [ $sut == "jaeger" ]; then
    database="elasticsearch"
else 
    echo "${sut} is a unkown sut. It has to be either 'tempo' or 'jaeger'"
    exit 1
fi

# Connect to the sut VM and check if the container is running
while ! gcloud compute ssh $sut --zone europe-west3-c --command "sudo docker container list" | grep -q $sut; do
    sleep 5
done

# Connect to the database VM and check if the container is running
while ! gcloud compute ssh $database --zone europe-west3-c --command "sudo docker container list" | grep -q $database; do
    sleep 5
done

echo "Starting monitor container"
cmd="sudo docker run --rm \
    --net bridge \
    -d \
    -v $PWD/output:/app/output \
    --name monitor \
    monitor:latest '-output=output_${sut}.csv' '-sut=${sut}'"
echo $cmd
gcloud compute ssh $clientInstanceName --zone europe-west3-c -- $cmd
echo "Done."

if [ $mode == "horizontal" ]; then
    counter=0
    end_time=$(( $(date +%s) + 1800 )) # 30min from now on
    echo "read, number_containers" >> output_${sut}_benchmark.csv
    while [[ $(date +%s) -lt $end_time ]]; do
        counter=$((counter + 1))
        echo "Starting benchmark container benchmark_${counter}"
        cmd="sudo docker run --rm \
            --net bridge \
            -d \
            --name benchmark_${counter} \
            benchmark:latest '-sut=${sut}' '-mode=${mode}' '-trace_length=1'"
        gcloud compute ssh $clientInstanceName --zone europe-west3-c -- $cmd
        # Write one line to the CSV file after each iteration
        echo "$(date +'%Y-%m-%d %H:%M:%S.%N %z %Z'), $counter" >> output_${sut}_benchmark.csv
        sleep $incrementInterval
    done
    echo "Benchmark is finished."
elif [ $mode == "vertical" ]; then
    echo "Starting benchmark container"
    cmd="sudo docker run --rm \
        --net bridge \
        -d \
        -v $PWD/benchmark_output:/app/benchmark_output \
        --name benchmark \
        benchmark:latest '-sut=${sut}' '-mode=${mode}' '-trace_length=1' '-increment_interval=${incrementInterval}' '-increment_percentage=${incrementPercentage}'"
    echo $cmd
    gcloud compute ssh $clientInstanceName --zone europe-west3-c -- $cmd
    sleep 1800
    echo "Benchmark is finished."
else 
    echo "${mode} is a unkown mode. It has to be either 'horizontal' or 'vertical'"
    exit 1
fi

echo "Removing benchmark containers"
cmd="sudo docker rm $(docker ps -a | grep "benchmark" | awk '{print $1}')"
echo $cmd
gcloud compute ssh $clientInstanceName --zone europe-west3-c -- $cmd
echo "Done."
