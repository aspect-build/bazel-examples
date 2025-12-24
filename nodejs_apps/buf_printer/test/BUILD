"Test that the main binary runs and prints the expected output"

load("@aspect_rules_js//js:defs.bzl", "js_run_binary")
load("@bazel_lib//lib:testing.bzl", "assert_contains")

js_run_binary(
    name = "execute_main",
    stdout = "stdout.txt",
    tool = "//nodejs_apps/buf_printer:main",
)

assert_contains(
    name = "assert_stdout",
    actual = ":execute_main",
    expected = "displayName: 'Alice'",
)
