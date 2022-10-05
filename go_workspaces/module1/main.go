package main

import (
	"fmt"
	"time"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/nathan-osman/go-sunrise"
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
			amount := btcutil.Amount(100)
			fmt.Printf("amount %v\n", amount)
		},
	}

	fmt.Println("Calling cmd.Execute()!")
	cmd.Execute()
}
