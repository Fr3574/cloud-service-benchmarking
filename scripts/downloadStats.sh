#!/usr/bin/env bash
clientInstanceName="client"
sut=$1
mode=$2
filename=output_${sut}.csv
benchmark_filename=output_${sut}_benchmark.csv

echo "Querying the results files"
gcloud compute scp $clientInstanceName:Github/cloud-service-benchmarking/output/$filename $PWD/$filename --zone europe-west3-c
if [ $mode == "horizontal" ]; then
    gcloud compute scp $clientInstanceName:~/output/$benchmark_filename $PWD/$benchmark_filename --zone europe-west3-c
else
    gcloud compute scp $clientInstanceName:Github/cloud-service-benchmarking/benchmark_output $PWD --zone europe-west3-c --recurse
fi
echo "Done."
