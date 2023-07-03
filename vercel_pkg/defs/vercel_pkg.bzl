"""Bazel Macro to run https://github.com/vercel/pkg:

This command line interface enables you to package your Node.js project into an executable that can
be run even on devices without Node.js installed.
"""

load("@bazel_skylib//rules:copy_file.bzl", "copy_file")
load("@npm//:pkg/package_json.bzl", pkg_bin = "bin")

# buildifier: disable=function-docstring
def vercel_pkg(name, entry_point, out, node_major_version, **kwargs):
    # Walk back from the cwd we'll run the tool in, which is bazel-out/arch/bin/path/to/package
    path_to_root = "/".join([".."] * (3 + len(native.package_name().split("/"))))

    for platform in ["linux-arm64", "linux-x64", "macos-arm64", "macos-x64"]:
        cache_folder = "@pkg_fetch_node_{}//file".format(platform.replace("-", "_"))
        cache_folder_path = path_to_root + "/external/pkg_fetch_node_{}/file".format(platform.replace("-", "_"))
        platform_out = "-".join([out, platform])
        pkg_bin.pkg(
            name = "_{}_{}".format(name, platform),
            srcs = [
                cache_folder,
                entry_point,
            ],
            copy_srcs_to_bin = False,
            outs = [platform_out],
            # See https://github.com/vercel/pkg#usage
            args = [
                entry_point,
                # TODO: Compiling bytecode is non-deterministic, see
                # https://github.com/vercel/pkg#bytecode-reproducibility
                "--no-bytecode",
                # Expose our source code in the executable, needed since we don't compile bytecode.
                "--public",
                "--targets",
                "node{}-{}".format(node_major_version, platform),
                "--output",
                platform_out,
            ],
            env = {
                "CHDIR": native.package_name(),
                "PKG_CACHE_PATH": cache_folder_path,
            },
            # Avoid fetching/building on platforms that won't be select'ed below.
            target_compatible_with = [
                "@platforms//os:linux" if platform.startswith("linux-") else "@platforms//os:macos",
                "@platforms//cpu:x86_64" if platform.endswith("-x64") else "@platforms//cpu:arm64",
            ],
            # Uncomment for debugging
            # silent_on_success = False,
            # Uncomment to allow the https://github.com/vercel/pkg-fetch tool to fetch nodejs packages
            # rather than require that the PKG_CACHE already has them.
            # tags = ["requires-network"],
        )

    copy_file(
        name = name,
        src = select({
            "//defs:linux_aarch64": "{}-{}".format(out, "linux-arm64"),
            "//defs:linux_x86_64": "{}-{}".format(out, "linux-x64"),
            "//defs:macos_aarch64": "{}-{}".format(out, "macos-arm64"),
            "//defs:macos_x86_64": "{}-{}".format(out, "macos-x64"),
        }),
        is_executable = True,
        out = out,
        **kwargs
    )
