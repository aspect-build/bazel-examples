load("@aspect_rules_ts//ts:defs.bzl", "ts_config")
load("@npm//:defs.bzl", "npm_link_all_packages")

# gazelle:js enabled

ts_config(
    name = "tsconfig",
    src = "tsconfig.json",
    visibility = [":__subpackages__"],
)

npm_link_all_packages(name = "node_modules")
