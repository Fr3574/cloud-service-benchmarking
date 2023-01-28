#!/usr/bin/env bash
clientInstanceName="client"
sut=$1

# Connect to the sut VM and check if the container is running
while ! gcloud compute ssh $sut --zone europe-west3-c --command "sudo docker container list" | grep -q $sut; do
    sleep 5
done

if [ $sut == "tempo" ]; then
    database="gcs"
else
    database="elasticsearch"
fi

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

echo "Starting benchmark container"
cmd="sudo docker run --rm \
    --net bridge \
    -d \
    --name benchmark \
    benchmark:latest '-sut=${sut}' '-trace_length=0.1'"
echo $cmd
gcloud compute ssh $clientInstanceName --zone europe-west3-c -- $cmd
echo "Done."
