package greeter

import (
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"testing"
)

func TestGreet(t *testing.T) {
	got := Greet("World")
	want := "Hello, World!"
	if got != want {
		t.Errorf("got %q, want %q", got, want)
	}
}

func TestGoldenOutput(t *testing.T) {
	// testdata/expected_greeting.txt is declared as a data dep in BUILD.bazel.
	// Bazel makes only declared data deps visible to the test action — if the
	// file is removed from BUILD.bazel, this test fails with "no such file",
	// proving that hermetic inputs are enforced at the build level.
	runfiles := os.Getenv("TEST_SRCDIR")
	path := filepath.Join(runfiles, "_main", "hermetic_tests", "go", "testdata", "expected_greeting.txt")
	golden, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("could not read golden file (is it declared in data?): %v", err)
	}
	got := Greet("World")
	if want := strings.TrimSpace(string(golden)); got != want {
		t.Errorf("Greet(\"World\") = %q, golden says %q", got, want)
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
