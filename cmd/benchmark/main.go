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
	// Define the flags
	sut := flag.String("sut", "tempo", "Defines the SUT (Jaeger or Tempo)")
	mode := flag.String("mode", "horizontal", "Defines the benchmarking mode (horizontal or vertical)")
	traceLength := flag.Float64("trace_length", 1.0, "Defines the length of a trace in seconds")
	incrementInterval := flag.Float64("increment_interval", 1.0, "Defines the interval to increase the load")
	name := flag.String("container_name", "benchmark", "The name of the container")
	flag.Parse()

	tp, err := load.InitProvider(*sut)
	if err != nil {
		log.Fatal(err)
	}

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt)
	defer cancel()

	defer func() {
		if err := tp.Shutdown(ctx); err != nil {
			log.Fatal("failed to shutdown TracerProvider: %w", err)
		}
	}()
	c := load.SetBenchmarkConfig(*mode, *traceLength, *incrementInterval, *name)

	log.Println("Spanner is initializing ...")
	spanner := load.NewSpanner(tp, c, *sut)

	log.Println("Spanner is running ....")
	if err = spanner.Run(); err != nil {
		log.Fatal("failed to start the benchmark run: %w", err)
	}
}
