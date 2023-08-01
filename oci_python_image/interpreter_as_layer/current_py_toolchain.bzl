load("@rules_pkg//:providers.bzl", "PackageFilegroupInfo", "PackageFilesInfo")

def _strip_platform_specific(path):
    parts = path.split("/")
    return "/".join(parts[2:])

def _current_py_toolchain_impl(ctx):
    default = ctx.toolchains["@rules_python//python:toolchain_type"].py3_runtime
    file_map = {}

    files = depset(transitive = [default.files])

    for file in files.to_list():
        file_map[_strip_platform_specific(file.path)] = file

    files = depset([], transitive = [files])

    return [
        PackageFilegroupInfo(
            pkg_dirs = [],
            pkg_files = [
                [PackageFilesInfo(
                    dest_src_map = file_map,
                    attributes = {},
                ), ctx.label],
            ],
        ),
        DefaultInfo(files = files),
    ]

current_py_toolchain = rule(
    implementation = _current_py_toolchain_impl,
    attrs = {},
    toolchains = ["@rules_python//python:toolchain_type"],
)
