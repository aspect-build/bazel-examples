package main

import (
	"testing"
)

func TestGenerateNumber(t *testing.T) {
	result := Compare("this", "that")

	if result == "" {
		t.Error("got an empty string")
	}
}
