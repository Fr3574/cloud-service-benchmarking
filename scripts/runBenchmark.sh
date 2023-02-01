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

echo "Waiting for the sut to become ready ..."

# Connect to the sut VM and check if the container is running
while ! gcloud compute ssh $sut --zone europe-west3-c --command "sudo docker container list" | grep -q $sut; do
    sleep 5
done > /dev/null 2>&1

# Connect to the database VM and check if the container is running
while ! gcloud compute ssh $database --zone europe-west3-c --command "sudo docker container list" | grep -q $database; do
    sleep 5
done > /dev/null 2>&1

# Connect to the client VM and check if the images are installed
while ! gcloud compute ssh $clientInstanceName --zone europe-west3-c --command "sudo docker images" | grep -q "monitor"; do
    sleep 5
done > /dev/null 2>&1

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
    cmd="nohup bash /cloud-service-benchmarking/scripts/runHorizontalBenchmark.sh ${sut} ${incrementInterval} &"
    gcloud compute ssh $clientInstanceName --zone europe-west3-c -- $cmd
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
else 
    echo "${mode} is a unkown mode. It has to be either 'horizontal' or 'vertical'"
    exit 1
fi
sleep 1800
echo "Benchmark is finished."


echo "Removing benchmark containers"
cmd="sudo docker rm $(docker ps -a | grep "benchmark" | awk '{print $1}')"
echo $cmd
gcloud compute ssh $clientInstanceName --zone europe-west3-c -- $cmd
echo "Done."
