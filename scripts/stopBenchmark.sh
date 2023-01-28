#!/usr/bin/env bash
clientInstanceName="client"

echo "Removing benchmark container"
cmd="sudo docker rm -f benchmark"
echo $cmd
gcloud compute ssh $clientInstanceName --zone europe-west3-c -- $cmd
echo "Done."
