package main

import (
	"strings"
	"testing"
)

func TestCompare(t *testing.T) {
	result := Compare("this1", "that")

	if !strings.Contains(result, "this1") {
		t.Error("expected a diff containing 'this' but got", result)
	}
}
