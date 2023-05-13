PLATFORMS = {
    "Darwin-x86_64": struct(
        compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
    ),
    "Darwin-arm64": struct(
        compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
    ),
    "Linux-aarch64": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
    ),
    "Linux-x86_64": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    ),
}

VERSIONS = {
    "1.18.0": {
        "Darwin-arm64": "sha256-gAAfMktCyUUHkzQchj9YljzHHTkrAty6EGOPuwF2/FA=",
        "Darwin-x86_64": "sha256-ADEnEVhf6Qo5UuiYIcoiGITd8RhyaoJV018vrbsBMn0=",
        "Linux-aarch64": "sha256-hrrgvPWblRvmD7HN5gfau9wyTbFxByLR45FB39TYC9g=",
        "Linux-x86_64": "sha256-kW54+eLHeZG1Tj/IZuBjI/CyKq/fGpT3hFhTjYQ+8fc=",
    },
}

TOOLCHAIN_TMPL = """\
toolchain(
    name = "{platform}_toolchain",
    target_compatible_with = {compatible_with},
    toolchain = "{toolchain}",
    toolchain_type = "{toolchain_type}",
)
"""

def _toolchains_repo_impl(repository_ctx):
    build_content = ""

    for [platform, meta] in PLATFORMS.items():
        build_content += TOOLCHAIN_TMPL.format(
            platform = platform,
            name = repository_ctx.attr.name,
            compatible_with = meta.compatible_with,
            toolchain_type = repository_ctx.attr.toolchain_type,
            toolchain = repository_ctx.attr.toolchain.format(platform = platform),
        )

    repository_ctx.file("BUILD.bazel", build_content)

toolchains_repo = repository_rule(
    _toolchains_repo_impl,
    attrs = {
        "toolchain": attr.string(doc = "Label of the toolchain with {platform} left as placeholder. example; @example_{platform}//:default_toolchain"),
        "toolchain_type": attr.string(doc = "Label of the toolchain_type"),
    },
)

BUF_BUILD_TMPL = """\
load("@bufbuild//:toolchain.bzl", "buf_toolchain")

buf_toolchain(
    name = "buf_toolchain", 
    buf = "buf/bin/buf"
)
"""

def _buf_repo_impl(rctx):
    url = "https://github.com/bufbuild/buf/releases/download/v{version}/buf-{platform}.tar.gz".format(
        version = rctx.attr.buf_version,
        platform = rctx.attr.platform,
    )
    rctx.download_and_extract(
        url = url,
        integrity = VERSIONS[rctx.attr.buf_version][rctx.attr.platform],
    )
    rctx.file("BUILD.bazel", BUF_BUILD_TMPL)

buf_repositories = repository_rule(
    _buf_repo_impl,
    doc = "Fetch external tools needed for buf toolchain",
    attrs = {
        "buf_version": attr.string(mandatory = True, values = VERSIONS.keys()),
        "platform": attr.string(mandatory = True, values = PLATFORMS.keys()),
        "_launcher_tpl": attr.label(default = "//buf/private/registry:buf_launcher.sh.tpl"),
    },
)

def buf_register_toolchains(name, buf_version):
    buf_toolchain_name = "{name}_toolchains".format(name = name)

    for platform in PLATFORMS.keys():
        buf_repositories(
            name = "{name}_{platform}".format(name = name, platform = platform),
            platform = platform,
            buf_version = buf_version,
        )
        native.register_toolchains("@{}//:{}_toolchain".format(buf_toolchain_name, platform))

    toolchains_repo(
        name = buf_toolchain_name,
        toolchain_type = "@bufbuild//:buf_toolchain_type",
        # avoiding use of .format since {platform} is formatted by toolchains_repo for each platform.
        toolchain = "@%s_{platform}//:buf_toolchain" % name,
    )
