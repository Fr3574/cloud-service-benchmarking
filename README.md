# Cloud-Service-Benchmarking: Jaeger vs Tempo

[![Report (PDF)](https://img.shields.io/badge/Download-Report%20(PDF)-blue?logo=adobe-acrobat-reader)](https://drive.google.com/file/d/12by4J2KbiBXSsMaZoozTnNXlnhT4T2Zi/view)

## Prerequisites
- [![Terraform for GCP](https://img.shields.io/badge/Install-Terraform%20for%20GCP-green?logo=terraform)](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#set-up-gcp)
- [![Install gcloud CLI](https://img.shields.io/badge/Install-gcloud%20CLI-yellow?logo=google-cloud)](https://cloud.google.com/sdk/docs/install?hl=en)

## Set your configuration as environment variables
```bash
export sut=<jaeger | tempo>
export mode=<horizontal | vertical>
export traceLength=<int>
export incrementInterval=<int>
export workers=<int>  # (only relevant if mode=vertical)
```
## Run Experiments

1. Setup the System (choose either a jaeger or tempo): `terraform -chdir=terraform/ apply -var sut=$sut`

1. Run the benchmark: `./scripts/runBenchmark.sh $sut $mode $traceLength $incrementInterval $workers`

1. Stop the benchmark (optional): `./scripts/stopBenchmark.sh`

1. Download the data: `./scripts/downloadStats.sh $sut $mode $traceLength $incrementInterval $workers`

5. Clean up the resources: `terraform -chdir=terraform/ destroy -var sut=$sut`
