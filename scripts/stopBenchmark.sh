#!/usr/bin/env bash
clientInstanceName="client"

echo "Removing benchmark containers"
cmd="sudo docker rm -f \$(sudo docker ps -aq --filter ancestor=benchmark:latest)"
echo $cmd
gcloud compute ssh $clientInstanceName --zone europe-west3-c --command $cmd
echo "Done."