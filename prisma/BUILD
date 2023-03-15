load("@aspect_rules_js//js:defs.bzl", "js_library")
load("@aspect_rules_ts//ts:defs.bzl", "ts_project")
load("@npm//:defs.bzl", "npm_link_all_packages")
load("@npm//:prisma/package_json.bzl", _prisma = "bin")

npm_link_all_packages(name = "node_modules")

_prisma.prisma_test(
    name = "validate",
    env = {
        # Fake env for validation.
        "DATABASE_URL": "postgres://localhost/",
    },
    data = ["schema.prisma"],
    args = [
        "validate",
        "--schema",
        "schema.prisma",
    ],
)

_prisma.prisma(
    name = "generate",
    srcs = [
        "schema.prisma",
        "//:node_modules/@prisma/client",
    ],
    args = [
        "generate",
        "--schema",
        "schema.prisma",
    ],
    env = {
        #
        # Trigger:
        # https://github.com/prisma/engines-wrapper/blob/850bb6fe48c4b9a05ab17e73dbbdf8caacdc6e41/packages/fetch-engine/src/util.ts#L23
        # TODO: This downloads stuff, that's bad! We should properly load this.
        "AWS_LAMBDA_FUNCTION_VERSION": "True",
        # do not install @prisma/client
        "PRISMA_GENERATE_SKIP_AUTOINSTALL": "True",
    },
    out_dirs = ["prisma-client"],
)

js_library(
    name = "prisma-client",
    srcs = [":generate"],
    deps = [
        "//:node_modules/@types/node",
    ],
)

ts_project(
    name = "my-code",
    srcs = ["index.ts"],
    tsconfig = {},
    deps = [":prisma-client"],
)
