load("@aspect_bazel_lib//lib:write_source_files.bzl", "write_source_files")
load("@aspect_bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory")

PACKAGES = ["rigel"]

def sync_npm_packages(packages = PACKAGES):
    """
    Sync npm packages from @other to this bazel package

    Args:
      packages: A list of package names to sync
    """
    files = {}

    for p in packages:
        copy_to_directory(
            name = "sync_{}".format(p),
            srcs = ["@other//packages/{}:srcs".format(p)],
            include_external_repositories = ["other"],
            root_paths = [],
            replace_prefixes = {"packages/{}/".format(p): ""},
        )
        files[":{}".format(p)] = "sync_{}".format(p)

    write_source_files(
        name = "other_packages",
        files = files,
    )
