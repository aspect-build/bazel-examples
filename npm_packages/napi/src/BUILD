load("@aspect_rules_ts//ts:defs.bzl", "ts_project")
load("@bazel_lib//lib:copy_file.bzl", "copy_file")
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")
load("//tools/napi-rs:defs.bzl", "napi_rust_shared_library")

cc_library(
    name = "adder",
    srcs = ["adder.c"],
    hdrs = ["adder.h"],
)

cc_binary(
    name = "adder_binding",
    srcs = ["adder_binding.c"],
    linkopts = [
        "-undefined",
        "dynamic_lookup",  # required on macOS
    ],
    linkshared = True,
    linkstatic = True,
    visibility = ["//visibility:public"],
    deps = [
        ":adder",
        "@rules_nodejs//nodejs/headers:current_node_cc_headers",  # keep
    ],
)

napi_rust_shared_library(
    name = "hello_binding",
    srcs = ["lib.rs"],
    proc_macro_deps = ["@crate_index//:napi-derive"],
    deps = ["@crate_index//:napi"],
)

# Need to rename the files from .so/.dylib to .node for Node.js
copy_file(
    name = "copy_c_binding",
    src = ":adder_binding",
    out = "my_native_c.node",
    visibility = ["//visibility:public"],
)

ts_project(
    name = "tsc",
    srcs = ["index.ts"],
    data = [
        ":copy_c_binding",
    ],
    declaration = True,
    tsconfig = "//npm_packages:tsconfig",
    visibility = ["//visibility:public"],
    deps = [
        "hello_binding",
        "//npm_packages/napi:node_modules/@types/node",
    ],
)
