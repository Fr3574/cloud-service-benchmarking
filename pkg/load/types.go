package load

import (
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

type BenchmarkConfig struct {
	mode                string
	traceLength         float64
	incrementInterval   float64
	incrementPercentage float64
}

type Spanner struct {
	tp     *sdktrace.TracerProvider
	config BenchmarkConfig
	sut    string
}
