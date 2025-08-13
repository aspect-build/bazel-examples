package main

import (
	"fmt"

	"github.com/google/go-cmp/cmp"
)

func Compare(str1, str2 string) string {
	return cmp.Diff(str1, str2)
}

func main() {
	fmt.Println(Compare("Hello World", "Hello Yoga"))
}
