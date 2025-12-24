load("@aspect_bazel_lib//lib:testing.bzl", "assert_contains")
load("@aspect_rules_js//js:defs.bzl", "js_binary", "js_run_binary")
load("@aspect_rules_ts//ts:defs.bzl", "ts_config", "ts_project")
load("@npm//:defs.bzl", "npm_link_all_packages")

# gazelle:js enabled
# gazelle:generation_mode update_only

npm_link_all_packages(name = "node_modules")

ts_project(
    name = "tsc",
    srcs = ["src/index.mts"],
    out_dir = "dist",
    root_dir = "src",
    tsconfig = ":tsconfig",
    deps = [
        ":node_modules/@bufbuild/protobuf",
        "//nodejs_apps/buf_printer/genproto/example/v1:tsc",
    ],
)

ts_config(
    name = "tsconfig",
    src = "tsconfig.json",
    visibility = [":__subpackages__"],
)

js_binary(
    name = "main",
    data = [":tsc"],
    entry_point = "dist/index.mjs",
)

################################################################################
# Test that the main binary runs and prints the expected output

js_run_binary(
    name = "execute_main",
    stdout = "stdout.txt",
    tool = ":main",
)

assert_contains(
    name = "assert_stdout",
    actual = ":execute_main",
    expected = "displayName: 'Alice'",
)
