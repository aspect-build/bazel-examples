package main

import (
	"fmt"
	"time"

	"github.com/nathan-osman/go-sunrise"
	zmq "github.com/pebbe/zmq4"
	"github.com/spf13/cobra"
)

func main() {
	cmd := &cobra.Command{
		Run: func(cmd *cobra.Command, args []string) {
			rise, set := sunrise.SunriseSunset(
				43.65, -79.38, // Toronto, CA
				2022, time.September, 26, // 2000-01-01
			)
			fmt.Printf("sunrise %v sunset %v\n", rise, set)
			reactor := zmq.NewReactor()
			fmt.Printf("reactor %v\n", reactor)
		},
	}

	fmt.Println("Calling cmd.Execute()!")
	cmd.Execute()
}
