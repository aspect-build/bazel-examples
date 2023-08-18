load("@rules_proto//proto:defs.bzl", "proto_common")

def _buf_gen_impl(ctx):
    buf_toolchain = ctx.toolchains["//:buf_toolchain_type"]

    args = ctx.actions.args()
    args.add("generate")
    args.add(ctx.file.template, format = "--template=%s")

    inputs = [ctx.file.template]
    outputs = []
    for dep in ctx.attr.deps:
        outputs.extend(
            proto_common.declare_generated_files(
                actions = ctx.actions,
                proto_info = dep[ProtoInfo],
                extension = ".pb.go",
            ),
        )
        inputs.extend(dep[ProtoInfo].direct_sources)
        args.add_all(dep[ProtoInfo].direct_sources, format_each = "--path=%s")

    args.add(ctx.bin_dir.path, format = "--output=%s")

    ctx.actions.run(
        executable = buf_toolchain.buf_info.binary,
        inputs = inputs,
        arguments = [args],
        outputs = outputs,
    )

    return DefaultInfo(files = depset(outputs))

buf_go_proto_library = rule(
    implementation = _buf_gen_impl,
    attrs = {
        "deps": attr.label_list(),
        "template": attr.label(mandatory = True, allow_single_file = True),
    },
    toolchains = ["//:buf_toolchain_type"],
)
