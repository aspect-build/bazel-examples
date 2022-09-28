package main

import (
	"fmt"
	"time"

	"github.com/nathan-osman/go-sunrise"
)

func main() {
	rise, set := sunrise.SunriseSunset(
		43.65, -79.38, // Toronto, CA
		2022, time.September, 26, // 2000-01-01
	)
	fmt.Printf("sunrise %v sunset %v\n", rise, set)
}
