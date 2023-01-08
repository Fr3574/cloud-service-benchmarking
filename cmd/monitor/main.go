package main

import (
	"context"
	"flag"
	"log"
	"os"
	"time"

	"github.com/Fr3574/cloud-service-benchmarking/pkg/monitor"
)

func main() {
	// Define the flags
	outputFileName := flag.String("output", "output.csv", "Defines the name of the output file")
	monitoringInterval := flag.Int("monitoring_interval", 10, "Defines the interval to monitor the SUT")
	min := flag.Int("min", 5, "Defines the minutes of how long to run the monitoring")
	flag.Parse()

	cli, err := monitor.CreateDockerClient()
	if err != nil {
		log.Fatal(err)
	}
	log.Println("Docker Client created")
	defer cli.Close()

	// Open a new CSV file
	f, err := os.Create("output/" + *outputFileName)
	if err != nil {
		log.Fatal(err)
	}
	log.Printf("CSV file %s created", *outputFileName)
	defer f.Close()

	// Write header to CSV file
	if err = monitor.WriteHeader(f); err != nil {
		log.Fatal(err)
	}

	// Get a list of containers
	containers, err := monitor.GetContainerList(cli)
	if err != nil {
		log.Fatal(err)
	}

	// Get the SUT container
	container, err := monitor.GetSUT(containers)
	if err != nil {
		log.Fatal(err)
	}
	log.Printf("Got a docker container with id %s", container.ID)

	// Get the current time
	startTime := time.Now()

	// Run the loop for a certain amount of minutes
	duration := time.Duration(*min) * time.Minute

	log.Println("Running the monitoring ...")
	for {
		// Check the elapsed time
		elapsedTime := time.Since(startTime)
		if elapsedTime >= duration {
			break
		}

		data, err := monitor.GetData(cli, context.Background(), *container)
		if err != nil {
			log.Fatal(err)
		}
		if err = monitor.WriteData(data, f); err != nil {
			log.Fatal(err)
		}
		time.Sleep(time.Duration(*monitoringInterval) * time.Second)
	}
	log.Println("Finished the monitoring")
}
