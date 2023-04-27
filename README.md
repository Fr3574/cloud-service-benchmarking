# Cloud-Service-Benchmarking: Jaeger vs Tempo

## Prerequisites
- [terraform for GCP](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#set-up-gcp)
- [gcloud CLI](https://cloud.google.com/sdk/docs/install?hl=en)

## Set your config as env variables
```
sut=<jaeger | tempo>
mode=<horizontal | vertical>
traceLength=<int>
incrementInterval=<int>
workers=<int> (only relevant if mode=vertical)
```
## Run Experiments

1. Setup the System (choose either a jaeger or tempo)
```
terraform -chdir=terraform/ apply -var sut=$sut
```

2. Run the benchmark
```
./scripts/runBenchmark.sh $sut $mode $traceLength $incrementInterval $workers
```

3. Stop the benchmark (optional)
```
./scripts/stopBenchmark.sh
```

4. Download the data
```
./scripts/downloadStats.sh $sut $mode $traceLength $incrementInterval $workers
```

5. Clean up the resources
```
terraform -chdir=terraform/ destroy -var sut=$sut
```