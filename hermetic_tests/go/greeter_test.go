package greeter

import (
	"runtime"
	"testing"
)

func TestGreet(t *testing.T) {
	got := Greet("World")
	want := "Hello, World!"
	if got != want {
		t.Errorf("got %q, want %q", got, want)
	}
}

func TestHermeticToolchain(t *testing.T) {
	// rules_go pins the Go SDK in MODULE.bazel (go_sdk.download version = "1.24.5").
	// If this test is compiled with any other Go version, it fails — proving the
	// hermetic toolchain is in use regardless of what Go is installed on the host.
	const want = "go1.24.5"
	if got := runtime.Version(); got != want {
		t.Errorf("Go version = %q, want %q — hermetic toolchain not in use", got, want)
	}
}
