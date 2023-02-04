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
	interval := s.config.traceLength
	counter := 0.0

	// Open a new CSV file
	f, err := os.Create(fmt.Sprintf("benchmark_output/output_%s_benchmark", s.sut))
	if err != nil {
		return err
	}
	defer f.Close()

	// Write the header
	if err = writeHeader(f, []string{"read", "trace_interval"}); err != nil {
		return err
	}

	for {
		go s.createTrace(fmt.Sprintf("%d", traceNumber))
		traceNumber++
		time.Sleep(time.Duration(interval) * time.Second)
		counter += interval
		if counter >= s.config.incrementInterval {
			interval = interval * (1 - s.config.incrementPercentage/100)
			counter = 0.0
			// Write the row
			if err = writeData(f, []string{time.Now().String(), fmt.Sprintf("%.3f", interval)}); err != nil {
				return err
			}
		}
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
