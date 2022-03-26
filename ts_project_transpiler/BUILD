load("@aspect_rules_swc//swc:swc.bzl", "swc_transpiler")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
# Note, Bazel 6 starlark has lambda so this is no longer needed after upgrade
load("@bazel_skylib//lib:partial.bzl", "partial")
load("babel.bzl", "babel")
load("@npm//@bazel/typescript:index.bzl", "ts_project")

# Create a test fixture that is a non-trivial sized TypeScript program
write_file(
    name = "gen_ts",
    out = "big.ts",
    content = [
        "export const a{0}: number = {0}".format(x)
        for x in range(100000)
    ],
)

_TSCONFIG = {
    "compilerOptions": {
        "declaration": True,
        "sourceMap": False,
    },
}

# Uses TypeScript (tsc) for both type-checking and transpilation
# % bazel build tsc
# INFO: Elapsed time: 6.798s, Critical Path: 5.24s
ts_project(
    name = "tsc",
    srcs = ["big.ts"],
    out_dir = "build-tsc",
    tsconfig = _TSCONFIG,
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
    # Partial allows us to apply some arguments here, while ts_project applies the rest.
    # See https://en.wikipedia.org/wiki/Partial_application
    # and https://docs.aspect.dev/bazelbuild/bazel-skylib/1.1.1/docs/partial.html
    transpiler = partial.make(
        swc_transpiler,
        # Attributes to the swc rule can appear here
        args = ["--env-name=test"],
        swcrc = ".swcrc",
    ),
    srcs = ["big.ts"],
    out_dir = "build-swc",
    tsconfig = _TSCONFIG,
)

# Runs babel to transpile ts -> js
# and tsc to type-check
# % bazel build babel
# INFO: Elapsed time: 3.928s, Critical Path: 3.73s
#
# Like the swc example, you could build babel_typecheck to run tsc.
ts_project(
    name = "babel",
    transpiler = babel,
    srcs = ["big.ts"],
    out_dir = "build-babel",
    tsconfig = _TSCONFIG,
)