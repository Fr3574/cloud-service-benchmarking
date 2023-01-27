package monitor

import (
	"context"
	"encoding/csv"
	"encoding/json"
	"fmt"
	"os"
	"reflect"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/client"
)

type BenchmarkData struct {
	read           string // The timestamp the benchmark was requested
	cpu_usage      string // The CPU usage of the container, as a percentage of the total CPU available on the host.
	memory_usage   string // The memory usage of the container, in megabytes.
	memory_limit   string // The memory limit of the container, in megabytes.
	memory_percent string // The percentage of the memory limit that is being used by the container.
	net_io         string // The network I/O of the container, including the amount of data received and transmitted over the network.
	block_io       string // The block I/O of the container, including the amount of data read from and written to storage devices.
	pids           string // The number of processes running in the container.
	restart_count  string // The number of times the container has been restarted
}

func GetData(cli *client.Client, ctx context.Context, container types.Container) (*BenchmarkData, error) {
	// Get the restart count
	containerJSON, err := cli.ContainerInspect(ctx, container.ID)
	if err != nil {
		return nil, err
	}
	restartCount := fmt.Sprintf("%d", containerJSON.RestartCount)

	// Get the container stats
	stats, err := cli.ContainerStats(ctx, container.ID, false)
	if err != nil {
		return nil, err
	}
	defer stats.Body.Close()

	// Decode the container stats
	var s types.StatsJSON

	if err := json.NewDecoder(stats.Body).Decode(&s); err != nil {
		return nil, err
	}

	// Calculate the CPU usage
	cpuDelta := float64(s.CPUStats.CPUUsage.TotalUsage) - float64(s.PreCPUStats.CPUUsage.TotalUsage)
	systemDelta := float64(s.CPUStats.SystemUsage) - float64(s.PreCPUStats.SystemUsage)
	resultCpuUsage := cpuDelta / systemDelta * float64(s.CPUStats.OnlineCPUs) * 100.0
	// cpuUsage := float64(s.CPUStats.CPUUsage.TotalUsage) / float64(s.CPUStats.SystemUsage) * 100.0
	cpuUsageStr := fmt.Sprintf("%.2f", resultCpuUsage)
	// fmt.Printf("CPU%: %.2f%%\n", cpuUsage)

	// Calculate the memory usage
	memoryUsage := float64(s.MemoryStats.Usage) / float64(1024*1024) // convert bytes to MB
	memoryUsageStr := fmt.Sprintf("%.3f", memoryUsage)
	memoryLimit := float64(s.MemoryStats.Limit) / float64(1024*1024) // convert bytes to MB
	memoryLimitStr := fmt.Sprintf("%.3f", memoryLimit)
	memoryPercent := int(memoryUsage / memoryLimit * 100.0)
	memoryPercentStr := fmt.Sprintf("%d%%", memoryPercent)

	// Calculate the network I/O
	netStats := s.Networks["eth0"]
	netInStr := fmt.Sprintf("%.2fMB", float64(netStats.RxBytes)/float64(1024*1024))
	netOutStr := fmt.Sprintf("%.2fMB", float64(netStats.TxBytes)/float64(1024*1024))

	// Calculate the block I/O
	blockReadStr := "N/A"
	blockWriteStr := "N/A"
	if len(s.BlkioStats.IoServiceBytesRecursive) > 1 {
		blockReadStr = fmt.Sprintf("%.2fMB", float64(s.BlkioStats.IoServiceBytesRecursive[0].Value)/float64(1024*1024))
		blockWriteStr = fmt.Sprintf("%.2fMB", float64(s.BlkioStats.IoServiceBytesRecursive[1].Value)/float64(1024*1024))
	}

	// Calculate the number of processes
	pidsStr := fmt.Sprintf("%d", s.PidsStats.Current)

	return &BenchmarkData{
		read:           s.Read.String(),
		cpu_usage:      cpuUsageStr,
		memory_usage:   memoryUsageStr,
		memory_limit:   memoryLimitStr,
		memory_percent: memoryPercentStr,
		net_io:         netInStr + " / " + netOutStr,
		block_io:       blockReadStr + " / " + blockWriteStr,
		pids:           pidsStr,
		restart_count:  restartCount,
	}, nil
}

func WriteData(data *BenchmarkData, file *os.File) error {
	w := csv.NewWriter(file)
	// Write the row to the CSV file
	row := []string{data.read, data.cpu_usage, data.memory_usage, data.memory_limit, data.memory_percent,
		data.net_io, data.block_io, data.pids, data.restart_count}
	if err := w.Write(row); err != nil {
		return err
	}
	defer w.Flush()
	return nil
}

func WriteHeader(file *os.File) error {
	// Create a new CSV writer
	w := csv.NewWriter(file)
	defer w.Flush()

	// Get the header
	t := reflect.TypeOf(BenchmarkData{})
	header := make([]string, t.NumField())
	// Get the field names and store them in the slice
	for i := 0; i < t.NumField(); i++ {
		header[i] = t.Field(i).Name
	}

	// Write the header
	if err := w.Write(header); err != nil {
		return err
	}

	return nil
}
