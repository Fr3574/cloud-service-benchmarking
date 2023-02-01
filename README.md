# Cloud-Service-Benchmarking: Jaeger vs Tempo

## Setup the System (choose either a jaeger or tempo)
```
terraform -chdir=terraform/ apply -var sut=<"jaeger"|"tempo">
```

## Run the benchmark
```
./scripts/runBenchmark.sh <"jaeger"|"tempo"> <"horizontal"|"vertical"> <incrementInterval int> <incrementPercentage int (only for vertical scaling)>
```

## Stop the benchmark
```
./scripts/stopBenchmark.sh
```

## Download the data
```
./scripts/downloadStats.sh <"jaeger"|"tempo">
```

## Clean up the resources
```
terraform -chdir=terraform/ destroy -var sut=<"jaeger"|"tempo">
```