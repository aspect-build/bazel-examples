"""Repository rule for prisma repositories."""

load(":constants.bzl", "BINARY_TYPES", "PLATFORMS")
load(":lib.bzl", "get_binary_name", "get_download_url")

def _get_primsa_engines_version(ctx):
    """Extract the engine version (commit SHA) from the @prisma/engines-version package."""

    resolved = json.decode(ctx.read(ctx.attr.resolved_json))

    # Version SHA is in build metadata:
    # 4.12.0-34.b36012d6e9bd4f7ff6b13fa02556b753d8bc9094
    raw_version = resolved["version"]
    version = raw_version.split(".")[-1]

    if len(version) != 40:
        fail("expected 40 char SHA for prisma engines version, got %s" % raw_version)

    return version

def _prisma_engines_store_repository_impl(ctx):
    platform = ctx.attr.platform
    version = _get_primsa_engines_version(ctx)

    for binary_type in BINARY_TYPES:
        binary_name = get_binary_name(binary_type, platform)

        # TODO: We do not have the checksums, so the downloads are not hermetic.
        ctx.download(
            url = get_download_url(version, platform, binary_type),
            output = binary_name + ".gz",
        )

    ctx.template(
        "BUILD",
        Label("//bzl:engines_store.BUILD.tpl"),
        substitutions = {
            "{PLATFORM}": platform,
        },
        executable = False,
    )

_prisma_engines_store_repository = repository_rule(
    implementation = _prisma_engines_store_repository_impl,
    attrs = {
        "platform": attr.string(
            values = PLATFORMS.keys(),
            mandatory = True,
        ),
        "resolved_json": attr.label(
            allow_single_file = [".json"],
        ),
    },
)

def _prisma_repository_impl(ctx):
    ctx.template(
        "BUILD",
        Label("//bzl:prisma_repo.BUILD"),
    )

_prisma_repository = repository_rule(
    implementation = _prisma_repository_impl,
)

def prisma_setup():
    """Create repositories for prisma engines (for use in prisma rules)."""

    for platform in PLATFORMS.keys():
        _prisma_engines_store_repository(
            name = "prisma_engines_" + platform,
            platform = platform,
            resolved_json = "@npm//:@prisma/engines-version/resolved.json",
        )

    _prisma_repository(
        name = "prisma",
    )
