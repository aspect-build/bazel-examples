load("@prisma-example//bzl:constants.bzl", "PLATFORMS")
load("@prisma-example//bzl:cli.bzl", "prisma_cli")

prisma_cli(
    name = "cli",
    visibility = ["//visibility:public"],
)

alias(
    name = "engines",
    actual = select({
        "@prisma-example//configs:" + platform: "@prisma_engines_" + platform + "//:engines"
        for platform in PLATFORMS.keys()
    }),
    visibility = ["//visibility:public"],
)
