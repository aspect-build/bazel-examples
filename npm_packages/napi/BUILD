load("@aspect_rules_js//js:defs.bzl", "js_library")
load("@npm//:defs.bzl", "npm_link_all_packages")

npm_link_all_packages(name = "node_modules")

js_library(
    name = "pkg",
    srcs = [
        "package.json",
        "//npm_packages/napi/src:pkg_contents",
    ],
    visibility = ["//visibility:public"],
)
