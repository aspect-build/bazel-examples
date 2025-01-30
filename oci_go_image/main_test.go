package main

import (
	"strings"
	"testing"
)

func TestCompare(t *testing.T) {
	result := Compare("this", "that")

	if !strings.Contains(result, "other") {
		t.Error("expected a diff containing 'this' but got", result)
	}
}
