package main

import "fmt"

// Add returns the sum of two integers.
func Add(a, b int) int {
	return a + b
}

func main() {
	fmt.Println("2 + 2 =", Add(2, 2))
}
