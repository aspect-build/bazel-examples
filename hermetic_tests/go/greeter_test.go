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
	// Attempt to change the kernel hostname — requires CAP_SYS_ADMIN, which
	// RBE containers do not have. The write must fail, proving the container
	// is running without elevated capabilities.
	err := os.WriteFile("/proc/sys/kernel/hostname", []byte("escaped"), 0644)
	if err == nil {
		t.Fatal("wrote to /proc/sys/kernel/hostname — container has CAP_SYS_ADMIN (not sandboxed)")
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
