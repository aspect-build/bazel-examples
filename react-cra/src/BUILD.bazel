load("@aspect_rules_jest//jest:defs.bzl", "jest_test")
load("@aspect_rules_js//js:defs.bzl", "js_library")
load("@aspect_rules_swc//swc:defs.bzl", "swc")
load("@aspect_rules_ts//ts:defs.bzl", "ts_project")
load("@bazel_skylib//lib:partial.bzl", "partial")
load("@npm//:eslint/package_json.bzl", eslint_bin = "bin")

ASSET_PATTERNS = [
    "*.svg",
    "*.css",
]

SRC_PATTERNS = [
    "*.tsx",
    "*.ts",
]

TRANSPILER = partial.make(
    swc,
    swcrc = "//:.swcrc",
)

# Filename conventions described at
# https://create-react-app.dev/docs/running-tests#filename-conventions
TEST_PATTERNS = [
    "*.test.tsx",
    "*.test.ts",
    "*.spec.tsx",
    "*.spec.ts",
]

js_library(
    name = "src",
    srcs = glob(ASSET_PATTERNS),
    visibility = ["//visibility:public"],
    deps = [
        ":src_ts",
    ],
)

ts_project(
    name = "src_ts",
    srcs = glob(
        include = SRC_PATTERNS,
        exclude = TEST_PATTERNS,
    ),
    declaration = True,
    resolve_json_module = True,
    transpiler = TRANSPILER,
    tsconfig = "//:tsconfig",
    deps = [
        "//:node_modules/react",
        "//:node_modules/react-dom",
        "//:node_modules/web-vitals",
    ],
)

ts_project(
    name = "src_test_ts",
    srcs = glob(TEST_PATTERNS),
    declaration = True,
    resolve_json_module = True,
    supports_workers = False,  # worker bug on macos: ERROR: react-cra/src/BUILD.bazel:50:11: output 'src/App.test.js' was not created
    transpiler = TRANSPILER,
    tsconfig = "//:tsconfig",
    deps = [
        ":src_ts",
        "//:node_modules/@testing-library/jest-dom",
        "//:node_modules/@testing-library/react",
        "//:node_modules/@types/jest",
    ],
)

jest_test(
    name = "src_test",
    config = "//:jest_config",
    data = [
        ":src",
        ":src_test_ts",
        "//:node_modules/jest-environment-jsdom",
        "//:node_modules/jest-transform-stub",
    ],
    node_modules = "//:node_modules",
)

eslint_bin.eslint_test(
    name = "eslint_test",
    args = ["{}/{}".format(
        package_name(),
        p,
    ) for p in SRC_PATTERNS],
    data = [
        "//:package_json",
        "//:node_modules/eslint-config-react-app",
    ] + glob(SRC_PATTERNS),
    timeout = "short",
)
