load("@aspect_rules_swc//swc:defs.bzl", "swc")
load("@aspect_rules_ts//ts:defs.bzl", "ts_project")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@bazel_skylib//lib:partial.bzl", "partial")
load("@npm//:defs.bzl", "npm_link_all_packages")
load("babel.bzl", "babel")
load("@bazel_skylib//rules:build_test.bzl", "build_test")

# This macro expands to a link_npm_package for each third-party package in package.json
npm_link_all_packages(name = "node_modules")

# Create a test fixture that is a non-trivial sized TypeScript program
write_file(
    name = "gen_ts",
    out = "big.ts",
    content = [
        "export const a{0}: number = {0}".format(x)
        for x in range(100000)
    ],
)

# Uses TypeScript (tsc) for both type-checking and transpilation
# % bazel build tsc
# INFO: Elapsed time: 6.798s, Critical Path: 5.24s
ts_project(
    name = "tsc",
    srcs = ["big.ts"],
    declaration = True,
    declaration_dir = "build-tsc",
    out_dir = "build-tsc",
    source_map = True,
)

# Runs swc to transpile ts -> js
# and tsc to type-check.
# % bazel build swc
# INFO: Elapsed time: 0.745s, Critical Path: 0.54s
#
# Optionally, or on CI, you can explicitly do the slow type-check:
# $ bazel build swc_typecheck
# INFO: Elapsed time: 3.330s, Critical Path: 3.19s
ts_project(
    name = "swc",
    srcs = ["big.ts"],
    declaration = True,
    out_dir = "build-swc",
    source_map = True,
    # Partial allows us to apply some arguments here, while ts_project applies the rest.
    # See https://en.wikipedia.org/wiki/Partial_application
    # and https://docs.aspect.dev/bazelbuild/bazel-skylib/1.1.1/docs/partial.html
    transpiler = partial.make(
        swc,
        # Attributes to the swc rule can appear here
        args = ["--env-name=test"],
        out_dir = "build-swc",
        swcrc = ".swcrc",
        source_maps = "true",
    ),
)

# Runs babel to transpile ts -> js
# and tsc to type-check
# % bazel build babel
# INFO: Elapsed time: 3.928s, Critical Path: 3.73s
#
# Like the swc example, you could build babel_typecheck to run tsc.
ts_project(
    name = "babel",
    srcs = ["big.ts"],
    declaration = True,
    declaration_dir = "build-babel",
    out_dir = "build-babel",
    source_map = True,
    # Partial allows us to apply some arguments here, while ts_project applies the rest.
    # See https://en.wikipedia.org/wiki/Partial_application
    # and https://docs.aspect.dev/bazelbuild/bazel-skylib/1.1.1/docs/partial.html
    transpiler = partial.make(
        babel,
        out_dir = "build-babel",
    ),
)

# Test each example transpiler produces the same outputs.
[
    build_test(
        name = "%s_test" % compiler,
        targets = [
            "%s" % compiler,
            "build-%s/big.js" % compiler,
            "build-%s/big.js.map" % compiler,
            "build-%s/big.d.ts" % compiler,
        ],
    )
    for compiler in [
        "tsc",
        "swc",
        "babel",
    ]
]
