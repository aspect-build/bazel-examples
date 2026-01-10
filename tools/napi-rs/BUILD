load("@aspect_rules_js//js:defs.bzl", "js_binary")

js_binary(
    name = "typegen_bin",
    data = ["//tools:node_modules/@napi-rs/cli"],
    entry_point = "napi-rs-typegen.cjs",
    patch_node_fs = False,
    visibility = ["//visibility:public"],
)