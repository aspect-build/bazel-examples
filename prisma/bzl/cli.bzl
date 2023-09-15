"""Prisma tool (with engines) for running in the exec configuration.

This can be used to automatically bind over the engines required for the host.

Attention: This cannot be used for cross building (the engines always match the exec platform).
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@npm//:prisma/package_json.bzl", _prisma = "bin")
load(":providers.bzl", "PrismaEnginesInfo")

def _prisma_cli_impl(ctx):
    prisma_bin_info = ctx.attr.prisma_bin[DefaultInfo]

    engines = ctx.attr._prisma_engines[PrismaEnginesInfo]

    runfiles = ctx.runfiles(
        files = [
            engines.libquery_engine,
            engines.query_engine,
            engines.schema_engine,
        ],
    ).merge(prisma_bin_info.default_runfiles)

    ctx.actions.expand_template(
        template = ctx.file._cli_tpl,
        output = ctx.outputs.out,
        is_executable = True,
        substitutions = {
            "{{LIBQUERY_ENGINE}}": paths.join(ctx.workspace_name, engines.libquery_engine.short_path),
            "{{PRISMA_BIN}}": paths.join(ctx.workspace_name, prisma_bin_info.files_to_run.executable.short_path),
            "{{QUERY_ENGINE}}": paths.join(ctx.workspace_name, engines.query_engine.short_path),
            "{{SCHEMA_ENGINE}}": paths.join(ctx.workspace_name, engines.schema_engine.short_path),
        },
    )

    return DefaultInfo(
        executable = ctx.outputs.out,
        runfiles = runfiles,
    )

_prisma_cli = rule(
    attrs = {
        "out": attr.output(),
        "prisma_bin": attr.label(),
        "_cli_tpl": attr.label(
            allow_single_file = True,
            default = Label(":cli.tpl.sh"),
        ),
        "_prisma_engines": attr.label(
            providers = [PrismaEnginesInfo],
            default = Label("@prisma//:engines"),
            cfg = "exec",
        ),
    },
    executable = True,
    implementation = _prisma_cli_impl,
)

def prisma_cli(name, visibility = None, testonly = None):
    """Prisma CLI with engines (for running the CLI in the same config than the engines)."""

    _prisma.prisma_binary(
        name = name + ".bin",
        testonly = testonly,
    )

    _prisma_cli(
        name = name,
        out = name + ".prisma.sh",
        prisma_bin = name + ".bin",
        visibility = visibility,
        testonly = testonly,
    )
