load("@aspect_rules_js//js:defs.bzl", "js_binary")
load("@aspect_rules_ts//ts:defs.bzl", "ts_config", "ts_project")
load("@npm//:defs.bzl", "npm_link_all_packages")

# gazelle:js enabled
# gazelle:generation_mode update_only
package(default_visibility = ["//nodejs_apps/buf_printer:__subpackages__"])

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
