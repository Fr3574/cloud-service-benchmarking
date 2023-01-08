package monitor

import (
	"context"
	"fmt"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/client"
)

// Get the SUT Container
func GetSUT(containers []types.Container) (*types.Container, error) {
	for _, container := range containers {
		for _, name := range container.Names {
			if name == "/tempo" || name == "/jaeger" {
				return &container, nil
			}
		}
	}
	return nil, fmt.Errorf("no container found that matches tempo or jaeger")
}

// Create a new Docker client
func CreateDockerClient() (*client.Client, error) {
	cli, err := client.NewClientWithOpts(client.FromEnv)
	if err != nil {
		return nil, err
	}
	return cli, nil
}

// Get a list of containers
func GetContainerList(cli *client.Client) ([]types.Container, error) {
	// Get a list of containers
	containers, err := cli.ContainerList(context.Background(), types.ContainerListOptions{})
	if err != nil {
		return nil, err
	}
	return containers, nil
}
