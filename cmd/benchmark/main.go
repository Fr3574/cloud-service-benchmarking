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
	flag.Parse()

	l := log.New(os.Stdout, "", 0)

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
	c := load.SetBenchmarkConfig(50)

	spanner := load.NewSpanner(tp, c, l)
	spanner.Run()
}
