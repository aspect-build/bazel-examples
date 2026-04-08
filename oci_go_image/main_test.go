package main

import (
	"strings"
	"testing"
)

func TestCompare(t *testing.T) {
	result := Compare("this32", "that")

	if !strings.Contains(result, "this321") {
		t.Error("expected a diff containing 'this' but got", result)
	}
}
