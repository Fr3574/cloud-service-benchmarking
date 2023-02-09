#!/usr/bin/env bash
clientInstanceName="client"
sut=$1
mode=$2
traceLength=$3
incrementInterval=$4
workers=$5
timestamp=$(date +%F_%T)
results_dir=$PWD/results/${sut}_${mode}_${traceLength}_${incrementInterval}_${timestamp}

echo "Creating results file directory called ${results_dir}"
mkdir ${results_dir}

echo "Querying the results files"
gcloud compute scp $clientInstanceName:Github/cloud-service-benchmarking/output/output_${sut}.csv ${results_dir}/output_${sut}.csv --zone europe-west3-c
if [ $mode == "horizontal" ]; then
    gcloud compute scp $clientInstanceName:~/output/output_${sut}_benchmark.csv ${results_dir}/output_${sut}_benchmark.csv --zone europe-west3-c
else
    for i in $(seq 1 $workers); do
        gcloud compute scp $clientInstanceName:benchmark_output/output_${sut}_benchmark_${i}.csv ${results_dir}/output_${sut}_benchmark_${i}.csv --zone europe-west3-c
    done
fi
echo "Done."
