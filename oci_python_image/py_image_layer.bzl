"Simple macro to create tar files from a Python binary."

load("//workaround_rules_pkg_153:runfiles.bzl", "runfiles")
load("@rules_pkg//:pkg.bzl", "pkg_tar")

def py_image_layer(name, binary, root = None, **kwargs):
    """Creates a tar file to add to a python image, output at `:<name>/app.tar`.

    The final directory tree will look like the following:

    `/{root of py_image_layer}/{package_name() if any}/{name of py_binary}.sh` -> entrypoint
    `/{root of py_image_layer}/{package_name() if any}/{name of py_binary}.sh.runfiles` -> runfiles directory (almost identical to one bazel lays out)

    Args:
        name: name for this target. Not reflected anywhere in the final tar.
        binary: label of a py_binary target
        root: Path where the py_binary will reside inside the final container image.
        **kwargs: Passed to pkg_tar. See: https://github.com/bazelbuild/rules_pkg/blob/main/docs/0.7.0/reference.md#pkg_tar
    """
    if root != None and not root.startswith("/"):
        fail("root path must start with '/' but got '{root}', expected '/{root}'".format(root = root))

    if kwargs.pop("package_dir", None):
        fail("use 'root' attribute instead of 'package_dir'.")

    common_kwargs = {
        "tags": kwargs.pop("tags", None),
        "visibility": kwargs.pop("visibility", None),
    }

    runfiles_kwargs = dict(
        common_kwargs,
        binary = binary,
        root = root,
    )

    pkg_tar_kwargs = dict(
        kwargs,
        # Be careful with this option. Leave it as is if you don't know what you are doing
        strip_prefix = kwargs.pop("strip_prefix", "."),
        **common_kwargs
    )

    runfiles(
        name = "%s/app/runfiles" % name,
        **runfiles_kwargs
    )

    pkg_tar(
        name = "%s/app" % name,
        srcs = ["%s/app/runfiles" % name],
        **pkg_tar_kwargs
    )

    native.filegroup(
        name = name,
        srcs = [
            "%s/app" % name,
        ],
        **common_kwargs
    )
