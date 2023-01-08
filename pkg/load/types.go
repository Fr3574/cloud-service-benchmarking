package load

import (
	"log"

	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

type BenchmarkConfig struct {
	min         int
	traceLength float64
}

type Spanner struct {
	tp     *sdktrace.TracerProvider
	config BenchmarkConfig
	logger *log.Logger
}
