"""prisma_generate rule."""

load("@npm//:prisma/package_json.bzl", _prisma = "bin")
load("@aspect_rules_js//js:providers.bzl", "JsInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")
load(":providers.bzl", "PrismaEnginesInfo", "PrismaSchemaInfo")

def _prisma_generate_impl(ctx):
    out_dirs = [
        ctx.actions.declare_directory(out_dir)
        for out_dir in ctx.attr.out_dirs
    ]

    schema = ctx.attr.schema[PrismaSchemaInfo].schema

    engines = ctx.attr._prisma_engines[PrismaEnginesInfo]

    inputs = depset(
        direct = [
            schema,
            engines.query_engine,
            engines.libquery_engine,
            engines.schema_engine,
        ],
        transitive = [
            d[JsInfo].transitive_sources
            for d in ctx.attr.deps
        ] + [
            d[JsInfo].transitive_npm_linked_package_files
            for d in ctx.attr.deps
        ],
    )

    ctx.actions.run(
        executable = ctx.executable.prisma,
        arguments = ["generate", "--schema", schema.short_path],
        inputs = inputs,
        outputs = out_dirs,
        # buildifier: disable=unsorted-dict-items
        env = {
            "BAZEL_BINDIR": ctx.bin_dir.path,

            # do not install @prisma/client
            "PRISMA_GENERATE_SKIP_AUTOINSTALL": "True",

            # Prisma engines.
            "PRISMA_SCHEMA_ENGINE_BINARY": paths.relativize(engines.schema_engine.path, ctx.bin_dir.path),
            "PRISMA_QUERY_ENGINE_BINARY": paths.relativize(engines.query_engine.path, ctx.bin_dir.path),
            "PRISMA_QUERY_ENGINE_LIBRARY": paths.relativize(engines.libquery_engine.path, ctx.bin_dir.path),

            # Set Prisma env variables for unused engines to make sure nothing gets downloaded.
            "PRISMA_FMT_BINARY": "unused",
            "PRISMA_INTROSPECTION_ENGINE_BINARY": "unused",
        },
    )

    return DefaultInfo(files = depset(out_dirs))

_prisma_generate = rule(
    implementation = _prisma_generate_impl,
    attrs = {
        "deps": attr.label_list(providers = [JsInfo]),
        "out_dirs": attr.string_list(),
        "prisma": attr.label(
            executable = True,
            cfg = "exec",
        ),
        "schema": attr.label(
            providers = [PrismaSchemaInfo],
        ),
        "_prisma_engines": attr.label(
            providers = [PrismaEnginesInfo],
            default = Label("@prisma//:engines"),
        ),
    },
)

def prisma_generate(name, schema, deps, out_dirs, visibility = None, testonly = None):
    """Rule to set-up prisma client generation."""

    # Instantiate a "bare" prisma binary here:
    # We need engines in a different configuration than the binary itself.
    _prisma.prisma_binary(
        name = name + ".bin",
        testonly = testonly,
    )

    _prisma_generate(
        name = name,
        schema = schema,
        out_dirs = out_dirs,
        deps = deps,
        prisma = name + ".bin",
    )
