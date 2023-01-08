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

	time.Sleep(time.Duration(s.config.traceLength) * time.Second)
}

// Runs the spanner based on the configuration.
func (s *Spanner) Run() {
	// Get the current time
	startTime := time.Now()

	// Run the loop for a certain amount of minutes
	duration := time.Duration(s.config.min) * time.Minute

	// Create a counter
	counter := 0
	s.logger.Println("Spanner starts run.")
	for {
		// Check the elapsed time
		elapsedTime := time.Since(startTime)
		if elapsedTime >= duration {
			break
		}
		s.createTrace(strconv.Itoa(counter))
		counter++
	}
}
