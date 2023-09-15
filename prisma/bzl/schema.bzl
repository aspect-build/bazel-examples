"""prisma_schema rule."""

load("@aspect_bazel_lib//lib:copy_to_bin.bzl", "copy_file_to_bin_action")
load("@aspect_bazel_lib//lib:write_source_files.bzl", "write_source_files")
load(":providers.bzl", "PrismaSchemaInfo")

def _validate_schema(ctx, schema):
    validation_marker = ctx.actions.declare_file(ctx.label.name + ".validation")

    ctx.actions.run_shell(
        command = "$1 validate --schema $2 && touch $3",
        arguments = [
            ctx.executable._prisma_tool.path,
            schema.path,
            validation_marker.path,
        ],
        env = {
            "BAZEL_BINDIR": ".",
            ctx.attr.db_url_env: ctx.attr.validate_db_url,
        },
        inputs = [schema],
        tools = [ctx.executable._prisma_tool],
        outputs = [validation_marker],
    )

    return validation_marker

def _format_schema(ctx, schema):
    ctx.actions.run_shell(
        command = "cp --no-preserve=mode $2 $3 && $1 format --schema $3",
        arguments = [
            ctx.executable._prisma_tool.path,
            schema.path,
            ctx.outputs.formatted_schema.path,
        ],
        env = {"BAZEL_BINDIR": "."},
        inputs = [schema],
        outputs = [ctx.outputs.formatted_schema],
        tools = [ctx.executable._prisma_tool],
    )

def _prisma_schema_impl(ctx):
    schema = copy_file_to_bin_action(ctx, ctx.file.schema)

    validation_marker = _validate_schema(ctx, schema)

    _format_schema(ctx, schema)

    return [
        DefaultInfo(
            files = depset([schema]),
        ),
        PrismaSchemaInfo(
            schema = schema,
            db_url_env = ctx.attr.db_url_env,
        ),
        OutputGroupInfo(
            _validation = depset([validation_marker]),
        ),
    ]

_prisma_schema = rule(
    implementation = _prisma_schema_impl,
    attrs = {
        "db_url_env": attr.string(
            mandatory = True,
        ),
        "formatted_schema": attr.output(),
        "schema": attr.label(
            mandatory = True,
            allow_single_file = [".prisma"],
        ),
        "validate_db_url": attr.string(
            mandatory = True,
        ),
        "_prisma_tool": attr.label(
            executable = True,
            cfg = "exec",
            default = "@prisma//:cli",
        ),
    },
)

def prisma_schema(name, schema, db_url_env, validate_db_url, visibility = None, testonly = None):
    """Declares a prisma schema, including a validation test.

    Args:
      name: name of the rule
      schema: schema file
      db_url_env: Environment variable name to use for the database URL.
      validate_db_url: Database URL to use when validating the schema.
          This URL only needs to be structurally valid (no db needs to run there).
      visibility: visibility of main schema rule.
      testonly: testonly flag
    """

    _prisma_schema(
        name = name,
        schema = schema,
        formatted_schema = name + ".fmt.prisma",
        db_url_env = db_url_env,
        validate_db_url = validate_db_url,
        testonly = testonly,
        visibility = visibility,
    )

    write_source_files(
        name = name + ".format",
        testonly = testonly,
        files = {
            schema: name + ".fmt.prisma",
        },
    )
