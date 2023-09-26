"""
Workaround for broken runfiles handling in rules_pkg

See https://github.com/bazelbuild/rules_pkg/issues/153
"""

load("@rules_pkg//:providers.bzl", "PackageFilegroupInfo", "PackageFilesInfo", "PackageSymlinkInfo")
load("@aspect_bazel_lib//lib:paths.bzl", "to_manifest_path")
load("@aspect_bazel_lib//lib:glob_match.bzl", "glob_match")

def _runfile_path(ctx, file, runfiles_dir):
    return "/".join([runfiles_dir, to_manifest_path(ctx, file)])

def _glob(path, include, excludes = []):
    if len(excludes):
        for exclude in excludes:
            if glob_match(exclude, path):
                return False
    return glob_match(include, path)

def _calculate_runfiles_dir(root, default_info):
    manifest = default_info.files_to_run.runfiles_manifest
    return "/".join([root, manifest.short_path.replace(manifest.basename, "")[:-1]])

def _runfiles_impl(ctx):
    # setup
    default_info = ctx.attr.binary[DefaultInfo]
    executable = default_info.files_to_run.executable
    executable_path = "/".join([ctx.attr.root, executable.short_path])
    runfiles_dir = _calculate_runfiles_dir(ctx.attr.root, default_info)

    manifest = {}

    if _glob(executable_path, ctx.attr.include, ctx.attr.excludes):
        manifest[executable_path] = executable

    for file in depset(transitive = [default_info.files, default_info.default_runfiles.files]).to_list():
        destination = _runfile_path(ctx, file, runfiles_dir)
        if _glob(destination, ctx.attr.include, ctx.attr.excludes):
            manifest[destination] = file

    symlinks = []

    # NOTE: symlinks is different than root_symlinks. See: https://bazel.build/rules/rules#runfiles_symlinks for distinction between
    # root_symlinks and symlinks and why they have to be handled differently.
    for symlink in default_info.data_runfiles.symlinks.to_list():
        destination = "/".join([runfiles_dir, ctx.workspace_name, symlink.path])
        if _glob(destination, ctx.attr.include, ctx.attr.excludes):
            if hasattr(manifest, destination):
                manifest.pop(destination)
            info = PackageSymlinkInfo(
                target = "/%s" % _runfile_path(ctx, symlink.target_file, runfiles_dir),
                destination = destination,
                attributes = {"mode": "0777"},
            )
            symlinks.append([info, symlink.target_file.owner])

    for symlink in default_info.data_runfiles.root_symlinks.to_list():
        destination = "/".join([runfiles_dir, symlink.path])
        if _glob(destination, ctx.attr.include, ctx.attr.excludes):
            if hasattr(manifest, destination):
                manifest.pop(destination)
            info = PackageSymlinkInfo(
                target = "/%s" % _runfile_path(ctx, symlink.target_file, runfiles_dir),
                destination = destination,
                attributes = {"mode": "0777"},
            )
            symlinks.append([info, symlink.target_file.owner])

    return [
        PackageFilegroupInfo(
            pkg_dirs = [],
            pkg_files = [
                [PackageFilesInfo(
                    dest_src_map = manifest,
                    attributes = {},
                ), ctx.label],
            ],
            pkg_symlinks = symlinks,
        ),
        DefaultInfo(files = depset(direct = manifest.values())),
    ]

runfiles = rule(
    implementation = _runfiles_impl,
    attrs = {
        "binary": attr.label(
            mandatory = True,
            providers = [PyInfo],
        ),
        "root": attr.string(),
        "include": attr.string(),
        "excludes": attr.string_list(),
    },
)
