"""This module implements the language-specific toolchain rule."""

BufInfo = provider(
    doc = "Information about how to invoke the buf executable.",
    fields = {
        "binary": "Executable buf binary",
    },
)

def _buf_toolchain_impl(ctx):
    binary = ctx.executable.buf
    template_variables = platform_common.TemplateVariableInfo({
        "BUF_BIN": binary.path,
    })
    default = DefaultInfo(
        files = depset([binary]),
        runfiles = ctx.runfiles(files = [binary]),
    )
    buf_info = BufInfo(binary = binary)
    toolchain_info = platform_common.ToolchainInfo(
        buf_info = buf_info,
        template_variables = template_variables,
        default = default,
    )
    return [
        default,
        toolchain_info,
        template_variables,
    ]

buf_toolchain = rule(
    implementation = _buf_toolchain_impl,
    attrs = {
        "buf": attr.label(
            doc = "A hermetically downloaded executable target for the target platform.",
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
    },
    doc = "Defines a buf toolchain. See: https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.",
)
