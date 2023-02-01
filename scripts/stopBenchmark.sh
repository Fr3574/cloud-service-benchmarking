#!/usr/bin/env bash
clientInstanceName="client"

echo "Removing benchmark containers"
cmd="sudo docker rm $(docker ps -a | grep "benchmark" | awk '{print $1}')"
echo $cmd
gcloud compute ssh $clientInstanceName --zone europe-west3-c -- $cmd
echo "Done."
