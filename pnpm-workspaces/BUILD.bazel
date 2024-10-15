load("@aspect_rules_js//js:defs.bzl", "js_library")
load("@aspect_rules_ts//ts:defs.bzl", "ts_config")
load("@npm//:defs.bzl", "npm_link_all_packages")
load("@npm//:tsconfig-to-swcconfig/package_json.bzl", tsconfig_to_swcconfig = "bin")

# aspect:generation_mode update

# aspect:map_kind ts_project ts_project //:defs.bzl

# aspect:js enabled
# aspect:js_tsconfig enabled
# aspect:js_npm_package enabled

# aspect:js_files **/*.{js,ts}
# aspect:js_npm_package_target_name pkg
# aspect:js_package_rule_kind js_library
# aspect:js_project_naming_convention tsc

npm_link_all_packages(name = "node_modules")

ts_config(
    name = "tsconfig",
    src = "tsconfig.json",
    visibility = ["//visibility:public"],
    deps = [
        "//:node_modules/@tsconfig/node16-strictest",  #keep
    ],
)

tsconfig_to_swcconfig.t2s(
    name = "write_swcrc",
    srcs = ["tsconfig.json"],
    stdout = ".swcrc",
    visibility = ["//:__subpackages__"],
)

js_library(
    name = "pkg",
    srcs = ["package.json"],
    visibility = ["//visibility:public"],
)
