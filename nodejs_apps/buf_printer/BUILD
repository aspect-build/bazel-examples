load("@aspect_bazel_lib//lib:testing.bzl", "assert_contains")
load("@aspect_rules_js//js:defs.bzl", "js_binary", "js_library", "js_run_binary")
load("@aspect_rules_ts//ts:defs.bzl", "ts_config", "ts_project")
load("@npm//:defs.bzl", "npm_link_all_packages")

# gazelle:js enabled
# gazelle:generation_mode update_only

npm_link_all_packages(name = "node_modules")

js_library(
    name = "example_pb",
    srcs = glob([
        "genproto/**/*_pb.js",
        "genproto/**/*_pb.d.ts",
    ]),
    deps = [":node_modules/@bufbuild/protobuf"],
)

ts_project(
    name = "tsc",
    srcs = [
        "genproto/example/v1/example_pb.js",
        "src/index.mts",
    ],
    out_dir = "dist",
    root_dir = "src",
    tsconfig = ":tsconfig",
    deps = [
        ":example_pb",
        ":node_modules/@bufbuild/protobuf",
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
