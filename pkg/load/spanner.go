package load

import (
	"context"
	"log"
	"strconv"
	"time"

	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

// Returns a new spanner
func NewSpanner(tp *sdktrace.TracerProvider, c BenchmarkConfig, l *log.Logger) *Spanner {
	l.Println("Spanner is initialized.")
	return &Spanner{tp: tp, config: c, logger: l}
}

// Creates a Trace
func (s *Spanner) createTrace(name string) {
	s.logger.Println("Trace is created.")
	// Each execution of the run loop, we should get a new "root" span and context.
	_, span := s.tp.Tracer("test").Start(context.Background(), name)
	defer span.End()

	time.Sleep(1 * time.Second)
}

// Runs the spanner based on the configuration.
func (s *Spanner) Run() {
	s.logger.Println("Spanner starts run.")
	for i := 0; i < s.config.spanAmount; i++ {
		s.createTrace(strconv.Itoa(i))
	}
}
