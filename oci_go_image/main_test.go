package main

import (
	"strings"
	"testing"
)

func TestCompare(t *testing.T) {
	result := Compare("this", "that")

	t.Log("DNL: intentionally failing to exercise test log reporting in PR status checks")
	t.Logf("Compare output:\n%s", result)

	if !strings.Contains(result, "DNL-intentional-failure") {
		t.Error("expected a diff containing 'DNL-intentional-failure' but got", result)
	}
}
