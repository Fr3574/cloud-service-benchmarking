#!/usr/bin/env bash
clientInstanceName="client"

echo "Starting monitor container"
cmd="docker run --rm \
    --net=host \
    -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $PWD/output:/app/output \
    --name monitor \
    monitor:latest '-output=output_tempo.csv' '-sut=tempo'"
echo $cmd
gcloud compute ssh $clientInstanceName --zone europe-west3-c -- $cmd
echo "Done."

echo "Starting benchmark container"
cmd="docker run --rm \
    --net=host \
    -d \
    --name benchmark \
    benchmark:latest '-sut=tempo' '-trace_length=0.0001'"
echo $cmd
gcloud compute ssh $clientInstanceName --zone europe-west3-c -- $cmd
echo "Done."