load("@aspect_rules_swc//swc:defs.bzl", "swc_transpiler")
load("@aspect_rules_ts//ts:defs.bzl", "ts_project")
load("@aspect_rules_js//js:defs.bzl", "js_binary")

load("@bazel_skylib//lib:partial.bzl", "partial")
load("@npm//:defs.bzl", "npm_link_all_packages")

npm_link_all_packages(name = "node_modules")

# For more information about using swc to transpile please see the ts_project_transpiler example
ts_project(
    name = "swc",
    srcs = [
        "src/app.controller.ts",
        "src/app.module.ts",
        "src/app.service.ts",
        "src/main.ts",
    ],
    transpiler = partial.make(
        swc_transpiler,
        swcrc = ".swcrc",
    ),
    deps = [
        ":node_modules/@nestjs/common",
        ":node_modules/@nestjs/core",
    ],
)

js_binary(
    name = "bin",
    entry_point = "src/main.js",
    data = [
        ":swc",

        # Added by swc during transpilation and used at runtime
        ":node_modules/regenerator-runtime",
    ],
)
