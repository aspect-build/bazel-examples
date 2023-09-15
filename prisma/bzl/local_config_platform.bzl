"""Override of the built-in @local_config_platform repository.

This is so we can add auto-detection for the host platform for our own platform constraints.

Most of it is adapted from the POC mentioned in https://github.com/bazelbuild/bazel/issues/8766:
https://github.com/fmeum/host_platform/blob/dbe055efc3ecdc7bfae5d7fbf1667f46f8c34b4e/internal/utils.bzl
"""

load(":lib.bzl", "compute_lib_ssl_specific_paths", "get_ssl_version", "parse_distro")

def _local_config_platform_impl(repository_ctx):
    repository_ctx.template(
        "BUILD",
        Label(":local_config_platform.BUILD.bazel"),
        executable = False,
    )

    constraints = _get_prisma_constraints(repository_ctx)

    bzl_lines = [
        "PRISMA_HOST_CONSTRAINTS = [",
    ] + [
        "    \"{}\",".format(constraint)
        for constraint in constraints
    ] + [
        "]",
    ]

    repository_ctx.file("constraints.bzl", content = "\n".join(bzl_lines) + "\n", executable = False)

local_config_platform = repository_rule(
    implementation = _local_config_platform_impl,
)

def _get_prisma_constraints(repository_ctx):
    if repository_ctx.os.name != "linux":
        return []

    distro = parse_distro(repository_ctx.read("/etc/os-release"))
    paths = compute_lib_ssl_specific_paths(distro, repository_ctx.os.arch)
    ssl_version = get_ssl_version(repository_ctx, paths)

    return [
        "@prisma-example//constraints:linux_{}".format(distro),
        "@prisma-example//constraints:openssl_{}".format(ssl_version),
    ]
