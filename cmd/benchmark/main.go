package main

import (
	"context"
	"flag"
	"log"
	"os"
	"os/signal"

	"github.com/Fr3574/cloud-service-benchmarking/pkg/load"
)

func main() {
	// Get the SUT
	sut := flag.String("sut", "tempo", "Defines the SUT (Jaeger or Tempo)")
	traceLength := flag.Float64("trace_length", 1.0, "Defines the length of a trace")
	min := flag.Int("min", 30, "Defines the minutes of how long to run the tracer")
	flag.Parse()

	l := log.New(os.Stdout, "", 0)

	tp, err := load.InitProvider(*sut)
	if err != nil {
		l.Fatal(err)
	}

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt)
	defer cancel()

	defer func() {
		if err := tp.Shutdown(ctx); err != nil {
			l.Fatal("failed to shutdown TracerProvider: %w", err)
		}
	}()
	c := load.SetBenchmarkConfig(*min, *traceLength)

	spanner := load.NewSpanner(tp, c, l)
	spanner.Run()
}
