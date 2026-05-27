package greeter

import (
	"os"
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

func TestSandboxEscapeAttempt(t *testing.T) {
	// Attempt to write a file outside the declared sandbox outputs.
	// A properly isolated sandbox (local or RBE container) should block this.
	// The test PASSES when the write is denied, proving sandbox containment.
	err := os.WriteFile("/etc/sandbox_escape.txt", []byte("escaped"), 0644)
	if err == nil {
		os.Remove("/etc/sandbox_escape.txt")
		t.Fatal("wrote to /etc/sandbox_escape.txt — sandbox did not contain the action")
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
