load("@aspect_rules_js//js:defs.bzl", "js_binary", "js_library")
load("@aspect_rules_ts//ts:defs.bzl", "ts_project")
load("@npm//:defs.bzl", "npm_link_all_packages")
load("//bzl:generate.bzl", "prisma_generate")
load("//bzl:schema.bzl", "prisma_schema")
load("//bzl:dev.bzl", "prisma_dev")

npm_link_all_packages(name = "node_modules")

prisma_schema(
    name = "schema",
    db_url_env = "DATABASE_URL",
    schema = "schema.prisma",
    validate_db_url = "postgres://localhost/",
)

prisma_generate(
    name = "generate",
    out_dirs = ["prisma-client"],
    schema = ":schema",
    deps = [
        "//:node_modules/@prisma/client",
    ],
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
    srcs = [
        "index.ts",
        "seed.ts",
    ],
    tsconfig = {},
    deps = [":prisma-client"],
)

prisma_dev(
    name = "dev",
    db_url = ":db_detector",
    schema = "schema",
    seed_script = ":seed",
)

sh_binary(
    name = "db_detector",
    srcs = ["detect-db.sh"],
)

js_binary(
    name = "seed",
    entry_point = "seed.js",
)
