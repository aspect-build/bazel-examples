load("@aspect_rules_ts//ts:defs.bzl", "ts_project")
load("@bazel_gazelle//:def.bzl", "gazelle")

gazelle(
    name = "gazelle",
    data = [],
    gazelle = "@aspect_rules_ts_gazelle//:gazelle_js_binary",
)

ts_project(
    name = "ts_gazelle",
    srcs = ["lib/foo.ts"],
)
