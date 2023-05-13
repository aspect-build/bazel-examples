package main

import (
	"app/pb"
	"fmt"
)

func main() {
	help := pb.Help{
		Topic: "test",
	}
	fmt.Println(help)
}
