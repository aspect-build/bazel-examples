"""Helper macro for prisma engine store."""

load(":constants.bzl", "BINARY_TYPES")
load(":lib.bzl", "get_binary_name")
load(":providers.bzl", "PrismaEnginesInfo")

def _prisma_engines_impl(ctx):
    return [
        PrismaEnginesInfo(
            schema_engine = ctx.file.schema_engine,
            libquery_engine = ctx.file.libquery_engine,
            query_engine = ctx.file.query_engine,
        ),
    ]

_prisma_engines = rule(
    implementation = _prisma_engines_impl,
    attrs = {
        "libquery_engine": attr.label(allow_single_file = True),
        "query_engine": attr.label(allow_single_file = True),
        "schema_engine": attr.label(allow_single_file = True),
    },
)

def prisma_engines_store(name, platform):
    """Load prisma engines.

    Args:
      name: Name of the main target (typically `engines`).
      platform: Prisma platform name.
    """

    for binary_type in BINARY_TYPES:
        binary_name = get_binary_name(binary_type, platform)

        native.genrule(
            name = binary_type,
            srcs = [binary_name + ".gz"],
            outs = [binary_name],
            cmd = "gunzip -c $< > $@",
        )

    _prisma_engines(
        name = name,
        schema_engine = ":schema-engine",
        query_engine = ":query-engine",
        libquery_engine = ":libquery-engine",
        visibility = ["//visibility:public"],
    )
