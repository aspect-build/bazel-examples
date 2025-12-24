load("@aspect_rules_js//js:defs.bzl", "js_binary", "js_library")
load("@aspect_rules_ts//ts:defs.bzl", "ts_config", "ts_project")
load("@npm//:defs.bzl", "npm_link_all_packages")

# gazelle:js enabled
# gazelle:generation_mode update_only
package(default_visibility = ["//nodejs_apps/buf_printer:__subpackages__"])

npm_link_all_packages(name = "node_modules")

js_library(
    name = "protos",
    srcs = [
        "genproto/buf/validate/validate_pb.d.ts",
        "genproto/buf/validate/validate_pb.js",
        "genproto/example/v1/example_pb.d.ts",
        "genproto/example/v1/example_pb.js",
    ],
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
        ":node_modules/@bufbuild/protobuf",
        ":protos",  # keep
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
