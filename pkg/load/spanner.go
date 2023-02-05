package load

import (
	"context"
	"fmt"
	"os"
	"time"

	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

// Returns a new spanner
func NewSpanner(tp *sdktrace.TracerProvider, c BenchmarkConfig, sut string) *Spanner {
	return &Spanner{
		tp:     tp,
		config: c,
		sut:    sut,
	}
}

// Creates a Trace
func (s *Spanner) createTrace(name string) {
	// Each execution of the run loop, we should get a new "root" span and context.
	_, span := s.tp.Tracer("test").Start(context.Background(), name)
	defer span.End()

	time.Sleep(time.Duration(s.config.traceLength * float64(time.Second)))
}

// Runs the spanner in the horizontal mode
func (s *Spanner) runHorizontal() error {
	traceNumber := 0
	for {
		s.createTrace(fmt.Sprintf("%d", traceNumber))
		traceNumber++
	}
}

// Runs the spanner in the vertical mode
func (s *Spanner) runVertical() error {
	traceNumber := 0
	traceCounter := 1
	sleepInterval := s.config.incrementInterval / float64(traceCounter)

	// Open a new CSV file
	f, err := os.Create(fmt.Sprintf("benchmark_output/output_%s_%s.csv", s.sut, s.config.name))
	if err != nil {
		return err
	}
	defer f.Close()

	// Write the header
	if err = writeHeader(f, []string{"read", "traces"}); err != nil {
		return err
	}

	for {
		for i := 1; i <= traceCounter; i++ {
			go s.createTrace(fmt.Sprintf("%d", traceNumber))
			time.Sleep(time.Duration(sleepInterval * float64(time.Second)))
			traceNumber++
		}
		if err = writeData(f, []string{time.Now().String(), fmt.Sprintf("%d", traceCounter)}); err != nil {
			return err
		}
		traceCounter++
		sleepInterval = s.config.incrementInterval / float64(traceCounter)
	}
}

// Runs the spanner based on the configuration.
func (s *Spanner) Run() error {
	if s.config.mode == "horizontal" {
		if err := s.runHorizontal(); err != nil {
			return err
		}
	} else if s.config.mode == "vertical" {
		if err := s.runVertical(); err != nil {
			return err
		}
	} else {
		return fmt.Errorf("there is no run implemented for the mode: %s", s.config.mode)
	}
	return fmt.Errorf("spanner unexpectetly ended running")
}
