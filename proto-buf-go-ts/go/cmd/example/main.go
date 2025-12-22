package main

import (
	"fmt"

	examplev1 "github.com/aspect-build/bazel-examples/proto-buf-go-ts/go/genproto/example/v1"
)

func main() {
	u := &examplev1.ExampleUser{
		Id:          "123e4567-e89b-12d3-a456-426614174000",
		Email:       "alice@example.com",
		DisplayName: "Alice",
		Age:         42,
	}
	fmt.Printf("user=%v\n", u)
}
