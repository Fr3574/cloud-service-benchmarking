#!/usr/bin/env bash
clientInstanceName="client"
sut=$1
filename=output_$sut.csv
resultPath="/home/frederik/Github/cloud-service-benchmarking"

echo "Querying the results file"
gcloud compute scp $clientInstanceName:Github/cloud-service-benchmarking/output/$filename $resultPath/$filename --zone europe-west3-c
echo "Done."
