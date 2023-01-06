package load

import (
	"log"

	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

type BenchmarkConfig struct {
	spanAmount int
}

type Spanner struct {
	tp     *sdktrace.TracerProvider
	config BenchmarkConfig
	logger *log.Logger
}
